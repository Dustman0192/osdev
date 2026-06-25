bits    16

org     0x7c00

start:
    mov ax, 0x7c0       ; logical addressing (0x7c00 / 0x10 = 0x7c0)
    mov ds, ax          ; start of data segment
    mov ax, 0x7e0       ; logical addressing (0x7c00 + 512 bytes = 0x7e00 / 0x10 = 0x7e0)
    mov ss, ax
    mov sp, 0x2000      ; 8K stack

screen_clear:
    push bp
    mov  bp, sp
    pusha

    mov ah, 0x07        ; scroll window
    mov al, 0x00        ; clear window
    mov bh, 0x07        ; white on black
    mov cx, 0x00        ; specifies top left of screen as (0,0)
    mov dh, 0x18        ; 0x18 = 24 rows of chars
    mov dl, 0x4f        ; 0x4f = 79 cols of chars
    int 0x10            ; video interrupt

    popa
    mov bp, sp
    pop bp
    ret
cursor_set_pos:
    push bp
    mov  bp, sp
    pusha

    mov dx, [bp+4]
    mov ah, 0x02
    mov bh, 0x00
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret
