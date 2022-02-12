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
RT_TAM					.equ	6
CONF1					.equ	1

EXP3:
						mov.w #MSG,R5 ; R5 = mensagem clara
						mov.w #GSM,R6 ; R6 = mensagem cifrada
						call #ENIGMA3

						mov.w #GSM, R5 ; R5 = mensagem cifrada
						mov.w #DCF, R6 ; R5 = mensagem decifrada
						call #ENIGMA3

						jmp $
						nop

ENIGMA3:
						mov.w #RT1, R7
						mov.w #CONF1, R8
						mov.w #CONF_ROTOR, R15
						call #APPLY_ROTOR_CONF
						mov.w R15, R8 ; R8 = CONFIGURED_ROTOR
ENIGMA3_LOOP:
						mov.b @R5+, R7
						tst.b R7
						jz END
						call #CYPHER_CHARACTER
						mov.b R15, R7 ; R7 = cyphered character
						mov.w R8, R9 ; R9 = CONFIGURED_ROTOR
						mov.w #RF1, R8 ; R8 = REFLECTOR
						call #REFLECT_CHARACTER
						mov.b R15, 0(R6)
						inc.w R6
						mov.w R9, R8 ; R8 = CONFIGURED_ROTOR
						jmp ENIGMA3_LOOP
END:
						ret

CYPHER_CHARACTER: ; returns the cyphered character in R15
									; receives the character being cyphered in R7
									; the rotor being used in R8
									; and the rotor's configuration in R9
						push.b R7
						cmp.b LAST_LETTER_PLUS_ONE, R7
						jge CHARACTER_IS_NOT_CYPHERABLE ; if R7 >= LAST_LETTER_PLUS_ONE
						sub.b FIRST_LETTER, R7 ; R7 = char - 'A'
						jn CHARACTER_IS_NOT_CYPHERABLE ; if R7 < FIRST_LETTER
CHARACTER_IS_CYPHERABLE:
						add.w R8, R7 ; R7 = ROTOR[char - 'A']
						mov.b FIRST_LETTER, R15
						add.b @R7, R15 ; R15 = 'A' + ROTOR[char - 'A']
						pop.b R7
						ret
CHARACTER_IS_NOT_CYPHERABLE:
						pop.b R7 ; R7 = clear character
						mov.b R7, R15 ; R15 = clear character
						ret


FIND_ELEM_INDEX: ; finds index of element in R7 in vector R8 and returns it in R15
						push.w R7 ; 4(SP) = R7
            			push.w R9 ; 2(SP) = R9
            			push.w R10; 0(SP) = R10
            			sub.b FIRST_LETTER, R7
            			mov.w #0, R9
            			add.b LAST_LETTER_PLUS_ONE, R9
            			sub.b FIRST_LETTER, R9 ; R9 = VECTOR SIZE
            			mov.w R8, R10 ; R10 = current element
            			mov.b #0, R15
FIND_ELEM_INDEX_LOOP:
            			cmp.b R15, R9
            			jz ELEM_INDEX_NOT_FOUND ; IF current_index == vector_size
            			cmp.b 0(R10), R7 ; IF current_element == element
            			jz ELEM_INDEX_FOUND
            			inc.w R10
            			inc.b R15
            			jmp FIND_ELEM_INDEX_LOOP
ELEM_INDEX_FOUND:
FIND_ELEM_INDEX_UNSTACK:
						pop.w R10
						pop.w R9
						pop.w R7
						ret
ELEM_INDEX_NOT_FOUND:
						jmp FIND_ELEM_INDEX_UNSTACK
						nop

REFLECT_CHARACTER: ; reflects char in r7 using reflector in R8 and rotor in R9 returning it in R15
						push.w R8 ; reflector
						call #CYPHER_CHARACTER
						mov.b R15, R7
						mov.w R9, R8 ; R8 = ROTOR
INVERSE_CYPHERING:		call #FIND_ELEM_INDEX
						add.b FIRST_LETTER, R15
						pop.w R8
						ret

MODULO: ; computes the modulo of R7 by R8 and returns it on R15
						push.w R7
MODULO_LOOP:
						cmp.w R8, R7
						jn MODULO_END
						sub.w R8, R7
						jmp MODULO_LOOP
MODULO_END:
						mov.w R7, R15
						pop.w R7
						ret

APPLY_ROTOR_CONF: ; applies to rotor on R7 configuration on R8 storing its adress on R15
						push.w R8
						push.w R9
						push.w R10
						push.w R11
						mov.w #0, R9 ; position in original rotor
						mov.w R8, R10 ; position in configured rotor
						mov.w #RT_TAM, R8 ; R8 = ROTOR_SIZE
APPLY_ROTOR_CONF_LOOP:
						cmp.w R8, R9
						jz APPLY_ROTOR_CONF_END
						push.w R7
						push.w R15
						mov.w R10, R7
						call #MODULO ; R15 = position_in_conf % last_index
						mov.w R15, R10
						pop.w R15
						pop.w R7
						add.w R7, R9 ; R9 = mem_position_on_rotor
						add.w R15, R10 ; R10 = mem_position_in_conf
						mov.b @R9+, 0(R10)
						sub.w R7, R9
						sub.w R15, R10
						inc.w R10
						jmp APPLY_ROTOR_CONF_LOOP
APPLY_ROTOR_CONF_END:
						pop.w R11
						pop.w R10
						pop.w R9
						pop.w R8
						ret

;
; Dados para o enigma
						.data
MSG: .byte "CABECAFEFACAFAD",0 ;Mensagem em claro
GSM: .byte "XXXXXXXXXXXXXXX",0 ;Mensagem cifrada
DCF: .byte "XXXXXXXXXXXXXXX",0 ;Mensagem decifrada
RT1: .byte 2, 4, 1, 5, 3, 0 ;Trama do Rotor 1
RF1: .byte 3, 5, 4, 0, 2, 1 ;Tabela do Refletor
CONF_ROTOR: .byte 0, 0, 0, 0, 0, 0 ; rotor configurado
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
            
