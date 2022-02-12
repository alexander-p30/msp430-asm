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
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
EXP1: 
						mov.w #MSG,R5 ; R5 = mensagem clara
						mov.w #GSM,R6 ; R6 = mensagem cifrada
						call #ENIGMA1
						jmp $
						nop
;
; Sua rotina ENIGMA (Exp 1)
ENIGMA1:
						mov.b @R5+, R7
						tst.b R7
						jz END
						call #CYPHER_CHARACTER
						mov.b R15, 0(R6)
						inc.w R6
						jmp ENIGMA1

END:
						ret
						
CYPHER_CHARACTER: ; returns the cyphered character in R15
						push.b R7 ; the character being cyphered
						cmp.b LAST_LETTER_PLUS_ONE, R7
						jge CHARACTER_IS_NOT_CYPHERABLE ; if R7 >= LAST_LETTER_PLUS_ONE
						sub.b FIRST_LETTER, R7 ; R7 = char - 'A'
						jn CHARACTER_IS_NOT_CYPHERABLE ; if R7 < FIRST_LETTER
CHARACTER_IS_CYPHERABLE:
						add.w #RT1, R7 ; R7 = ROTOR[char - 'A']
						mov.b FIRST_LETTER, R15
						add.b @R7, R15
						pop.b R7
						ret
CHARACTER_IS_NOT_CYPHERABLE:
						pop.b R7 ; R7 = clear character
						mov.b R7, R15 ; R15 = clear character
						ret
						
;
; Dados para o enigma
						.data
MSG: .byte "CABECAFEFACAFAD",0 ;Mensagem em claro
GSM: .byte "XXXXXXXXXXXXXXX",0 ;Mensagem cifrada
RT1: .byte 2, 4, 1, 5, 3, 0 ;Trama do Rotor 1
FIRST_LETTER: .byte 65
LAST_LETTER_PLUS_ONE: .byte 71

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
            
