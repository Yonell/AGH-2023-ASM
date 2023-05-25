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
			call draw_ellipse
		dont_update_ellipse:
		call wait_for_key
	end_main_loop:
	jmp main_loop
	
	mov ah, 4ch ; konczy program
	int 21h

x_pixel	dw 	0
y_pixel	dw 	0
result dw 0
buffer320 dw 320
buffer160 dw 160
buffer100 dw 100

; funkcja rysuje elipsę o zadanych wymiarach
draw_ellipse:
	mov word ptr cs:[x_pixel], 0
	mov word ptr cs:[y_pixel], 0
	loop_draw_ellipse_x:
		loop_draw_ellipse_y:
			finit

			fild word ptr cs:[x_pixel]
			fisub word ptr cs:[buffer160]
			fild word ptr cs:[x_pixel]
			fisub word ptr cs:[buffer160]
			fmul
			fild word ptr ds:[ellipse_width]
			fild word ptr ds:[ellipse_width]
			fmul
			fdiv
			fild word ptr cs:[y_pixel]
			fisub word ptr cs:[buffer100]
			fild word ptr cs:[y_pixel]
			fisub word ptr cs:[buffer100]
			fmul
			fild word ptr ds:[ellipse_height]
			fild word ptr ds:[ellipse_height]
			fmul
			fdiv
			fadd

			fistp word ptr cs:[result]

			mov ax, word ptr cs:[result]
			cmp ax, 1
			jg dont_draw_ellipse
				mov ax, word ptr cs:[y_pixel]
				mul word ptr cs:[buffer320]
				add ax, word ptr cs:[x_pixel]
				mov bx, ax
				mov byte ptr es:[bx], 3
				jmp draw_ellipse_end
			dont_draw_ellipse:
				mov ax, word ptr cs:[y_pixel]
				mul word ptr cs:[buffer320]
				add ax, word ptr cs:[x_pixel]
				mov bx, ax
				mov byte ptr es:[bx], 0
			draw_ellipse_end:
			inc word ptr cs:[y_pixel]
			cmp word ptr cs:[y_pixel], 100
			jge end_loop_draw_ellipse_y
		jmp loop_draw_ellipse_y
		end_loop_draw_ellipse_y:
		mov word ptr cs:[y_pixel], 0
		inc word ptr cs:[x_pixel]
		cmp word ptr cs:[x_pixel], 160
		jge end_loop_draw_ellipse_x
	jmp loop_draw_ellipse_x
	end_loop_draw_ellipse_x:
	call copy_ellipse_quarter
	ret

; funkcja kopiuje lewą górną ćwiartkę elipsy do pozostałych ćwiartek
copy_ellipse_quarter:
	mov word ptr cs:[x_pixel], 0
	mov word ptr cs:[y_pixel], 0
	loop_copy_ellipse_quarter_x:
		loop_copy_ellipse_quarter_y:
			mov ax, word ptr cs:[y_pixel]
			mul word ptr cs:[buffer320]
			add ax, word ptr cs:[x_pixel]
			mov bx, ax

			mov ax, 319
			sub ax, word ptr cs:[x_pixel]
			sub ax, word ptr cs:[x_pixel]
			mov ch, byte ptr es:[bx]
			add bx, ax
			mov byte ptr es:[bx], ch

			mov ax, 199
			sub ax, word ptr cs:[y_pixel]
			sub ax, word ptr cs:[y_pixel]
			mul word ptr cs:[buffer320]
			mov ch, byte ptr es:[bx]
			add bx, ax
			mov byte ptr es:[bx], ch

			mov ax, 319
			sub ax, word ptr cs:[x_pixel]
			sub ax, word ptr cs:[x_pixel]
			mov ch, byte ptr es:[bx]
			sub bx, ax
			mov byte ptr es:[bx], ch

			inc word ptr cs:[y_pixel]
			cmp word ptr cs:[y_pixel], 100
			jg end_loop_copy_ellipse_quarter_y
		jmp loop_copy_ellipse_quarter_y
		end_loop_copy_ellipse_quarter_y:
		mov word ptr cs:[y_pixel], 0
		inc word ptr cs:[x_pixel]
		cmp word ptr cs:[x_pixel], 160
		jg end_loop_copy_ellipse_quarter_x
	jmp loop_copy_ellipse_quarter_x
	end_loop_copy_ellipse_quarter_x:
	
	ret

wait_for_key:
	;mov ax, 601h
	;int 16h
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
	cmp ah, 01h
	je detected_escape_key

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
	detected_escape_key:
		call clear_screen
        mov ah, 4ch ; konczy program
        int 21h
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

clear_screen:
	mov cx, 64000
	loop_clear_screen:
		mov bx, cx
		mov byte ptr es:[bx], 0
	loop loop_clear_screen
	ret

	
code1 ends

stack1 segment stack
	dw 300 dup(?)
	endstack dw ?
stack1 ends

end start1