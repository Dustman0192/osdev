; ═══════════════════════════════════════════════════════════════
; stage2.asm - Second stage bootloader
; Loaded at 0x1000:0x0000 (physical address 0x10000)
; ═══════════════════════════════════════════════════════════════

[bits 16]
[org 0x0000]    ; loaded at offset 0 within segment 0x1000

stage2_start:
    ; set up segments for stage 2
    mov ax, 0x1000
    mov ds, ax
    mov es, ax

    ; print stage 2 message
    mov si, msg_stage2
    call    print_string

    ; enable A20 line (required to access memory above 1MB)
    call    enable_a20

    ; From here, you would:
    ; 1. Load the kernel from disk
    ; 2. Set up the GDT
    ; 3. Switch to protected mode
    ; 4. Jump to kernel

    ; For now, just hang
    mov si, msg_ready
    call    print_string
    jmp $

enable_a20:
    in  al, 0x92
    or  al, 2
    out 0x92, al
    ret

print_string:
    pusha
    mov ah, 0x0e
.loop:
    lodsb
    test    al, al
    jz  .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

msg_stage2: db 'Stage 2 loaded successfully!', 13, 10, 0
msg_ready:  db 'Ready for protected mode...', 13, 10, 0

; Pad to fill entire 5 sectors (2560 bytes)
    times 2560-($-$$) db 0
