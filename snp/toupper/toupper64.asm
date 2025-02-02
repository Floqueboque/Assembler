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
%ifidn __OUTPUT_FORMAT__, macho64
        DEFAULT REL
        global start            ; make label available to linker
start:                         ; standard entry point for ld
%else
        DEFAULT ABS
        global _start:function  ; make label available to linker
_start:
%endif
        nop

next_string:
        ;-----------------------------------------------------------
        ; read string from standard input (usually keyboard)
        ;-----------------------------------------------------------
        SYSCALL_4 SYS_READ, FD_STDIN, buffer, BUFFER_SIZE
        test    rax,rax         ; check system call return value
        jz      _exit           ; jump to loop exit if end of input is
                                ; reached, i.e. no characters have been
                                ; read (rax == 0)
        lea     rdi,[buffer]
        mov     byte [rdi+rax],0    ; zero terminate string

        ;-----------------------------------------------------------
        ; convert all lower case characters in the string
        ; to upper case, others remain unchanged
        ;
        ; Note: rax contains the number of characters in the string,
        ;       returned by the read system call above
        ;-----------------------------------------------------------
        lea     rsi,[buffer]    ; load pointer to character buffer
next_char:
        movzx   edx,byte [rsi]  ; load next character from buffer
        lea     r8d, [rdx-'a']
        cmp     r8b, ('z'-'a')  ; check whether character is lower case
        ja      not_lower_case  ;   no, then skip conversion
        sub     dl,'a'-'A'      ; otherwise, convert to upper case and
        mov     [rsi],dl        ; store converted character back to buffer
not_lower_case:
        inc     rsi             ; increment buffer pointer
        test    dl,dl           ; check for end-of-string
        jnz     next_char       ;   no, process next char in buffer

        mov byte [buffer+rax],0

        ; rsi: pointer ro current chaarcter in buffer
        lea     rsi,[buffer] ;Adresse buffer wird in rsi geschrieben

;------------------ Komplizierter Algorithmus -------------------------------------------------
next_char:
        movzx   edx,byte[rsi] ;32bit Register initialisieren
        ; 'a' <= rdx <= 'z'
        ; rdx - 'a' -> r8
        ; r8:
        ; r8 < 0                -> dl < 'a'
        ; 0 <= r8 <= 25         -> 'a' <= dl <= 'z'
        ; r8 > 25               -> dl > 'z'
        ; 0 - 'a' = -97         -> -97 = 0x9f
        ; 2er-Komplement        -> 159 = 0x9f 
        lea     r8d,[rdx-'a']
        cmp     r8b,('z'-'a')  ; = 25
        ja      not_lower_case
        add     dl,'A'-'a'
        mov     [rsi],dl
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

