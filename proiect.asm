ASSUME cs:code, ds:data

data SEGMENT
    msj_intro db 'Indroduceti octetii in format hex (intre 8 si 16 valori): $'
    msj_eroare db 13, 10, 'Input invalid / numar de valori invalid(8 - 16 valori).', 13, 10, '$'
    sir_introdus db 50, ?, 50 dup(?)	; AH = 0Ah (buffer DOS)
    octeti db 16 dup(0) ; aici stocam octetii convertiti
    nocteti db 0        ; cate valori am citit

data ENDS

code SEGMENT
start:
    ; initializam segmentul de date
    mov ax, data
    mov ds, ax

citire:
    ; afisare mesaj de introducere
    mov ah, 09h
    lea dx, msj_intro
    int 21h

    ;citire sir de la tastatura
    mov ah, 0Ah
    lea dx, sir_introdus
    int 21h 

    ; initializari
    mov nocteti, 0                  ; resetare contor
    mov si, offset sir_introdus
    add si, 2                       ; sirul incepe efectiv de la al treilea octet
    mov cl, [sir_introdus + 1]
    mov ch, 0                       ; cate caractere trebuie introduse
    mov di, offset octeti           ; aici salvam octetii rezultati

    jmp conversie_octeti_hexa

input_gresit:
    ; la orice greseala de introducere se afiseaza eroare si se reface citirea
    mov ah, 09h
    lea dx, msj_eroare
    int 21h
    jmp citire

conversie_octeti_hexa:
    cmp cx, 0
    je conversie_finalizata         ; daca nu mai sunt caractere, se opreste

sarim_spatiu:
    cmp cx, 0
    je conversie_finalizata
    cmp byte ptr [si],' '
    jne cifra1                      ; daca nu este spatiu inseamana ca e prima parte din numarul hexa
    inc si
    dec cx
    jmp sarim_spatiu                ; daca este spatiu, sarim peste el

cifra1:
    mov al, [si]                    ; luam prima cifra
    cmp al, '9'
    jbe cifra1_numar                ; este cifra 0 - 9
    cmp al, 'A'
    jb input_gresit                 ; cod ASCII mai mic decat A
    cmp al, 'F'
    ja input_gresit                 ; cod ASCII mai mare decat F
    sub al, 'A' - 10                ; transformam A - F in 10 - 15
    jmp cifra1_corecta 

cifra1_numar:
    ; transformam din ASCII in valori efective
    cmp al, '0'
    jb input_gresit
    sub al, '0'                 

cifra1_corecta:
    shl al, 4
    mov bl, al

    inc si
    dec cx
    cmp cx, 0
    je input_gresit                 ; eroare daca nu exista un alt caracter

cifra2:
    mov al, [si]                    ; luam a doua cifra
    cmp al, '9'
    jbe cifra2_numar                ; este cifra 0 - 9
    cmp al, 'A'
    jb input_gresit                 ; cod ASCII mai mic decat A
    cmp al, 'F'
    ja input_gresit                 ; cod ASCII mai mare decat F
    sub al, 'A' - 10                ; transformam A - F in 10 - 15
    jmp cifra2_corecta
    
cifra2_numar:
    ; transformam din ASCII in valori efective
    cmp al, '0'
    jb input_gresit
    sub al, '0'

cifra2_corecta:
    or al, bl                       ; lipire octet
    mov [di], al                    ; stocare
    inc di

    mov al, nocteti
    inc al
    mov nocteti, al
    cmp al, 16
    ja input_gresit                 ; incrementarea numarului de octeti, daca sunt mai mult de 16 rezulta o eroare din lipsa de memorie

    inc si
    dec cx                          ; avansam dupa a doua cifra

    cmp cx, 0
    je conversie_finalizata         ; verific daca am terminat

    cmp byte ptr [si], ' '
    jne input_gresit
    jmp sarim_spatiu

conversie_finalizata:
    mov al, nocteti

    cmp al, 16
    jbe ok_max
    jmp input_gresit                ; verific sa fie mai putin de 16 octeti
    ok_max:

    mov ah, 08h                    ; codul e in standby pana interactioneaza utilizatorul
    int 21h

    mov ax, 4C00h
    int 21h
code ENDS
END start