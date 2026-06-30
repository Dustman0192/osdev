; ===============================================================
; bootloader2.asm
; Assemble: nasm -f bin bootloader2.asm -out boot.img
; Run: qemu-system-i386 -fda boot.img
; ===============================================================

%define ORG_ADDR    0x7c00

[bits 16]
[org ORG_ADDR]

; ===============================================================
; Entry Point
; ===============================================================
start:
    cli                 ; disable interrupts

    ; initialize segment registers
    xor ax, ax          ; ax = 0
    mov ds, ax          ; ds = 0
    mov es, ax          ; es = 0
    mov ss, ax          ; ss = 0
    mov sp, ORG_ADDR    ; stack grows down from ORG_ADDR

    sti                 ; re-enable interrupts

    call clear_screen

    mov si, msg_welcome
    call print_string

    mov si, msg_info
    call print_string

    call print_memory_size

    mov si, msg_prompt
    call print_string

    call wait_keypress

    ; reboot
    jmp 0xffff:0x0000

; ===============================================================
; Functions
; ===============================================================

; Clears the screen and sets cursor to 0,0
clear_screen:
    push bp,
    mov bp, sp
    pusha

    mov ah, 0x00        ; set video mode
    mov al, 0x03        ; 80x25 text mode
    int 0x10            ; video interrupt

    popa
    mov sp, bp
    pop bp
    ret

; Print null-terminated string
; Input: si = address of string
print_string:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x0e        ; teletype output
.loop:
    lodsb               ; load byte from si into al, increment si
    test al, al         ; is it null byte?
    jz  .done           ; yes? exit
    int 0x10            ; no? print it
    jmp .loop           ; get next char

.done:
    popa
    mov sp, bp
    pop bp
    ret

; Print hexadecimal number
; Input: ax = number to print
print_hex:
    push bp
    mov bp, sp
    pusha

    mov cx, 4           ; 4 hex digits
    mov bx, hex_chars   ; lookup table
.loop:
    rol ax, 4           ; rotate left 4 bits
    push ax
    and al, 0x0f        ; mask lower 4 bits
    xlat                ; al = [bx + al]
    mov ah, 0x0e
    int 0x10
    pop ax
    loop .loop

    popa
    mov sp, bp
    pop bp
    ret

; print memory size in KB
print_memory_size:
    push bp
    mov bp, sp
    pusha

    ; interrupt 0x12 returns memory size in KB in ax
    int 0x12    ; get conventional memory size

    mov si, msg_memory
    call print_string
    call print_hex

    mov si, msg_kb
    call print_string

    popa
    mov sp, bp
    pop bp
    ret

; Wait for any keypress
wait_keypress:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x00    ; wait for key press
    int 0x16        ; keyboard BIOS service

    popa
    mov sp, bp
    pop bp
    ret

msg_welcome:    db '=================================', 13, 10
                db '  My First Bootloader!', 13, 10
                db '  Running on bare metal x86', 13, 10
                db '=================================', 13, 10, 0

msg_info:       db 13, 10
                db 'CPU is in 16-bit Real Mode', 13, 10
                db 'Segment registers initialized', 13, 10
                db 'BIOS interrupts available', 13, 10, 0

msg_memory:     db 13, 10, 'Conventional memory: 0x', 0
msg_kb:         db ' KB', 13, 10, 0

msg_prompt:     db 13, 10, 'Press any key to reboot...', 0
hex_chars:      db '0123456789ABCDEF'

    times 510 - ($ - $$)    db  0       ; pad to 512 bytes
                            dw  0xaa55  ; boot signature
