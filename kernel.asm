[org 0x8000]
[bits 32]

; Simple kernel entry point
mov eax, 0xB8000    ; Video memory address
mov edx, 0x1F00    ; Green 'K' on black
mov [eax], edx

mov edx, 0x1F69    ; Green 'i' on black
mov [eax + 2], edx

mov edx, 0x1F6E    ; Green 'n' on black
mov [eax + 4], edx

mov edx, 0x1F67    ; Green 'g' on black
mov [eax + 6], edx

; Hang in kernel
kernel_hang:
    hlt
    jmp kernel_hang
