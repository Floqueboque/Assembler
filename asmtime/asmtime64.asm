;----------------------------------------------------------------------------
;  asmtime64.asm - get time of day using gettimeofday system call
;----------------------------------------------------------------------------
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
;
;----------------------------------------------------------------------------

%include "syscall.inc"  ; OS-specific system call macros

;-----------------------------------------------------------------------------
; CONSTANTS
;-----------------------------------------------------------------------------

%define SECS_PER_MIN         60 ; seconds per minute
%define SECS_PER_HOUR        60 * SECS_PER_MIN
%define SECS_PER_DAY         24 * SECS_PER_HOUR
%define DAYS_PER_WEEK         7 ; number of days per week
%define EPOCH_WDAY            4 ; Epoch week day was a Thursday
%define CHR_LF               10 ; Line feed character


;-----------------------------------------------------------------------------
; Section DATA
;-----------------------------------------------------------------------------
SECTION .data

message: db "Hallo"
         db CHR_LF
hh:      db "__:"
mm:      db "__:"
sec:     db "__ "
         db "GTM"
         db CHR_LF
message_len    equ $-message


;-----------------------------------------------------------------------------
; Section RODATA
;-----------------------------------------------------------------------------
SECTION .rodata

; empty


;-----------------------------------------------------------------------------
; Section BSS
;-----------------------------------------------------------------------------
SECTION .bss

; timeval structure
timeval:
tv_sec          resq 1
tv_usec         resq 1

secs_today      resd 1
days_epoch      resd 1

; weekday (0 = Sunday, 1 = Monday, etc)
wday            resb 1

hms:
hours           resb 1
minutes         resb 1
seconds         resb 1


;-----------------------------------------------------------------------------
; Section TEXT
;-----------------------------------------------------------------------------
SECTION .text

        ;-----------------------------------------------------------
        ; PROGRAM'S START ENTRY
        ;-----------------------------------------------------------
        global _start:function  ; make label available to linker
_start:
        ;-----------------------------------------------------------
        ; the system call returns the number of seconds since the Unix
        ; Epoch (01.01.1970 00:00:00 UTC).
        ; The first parameter is a pointer to a timeval structure.
        ;-----------------------------------------------------------
        SYSCALL_3 SYS_GETTIMEOFDAY, timeval, 0
        mov     rax, [tv_sec]

        ;-----------------------------------------------------------
        ; convert ticks into hours, minutes and seconds of today
        ; rax contains the number of seconds since the Epoche
        ;-----------------------------------------------------------
        xor     rdx,rdx            ; clear upper 64-bit of dividend
        mov     rbx,SECS_PER_DAY   ; load divisor
        div     rbx                ; div rdx:rax by rbx
        ;-----------------------------------------------------------
        ; division result: rdx:rax div rbx => rax * rbx + rdx
        ; - rax contains the number of days since the Epoche
        ; - rdx contains the number of seconds elapsed today
        ;
        ; Note: since the number of seconds elapsed today easily fits
        ; into 32-bit we continue with 32-bit integer arithmetic.
        ;-----------------------------------------------------------
        mov     [secs_today],edx

        ;-----------------------------------------------------------
        ; calculate the number of hours
        ;-----------------------------------------------------------
        mov     eax,edx            ; seconds elapsed today, from above
        xor     edx,edx            ; clear upper 32-bit of dividend
        mov     ebx,SECS_PER_HOUR  ; load divisor
        div     ebx                ; div edx:eax by ebx
        ;-----------------------------------------------------------
        ; division result: edx:eax div ebx => eax * ebx + edx
        ; - eax contains the number of hours elapsed today
        ; - edx contains the number of seconds of the current hour
        ;-----------------------------------------------------------
        mov     [hours],al

        mov     bl,10
        div     bl
        add     al,'0'
        add     ah,'0'
        mov     [hh],al
        mov     [hh+1],ah

        ;-----------------------------------------------------------
        ; calculate the number of minutes
        ;-----------------------------------------------------------
        mov     eax,edx            ; seconds of current hour, from above
        xor     edx,edx            ; clear upper 32-bit of dividend
        mov     ebx,SECS_PER_MIN   ; load divisor
        div     ebx                ; div edx:eax by ebx
        ;-----------------------------------------------------------
        ; division result: edx:eax div ebx => eax * ebx + edx
        ; - eax contains the number of minutes of the current hour
        ; - edx contains the number of seconds of the current minute
        ;-----------------------------------------------------------
        mov     [minutes],al
        mov     [seconds],dl


        ;-----------------------------------------------------------
        ; start of the output for the time to the stdout
        ;-----------------------------------------------------------

        ; in eax steht bereits die minuten
        ; mov     eax,[minutes]
        mov     bl,10
        div     bl
        add     al,'0'
        add     ah,'0'
        mov     [mm],al
        mov     [mm+1],ah

        ; Geht nicht - but why
        ; mov     eax,[hours]
        ; mov     bl,10
        ; div     bl
        ; add     al,'0'
        ; add     ah,'0'
        ; mov     [hh],al
        ; mov     [hh+1],ah

        ; Seconds in CHAR umwandeln
        mov     eax,[seconds]   ; Seconds in eax
        mov     bl,10           ; Teiler in bl
        div     bl              ; eax (seconds) / bl (10) = al REST ah
        add     al,'0'          ; char trick 48 ('0') + al
        add     ah,'0'
        mov     [sec],al        ; char in sec einfügen / ersetzten von _
        mov     [sec+1],ah

        ; syscall for the print
        mov    rdx,message_len       
        mov    rsi,message
        mov    rdi,1
        mov    eax,1
        
        syscall

        ;-----------------------------------------------------------
        ; create label before program exit for our gdb script
        ;-----------------------------------------------------------
_exit:

        ;-----------------------------------------------------------
        ; call system exit and return to operating system / shell
        ;-----------------------------------------------------------
        SYSCALL_2 SYS_EXIT, 0

        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------

