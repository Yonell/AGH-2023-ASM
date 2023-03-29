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
	numberstringsoffsets db 0, 5, 11, 15, 20, 27, 32, 38, 45, 51
	
	number1 db ?
	number2 db ?
    
    newline db 10, 13, "$"
    debug db "debug", 10, 13, "$"
    output1 db "Wpisz operacje: $"
    output2 db "Operacja: $"
    output3 db "Liczba 1: $"
    output4 db "operacja: $"
    output5 db "Liczba 2: $"
    error_mssg_default db "Some error occured!", 10, 13, "$"
    error_mssg1 db "Too many arguments!", 10, 13, "$"
    error_mssg2 db "Too little arguments!", 10, 13, "$"
    error_mssg3 db "Parsing error! Some strings ended up empty!", 10, 13, "$"
    error_mssg4 db "Number parsing error!", 10, 13, "$"
data1 ends

code1 segment
start1:
	mov ax, seg stack1
	mov ss, ax
	mov sp, offset endstack
	
	mov ax, seg data1
	mov ds, ax
    
	mov dx, offset output1 ; Wypisanie komunikatu
	mov ah, 9
	int 21h 
    
    mov dx, offset bufferSize ; wczytanie stringa
    mov ah, 0ah
    int 21h
    
	mov dx, offset newline ; Wypisanie newline
	mov ah, 9
	int 21h 
    
    call remove_spaces_on_the_end
    
    call call_split_strings
    
    call yield_input
	
	call fill_the_numbers
    
    call handle_errors_main
	
	mov ah, 4ch
	int 21h
	
fill_the_numbers: ; broken
	mov cx, 0
	pre_loop1_fill_the_numbers:
	cmp cl, 10
	je error_fill_the_numbers
		mov si, offset numberstring1
		mov di, offset numberstrings
		mov bx, offset numberstringsoffsets
		add bx, cx
		mov ah, 0
		mov al, byte ptr ds:[bx]
		add di, ax
		call str_cmp_equal
		cmp ax, 1
		je found_the_string1
		inc cl
    
		mov dx, di
		mov ah, 9
		;int 21h
	jmp pre_loop1_fill_the_numbers
	
	found_the_string1:
	
	mov byte ptr ds:[number1], cl
	
	mov cl, 0
	pre_loop2_fill_the_numbers:
	cmp cl, 10
	je error_fill_the_numbers
		mov si, offset numberstring1
		mov di, offset numberstrings
		mov bx, offset numberstringsoffsets
		add bx, cx
		mov ah, 0
		mov al, byte ptr ds:[bx]
		add di, ax
		call str_cmp_equal
		cmp ax, 1
		je found_the_string2
		inc cl
	jmp pre_loop2_fill_the_numbers
	
	found_the_string2:
	
	mov si, offset number2
	mov byte ptr ds:[si], cl
	
	ret
	
	error_fill_the_numbers:
	mov al, 4
	mov byte ptr ds:[error1], al
	
	ret
	
	
	
	
str_cmp_equal: ; expects si and di to be offsets of the strings to compare
	push si
	push di
	push ax
	pre_loop_str_cmp_equal:
	cmp byte ptr ds:[si], '$'
	je exit_loop_str_cmp_equal
	
		mov al, byte ptr ds:[di]
		cmp byte ptr ds:[si], al
		jne return_false_str_cmp_equal
		
		inc si
		inc di
	jmp pre_loop_str_cmp_equal
	exit_loop_str_cmp_equal:
	
	mov al, byte ptr ds:[si]
	cmp byte ptr ds:[di], al
	je return_true_str_cmp_equal
	jne return_false_str_cmp_equal
	
	return_false_str_cmp_equal:
		pop ax
		pop di
		pop si
		mov ah, 0
		ret
	
	return_true_str_cmp_equal:
		pop ax
		pop di
		pop si
		mov ah, 1
		ret
	
	ret
	
remove_spaces_on_the_end:
	mov al, ds:[inputLength]
	dec al
	mov bx, offset input1
	xor ah, ah
	add bx, ax
	
	mov cx, offset input1
	dec cx
	
	pre_loop_remove_spaces_on_the_end:
	cmp byte ptr ds:[bx], ' '
	jne exit_loop_remove_spaces_on_the_end
	cmp bx, cx
	je exit_loop_remove_spaces_on_the_end
	
	mov byte ptr ds:[bx], '$'
	dec bx
	
	jmp pre_loop_remove_spaces_on_the_end
	exit_loop_remove_spaces_on_the_end:
	
	ret
    
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
    mov ah, 3
    cmp byte ptr ds:[bx], ah
    je empty_operation_or_number_error_main
    mov ah, 4
    cmp byte ptr ds:[bx], ah
    je parsing_number_error_main
    
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
	
	empty_operation_or_number_error_main:
    mov dx, offset error_mssg3
    mov ah, 9
    int 21h
    jmp other_error_main
	
	parsing_number_error_main:
    mov dx, offset error_mssg4
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
	
	ret
    

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
    mov ds:[error1], al
    
    no_too_many_arguments_error_call_split_strings:
    
    mov ah, '$'
    mov al, ds:[numberstring2]
    cmp ah, al
    jne no_too_little_arguments_error_call_split_strings
    
    mov al, 2
    mov ds:[error1], al
    
    no_too_little_arguments_error_call_split_strings:
    
    mov ah, '$'
    mov al, ds:[numberstring1]
    cmp ah, al
    je parsing_error_call_split_strings
    
    mov ah, '$'
    mov al, ds:[operation]
    cmp ah, al
    je parsing_error_call_split_strings
    
	jmp no_parsing_error_call_split_strings
    
    parsing_error_call_split_strings:
    mov al, 3
    mov ds:[error1], al
	
	no_parsing_error_call_split_strings:
    
    
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