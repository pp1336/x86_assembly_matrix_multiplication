;
; ***************************************************************
;       SKELETON: INTEL ASSEMBLER MATRIX MULTIPLY (LINUX)
; ***************************************************************
;
;
; --------------------------------------------------------------------------
; class matrix {
;     int ROWS              // ints are 64-bit
;     int COLS
;     int elem [ROWS][COLS]
;
;     void print () {
;         output.newline ()
;         for (int row=0; row < this.ROWS; row++) {
;             for (int col=0; col < this.COLS; cols++) {
;                 output.tab ()
;                 output.int (this.elem[row, col])
;             }
;             output.newline ()
;         }
;     }
;
;     void mult (matrix A, matrix B) {
;         for (int row=0; row < this.ROWS; row++) {
;             for (int col=0; col < this.COLS; cols++) {
;                 int sum = 0
;                 for (int k=0; k < A.COLS; k++)
;                     sum = sum + A.elem[row, k] * B.elem[k, col]
;                 this.elem [row, col] = sum
;             }
;         }
;     }
; }
; ---------------------------------------------------------------------------
; main () {
;     matrix matrixA, matrixB, matrixC  ; Declare and suitably initialise
;                                         matrices A, B and C
;     matrixA.print ()
;     matrixB.print ()
;     matrixC.mult (matrixA, matrixB)
;     matrixC.print ()
; }
; ---------------------------------------------------------------------------
;
; Notes:
; 1. For conditional jump instructions use the form 'Jxx NEAR label'  if label
;    is more than 127 bytes from the jump instruction Jxx.
;    For example use 'JGE NEAR end_for' instead of 'JGE end_for', if the
;    assembler complains that the label end_for is more than 127 bytes from
;    the JGE instruction with a message like 'short jump is out of  range'
;
;
; ---------------------------------------------------------------------------

segment .text
        global  _start
_start:

main:
          mov  rax, matrixA     ; matrixA.print ()
          push rax
          call matrix_print
          add  rsp, 8

          mov  rax, matrixB     ; matrixB.print ()
          push rax
          call matrix_print
          add  rsp, 8

          mov  rax, matrixB     ; matrixC.mult (matrixA, matrixB)
          push rax
          mov  rax, matrixA
          push rax
          mov  rax, matrixC
          push rax
          call matrix_mult
          add  rsp, 24          ; pop parameters & object reference

          mov  rax, matrixC     ; matrixC.print ()
          push rax
          call matrix_print
          add  rsp, 8

          call os_return                ; return to operating system

; ---------------------------------------------------------------------

matrix_print:                   ; void matrix_print ()
         push rbp                ; setup base pointer
         mov  rbp, rsp
		 call output_newline    ; print newline
         push rbx
		 push rcx
		 push rdx               ; remember value in registers
		 mov  rax, [rbp]        ; num of row in rax
		 mov  rcx, [rbp + 8]    ; num of col in rcx
		 mov  rbx, 1            ; rbx = i = 0
		 mov  rdx, 1            ; rdx = j = 0
         body_print_1: 
		 cmp  rbx, rax
		 jg  end_print         ; exit loop if i = num of row
		   body_print_3:
		   cmp  rdx, rcx        ; exit loop if j = num of col
		   jg  body_print_2    ; exit inner loop
		   call output_tab      ; print tab
		   push [rbp + 16 + (rax - 1) * rcx * 8 + (rcx - 1) * 8]  ; setup element to be printed
		   call output_int      ; print element
		   add  rsp, 8          ; remove element
		   inc  rdx             ; j++
           jmp  body_print_3    ; next col
	     body_print_2:
		 inc  rbx                ; i++
		 jmp  body_print_1       ; jump back to next row
         end_print: 
		 call output_newline    ; print newline
		 mov  rsp, (rbp - 24)   ; move stack pointer back to where base point was
		 pop  rdx
		 pop  rcx
		 pop  rbx                ; restore registers
         pop  rbp                ; restore base pointer & return
         ret

;  --------------------------------------------------------------------------

matrix_mult:                    ; void matix_mult (matrix A, matrix B)

         push rbp                ; setup base pointer
         mov  rbp, rsp
         push rbx
		 push rcx
		 push rdx
		 push r8                ; 1
		 push r9                ; j
		 push r10               ; k
		 push r11               ; accumlator for multiplication
		 mov  rbx, [rbp]        ; num of row of A in rbx 
		 mov  rcx, [rbp + 8]    ; num of col of A = num of row of B in rcx 
		 mov  rdx, [rbx * rcx * 8]  ; num of col of B in rdx, kept as constant 
		 mov  r8, 1            ; i = 1
		 mov  r9, 1            ; j = 1
		 mov  r10, 1           ; k = 1
		 loop_body_1:
		 cmp  r8, rbx                ; i <= row of A
		 jg   loop_exit_1            ; exit loop
		   loop_body_2:
		   cmp  r9, rdx              ; j <= col of B
		   jg   loop_exit_2           ; exit loop
		     mov  rax, 0              ; sum = 0
			 loop_body_3:
		     cmp  r10, rcx            ; k <= col of A = row of B
			 jg   loop_exit_3         ; exit loop
			   mov  r11, 1            ; accumlator for multiplying
			   imul r11, [rbp + 16 + (r8 - 1) * rcx * 8 + (r10 - 1) * 8] ; value of A[i, k]
			   imul r11, [rbp + 24 + rbx * rcx * 8 + (r10 - 1) * rdx * 8 + (r9 - 1) * 8] ; value of B[k, j] * A[i, k]
			   add  rax, r11          ; sum += A[i, k] * B[k, j]
			   inc  r10               ; k++
			   jmp  loop_body_3       ; next k
             loop_exit_3:
			 mov  [rbp + rbx * rcx * 8 + rdx * rcx * 8 + 32 + (r8 - 1) * rcx * 8 + (r9 - 1) * 8], rax ; C[i, j] = sum
			 inc  r9               ; j++
			 jmp  loop_body_2      ; next j
		   loop_exit_2:
		   inc  r8                 ; i++
		   jmp  loop_body_1        ; next i
		 loop_exit_1:
         mov  rsp, (rbp - 56)      ; move stack pointer back to where base point was
		 pop  r11
		 pop  r10
		 pop  r9
		 pop  r8
		 pop  rdx
		 pop  rcx
		 pop  rbx                ; restore registers
         pop  rbp                ; restore base pointer & return
         ret


; ---------------------------------------------------------------------
;                    ADDITIONAL METHODS

CR      equ     13              ; carriage-return
LF      equ     10              ; line-feed
TAB     equ     9               ; tab
MINUS   equ     '-'             ; minus

LINUX   equ     80H             ; interupt number for entering Linux kernel
EXIT    equ     1               ; Linux system call 1 i.e. exit ()
WRITE   equ     4               ; Linux system call 4 i.e. write ()
STDOUT  equ     1               ; File descriptor 1 i.e. standard output

; ------------------------

os_return:
        mov  rax, EXIT          ; Linux system call 1 i.e. exit ()
        mov  rbx, 0             ; Error code 0 i.e. no errors
        int  LINUX              ; Interrupt Linux kernel

output_char:                    ; void output_char (ch)
        push rax
        push rbx
        push rcx
        push rdx
        push r8                ; r8..r11 are altered by Linux kernel interrupt
        push r9
        push r10
        push r11
        push qword [octetbuffer] ; (just to make output_char() re-entrant...)

        mov  rax, WRITE         ; Linux system call 4; i.e. write ()
        mov  rbx, STDOUT        ; File descriptor 1 i.e. standard output
        mov  rcx, [rsp+80]      ; fetch char from non-I/O-accessible segment
        mov  [octetbuffer], rcx ; load into 1-octet buffer
        lea  rcx, [octetbuffer] ; Address of 1-octet buffer
        mov  rdx, 1             ; Output 1 character only
        int  LINUX              ; Interrupt Linux kernel

        pop qword [octetbuffer]
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        pop  rdx
        pop  rcx
        pop  rbx
        pop  rax
        ret

; ------------------------

output_newline:                 ; void output_newline ()
       push qword LF
       call output_char
       add rsp, 8
       ret

; ------------------------

output_tab:                     ; void output_tab ()
       push qword TAB
       call output_char
       add  rsp, 8
       ret

; ------------------------

output_minus:                   ; void output_minus()
       push qword MINUS
       call output_char
       add  rsp, 8
       ret

; ------------------------

output_int:                     ; void output_int (int N)
       push rbp
       mov  rbp, rsp

       ; rax=N then N/10, rdx=N%10, rbx=10

       push rax                ; save registers
       push rbx
       push rdx

       cmp  qword [rbp+16], 0 ; minus sign for negative numbers
       jge  L88

       call output_minus
       neg  qword [rbp+16]

L88:
       mov  rax, [rbp+16]       ; rax = N
       mov  rdx, 0              ; rdx:rax = N (unsigned equivalent of "cqo")
       mov  rbx, 10
       idiv rbx                ; rax=N/10, rdx=N%10

       cmp  rax, 0              ; skip if N<10
       je   L99

       push rax                ; output.int (N / 10)
       call output_int
       add  rsp, 8

L99:
       add  rdx, '0'           ; output char for digit N % 10
       push rdx
       call output_char
       add  rsp, 8

       pop  rdx                ; restore registers
       pop  rbx
       pop  rax
       pop  rbp
       ret


; ---------------------------------------------------------------------

segment .data

        ; Declare test matrices
matrixA DQ 2                    ; ROWS
        DQ 3                    ; COLS
        DQ 1, 2, 3              ; 1st row
        DQ 4, 5, 6              ; 2nd row

matrixB DQ 3                    ; ROWS
        DQ 2                    ; COLS
        DQ 1, 2                 ; 1st row
        DQ 3, 4                 ; 2nd row
        DQ 5, 6                 ; 3rd row

matrixC DQ 2                    ; ROWS
        DQ 2                    ; COLS
        DQ 0, 0                 ; space for ROWS*COLS ints
        DQ 0, 0                 ; (for filling in with matrixA*matrixB)

; ---------------------------------------------------------------------

        ; The following is used by output_char - do not disturb
        ;
        ; space in I/O-accessible segment for 1-octet output buffer
octetbuffer     DQ 0            ; (qword as choice of size on stack)
