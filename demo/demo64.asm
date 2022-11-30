%define CHR_LF 10;

SECTION .data
message: db "Hello world!"
         db CHR_LF
hh: db "__"
mm: db "__"
sese: db "__"

SECTION .rodata
SECTION .bss
SECTION .text

    global _start:function
    _start:
        mov rax, 1
        mov rdi, 1
        mov rsi, message
        mov rdx, 14
        syscall

        mov eax,60
        syscall
