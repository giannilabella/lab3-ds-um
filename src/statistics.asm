; *** FILE DATA ***
;   Filename: statistics.asm
;   Date: June 6, 2023
;   Version: 1.0
;
;   Author: Gianni Labella
;   Company: Universidad de Montevideo

; *** Processor Config ***
    list		p=16f877a       ; list directive to define processor
    #include	<p16f877a.inc>  ; processor specific variable definitions

    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF


; *** Variable Definition ***
; Array variables
array_address   EQU 0x20
array_length    EQU 0x21

; Statistics variables
array_minimum           EQU 0x22
array_maximum           EQU 0x23
array_average           EQU 0x24

current_position        EQU 0x25
current_position_value  EQU 0x26
array_sum_high          EQU 0x27
array_sum_low           EQU 0x28
divisions_counter       EQU 0x29


; *** Reset Config ***
    ORG     0x000   ; processor reset vector

    nop             ; nop required for icd
  	goto    main    ; go to beginning of program


; *** Interrupt Config ***
    ORG     0x004   ; interrupt vector location

    retfie          ; return from interrupt


; *** Main Routine ***
main
    call    load_test_array_0
    ; call    load_test_array_1
    ; call    load_test_array_2

    call    statistics

loop
    goto    loop

; *** Statistics subroutine ***
statistics
    ; Initialize loop variables
    movf    array_address, W

    movwf   current_position    ; Initialize to array's second position
    incf    current_position, F

    movwf   FSR                 ; Initialize to array's first value
    movf    INDF, W
    movwf   array_minimum
    movwf   array_maximum
    movwf   array_sum_low

    clrf    array_sum_high      ; Initialize with value 0

    ; Loop over array
    call    statistics_loop

    ; Calculate average
    ; Rotate right array_sum_high and array_sum_low n times
    ; Since array_length is a power of 2, n = log_2 array_length
    ; Value of n is also the number of divisions by 2 required to make array_length equal 1
    movf    array_length, W
    movwf   divisions_counter
    
avg ; Loop while division counter is bigger than 1
    rrf     array_sum_high, F   ; Divide array_sum by 2
    rrf     array_sum_low, F

    ; If there are remaining division restart loop
    bcf     STATUS, C
    rrf     divisions_counter, F
    decfsz  divisions_counter, W    ; Skip if zero
    goto    avg                     ; If result is not zero, restart average loop

    ; Set array_average after array_sum division
    movf    array_sum_low, W
    movwf   array_average

    return

; *** Statistics loop subroutine ***
statistics_loop
    ; Loop while the current position is inside array
    ; While current_position < array_address + array_length
    ; (i.e. current_position - (array_address + array_length) < 0)
    movf    array_address, W
    addwf   array_length, W
    subwf   current_position, W
    btfsc   STATUS, C   ; Skip if borrowed (i.e. result is negative)
    return              ; If result is positive, break out of loop

    ; Load current position value for following operations
    movf    current_position, W
    movwf   FSR
    movf    INDF, W
    movwf   current_position_value

min ; Set minimum to current position value,
    ; If current_position_value < minimum
    ; (i.e. current_position_value - minimum < 0)
    movf    array_minimum, W
    subwf   current_position_value, W
    btfsc   STATUS, C                   ; Skip if borrowed (i.e. result is negative)
    goto    max                         ; If result is positive, go to maximum subroutine

    movf    current_position_value, W   ; If result is negative, set minimum and skip maximum subroutine
    movwf   array_minimum
    goto    sum


max ; Set maximum to currrent position value,
    ; If current_position_value > maximum
    ; (i.e. maximum - current_position_value < 0)
    movf    current_position_value, W
    subwf   array_maximum, W
    btfsc   STATUS, C                   ; Skip if borrowed (i.e. result is negative)
    goto    sum                         ; If result is positive, go to summation subroutine

    movf    current_position_value, W   ; If result is negative, set maximum
    movwf   array_maximum

sum ; Add current position value to array sum,
    ; If array_sum_low overflows increment array_sum_high
    ; (i.e. carry bit is set)
    movf    current_position_value, W
    addwf   array_sum_low

    btfsc   STATUS, C
    incf    array_sum_high  ; If array_sum_low overflowed increment array_sum_high

    ; Update current position variable and restart loop
    incf    current_position, F
    goto    statistics_loop


; *** Load test array 0 subroutine ***
load_test_array_0
    movlw	d'1'
    movwf	0x40    
    movlw	d'23'   
    movwf	0x41    
    movlw	d'42'   
    movwf	0x42    
    movlw	d'0'    
    movwf	0x43    
    movlw	d'77'   
    movwf	0x44    
    movlw	d'39'   
    movwf	0x45    
    movlw	d'126'  
    movwf	0x46    
    movlw	d'127'  
    movwf	0x47    

    movlw	0x40            ; array_address is loadad with the address where the first data is positioned
    movwf	array_address
    movlw	d'8'
    movwf	array_length

    return

; *** Load test array 1 subroutine
load_test_array_1
    movlw	d'1'	
    movwf	0x40	
    movlw	d'23'	
    movwf	0x41	
    movlw	d'42'	
    movwf	0x42	
    movlw	d'0'	
    movwf	0x43	
    movlw	d'70'	
    movwf	0x44	
    movlw	d'39'	
    movwf	0x45	
    movlw	d'120'	
    movwf	0x46	
    movlw	d'127'	
    movwf	0x47	
    movlw	d'15'	
    movwf	0x48	
    movlw	d'93'	
    movwf	0x49	
    movlw	d'14'	
    movwf	0x4A	
    movlw	d'70'	
    movwf	0x4B	
    movlw	d'85'	
    movwf	0x4C	
    movlw	d'15'	
    movwf	0x4D	
    movlw	d'32'	
    movwf	0x4E	
    movlw	d'120'	
    movwf	0x4F	

    movlw	0x40            ; array_address is loaded with array's first position
    movwf	array_address
    movlw	d'16'
    movwf	array_length

    return

; *** Load test array 2 subroutine
load_test_array_2
    movlw	d'32'   
    movwf	0x40	

    movlw	0x40            ; array_address is loaded with array's first position
    movwf	array_address
    movlw	d'1'
    movwf	array_length

    return


    END ; directive 'end of program'
