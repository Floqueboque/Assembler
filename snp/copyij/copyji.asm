;----------------------------------------------------------------------------
; copyji.asm
;----------------------------------------------------------------------------
;
; DHBW Ravensburg - Campus Friedrichshafen
;
; Vorlesung Systemnahe Programmierung (SNP)
;
;----------------------------------------------------------------------------

SECTION .text

;-------------------------------------------------------------------
; FUNCTION:   copy_array
;
; PURPOSE:    Copy a two-dimensional array in column-major oder
;
; PARAMETERS: (via register)
;             RDI - pointer to source array
;             RSI - pointer to destination array
;
; RETURN:     none
;
; C Code:
;
;  for (j = 0; j < NUM_COLS; j++) {
;      for (i = 0; i < NUM_ROWS; i++) {
;          dst->a[i][j] = src->a[i][j];
;      }
;  }
;
;-------------------------------------------------------------------
        global copy_array:function
copy_array:
        mov     ecx, 1073741824
.L8:
        lea     rax, [rcx-1073741824]
.L9:
        mov     edx, DWORD PTR [rdi+rax]
        mov     DWORD PTR [rsi+rax], edx
        add     rax, 65536
        cmp     rax, rcx
        jne     .L9
        lea     rcx, [rax+4]
        cmp     rax, 1073807356
        jne     .L8
        ret
