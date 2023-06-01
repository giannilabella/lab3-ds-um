; *** FILE DATA ***
;   Filename: XXX.asm
;   Date:
;   Version:
;
;   Author: 
;   Company:
;
;   Notes:


; *** Processor Config ***
	list		p=16f877a       ; list directive to define processor
	#include	<p16f877a.inc>  ; processor specific variable definitions
	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF


; *** Variable Definition ***
w_temp      EQU	0x7D    ; variable used for context saving 
status_temp	EQU	0x7E    ; variable used for context saving
pclath_temp	EQU	0x7F    ; variable used for context saving			


; *** Reset Config ***
	ORG     0x000   ; processor reset vector

	nop             ; nop required for icd
  	goto    main    ; go to beginning of program


; *** Interrupt Config ***
	ORG     0x004       ; interrupt vector location

	movwf   w_temp      ; save off current W register contents
	movf	STATUS, w   ; move status register into W register
	movwf	status_temp ; save off contents of STATUS register
	movf	PCLATH, w	; move pclath register into w register
	movwf	pclath_temp ; save off contents of PCLATH register

    ; isr code can go here or be located as a call subroutine elsewhere

	movf	pclath_temp, w  ; retrieve copy of PCLATH register
	movwf	PCLATH		    ; restore pre-isr PCLATH register contents
	movf    status_temp, w  ; retrieve copy of STATUS register
	movwf	STATUS          ; restore pre-isr STATUS register contents
	swapf   w_temp, f
	swapf   w_temp, w       ; restore pre-isr W register contents
	retfie                  ; return from interrupt


; *** Main Routine ***
main
    ; main code goes here

	END ; directive 'end of program'
