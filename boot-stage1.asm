; ===============================================================
; boot-stage1.asm
; Contains the boot sector code as well as stage 1
;   code (load stage 2 from disk)
; ===============================================================

STAGE2_SEGMENT      equ     0x1000
STAGE2_OFFSET       equ     0x0000
SECTORS_TO_READ     equ     5

[bits 16]
[org 0x7c00]

; ===============================================================
; Entry Point
; ===============================================================
start:
    cli                     ; disable interrupts

    ; initialize segment registers
    xor ax, ax              ; ax = 0
    mov ds, ax              ; ds = 0
    mov es, ax              ; es = 0
    mov ss, ax              ; ss = 0
    mov sp, 0x7c00          ; stack grows down from ORG_ADDR

    sti                     ; re-enable interrupts

    mov [boot_drive], dl    ; persist boot drive number

    mov si, msg_loading
    call    print_string

    call    load_stage2
    jc  .disk_error

    mov si, msg_jumping
    call    print_string

    jmp STAGE2_SEGMENT:STAGE2_OFFSET

.disk_error:
    mov si, msg_error
    call    print_string
    shr ax, 8
    call    print_hex
    jmp $                   ; hang on error
; ===============================================================
; Functions
; ===============================================================

; Read stage 2 from disk and jumps to it
load_stage2:
    mov di, 3

.retry:
    ; reset disk system
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13

    ; set up read parameters
    mov ah, 0x02            ; read sectors
    mov al, SECTORS_TO_READ ; number of sectors
    mov ch, 0               ; cylinder 0
    mov cl, 2               ; start at sector 2
    mov dh, 0               ; head 0
    mov dl, [boot_drive]    ; drive number

    ; set destination buffer
    mov bx, STAGE2_SEGMENT
    mov es, bx
    mov bx, STAGE2_OFFSET

    ; perform read
    int 0x13
    jnc .success            ; no carry = success

    ; retry on failure
    dec di
    jnz .retry

    ; all retries failed
.fail:
    stc                     ; set carry flag (error)
    ret

.success:
    clc                     ; clear carry flag (success);
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
; Input: AX = number to print
print_hex:
    pusha
    mov cx, 4           ; 4 hex digits
    mov bx, hex_chars   ; Lookup table
.loop:
    rol ax, 4           ; Rotate left 4 bits
    push ax
    and al, 0x0F        ; Mask lower 4 bits
    xlat                ; table look up on hex_chars, AL = [BX + AL] = [&hex_chars + al]
    mov ah, 0x0E
    int 0x10
    pop ax
    loop .loop
    popa
    ret

; Data
boot_drive:     db 0
msg_loading:    db 'Loading stage 2...', 13, 10, 0
msg_jumping:    db 'Jumping to stage 2!', 13, 10, 0
msg_error:      db 'Disk read error! 0x', 0
hex_chars:      db '0123456789ABCDEF'

    times 510 - ($ - $$)    db  0       ; pad to 512 bytes
                            dw  0xaa55  ; boot signature
