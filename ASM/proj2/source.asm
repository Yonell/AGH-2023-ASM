	.387

data1 segment
	command_line db 255 dup("$")

	ellipse_width dw 0
	ellipse_height dw 0
	
data1 ends

code1 segment
start1:
	mov ax, stack1
	mov ss, ax
	mov sp, offset endstack

	call copy_command_line_args

	mov ax, data1
	mov ds, ax

	call parse_command_line_two_numbers

	mov al, 13h ; ustawia tryb graficzny 320x200x256
	mov ah, 0
	int 10h

	mov ax, 0a000h ; ustawia segment pamieci wideo
	mov es, ax

	mov ax, 0
	cmp ax, 1

	main_loop:
		jz dont_update_ellipse
			call clear_screen
			call draw_ellipse
		dont_update_ellipse:
		call wait_for_key
	end_main_loop:
	jmp main_loop
	
	mov ah, 4ch ; konczy program
	int 21h

clear_screen:
	mov cx, 64000
	loop_clear_screen:
		dec cx
		mov bx, cx
		mov byte ptr es:[bx], 0
	loop loop_clear_screen
	ret

x	dw 	0
y	dw 	0
result dw 0

draw_ellipse:
	finit
	mov cx, 64000
	loop_draw_ellipse:
		dec cx
		mov ax, cx
		div 320
		mov word ptr cs:[x], ax
		mov word ptr cs:[y], dx
		fild word ptr cs:[x]
		fsub 160
		fild word ptr cs:[x]
		fsub 160
		fmul 
		fild word ptr cs:[ellipse_width]
		fild word ptr cs:[ellipse_width]
		fmul
		fdiv
		fild word ptr cs:[y]
		fsub 100
		fild word ptr cs:[y]
		fsub 100
		fmul
		fild word ptr cs:[ellipse_height]
		fild word ptr cs:[ellipse_height]
		fmul
		fdiv
		fild 1000
		fmul
		fist result
		mov ax, word ptr cs:[result]
		cmp ax, 1000
		jg draw_ellipse_end
			mov bx, cx
			mov byte ptr es:[bx], 1
		draw_ellipse_end:

	loop loop_draw_ellipse
	ret

wait_for_key:
	xor ax, ax
	mov ah, 01h
	int 16h
	jz end_wait_for_key
	cmp ah, 48h
	je detected_up_key
	cmp ah, 50h
	je detected_down_key
	cmp ah, 4bh
	je detected_left_key
	cmp ah, 4dh
	je detected_right_key

	detected_up_key:
		mov ax, word ptr ds:[ellipse_height]
		inc ax
		mov word ptr ds:[ellipse_height], ax
		ret
	detected_down_key:
		mov ax, word ptr ds:[ellipse_height]
		dec ax
		mov word ptr ds:[ellipse_height], ax
		ret
	detected_left_key:
		mov ax, word ptr ds:[ellipse_width]
		dec ax
		mov word ptr ds:[ellipse_width], ax
		ret
	detected_right_key:
		mov ax, word ptr ds:[ellipse_width]
		inc ax
		mov word ptr ds:[ellipse_width], ax
		ret

	end_wait_for_key:
	ret



parse_command_line_two_numbers:
	mov si, offset command_line
	mov ax, 0

	loop1:
	cmp byte ptr ds:[si], " "
	je loop1_end
	cmp byte ptr ds:[si], "$"
	je loop1_end
		mov cx, 10
		mul cx
		sub byte ptr ds:[si], 30h
		xor dx, dx
		mov dl, byte ptr ds:[si]
		add ax, dx
	inc si
	jmp loop1
	loop1_end:

	inc si
	mov word ptr ds:[ellipse_width], ax

	mov ax, 0
	loop2:
	cmp byte ptr ds:[si], " "
	je loop2_end
	cmp byte ptr ds:[si], "$"
	je loop2_end
		mov cx, 10
		mul cx
		sub byte ptr ds:[si], 30h
		xor dx, dx
		mov dl, byte ptr ds:[si]
		add ax, dx
	inc si
	jmp loop2
	loop2_end:

	mov word ptr ds:[ellipse_height], ax

	ret

copy_command_line_args:

	mov ax, data1
	mov es, ax
	mov si, 82h
	mov di, offset command_line
	xor cx, cx
	mov cl, byte ptr ds:[80h]
	dec cx

	p1: push cx
	mov al, byte ptr ds:[si]
	mov byte ptr es:[di], al
	inc si
	inc di
	pop cx
	loop p1

	ret

	
code1 ends

stack1 segment stack
	dw 300 dup(?)
	endstack dw ?
stack1 ends

end start1