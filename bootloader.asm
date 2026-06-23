; bootloader.asm
; super simple "bootloader"
; will research and expand

%define SCREEN_WIDTH            80
%define SCREEN_HEIGHT           25

; interrupts
%define INT_VIDEO               0x10

; interrupt functions
%define INT_FUNC_SETCURSORPOS   0x02
%define INT_FUNC_WRITECHAR      0x09

; colors
%define COLOR_WHITE             0x000f  ; BH = page 0, BL = 0x0f (white)

bits 16                             ; 16-bit instruction set

org 0x7c00                          ; bootloader will be loaded at 0x7c00 so offset from that

    jmp start                       ; jump to start

msg:        db  "Hello, World! "
end_msg:

start:
    xor dx, dx                      ; set cursor position = 0,0 (dh = y-pos, dl = x-pos)
    mov ds, dx                      ; set data segment register = 0
    cld                             ; clear direction flag so lodsb reads left to right

print:
    mov si, msg                     ; load address of msg into si

char:
    mov bx, COLOR_WHITE             ; set char color
    mov cx, 1                       ; write 1 char at a time
    mov ah, INT_FUNC_SETCURSORPOS   ; set cursor pos
    int INT_VIDEO                   ; video services interrupt

    lodsb                           ; load al with byte at ds:si then inc si (i.e. msg+si)
    mov ah, INT_FUNC_WRITECHAR      ; write char and attribute at cursor pos
    int INT_VIDEO                   ; video services interrupt

    inc dl                          ; cursor x-pos

    cmp dl, SCREEN_WIDTH            ; if cursor x-pos != SCREEN_WIDTH
    jne skip                        ; skip y-pos increment
    xor dl, dl                      ; set x-pos = 0
    inc dh                          ; inc y-pos

    cmp dh, SCREEN_HEIGHT           ; if y-pos != SCREEN_HEIGHT
    jne skip                        ; skip y-pos reset
    xor dh, dh                      ; set y-pos = 0

skip:
    cmp si, end_msg                 ; if si (i.e. address of byte to print) != last byte
    jne char                        ; print the byte
    jmp print                       ; otherwise, run print again

    times   512 - 2 - ($ - $$)  db 0        ; fill up to 510th byte
                                dw 0xaa55   ; 2-byte boot sector signature

; end of file
