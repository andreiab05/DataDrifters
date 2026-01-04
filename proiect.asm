ASSUME cs:code, ds:data

data SEGMENT
    msj_intro db 'Indroduceti octetii in format hex (intre 8 si 16 valori): $'
    sir_introdus db 20, ?, 20 dup(?)	; AH = 0Ah (buffer DOS)
data ENDS

code SEGMENT
start:
    mov ax, data
    mov ds, ax

    ; afisare mesaj de introducere
    mov ah, 09h
    lea dx, msj_intro
    int 21h

    ;citire sir de la tastatura
    mov ah, 0Ah
    lea dx, sir_introdus
    int 21h 

    mov ax, 4C00h
    int 21h
code ENDS
END start