data1 segment
    bufferSize db 25          ; struktura na input
    inputLength db 0
	input1 db 25 dup('$')
    
	numberstring1 db 9 dup('$') ; zmienna przechowujaca pierwsza liczbe
	operation db 6 dup('$')     ; zmienna przechowujaca operacje
	numberstring2 db 9 dup('$') ; zmienna przechowujaca druga liczbe
    error1 db 0               ; zmienna przechowujaca kod bledu
    input_ending db ?         ; zmienna przechowujaca czym skonczyl sie string w split_string
    
	numberstrings db "zero$", "jeden$", "dwa$", "trzy$", "cztery$", "piec$", "szesc$", "siedem$", "osiem$", "dziewiec$"
    
    newline db 10, 13, "$"
    debug db "debug$", 10, 13, "$"
    output1 db "Wpisz operacje: $"
    output2 db "Operacja: $"
    output3 db "Liczba 1: $"
    output4 db "operacja: $"
    output5 db "Liczba 2: $"
    error_mssg_default db "Some error occured!", 10, 13, "$"
    error_mssg1 db "Too many arguments!", 10, 13, "$"
    error_mssg2 db "Too little arguments!", 10, 13, "$"
data1 ends

code1 segment
start1:
	mov ax, seg stack1
	mov ss, ax
	mov sp, offset endstack
	
	mov ax, seg data1
	mov ds, ax
    
	mov dx, offset output1 ; Wypisanie outputu
	mov ah, 9
	int 21h 
    
    mov dx, offset bufferSize ; wczytanie stringa
    mov ah, 0ah
    int 21h
    
	mov dx, offset newline ; Wypisanie newline
	mov ah, 9
	int 21h 
    
    ; TODO zrobic usuwanie spacji z konca
    
    call call_split_strings
    
    call handle_errors_main
    
    call yield_input
    
    mov dx, offset debug
	mov ah, 9
	int 21h
	
	mov ah, 4ch
	int 21h
    
handle_errors_main:
    
    mov bx, offset error1
    mov ah, 0
    cmp byte ptr ds:[bx], ah
    je no_error_main
    mov ah, 1
    cmp byte ptr ds:[bx], ah
    je too_many_arguments_error_main
    mov ah, 2
    cmp byte ptr ds:[bx], ah
    je too_little_arguments_error_main
    
    jne other_error_main
    
    too_many_arguments_error_main:
    mov dx, offset error_mssg1
    mov ah, 9
    int 21h
    jmp other_error_main
    
    too_little_arguments_error_main:
    mov dx, offset error_mssg2
    mov ah, 9
    int 21h
    jmp other_error_main
    
    other_error_main:
    mov dx, offset error_mssg_default
    mov ah, 9
    int 21h
    mov al, 1
    mov ah, 4ch
    int 21h
    
    no_error_main:
    

split_string:   ; funkcja dzielaca string na wyrazy. po wykonaniu ustawia si i dx na offset tuz po wyrazie. 
                ; Oczekuje offsetu na input w dx, a dest w ax. Korzysta z: si, di, dx, ax, bl
                ; Ustawia input_ending na ostatni znak, ktory przerwal petle
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
    
    mov di, offset input_ending
    mov bh, ds:[si]
    mov byte ptr ds:[di], bh
    
    inc si
    mov dx, si
	ret
    
call_split_strings:
	mov dx, offset input1
    mov ax, offset numberstring1
	call split_string
    
    mov ax, offset operation
	call split_string
    
    mov ax, offset numberstring2
	call split_string
    
    mov ah, ' '
    mov bx, offset input_ending
    mov al, ds:[bx]
    cmp ah, al
    jne no_too_many_arguments_error_call_split_strings
    
    mov al, 1
    mov bx, offset error1
    mov ds:[bx], al
    
    no_too_many_arguments_error_call_split_strings:
    
    mov ah, '$'
    mov bx, offset numberstring2
    mov al, ds:[bx]
    cmp ah, al
    jne no_too_little_arguments_error_call_split_strings
    
    mov al, 2
    mov bx, offset error1
    mov ds:[bx], al
    
    no_too_little_arguments_error_call_split_strings:
    
    
    ret
    
yield_input:
	mov dx, offset output3 ; wypisuje komunikat
	mov ah, 9
	int 21h 
	
	mov dx, offset numberstring1 ; wypisuje numberstring1
	mov ah, 9
	int 21h 
    
	mov dx, offset newline ; Wypisanie newline
	mov ah, 9
	int 21h 
    
	mov dx, offset output4 ; wypisuje komunikat
	mov ah, 9
	int 21h 
	
	mov dx, offset operation ; wypisuje operacje
	mov ah, 9
	int 21h
    
	mov dx, offset newline ; Wypisanie newline
	mov ah, 9
	int 21h 
    
	mov dx, offset output5 ; wypisuje komunikat
	mov ah, 9
	int 21h 
	
	mov dx, offset numberstring2 ; wypisuje numberstring2
	mov ah, 9
	int 21h
    
	mov dx, offset newline ; Wypisanie newline
	mov ah, 9
	int 21h 
    
    ret
	
code1 ends

stack1 segment stack
	dw 300 dup(?)
	endstack dw ?
stack1 ends

end start1