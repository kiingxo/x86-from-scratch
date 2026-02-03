[org 0x7c00]
[bits 16]

; Clear screen
mov ah, 0x00
mov al, 0x03
int 0x10

; Move cursor to center (row 12, col 38)
mov ah, 0x02
mov bh, 0x00
mov dh, 12
mov dl, 38
int 0x10

; Print "King" character by character
mov ah, 0x0E
mov bl, 0x0F    ; White text

mov al, 'K'
int 0x10

mov al, 'i'
int 0x10

mov al, 'n'
int 0x10

mov al, 'g'
int 0x10

; Infinite loop
hang:
    jmp hang

times 510-($-$$) db 0
dw 0xAA55

