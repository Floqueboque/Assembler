;----------------------------------------------------------------------------
; copyij.asm
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
; PURPOSE:    Copy a two-dimensional array in row-major oder
;
; PARAMETERS: (via register)
;             RDI - pointer to source array
;             RSI - pointer to destination array
;
; RETURN:     none
;
; C Code:
;
;  for (i = 0; i < NUM_ROWS; i++) {
;      for (j = 0; j < NUM_COLS; j++) {
;          dst->a[i][j] = src->a[i][j];
;      }
;  }
;
;-------------------------------------------------------------------
        global copy_array:function
copy_array:
        mov     ecx, 65536                       # 16384*4
.outer_loop:
        lea     rax, [rcx-65536]                 # j=0
.inner_loop:
        mov     edx, DWORD [rdi+rax]            # copy src->temp
        mov     DWORD [rsi+rax],edx             # copy temp->dst
        add     rax, 4                           # j++ (+4 weil int(32bit))
        cmp     rax, rcx                         # j < NUM
        jne     .inner_loop                     # j < NUM
        lea     rcx, [rax+65536]                 # i++
        cmp     rax, 1073741824                  # 16384*16384*4
        jne     outer_loop
        ret