; A simple boot sector that loops forever
loop:
    jmp loop    ; Jump to itself forever

times 510-($-$$) db 0    ; Pad with zeros to byte 510
dw 0xaa55                ; Magic boot sector number
