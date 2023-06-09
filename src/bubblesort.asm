; *** FILE DATA ***
;   Filename: bubblesort.asm
;   Date: May 30, 2023
;   Version: 2.0
;
;   Author: Gianni Labella
;   Company: Universidad de Montevideo


; *** Processor Config ***
    list        p=16f877a       ; list directive to define processor
    #include    <p16f877a.inc>  ; processor specific variable definitions
    
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF


; *** Variable Definition ***
; Array variables
array_address  EQU 0x20
array_length   EQU 0x21

; Bubblesort variables
current_position                EQU 0x22
previous_position               EQU 0x23
last_swapped_position           EQU 0x24
current_position_value          EQU 0x25
previous_position_value         EQU 0x26
number_of_unsorted_positions    EQU 0x27


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

    call    bubblesort

loop
    goto    loop


; *** Bubblesort subroutine ***
bubblesort
    ; Initialize outer loop variables
    movf    array_length, W     ; Set the number of unsorted positions to the array length
    movwf   number_of_unsorted_positions

    ; Sort array
    call    bubblesort_outer_loop

    ; End of bubblesort subroutine
    return

; *** Bubblesort outer loop subroutine ***
bubblesort_outer_loop
    ; Initialize inner loop variables
    movf    array_address, W        ; Load W register with array_address

    movwf   previous_position       ; Initialize to array's first position
    movwf   last_swapped_position

    movwf   current_position        ; Initialize to array's second position
    incf    current_position, F

    ; Run inner loop
    call    bubblesort_inner_loop

    ; Update the number of unsorted positions given the last swapped position in inner loop
    ; (i.e. number_of_unsorted_positions = last_swapped_position - array_address)
    movf    array_address, W
    subwf   last_swapped_position, W
    movwf   number_of_unsorted_positions

    ; Repeat loop while there are unsorted positions
    ; While number_of_unsorted_positions >= 2
    ; (i.e. number_of_unsorted_positions - 2 >= 0)
    movlw   2
    subwf   number_of_unsorted_positions, W
    btfsc   STATUS, C                       ; Skip if borrowed (i.e. result is negative)
    goto    bubblesort_outer_loop           ; If result is positive, repeat loop
    return                                  ; If result is negative, break out of outer loop

; *** Bubblesort inner loop subroutine ***
bubblesort_inner_loop
    ; Loop while the current position is an unsorted position
    ; While current_position < array_address + number_of_unsorted_positions
    ; (i.e. current_position - (array_address + number_of_unsorted_positions) < 0
    movf    array_address, W
    addwf   number_of_unsorted_positions, W
    subwf   current_position, W
    btfsc   STATUS, C                       ; Skip if borrowed (i.e. result is negative)
    return                                  ; If result is positive, break out of inner loop

    ; Load value at current position for following operations,
    ; Value is loaded into current_position_value variable
    movf    current_position, W     ; Set indirect addressing pointer
    movwf   FSR
    movf    INDF, W                 ; Load value into variable
    movwf   current_position_value

    ; Load value at previous position for following operations,
    ; Value is loaded into previous_position_value variable
    movf    previous_position, W    ; Set indirect addressing pointer
    movwf   FSR
    movf    INDF, W                 ; Load value into variable
    movwf   previous_position_value

    ; Swap value at current position with value at previous position,
    ; If current_position_value < previous_position_value
    ; (i.e. current_position_value - previous_position_value < 0)
    subwf   current_position_value, W   ; Value at previous position loaded into W by previous operations
    btfss   STATUS, C                   ; Skip if not borrowed (i.e. result is positive)
    call    bubblesort_swap             ; If result is negative, swap values

    ; Update position variables and restart inner loop
    incf    current_position, F
    incf    previous_position, F
    goto    bubblesort_inner_loop

; *** Bubblesort swap subroutine ***
bubblesort_swap
    ; Move value at current position to previous position
    ; Indirect addressing pointer to previous position has already been set at value load
    movf    current_position_value, W   ; Move value into previous_position
    movwf   INDF    

    ; Move value at previous position to current position
    movf    current_position, W ; Set indirect addressing pointer
    movwf   FSR
    movf    previous_position_value, W  ; Move value into current_position
    movwf   INDF

    ; Update last swapped position to current position
    movf    current_position, W
    movwf   last_swapped_position

    ; End of swap subroutine
    return


; *** Load test array 0 subroutine ***
load_test_array_0
    movlw   d'1'
    movwf   0x40    
    movlw   d'23'   
    movwf   0x41    
    movlw   d'42'   
    movwf   0x42    
    movlw   d'0'    
    movwf   0x43    
    movlw   d'77'   
    movwf   0x44    
    movlw   d'39'   
    movwf   0x45    
    movlw   d'126'  
    movwf   0x46    
    movlw   d'127'  
    movwf   0x47    

    movlw   0x40            ; Load array_address with the address where the first data is positioned
    movwf   array_address
    movlw   d'8'
    movwf   array_length

    return

; *** Load test array 1 subroutine
load_test_array_1
    movlw   d'1'    
    movwf   0x40    
    movlw   d'23'   
    movwf   0x41    
    movlw   d'42'   
    movwf   0x42    
    movlw   d'0'    
    movwf   0x43    
    movlw   d'70'   
    movwf   0x44    
    movlw   d'39'   
    movwf   0x45    
    movlw   d'120'  
    movwf   0x46    
    movlw   d'127'  
    movwf   0x47    
    movlw   d'15'   
    movwf   0x48    
    movlw   d'93'   
    movwf   0x49    
    movlw   d'14'   
    movwf   0x4A    
    movlw   d'70'   
    movwf   0x4B    
    movlw   d'85'   
    movwf   0x4C    
    movlw   d'15'   
    movwf   0x4D    
    movlw   d'32'   
    movwf   0x4E    
    movlw   d'120'  
    movwf   0x4F    

    movlw   0x40            ; Load array_address with array's first position
    movwf   array_address
    movlw   d'16'
    movwf   array_length

    return

; *** Load test array 2 subroutine
load_test_array_2
    movlw   d'32'   
    movwf   0x40    

    movlw   0x40            ; Load array_address with array's first position
    movwf   array_address
    movlw   d'1'
    movwf   array_length

    return


    END ; directive 'end of program'
