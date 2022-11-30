;-----------------------------------------------------------------------------
; toupper64.asm - convert lower case characters to upper case
;-----------------------------------------------------------------------------
;
; DHBW Ravensburg - Campus Friedrichshafen
;
; Vorlesung Systemnahe Programmierung (SNP)
;
;----------------------------------------------------------------------------
;
; Architecture:  x86-64
; Language:      NASM Assembly Language
;
; Author:        Ralf Reutemann
; Created:       2021-11-25
;
;----------------------------------------------------------------------------

%include "syscall.inc"  ; OS-specific system call macros

;-----------------------------------------------------------------------------
; CONSTANTS
;-----------------------------------------------------------------------------

%define BUFFER_SIZE          80 ; max buffer size
%define CHR_LF               10 ; line feed (LF) character
%define CHR_CR               13 ; carriage return (CR) character


;-----------------------------------------------------------------------------
; Section DATA
;-----------------------------------------------------------------------------
SECTION .data

chcnt:          times 7 dq 0
chtotal:        dq 0

outstr:
                db "DIG:   "
.dig            db "             ", CHR_LF
                db "LOW    "
.low            db "             ", CHR_LF


SECTION .rodata

                align 8
asciitable:


;-----------------------------------------------------------------------------
; Section BSS
;-----------------------------------------------------------------------------
SECTION .bss

                align 128
buffer          resb BUFFER_SIZE+1


;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

        ;-----------------------------------------------------------
        ; PROGRAM'S START ENTRY
        ;-----------------------------------------------------------
        global _start:function  ; make label available to linker
_start:
        nop

next_string:
        ;-----------------------------------------------------------
        ; read string from standard input (usually keyboard)
        ;-----------------------------------------------------------
        SYSCALL_4 SYS_READ, FD_STDIN, buffer, BUFFER_SIZE
        test    rax,rax         ; check system call return value
        jz      _exit           ; jump to loop exit if end of input is
                                ; reached, i.e. no characters have been
                                ; read (eax == 0)

        mov byte [buffer+rax],0

        ; rsi: pointer ro current chaarcter in buffer
        lea     rsi,[buffer] ;Adresse buffer wird in rsi geschrieben

;------------------ Komplizierter Algorithmus -------------------------------------------------
next_char:
        movzx   edx,byte[rsi+rax-1] ;edx=aktuelles Zeichen
        ;if(isgitit(ch))
        ;if(islower(ch))
        movzx   ebx,byte[asciitable+rdx] ;Basisadresse+gelesenes Zeichen als Index, C-Syntax: tagid=asciitable[ch]
        inc     qword [chcnt+rbx*8] 
        dec     rax
        jnz     next_char
        jmp     next_string
not_lower_case: 
        inc     rsi ;inkrementieren des Pointers
        test    dl,dl
        jnz     next_char ;jump not zero


;------------------------ Einfacher Algorithmus -------------------------------------------------------;
; next_char:
;         mov     dl,[rsi]
;         ;ASCII
;         ; 'a' = 97 <= dl <= 'z' = 122 ??
;         cmp     dl,'a'
;         jb      not_lower_case ;jump bigger
;         ; dl >= 'a'
;         cmp     dl,'z'
;         ja      not_lower_case ;jump above
;         ; 'a' = 97 <= dl <= 'z' = 122 //Jetzt weiß ich, ob der Buchstabe klein oder groß ist
;         add     dl,'A'-'a'
;         mov     [rsi],dl

; not_lower_case: ;Sprungmarke
;         inc     rsi ;inkrementieren des Pointers
;         test    dl,dl
;         jnz     next_char ;jump not zero


        ;-----------------------------------------------------------
        ; print modified string stored in buffer
        ;-----------------------------------------------------------
        SYSCALL_4 SYS_WRITE, FD_STDOUT, buffer, rax
        jmp     next_string     ; jump back to read next input line

        ;-----------------------------------------------------------
        ; call system exit and return to operating system / shell
        ;-----------------------------------------------------------
_exit:  SYSCALL_2 SYS_EXIT, 0
        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------

