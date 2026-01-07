ASSUME cs:code, ds:data

data SEGMENT
    msj_intro db 'Indroduceti octetii in format hex (intre 8 si 16 valori): $'
    msj_eroare db 13, 10, 'Input invalid / numar de valori invalid(8 - 16 valori).', 13, 10, '$'
    msj_C   db 13, 10, 'Cuvantul C calculat: $'
    hex_tbl db '0123456789ABCDEF'
    bufC    db '0000','$'
    sir_introdus db 50, ?, 50 dup(?)	; AH = 0Ah (buffer DOS)
    octeti db 16 dup(0) ; aici stocam octetii convertiti
    nocteti db 0        ; cate valori am citit
    C dw ?
    msj_poz db 13,10,'Pozitia octetului cu cei mai multi biti 1: $'
    max_bits db 0
    poz_max  db 0


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

    cmp al, 8
    jae ok_min        
    jmp input_gresit  
    ok_min:                         ; verific sa fie minim de 8 octeti

    cmp al, 16
    jbe ok_max
    jmp input_gresit                ; verific sa fie maxim de 16 octeti
    ok_max:

; ====================================================================================================

    mov al, [octeti]                ; primul octet 

    xor bh, bh
    mov bl, nocteti
    dec bl
    mov ah, [octeti + bx]           ; ultimul octet

    and al, 0F0H                    
    shr al, 4                       ; AL = primii 4 biti

    and ah, 0Fh                     ; AH = ultimii 4 biti

    xor al, ah
    mov dl, al                      ; DL = bitii 0 - 3 din C

    xor bl, bl                      ; golim BL pentru PAS 2
    mov cl, nocteti
    xor ch, ch
    mov si, offset octeti

    pas2_loop:
        mov al, [si]
        shr al, 2                   ; bitii 2 - 5 devin bitii 4 - 7
        and al, 0Fh                 
        or  bl, al                  ; facem OR intre bitii acumulati
        inc si
    loop pas2_loop

    and bl, 0Fh     

    xor ax, ax
    mov cl, nocteti
    xor ch, ch
    mov si, offset octeti

    pas3_loop:
        add al, [si]
        inc si
    loop pas3_loop                

    mov ah, al
    shl bl, 4
    or  bl, dl

    mov al, bl                      ; AX = cuvantul C
    mov C, ax

    lea si, hex_tbl
    lea di, bufC

    ; cifra 1: high nibble din AH
    mov bl, ah
    shr bl, 4
    and bl, 0Fh
    xor bh, bh
    mov dl, [si+bx]
    mov [di], dl
    inc di

    ; cifra 2: low nibble din AH
    mov bl, ah
    and bl, 0Fh
    xor bh, bh
    mov dl, [si+bx]
    mov [di], dl
    inc di

    ; cifra 3: high nibble din AL
    mov bl, al
    shr bl, 4
    and bl, 0Fh
    xor bh, bh
    mov dl, [si+bx]
    mov [di], dl
    inc di

    ; cifra 4: low nibble din AL
    mov bl, al
    and bl, 0Fh
    xor bh, bh
    mov dl, [si+bx]
    mov [di], dl
    ; urmeaza deja '$' in bufC

    ; afisare mesaj
    mov ah, 09h
    lea dx, msj_C
    int 21h

    ; afisare valoare C (hex, ASCII)
    mov ah, 09h
    lea dx, bufC
    int 21h



    mov cl, nocteti
    dec cl                              ; n-1 iteratii externe

outer_loop:
    mov si, offset octeti
    mov ch, cl                          ; contor interior

inner_loop:
    mov al, [si]
    mov bl, [si+1]
    cmp al, bl
    jae no_swap                         ; daca al >= bl, e ok (descrescator)

    ; swap
    mov [si], bl
    mov [si+1], al

no_swap:
    inc si
    dec ch
    jnz inner_loop

    dec cl
    jnz outer_loop
    mov max_bits, 0
    mov poz_max, 0

    lea si, octeti
    mov cl, nocteti
    xor ch, ch              ; CX = nr elemente

    xor di, di              ; DI = index curent (0..)

find_loop:
    cmp cx, 0
    je  find_done

    mov al, [si]            ; AL = octet curent

    ; numaram bitii 1 in AL -> BL
    mov ah, al              ; lucram pe AH ca sa nu ne pese ca se modifica
    xor bl, bl
    mov bp, 8
count_bits:
    shl ah, 1
    jnc bit0
    inc bl
bit0:
    dec bp
    jne count_bits

    ; BL = nr biti 1
    cmp bl, 3
    jbe not_candidate

    mov al, max_bits
    cmp bl, al
    jbe not_candidate

    ; update max + pozitie
    mov max_bits, bl
    mov ax, di
    mov poz_max, al

not_candidate:
    inc si                   ; urmatorul octet
    inc di                   ; index++
    dec cx
    jmp find_loop

find_done:

    mov ah, 09h
    lea dx, msj_poz
    int 21h

    lea si, hex_tbl
    lea di, bufC

    mov ah, poz_max          ; AH = valoarea (byte) de afisat

    ; cifra 1: high nibble din AH
    mov bl, ah
    shr bl, 4
    and bl, 0Fh
    xor bh, bh
    mov dl, [si+bx]
    mov [di], dl
    inc di

    ; cifra 2: low nibble din AH
    mov bl, ah
    and bl, 0Fh
    xor bh, bh
    mov dl, [si+bx]
    mov [di], dl
    inc di

    mov byte ptr [di], '$'   ; terminator pentru AH=09h

    mov ah, 09h
    lea dx, bufC
    int 21h



; ====================================================================================================

    mov ah, 08h                    ; codul e in standby pana interactioneaza utilizatorul
    int 21h

    mov ax, 4C00h
    int 21h
code ENDS
END start


