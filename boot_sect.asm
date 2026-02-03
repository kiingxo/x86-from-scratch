[org 0x7c00]
[bits 16]

mov ah, 0x0E
mov al, 'K'
int 0x10

mov al, 'i'
int 0x10

mov al, 'n'
int 0x10

mov al, 'g'
int 0x10

loop:
    jmp loop

times 510-($-$$) db 0
dw 0xAA55

