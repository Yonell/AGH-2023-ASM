data1 segment
    bufferSize db 25
    inputLength db 0
	input1 db 25 dup("$")
    debug db "debug$"
	numberstring1 db 9 dup(?)
	operation db 6 dup(?)
	numberstring2 db 9 dup(?)
	numberstrings db "zero$", "jeden$", "dwa$", "trzy$", "cztery$", "piec$", "szesc$", "siedem$", "osiem$", "dziewiec$"
data1 ends

code1 segment
start1:
	mov ax, seg stack1
	mov ss, ax
	mov sp, offset endstack
	
	mov ax, seg data1
	mov ds, ax
    
    mov dx, offset bufferSize ; wczytanie stringa
    mov ah, 0ah
    int 21h
	
	mov dx, offset input1 ; Tu bedzie wczytywanie stringa na razie jest na stale
	mov ah, 9
	int 21h 
	
	mov dx, offset input1
    mov ax, offset numberstring1
	call split_string
    
    mov ax, offset operation
	call split_string
    
    mov ax, offset numberstring2
	call split_string
	
	mov dx, offset numberstring1
	mov ah, 9
	int 21h ; wypisuje numberstring1
	
	mov dx, offset operation
	mov ah, 9
	int 21h ; wypisuje numberstring1
	
	mov dx, offset numberstring2
	mov ah, 9
	int 21h ; wypisuje numberstring1
    
    mov dx, offset debug
	mov ah, 9
	int 21h
	
	mov ah, 4ch
	int 21h

split_string:
	mov si, dx ; "argumentem" funkcji jest string source
    
	mov di, ax ; destination ustawiam na numberstring1
    
	pre_split_string_loop1:
    mov al, ds:[si]
    mov bl, ' '
	cmp al, bl ; Petla sprawdza przed każdym przejsciem, czy si jest spacja lub $. Jesli jest to wychodzi
	je exit_split_string_loop1
    mov bl, '$'
	cmp al, bl
	je exit_split_string_loop1
		mov al, ds:[si] ; kopiuje po znaku
		mov ds:[di], al
		
		inc si
        inc di
	jmp pre_split_string_loop1
	exit_split_string_loop1:
    
    mov ah, '$'
	mov byte ptr ds:[di], ah ; ustawiam dolar na koncu numberstring
    
    inc si
    mov dx, si
	ret
	
code1 ends

stack1 segment stack
	dw 300 dup(?)
	endstack dw ?
stack1 ends

end start1