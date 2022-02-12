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

						mov.w #str1, R4 ; copiar o endereco de str1 para R4
						mov.w #str2, R5 ; copiar o endereco de str2 para R4
						call #DISPARIDADE
						jmp $

DISPARIDADE:
						mov.w #0x0, R6 ; inicializa R6 = 0
						mov.w R4, R7 ; inicializa R7 = R4 para preservar R4
						mov.w R5, R8 ; inicializa R8 = R5 para preservar R5
						mov.w #0x0, R14	 ; R14 indica se R7 já chegou ao fim
						mov.w #0x0, R15	 ; R15 indica se R8 já chegou ao fim
						jmp loop

loop:
						mov.b @R7, R14
						mov.b @R8, R15
						tst.b R14
						jz lower_than_or_equal_to_min
						tst.b R15
						jz lower_than_or_equal_to_min
						mov.w #0x0, R9 ; R9 recebera a subtracao entre os chars da string
						cmp.b 0(R8), 0(R7)
						jn second_lower_than_first
						add.b 0(R7), R9 ; R9 = R7
						sub.b 0(R8), R9 ; R9 = R7 - R8
						add.w R9, R6 ; R6 += R9

next_characters:
next_character_str1:
						tst.w R14
						jz next_character_str2
						inc.w R7 ; proximo caractere de R7
next_character_str2:
						tst.w R15
						jz loop
						inc.w R8 ; proximo caractere de R8
						jmp loop

second_lower_than_first:
						add.b 0(R8), R9 ; R9 = R8
						sub.b 0(R7), R9 ; R9 = R8 - R7
						add.w R9, R6 ; R6 += R9
						jmp next_characters

lower_than_or_equal_to_min:
						mov.b #0x0, R13
						add.b R15, R13
						add.b R14, R13 ; R13 = R15 + R15
						jz fim
						add.w #0x100, R6
						jmp next_characters

fim:
						ret

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
						.data
;str1: .byte "EDUARDO",0
;str2: .byte "EDWARD",0
;str1: .byte 0
;str2: .byte 0
;str1: .byte "ADAD",0
;str2: .byte "ADAD",0
;str1: .byte "ADAD",0
;str2: .byte "ADADAAA",0
str1: .byte "za", 0
str2: .byte "zzzzzzzzzz",0

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
            
