data1 segment
    bufferSize db 25          ; struktura na input
    inputLength db 0
	input1 db 25 dup('$')
    
	numberstring1 db 9 dup('$') ; zmienna przechowujaca pierwsza liczbe
	operation db 6 dup('$')     ; zmienna przechowujaca operacje
	numberstring2 db 9 dup('$') ; zmienna przechowujaca druga liczbe
    error1 db 0               ; zmienna przechowujaca kod bledu
    input_ending db ?         ; zmienna przechowujaca czym skonczyl sie string w split_string
    
	numberstrings db "zero$", "jeden$", "dwa$", "trzy$", "cztery$", "piec$", "szesc$", "siedem$", "osiem$", "dziewiec$" ; tablica lancuchow znakow do konwersji slowa na liczbe.
	numberstringsoffsets dw 0, 5, 11, 15, 20, 27, 32, 38, 45, 51 ; tablica przesuniec do pierwszych liter
	
	extendednumberstrings db "minus dziewiec$", "minus osiem$", "minus siedem$", "minus szesc$", "minus piec$", "minus cztery$", "minus trzy$", "minus dwa$", "minus jeden$", "zero$" ; taka sama struktura jak wyzej, ale dla liczb od -9 do 81
	decoy1 db "jeden$", "dwa$", "trzy$", "cztery$", "piec$", "szesc$", "siedem$", "osiem$", "dziewiec$", "dziesiec$"
	decoy2 db "jedenascie$", "dwanascie$", "trzynascie$", "czternascie$", "pietnascie$", "szesnascie$", "siedemnascie$", "osiemnascie$", "dziewietnascie$", "dwadziescia$"
	decoy3 db "dwadziescia jeden$", "dwadziescia dwa$", "dwadziescia trzy$", "dwadziescia cztery$", "dwadziescia piec$", "dwadziescia szesc$", "dwadziescia siedem$", "dwadziescia osiem$", "dwadziescia dziewiec$", "trzydziesci$"
	decoy4 db "trzydziesci jeden$", "trzydziesci dwa$", "trzydziesci trzy$", "trzydziesci cztery$", "trzydziesci piec$", "trzydziesci szesc$", "trzydziesci siedem$", "trzydziesci osiem$", "trzydziesci dziewiec$", "czterdziesci$"
	decoy5 db "czterdziesci jeden$", "czterdziesci dwa$", "czterdziesci trzy$", "czterdziesci cztery$", "czterdziesci piec$", "czterdziesci szesc$", "czterdziesci siedem$", "czterdziesci osiem$", "czterdziesci dziewiec$", "piecdziesiat$"
	decoy6 db "piecdziesiat jeden$", "piecdziesiat dwa$", "piecdziesiat trzy$", "piecdziesiat cztery$", "piecdziesiat piec$", "piecdziesiat szesc$", "piecdziesiat siedem$", "piecdziesiat osiem$", "piecdziesiat dziewiec$", "szescdziesiat$"
	decoy7 db "szescdziesiat jeden$", "szescdziesiat dwa$", "szescdziesiat trzy$", "szescdziesiat cztery$", "szescdziesiat piec$", "szescdziesiat szesc$", "szescdziesiat siedem$", "szescdziesiat osiem$", "szescdziesiat dziewiec$", "siedemdziesiat$"
	decoy8 db "siedemdziesiat jeden$", "siedemdziesiat dwa$", "siedemdziesiat trzy$", "siedemdziesiat cztery$", "siedemdziesiat piec$", "siedemdziesiat szesc$"
	decoy9 db "siedemdziesiat siedem$", "siedemdziesiat osiem$", "siedemdziesiat dziewiec$", "osiemdziesiat$", "osiemdziesiat jeden$"
	extendednumberstringsoffsets dw 0, 15, 27, 40, 52, 63, 76, 87, 97, 109
	decoy11 dw 114, 120, 124, 129, 136, 141, 147, 154, 160, 169
	decoy12 dw 178, 189, 199, 210, 222, 233, 244, 257, 269, 284
	decoy13 dw 296, 314, 330, 347, 366, 383, 401, 420, 438, 459
	decoy14 dw 471, 489, 505, 522, 541, 558, 576, 595, 613, 634
	decoy15 dw 647, 666, 683, 701, 721, 739, 758, 778, 797, 819
	decoy16 dw 832, 851, 868, 886, 906, 924, 943, 963, 982, 1004
	decoy17 dw 1018, 1038, 1056, 1075, 1096, 1115, 1135, 1156, 1176, 1199
	decoy18 dw 1214, 1235, 1254, 1274, 1296, 1316, 1337, 1359, 1380, 1404, 1418
									
	plus db "plus$"  ; slownie zapisane slowa operacji
	minus db "minus$"
	multiply db "razy$"
	
	number1 db ? ; zmienne przechowujace liczby do wykonania operacji
	number2 db ?
	resultnumber dw ?
    
    newline db 10, 13, "$"       ; pomocnicze komunikaty do wyrzucania na ekran
    debug db "debug", 10, 13, "$"
    output1 db "Wpisz operacje: $"
    output2 db "Operacja: $"
    output3 db "Liczba 1: $"
    output4 db "operacja: $"
    output5 db "Liczba 2: $"
	output6 db "Wynikiem jest: $"
    error_mssg_default db "Some error occured!", 10, 13, "$"
    error_mssg1 db "Too many arguments!", 10, 13, "$"
    error_mssg2 db "Too little arguments!", 10, 13, "$"
    error_mssg3 db "Parsing error! Some strings ended up empty!", 10, 13, "$"
    error_mssg4 db "Number parsing error!", 10, 13, "$"
    error_mssg5 db "Invalid operand!", 10, 13, "$"
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
    
    call remove_spaces_and_CR_on_the_end ; usuwa niepotrzebne znaki na koncu, ktore psuja wynik
    
    call call_split_strings ; dzieli input na dwie liczby i operacje
    
    ;call yield_input ; wyrzuca podzielone stringi na ekran
	
	call fill_the_numbers ; zamienia stringi w liczbach na liczby
    
    call handle_errors_main ; zajmuje sie wszelkimi bledami po drodze
	
	call use_the_operand          ; wykonuje operacje miedzy dwoma liczbami i wpisuje wynik do ax
	mov word ptr ds:[resultnumber], ax ; wpisuje wynik z ax do resultnumber
    
    call handle_errors_main ; znowu sprawdzam bledy
	
	call show_the_result ; wyswietla wynik na ekran
	
	mov ah, 4ch ; konczy program
	int 21h
	
show_the_result: ; funkcja korzystajac z resultnumber, tablic stringow i komunikatow wypisuje na ekran wynik dzialania. Korzysta z: ax, bx, cx, dx
	mov bx, word ptr ds:[resultnumber] ; wciagnij resultnumber z pamieci
	add bx, 9 ; dodaj do niego 9 ( aby bx = 0 oznaczalo "minus dziewiec" w tablicy stringow )
	shl bx, 1 ; pomnoz razy dwa ( bo mamy do czynienia z word pointr )
	mov cx, word ptr ds:[extendednumberstringsoffsets + bx] ; zmapuj bx na offset wzgledem poczatku tablicy extendednumberstrings
	add cx, offset extendednumberstrings ; dodaj offset do extendednumberstrings
	; po tej operacji cx wskazuje na stringa z liczba szukana slownie
	
	mov dx, offset output6 ; wypisz komunikat
	mov ah, 9
	int 21h
	
	mov dx, cx ; wypisz slownie liczbe
	mov ah, 9
	int 21h
	
	mov dx, offset newline ; wypisz nowa linijke
	mov ah, 9
	int 21h
	
	ret
	
use_the_operand: ; sprawdza co jest w operation i wykonuje odpowiednia operacje. Korzysta z: ax, bx, si, di
	mov di, offset operation ; jezeli operacja jest "plus" 
	mov si, offset plus
	call str_cmp_equal ; porownaj stringi w si i di
	cmp ax, 1
	je operation_is_plus_use_the_operand ; skocz do odpowiedniej linii
	mov di, offset operation; j. w.
	mov si, offset minus
	call str_cmp_equal
	cmp ax, 1
	je operation_is_minus_use_the_operand
	mov di, offset operation ; j. w.
	mov si, offset multiply
	call str_cmp_equal
	cmp ax, 1
	je operation_is_multiply_use_the_operand
	
	mov byte ptr ds:[error1], 5 ; jezeli nie znalazlo operacji, to wpisz 5 do error1 i wyjdz z funkcji
	ret
	
	operation_is_plus_use_the_operand:
	xor ax, ax ; wyzeruj ax i bx
	xor bx, bx
	mov al, byte ptr ds:[number1] ; ustaw na ich miejscu odpowiednie liczby
	mov bl, byte ptr ds:[number2]
	add ax, bx ; wykonaj operacje
	
	ret
	
	operation_is_minus_use_the_operand:
	xor ax, ax ; wyzeruj ax i bx
	xor bx, bx
	mov al, byte ptr ds:[number1] ; ustaw na ich miejscu odpowiednie liczby
	mov bl, byte ptr ds:[number2]
	sub ax, bx ; wykonaj operacje
	
	ret
	
	operation_is_multiply_use_the_operand:
	xor ax, ax ; wyzeruj ax i bx
	xor bx, bx
	mov al, byte ptr ds:[number1] ; ustaw na ich miejscu odpowiednie liczby
	mov bl, byte ptr ds:[number2]
	imul bx ; wykonaj operacje
	
	ret
	
	
	
fill_the_numbers: ; znajduje w numberstrings odpowiednie stringi i odpowiednio uzupelnia number1 i number2. Korzysta z: ax, bx, cx, si, di
	xor cx, cx
	pre_loop1_fill_the_numbers: ; dla kazdej cyfry od 0 do 9 sprawdzam, czy odpowiednie stringi w numberstrings sa rowne wczytanemu, jesli tak, ide dalej
	cmp cl, 10 ; jezeli dojdziemy do 10, to znalezlismy blad - nie ma takiego stringa, ktory jest rowny naszemu
	je error_fill_the_numbers
		mov si, offset numberstring1
		mov di, offset numberstrings ; wczytuje wskaznik na pierwszy element
		mov bx, offset numberstringsoffsets ; wczytuje wskaznik na tablice przesuniec
		shl cx, 1 ; mnoze cx razy dwa ( poniewaz uzywam worda i offsety sa podwojne )
		add bx, cx ; dodaje cx do bx. Po tej operacji bx wskazuje na cl'ty element tablicy
		shr cx, 1
		mov ax, word ptr ds:[bx] ; ax ustawiam na wartosc elementu tablicy pod indeksem bx
		add di, ax ; dodaje do di ax. Po tej operacji di wskazuje na cl'ty string w tablicy numberstrings
		call str_cmp_equal
		cmp ax, 1 ; jezeli dwa stringi sa rowne
		je found_the_string1 ; wyskocz z petli
		inc cl
	jmp pre_loop1_fill_the_numbers
	
	found_the_string1:
	
	mov byte ptr ds:[number1], cl ; zapisz cl w number1
	
	
	xor cx, cx                                ; j. w.
	pre_loop2_fill_the_numbers:
	cmp cl, 10
	je error_fill_the_numbers
		mov si, offset numberstring2
		mov di, offset numberstrings
		mov bx, offset numberstringsoffsets
		shl cx, 1
		add bx, cx
		shr cx, 1
		mov ax, word ptr ds:[bx]
		add di, ax
		call str_cmp_equal
		cmp ax, 1
		je found_the_string2
		inc cl
	jmp pre_loop2_fill_the_numbers
	
	found_the_string2:
	
	mov byte ptr ds:[number2], cl
	
	ret
	
	error_fill_the_numbers: ; jezeli jest blad, to zapisz to w error1 i wyjdz z funkcji
	mov al, 4
	mov byte ptr ds:[error1], al
	
	ret
	
	
	
	
str_cmp_equal: ; Oczekuje w si i di offsetow na stringi do porownania. Jesli sa rowne, to w ax zostawia 1, jesli nie, to 0. Korzysta z: ax, si, di
	pre_loop_str_cmp_equal:
	cmp byte ptr ds:[si], '$' ; dopóki si ni jest dolarem, to zapetlaj
	je exit_loop_str_cmp_equal
	
		mov al, byte ptr ds:[di] ; sprawdzaj kolejne znaki
		cmp byte ptr ds:[si], al
		jne return_false_str_cmp_equal ; jesli nie sa rowne, to zwroc 0
		
		inc si
		inc di
	jmp pre_loop_str_cmp_equal
	exit_loop_str_cmp_equal:
	
	cmp byte ptr ds:[di], '$' ; jezeli po wyjsciu z petli di tez wskazuje na dolar, to zwroc 1
	je return_true_str_cmp_equal
	jne return_false_str_cmp_equal
	
	return_false_str_cmp_equal:
		mov ax, 0
		ret
	
	return_true_str_cmp_equal:
		mov ax, 1
		ret
	
	ret
	
remove_spaces_and_CR_on_the_end: ; usuwa spacje i znaki CR z konca linii. Korzysta z ax, bx, cx
	mov al, ds:[inputLength] ; wczytaj dlugosc wczytanego lancucha
	mov bx, offset input1
	xor ah, ah
	add bx, ax
	
	mov cx, offset input1
	dec cx
	
	mov byte ptr ds:[bx], '$' ; na bx'te miejsce wpisz dolar ( usuwa to z konca znak CR )
	dec bx
	
	
	pre_loop_remove_spaces_on_the_end: ; dopóki ostatnim znakiem jest spacja, wstawiaj za jej miejsce dolar
	cmp byte ptr ds:[bx], ' '
	jne exit_loop_remove_spaces_on_the_end
	cmp bx, cx
	je exit_loop_remove_spaces_on_the_end
	
	mov byte ptr ds:[bx], '$'
	dec bx
	
	jmp pre_loop_remove_spaces_on_the_end
	exit_loop_remove_spaces_on_the_end:
	
	ret
    
handle_errors_main: ; sprawdza, czy error1 zawiera blad, jesli tak, to wypisuje komunikat i wychodzi z programu. Korzysta z: ax, dx
    
    cmp byte ptr ds:[error1], 0 ; sprawdza dla kolejnych typow bledow czy on wystapil
    je no_error_main
    cmp byte ptr ds:[error1], 1
    je too_many_arguments_error_main
    cmp byte ptr ds:[error1], 2
    je too_little_arguments_error_main
    cmp byte ptr ds:[error1], 3
    je empty_operation_or_number_error_main
    cmp byte ptr ds:[error1], 4
    je parsing_number_error_main
    cmp byte ptr ds:[error1], 5
    je invalid_operation_error_main
    
    jne other_error_main
    
    too_many_arguments_error_main:
    mov dx, offset error_mssg1 ; wypisz na ekran odpowiedni komunikat
    mov ah, 9
    int 21h
    jmp other_error_main
    
    too_little_arguments_error_main:
    mov dx, offset error_mssg2 ; j. w.
    mov ah, 9
    int 21h
    jmp other_error_main
	
	empty_operation_or_number_error_main:
    mov dx, offset error_mssg3 ; j. w.
    mov ah, 9
    int 21h
    jmp other_error_main
	
	parsing_number_error_main:
    mov dx, offset error_mssg4 ; j. w.
    mov ah, 9
    int 21h
    jmp other_error_main
	
	invalid_operation_error_main:
    mov dx, offset error_mssg5 ; j. w.
    mov ah, 9
    int 21h
    jmp other_error_main
    
    other_error_main:
    mov dx, offset error_mssg_default ; j. w.
    mov ah, 9
    int 21h
    mov al, 1
    mov ah, 4ch
    int 21h
    
    no_error_main:
	
	ret
    

split_string:   ; funkcja dzielaca string na wyrazy. po wykonaniu ustawia si i dx na offset tuz po wyrazie. Mozna dzieki temu wykonac ta funkcje po raz kolejny i zczyta dalsze slowa
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
    
    mov bh, ds:[si] ; ustawiam input ending na ustatni znak. Wykorzystuje to potem do sprawdzenia bledu.
    mov byte ptr ds:[input_ending], bh
    
    inc si
    mov dx, si
	ret
    
call_split_strings: ; wykonuje split_string dla trzech kolejnych slow, a nastepnie sprawdza wystapienie bledow wejscia. Korzysta z: ax, bx, dx, di, si
	mov dx, offset input1
    mov ax, offset numberstring1
	call split_string
    
    mov ax, offset operation
	call split_string
    
    mov ax, offset numberstring2
	call split_string
	
	; obsluga bledow
    
    cmp byte ptr ds:[input_ending], ' '
    jne no_too_many_arguments_error_call_split_strings
    
    mov ds:[error1], 1
    
    no_too_many_arguments_error_call_split_strings:
    
    cmp ds:[numberstring2], '$'
    jne no_too_little_arguments_error_call_split_strings
    
    mov ds:[error1], 2
    
    no_too_little_arguments_error_call_split_strings:
    
    cmp ds:[numberstring1], '$'
    je parsing_error_call_split_strings
    
    cmp ds:[operation], '$'
    je parsing_error_call_split_strings
    
	jmp no_parsing_error_call_split_strings
    
    parsing_error_call_split_strings:
    mov ds:[error1], 3
	
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