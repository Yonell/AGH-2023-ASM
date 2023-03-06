data1 segment
	input1 db "dwa plus trzy$"
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
	
	mov dx, offset input1 ; Tu bedzie wczytywanie stringa na razie jest na stale
	mov ah, 9
	int 21h 
	
	mov ax, offset input1
	push ax
	call split_string
	
	mov ah, 4ch
	int 21h

split_string:
	pop si ; "argumentem" funkcji jest string source
    
	mov di, offset numberstring1 ; destination ustawiam na numberstring1
    
	pre_split_string_loop1:
	cmp si, ' ' ; Petla sprawdza przed każdym przejsciem, czy si jest spacja. Jesli jest to wychodzi
	je exit_split_string_loop1
		
		mov di, si ; kopiuje po znaku
		
		inc si
        inc di
	jmp pre_split_string_loop1
	exit_split_string_loop1:
    
	mov di, '$' ; ustawiam dolar na koncu numberstring1
	
	mov dx, offset numberstring1
	mov ah, 9
	int 21h ; wypisuje numberstring1
	ret
	
code1 ends

stack1 segment stack
	dw 300 dup(?)
	endstack dw ?
stack1 ends

end start1