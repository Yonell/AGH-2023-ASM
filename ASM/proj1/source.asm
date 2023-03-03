data1 segment
	input1 db "dwa plus trzy$"
	numberstring1 db "00000000$"
	operation db "00000$"
	numberstring2 db "00000000$"
	numberstrings db "zero$", "jeden$", "dwa$", "trzy$", "cztery$", "piec$", "szesc$", "siedem$", "osiem$", "dziewiec$"
data1 ends

code1 segment
start1:
	mov ax, seg stack1
	mov ss, ax
	mov sp, offset endstack
	
	mov ax, seg data1
	mov ds, ax
	
	mov dx, offset input1 ; Tu bedzie wczytywanie stringa na razie jest na stale
	mov ah, 9
	int 21h 
	
	mov ax, offset input1
	push ax
	call split_string
	
	mov ah, 4ch
	int 21h

split_string:
	pop bx
	mov si, 0
	
	pre_split_string_loop1:
	cmp byte ptr [bx+si], 20h ; Petla sprawdza przed każdym przejsciem, czy [bx + si] jest spacja. Jesli jest to wychodzi
	je exit_split_string_loop1
		
		mov ax, offset numberstring1
		push byte ptr [bx+si]
		pop cx
		mov byte ptr [ax+si], cx
		
		inc si
	jmp pre_split_string_loop1
	exit_split_string_loop1:
	
	push bx	
	mov bx, offset numberstring1
	mov ch, '$'
	mov byte ptr ds:[bx + si], ch
	pop bx
	
	mov dx, offset numberstring1
	mov ah, 9
	int 21h 
	ret
	
code1 ends

stack1 segment stack
	dw 300 dup(?)
	endstack dw ?
stack1 ends

end start1