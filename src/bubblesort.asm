; *** FILE DATA ***
;   Filename: bubblesort.asm
;   Date: May 30, 2023
;   Version: 1.0
;
;   Author: Gianni Labella
;   Company: Universidad de Montevideo


; *** Processor Config ***
	list		p=16f877a       ; list directive to define processor
	#include	<p16f877a.inc>  ; processor specific variable definitions
	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF


; *** Variable Definition ***
w_temp      EQU	0x7D    ; variable used for context saving 
status_temp	EQU	0x7E    ; variable used for context saving
pclath_temp	EQU	0x7F    ; variable used for context saving	

; Vector variables
vector_address  EQU 0x20   ; vector address
vector_length   EQU 0x21   ; vector length address

; Bubblesort variables
counter         EQU 0x22    ; counter for outerloop iterations
current         EQU 0x23    ; current element address on innerloop
previous        EQU 0x24    ; previous element address on innerloop
compare         EQU 0x25    ; used to compare current and previous elements
temp_current    EQU 0x26    ; temporary current element when swapping
temp_previous   EQU 0x27    ; temporary previous element when swapping


; *** Reset Config ***
	ORG     0x000   ; processor reset vector

	nop             ; nop required for icd
  	goto    main    ; go to beginning of program


; *** Interrupt Config ***
	ORG     0x004       ; interrupt vector location

	movwf   w_temp      ; save off current W register contents
	movf	STATUS, W   ; move status register into W register
	movwf	status_temp ; save off contents of STATUS register
	movf	PCLATH, W	; move pclath register into w register
	movwf	pclath_temp ; save off contents of PCLATH register

    ; isr code can go here or be located as a call subroutine elsewhere

	movf	pclath_temp, W  ; retrieve copy of PCLATH register
	movwf	PCLATH		    ; restore pre-isr PCLATH register contents
	movf    status_temp, W  ; retrieve copy of STATUS register
	movwf	STATUS          ; restore pre-isr STATUS register contents
	swapf   w_temp, F
	swapf   w_temp, W       ; restore pre-isr W register contents
	retfie                  ; return from interrupt


; *** Main Routine ***
main
    call    load_testvector0
    ; call    load_testvector1
    ; call    load_testvector2

    call    bubblesort

loop
    goto    loop


; *** Bubblesort subroutine
bubblesort
    ; Initialize outer loop variables
    movf    vector_length, W    ; set counter to vector length
    movwf   counter

    call    bubblesort_outerloop
    return

; *** Bubblesort outer loop ***
bubblesort_outerloop
    ; Initialize inner loop variables
    movf    vector_address, W   ; set current to first element
    movwf   current
    movwf   previous            ; set previous to current - 1
    decf    previous, F

    ; Run inner loop when counter not zero
    decfsz  counter, F              ; counter--
    goto    bubblesort_innerloop    ; if counter != 0
    return                          ; if counter == 0

; *** Bubblesort inner loop ***
bubblesort_innerloop
    incf    current, F  ; current++
    incf    previous, F ; previous++

    ; Check if current element is in range
    movf    vector_address, W   ; vect_address_reg -> W
    addwf   vector_length, W    ; W += vect_length_reg
    subwf   current, W          ; W = current - W = current - (vector address + vector length)

    btfsc   STATUS, C               ; check if W is negative (current < (addr + len))
    goto    bubblesort_outerloop    ; go back to outer loop if W is positive (current >= (addr + len))

    ; Check if previous is bigger than current element
    movf    current, W  ; current -> W
    movwf   FSR         ; W -> FSR
    movf    INDF, W     ; reg pointed by current -> W
    movwf   compare     ; W -> compare

    movf    previous, W ; previous -> W
    movwf   FSR         ; W -> FSR
    movf    INDF, W     ; reg pointed by previous -> W
    subwf   compare, F  ; compare -= W

    btfsc   compare, 7  ; check if compare is positive (current >= previous)
    call    swap        ; swap current and previous if compare is negative (current < previous)

    goto    bubblesort_innerloop    ; repeat inner loop

; *** Bubblesort swap subroutine
swap
    ; Move value at register pointed by current to temp
    movf    current, W      ; current -> W
    movwf   FSR             ; W -> FSR
    movf    INDF, W         ; reg pointed by current -> W
    movwf   temp_current    ; W -> temp current

    ; Move value at register pointed by previous to register pointed by current
    movf    previous, W     ; previous -> W
    movwf   FSR             ; W -> FSR
    movf    INDF, W         ; reg pointed by previous -> W
    movwf   temp_previous   ; W -> temp previous

    movf    current, W          ; current -> W
    movwf   FSR                 ; W -> FSR
    movf    temp_previous, W    ; temp previous -> W
    movwf   INDF                ; W -> reg pointed by current

    ; Move value at temp to register pointed by previous
    movf    previous, W     ; previous -> W
    movwf   FSR             ; W -> FSR
    movf    temp_current, W ; temp current -> W
    movwf   INDF            ; W -> reg pointed by previous

    return


; *** Load test vector 0 subroutine
load_testvector0
    movlw	d'1'    ; W <- d'1'
	movwf	0x40    ; (0x40) <- W
	movlw	d'23'   ; W <- d'23'
	movwf	0x41    ; (0x41) <- W
	movlw	d'42'   ; W <- d'42'
	movwf	0x42    ; (0x42) <- W
	movlw	d'0'    ; W <- d'0'
	movwf	0x43    ; (0x43) <- W
	movlw	d'77'   ; W <- d'77'
	movwf	0x44    ; (0x44) <- W
	movlw	d'39'   ; W <- d'39'
	movwf	0x45    ; (0x45) <- W
	movlw	d'120'  ; W <- d'120'
	movwf	0x46    ; (0x46) <- W
	movlw	d'127'  ; W <- d'127'
	movwf	0x47    ; (0x47) <- W

	movlw	0x40    ; vector_address is loadad with the address where the first data is positioned
	movwf	vector_address
	movlw	d'8'    ; vector_length is loaded with the legnth of data
	movwf	vector_length

    return

; *** Load test vector 1 subroutine
load_testvector1
    movlw	d'1'	; W <- d'1'
	movwf	0x40	; (0x40) <- W
	movlw	d'23'	; W <- d'23'
	movwf	0x41	; (0x41) <- W
	movlw	d'42'	; W <- d'42'
	movwf	0x42	; (0x42) <- W
	movlw	d'0'	; W <- d'0'
	movwf	0x43	; (0x43) <- W
	movlw	d'70'	; W <- d'77'
	movwf	0x44	; (0x44) <- W
	movlw	d'39'	; W <- d'39'
	movwf	0x45	; (0x45) <- W
	movlw	d'120'	; W <- d'120'
	movwf	0x46	; (0x46) <- W
	movlw	d'127'	; W <- d'127'
	movwf	0x47	; (0x47) <- W
	movlw	d'15'	; W <- d'15'
	movwf	0x48	; (0x48) <- W
	movlw	d'93'	; W <- d'93'
	movwf	0x49	; (0x49) <- W
	movlw	d'14'	; W <- d'14'
	movwf	0x4A	; (0x4A) <- W
	movlw	d'70'	; W <- d'70'
	movwf	0x4B	; (0x4B) <- W
	movlw	d'85'	; W <- d'85'
	movwf	0x4C	; (0x4C) <- W
	movlw	d'15'	; W <- d'15'
	movwf	0x4D	; (0x4D) <- W
	movlw	d'32'	; W <- d'32'
	movwf	0x4E	; (0x4E) <- W
	movlw	d'120'	; W <- d'120'
	movwf	0x4F	; (0x4F) <- W

	movlw	0x40    ; vector_address is loadad with the address where the first data is positioned
	movwf	vector_address
	movlw	d'16'	; vector_length is loaded with the legnth of data
	movwf	vector_length

    return

; *** Load test vector 2 subroutine
load_testvector2
    movlw	d'32'   ; W <- d'32'
	movwf	0x40	; (0x40) <- W

	movlw	0x40    ; vector_address is loadad with the address where the first data is positioned
	movwf	vector_address
	movlw	d'1'    ; vector_length is loaded with the legnth of data
	movwf	vector_length

    return


	END ; directive 'end of program'
