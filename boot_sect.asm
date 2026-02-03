[org 0x7c00]
[bits 16]

cli
cld

; Set up segments
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

; Clear screen
mov ah, 0x00
mov al, 0x03
int 0x10

; Move cursor to top
mov ah, 0x02
mov bh, 0x00
mov dh, 0
mov dl, 0
int 0x10

; Print boot messages
mov si, boot_msg
call print_string

; Detect memory
call detect_memory

; Load kernel from disk (sectors 2-9)
mov si, load_msg
call print_string

mov ah, 0x02        ; Read sectors
mov al, 8           ; Number of sectors
mov ch, 0           ; Cylinder
mov cl, 2           ; Sector (starts at 2, sector 1 is boot)
mov dh, 0           ; Head
mov dl, 0x80        ; Drive (0x80 = first hard disk)
mov bx, 0x8000      ; Load address
int 0x13

jc disk_error

; Display ready message
mov si, ready_msg
call print_string

; Setup GDT
call setup_gdt

; Enter protected mode
mov eax, cr0
or al, 0x01
mov cr0, eax

; Far jump to protected mode
jmp 0x08:protected_mode

; ==================== Functions ====================

print_string:
    mov ah, 0x0E
    mov bh, 0x00
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

detect_memory:
    mov si, mem_msg
    call print_string
    
    xor dx, dx
    mov ax, 0xE801
    int 0x15
    
    ; AX = KB between 1MB and 16MB
    ; BX = 64KB blocks above 16MB
    ; Convert to KB
    add ax, 1024        ; 1MB in KB
    
    ; Display memory
    mov bx, ax
    mov si, mem_kb
    call print_number
    
    mov si, newline
    call print_string
    ret

print_number:
    mov ax, bx
    mov cx, 0
    mov dx, 0
    mov bx, 10
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne .divide
.print:
    pop ax
    add al, '0'
    mov ah, 0x0E
    int 0x10
    loop .print
    ret

setup_gdt:
    ; Load GDT
    lgdt [gdt_descriptor]
    ret

disk_error:
    mov si, error_msg
    call print_string
    jmp hang

hang:
    hlt
    jmp hang

; ==================== Data ====================

boot_msg: db "King Boot Loader v1.0", 0x0D, 0x0A, 0
mem_msg: db "Detecting memory: ", 0
mem_kb: db " KB", 0x0D, 0x0A, 0
load_msg: db "Loading kernel...", 0x0D, 0x0A, 0
ready_msg: db "Entering protected mode...", 0x0D, 0x0A, 0
error_msg: db "Disk error!", 0x0D, 0x0A, 0
newline: db 0x0D, 0x0A, 0

; GDT Table
gdt:
    ; Null descriptor
    dq 0
    
    ; Code descriptor (0x08)
    db 0xFF, 0xFF       ; Limit
    db 0x00, 0x00, 0x00 ; Base
    db 0x9A             ; Present, DPL=0, Code
    db 0xCF             ; Limit, 4K granularity
    db 0x00             ; Base high
    
    ; Data descriptor (0x10)
    db 0xFF, 0xFF       ; Limit
    db 0x00, 0x00, 0x00 ; Base
    db 0x92             ; Present, DPL=0, Data
    db 0xCF             ; Limit, 4K granularity
    db 0x00             ; Base high

gdt_descriptor:
    dw 23               ; Size
    dd gdt              ; Offset

; Protected mode code
[bits 32]
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    
    mov esp, 0x90000
    
    ; Jump to kernel at 0x8000
    jmp 0x8000
    
    jmp $

times 510-($-$$) db 0
dw 0xAA55

