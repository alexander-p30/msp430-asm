;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
jRESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
		mov.w #vetor1,R5 ;Move o endereço do vetor em R5.
		mov.w #vetor2,R6 ;Move o endereço do vetor em R6.
		mov.w #vetor3,R7 ;Move o endereço do vetor em R7.
		call #SUM16
		jmp $


SUM16: 	cmp.w 0(R5),0(R6) ; o equivalente a @R5 e @R6, no entanto a sintaxe do MSP não aceita @R5,@R6
		jeq tam_iguais
		jmp fim

tam_iguais: mov.w 0(R5),R8
			mov.w 0(R5),0(R7) ; coloco o tamanho do vetor soma (Vetor3).
			incd.w R5
			incd.w R6
			incd.w R7

loop: ; 0(R7) = 0(R5) + 0(R6)
		mov.w 0(R5),R9
		add.w 0(R6),R9 ; o MSP430 não usa carry na soma. Em algumas arquiteturas vc tem que zerar o carry
		mov.w R9,0(R7)
		incd.w R5
		incd.w R6
		incd.w R7
		dec.w R8
		jnz loop

fim: 	ret

 	.data
; Declarar os vetores com 7 elementos
vetor1: .word 7, 65000, 50054, 26472, 53000, 60606, 814, 41121
vetor2:	.word 7, 226, 3400, 26472, 470, 1020, 44444, 12345
vetor3: .word 0, 0, 0, 0, 0, 0, 0, 0
                                            

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
