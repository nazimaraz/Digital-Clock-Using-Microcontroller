list p = 16f877a
    #include p16f877a.inc
    __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
    ORG 0

D1 equ h'20'			    ; Delay variable
D2 equ h'21'			    ; Delay variable
D3 equ h'22'			    ; Delay variable
SECOND equ h'23'		    ; variable for second
MINUTE equ h'24'		    ; variable for minute
HOUR equ h'25'			    ; variable for hour
POSITION equ h'26'		    ; store the adjustuble number
DIVIDEND equ h'27'		    ; variable for dividend
DIVISOR equ h'28'		    ; variable for divisor
QUOTIENT equ h'29'		    ; variable for quotient
REMAINDER equ h'2A'		    ; variable for remainder
TEMP equ h'2B'			    ; variable for temp
TEMP2 equ h'2C'			    ; variable for another temp
TEMP_DIVIDEND equ h'2D'		    ; variable for temp using for dividend
TEMP_X equ h'2E'		    ; variable for temp using for display number
X equ h'2F'			    ; variable for display number
DL1 equ h'30'			    ; Delay variable
DL2 equ h'31'			    ; Delay variable
DL3 equ h'32'			    ; Delay variable
DISPLAY_ON equ h'33'		    ; store the which display turn on

 goto START			    ; goto START label

    org 4			    ; when the pressed SET button

bsf PORTB, 5			    ; set high 5th pin of PORTB
goto INTERRUPT			    ; goto INTERRUPT label

START
    bsf INTCON, 7		    ; Global interrupt enable
    bsf INTCON, 4		    ; RB0 Interrupt Enable
    bcf INTCON, 1		    ; Clear FLag Bit Just In Case

    clrf PORTB			    ; Clear PORTB
    clrf PORTC			    ; Clear PORTC
    clrf PORTD			    ; Clear PORTD

    bsf STATUS, RP0		    ; Switch the bank
    movlw b'00011111'		    ; Set some pins high for input
    movwf TRISB			    ; move the this value TRISB
    clrf TRISC			    ; Clear TRISC
    clrf TRISD			    ; Clear TRISD
    bcf STATUS, RP0		    ; Switch the bank

    clrf SECOND			    ; value of SECOND is d'0'
    clrf MINUTE			    ; value of MINUTE is d'0'
    clrf HOUR			    ; value of HOUR is d'0'

    bsf POSITION, 0

    call TURN_ON_DISPLAYS

MAIN
    call DELAY_ONE_SECOND

    call INCREMENT_SECOND

    call BLINK_LED

    goto MAIN

INCREMENT_SECOND
    incf SECOND, F		    ; increment SECOND per second
    btfss SECOND, 5
    return			    ; If SECOND is 0
    btfss SECOND, 4
    return
    btfss SECOND, 3
    return
    btfss SECOND, 2
    return

    clrf SECOND			    ; SECOND is now 0
    goto INCREMENT_MINUTE

INCREMENT_MINUTE
    incf MINUTE, F		    ; increment MINUTE

    movf MINUTE, W
    movwf X			    ; X = MINUTE
    call DISPLAY
    movwf PORTC

    btfss MINUTE, 5
    return
    btfss MINUTE, 4
    return
    btfss MINUTE, 3
    return
    btfss MINUTE, 2
    return

    clrf MINUTE
    movf MINUTE, W
    movwf X			    ; X = MINUTE
    call DISPLAY
    movwf PORTC
    goto INCREMENT_HOUR

INCREMENT_HOUR
    incf HOUR, F
    movf HOUR, W
    movwf X			    ; X = MINUTE
    call DISPLAY
    movwf PORTD
    btfss HOUR, 4
    return
    btfss HOUR, 3
    return

    clrf HOUR
    movf HOUR, W
    movwf X			    ; X = MINUTE
    call DISPLAY
    movwf PORTD
    return

TURN_OFF_0
    bcf DISPLAY_ON, 0

    bsf PORTC, 0
    bsf PORTC, 1
    bsf PORTC, 2
    bsf PORTC, 3

    return

TURN_ON_0
    bsf DISPLAY_ON, 0
    call LOAD_MINUTE
    return

TURN_OFF_1
    bcf DISPLAY_ON, 1

    bsf PORTC, 4
    bsf PORTC, 5
    bsf PORTC, 6
    bsf PORTC, 7

    return

TURN_ON_1
    bsf DISPLAY_ON, 1
    call LOAD_MINUTE
    return

LOAD_MINUTE
    movf MINUTE, W		    ; F is value of MINUTE
    movwf X
    call DISPLAY
    movwf PORTC

    return

TURN_OFF_2
    bcf DISPLAY_ON, 2

    bsf PORTD, 0
    bsf PORTD, 1
    bsf PORTD, 2
    bsf PORTD, 3

    return

TURN_ON_2
    bsf DISPLAY_ON, 2
    call LOAD_HOUR
    return

TURN_OFF_3
    bcf DISPLAY_ON, 3

    bsf PORTD, 4
    bsf PORTD, 5
    bsf PORTD, 6
    bsf PORTD, 7

    return

TURN_ON_3
    bsf DISPLAY_ON, 3
    call LOAD_HOUR
    return

LOAD_HOUR
    movf HOUR, W		    ; F is value of MINUTE
    movwf X
    call DISPLAY
    movwf PORTD

    return

NEXT_0
    btfss POSITION, 0
    goto NEXT_1
    btfss DISPLAY_ON, 0
    goto TURN_ON_0
    goto TURN_OFF_0
NEXT_1
    btfss POSITION, 1
    goto NEXT_2
    btfss DISPLAY_ON, 1
    goto TURN_ON_1
    goto TURN_OFF_1
NEXT_2
    btfss POSITION, 2
    goto NEXT_3
    btfss DISPLAY_ON, 2
    goto TURN_ON_2
    goto TURN_OFF_2
NEXT_3
    btfss POSITION, 3
    return
    btfss DISPLAY_ON, 3
    goto TURN_ON_3
    goto TURN_OFF_3

INTERRUPT
    call DELAY_A_LITTLE
    btfss PORTB, RB0
    goto LOOP			    ; If RB0 is 0
    goto INTERRUPT		    ; If RB0 is 1

LOOP
    movlw d'255'
    movwf DL1

BLINK_DISPLAY_LOOP_1
    movlw d'255'
    movwf DL2

BLINK_DISPLAY_LOOP_2
    movlw d'5'
    movwf DL3

BLINK_DISPLAY_LOOP_3
    btfsc PORTB, RB0
    goto EXIT_LOOP		    ; If RB0 is 1
    btfsc PORTB, RB1
    call UP			    ; If RB1 is 1
    btfsc PORTB, RB2		    ; If RB2 is 1
    call DOWN
    btfsc PORTB, RB3		    ; If RB3 is 1
    call RIGHT
    btfsc PORTB, RB4		    ; If RB4 is 1
    call LEFT

    decfsz DL3, F
    goto BLINK_DISPLAY_LOOP_3
    decfsz DL2, F
    goto BLINK_DISPLAY_LOOP_2
    decfsz DL1, F
    goto BLINK_DISPLAY_LOOP_1

    call NEXT_0

    goto LOOP

EXIT_LOOP
    call DELAY_A_LITTLE
    call TURN_ON_DISPLAYS
    clrf SECOND
    clrf POSITION
    bsf POSITION, 0

    bcf INTCON, 1
    retfie			    ; Come out of the interrupt routine

UP
    call DELAY_A_LITTLE

    btfsc POSITION, 0
    goto INCREMENT_0

    btfsc POSITION, 1
    goto INCREMENT_1

    btfsc POSITION, 2
    goto INCREMENT_2

    btfsc POSITION, 3
    goto INCREMENT_3

DOWN
    call DELAY_A_LITTLE

    btfsc POSITION, 0
    goto DECREMENT_0

    btfsc POSITION, 1
    goto DECREMENT_1

    btfsc POSITION, 2
    goto DECREMENT_2

    btfsc POSITION, 3
    goto DECREMENT_3

RIGHT
    call DELAY_A_LITTLE
    call TURN_ON_DISPLAYS
    btfsc POSITION, 0
    goto CLEAR_AND_PUSH_FOR_RIGHT
    rrf POSITION, F
    return

CLEAR_AND_PUSH_FOR_RIGHT
    clrf POSITION
    ;bcf POSITION, 0
    bsf POSITION, 3
    return

LEFT
    call DELAY_A_LITTLE
    call TURN_ON_DISPLAYS
    btfsc POSITION, 3
    goto CLEAR_AND_PUSH_FOR_LEFT
    rlf POSITION, F
    return

CLEAR_AND_PUSH_FOR_LEFT
    clrf POSITION
    ;bcf POSITION, 3
    bsf POSITION, 0
    return

INCREMENT_0
    movf MINUTE, W
    movwf DIVIDEND		;	    DIVIDEND = MINUTE

    movlw d'10'
    movwf DIVISOR		;	    DIVISOR = 10

    call DIVISION

    movf REMAINDER, W
    movwf TEMP			;	    TEMP = REMAINDER

    incf REMAINDER, 1		;	    REMAINDER += 1

    movf REMAINDER, W
    movwf DIVIDEND		;	    DIVIDEND = REMAINDER

    call DIVISION

    movf TEMP, W
    subwf MINUTE, W		;	    MINUTE -= TEMP
    movwf MINUTE

    movf REMAINDER, W
    addwf MINUTE, W		;	    MINUTE += REMAINDER
    movwf MINUTE

    movf MINUTE, W		    ; F is value of MINUTE
    movwf X
    call DISPLAY
    movwf PORTC

    return

INCREMENT_1
    movlw d'10'
    movwf TEMP
    movf TEMP, W

DECREMENT_1_CONT
    addwf MINUTE, W
    movwf MINUTE		;	    MINUTE += 10

    movf MINUTE, 0
    movwf DIVIDEND		;	    DIVIDEND = MINUTE

    movlw d'60'
    movwf DIVISOR		;	    DIVISOR = 60

    call DIVISION

    movf REMAINDER, 0		;	    REMAINDER = MINUTE % 60
    movwf MINUTE		;	    MINUTE = REMAINDER

    movf MINUTE, W
    movwf X
    call DISPLAY
    movwf PORTC

    return

INCREMENT_2
    movf HOUR, 0
    movwf DIVIDEND		;	    DIVIDEND = MINUTE

    movlw d'10'
    movwf DIVISOR		;	    DIVISOR = 10

    call DIVISION

    btfsc QUOTIENT, 1
    goto MORE_THAN_TWENTY

    movf HOUR, 0
    movwf DIVIDEND		;	    DIVIDEND = HOUR

    movlw d'10'
    movwf DIVISOR		;	    DIVISOR = 10

    call DIVISION

    movf REMAINDER, W
    subwf HOUR, W		;	    HOUR -= REMAINDER
    movwf HOUR

    incf REMAINDER, 1		;	    REMAINDER += 1

    movf REMAINDER, 0
    movwf DIVIDEND		;	    DIVIDEND = REMAINDER

    call DIVISION

    movf REMAINDER, W
    addwf HOUR, W		;	    HOUR += REMAINDER
    movwf HOUR

    movf HOUR, W
    movwf X
    call DISPLAY
    movwf PORTD

    return

MORE_THAN_TWENTY
    incf REMAINDER, 1

    movf REMAINDER, 0
    movwf DIVIDEND		    ;	    DIVIDEND = REMAINDER

    movlw d'4'
    movwf DIVISOR

    call DIVISION

    movlw d'20'
    movwf HOUR

    movf REMAINDER, W
    addwf HOUR, W		;	    MINUTE += REMAINDER
    movwf HOUR

    movf HOUR, W
    movwf X
    call DISPLAY
    movwf PORTD

    return

INCREMENT_3
    movf HOUR, 0
    movwf DIVIDEND		;	    DIVIDEND = MINUTE

    movlw d'10'
    movwf DIVISOR		;	    DIVISOR = 10

    movf DIVISOR, W
    addwf HOUR, W		;	    HOUR += DIVISOR (DIVISOR = 10)
    movwf HOUR

    call DIVISION

    movlw d'4'
    movwf TEMP

    movf TEMP, W
    subwf REMAINDER, W		;	    REMAINDER -= 4
    movwf REMAINDER
    btfss STATUS, 0
    goto LESS_THAN_FIVE
    movf HOUR, 0
    movwf DIVIDEND		;	    DIVIDEND = HOUR

    movlw d'20'
    movwf DIVISOR		;	    DIVISOR = 10

    call DIVISION

    movf REMAINDER, 0
    movwf HOUR

    movf HOUR, W
    movwf X
    call DISPLAY
    movwf PORTD

    return

LESS_THAN_FIVE
    movf HOUR, 0
    movwf DIVIDEND		;	    DIVIDEND = HOUR

    movlw d'30'
    movwf DIVISOR		;	    DIVISOR = 10

    call DIVISION

    movf REMAINDER, 0
    movwf HOUR

    movf HOUR, W
    movwf X
    call DISPLAY
    movwf PORTD

    return

DECREMENT_0
    movf MINUTE, 0
    movwf DIVIDEND		;54	    DIVIDEND = MINUTE

    movlw d'10'
    movwf DIVISOR		;	    DIVISOR = 10

    call DIVISION		;	    REMAINDER = 4

    movf REMAINDER, W
    subwf MINUTE, W		;50	    MINUTE -= REMAINDER (DIVISOR = 60)
    movwf MINUTE

    movlw d'1'
    movwf TEMP
    movf TEMP, W
    subwf REMAINDER, W		;	    REMAINDER -= 1
    movwf REMAINDER
    movlw d'9'
    btfss STATUS, 0
    movwf REMAINDER

    movf REMAINDER, W
    addwf MINUTE, W		;	    MINUTE += REMAINDER
    movwf MINUTE

    movf MINUTE, W
    movwf X
    call DISPLAY
    movwf PORTC

    return

DECREMENT_1
    movlw d'50'
    movwf TEMP
    movf TEMP, W

    goto DECREMENT_1_CONT

DECREMENT_2
    movf HOUR, 0
    movwf DIVIDEND		;	    DIVIDEND = HOUR

    movlw d'10'
    movwf DIVISOR		;	    DIVISOR = 10

    call DIVISION		;

    btfsc QUOTIENT, 1
    goto DEC_MORE_THAN_TWENTY

    movf REMAINDER, W
    subwf HOUR, W		;	    HOUR -= REMAINDER
    movwf HOUR

    movlw d'1'
    movwf TEMP
    movf TEMP, W
    subwf REMAINDER, W		;	    REMAINDER -= 1
    movwf REMAINDER
    movlw d'9'
    btfss STATUS, 0
    movwf REMAINDER
    movf REMAINDER, W
    addwf HOUR, W		;	    HOUR += REMAINDER
    movwf HOUR

    movf HOUR, W
    movwf X
    call DISPLAY
    movwf PORTD

    return

DEC_MORE_THAN_TWENTY
    movf REMAINDER, W
    subwf HOUR, W		;	    HOUR -= REMAINDER
    movwf HOUR

    movlw d'1'
    movwf TEMP
    movf TEMP, W
    subwf REMAINDER, W		;	    REMAINDER -= 1
    movwf REMAINDER
    movlw d'3'
    btfss STATUS, 0
    movwf REMAINDER
    movf REMAINDER, W
    addwf HOUR, W		;	    HOUR += REMAINDER
    movwf HOUR

    movf HOUR, W
    movwf X
    call DISPLAY
    movwf PORTD

    return

DECREMENT_3
    movlw d'10'
    movwf TEMP

    movf HOUR, 0
    movwf TEMP2		;	    TEMP2 = HOUR

    movf TEMP, W
    subwf TEMP2, W		;	    TEMP2 -= TEMP
    movwf TEMP2
    btfss STATUS, 0
    goto HOUR_IS_NEGATIVE

    movf TEMP2, 0
    movwf HOUR		;	    HOUR = TEMP2

    movf HOUR, W
    movwf X
    call DISPLAY
    movwf PORTD

    return

HOUR_IS_NEGATIVE
    ;;;;;;;;;;;;;;;;;
    movlw d'3'
    movwf TEMP

    movf HOUR, W
    subwf TEMP, W		;	    REMAINDER -= 4
    movwf TEMP
    btfss STATUS, 0
    goto LESS_THAN_THREE

    ;;;;;;;;;;;;;;;;;

    movlw d'20'
    movwf TEMP

CONT_DEC_3

    movf TEMP, W
    addwf HOUR, W		;	    HOUR += TEMP
    movwf HOUR

    movf HOUR, W
    movwf X
    call DISPLAY
    movwf PORTD

    return

LESS_THAN_THREE
    movlw d'10'
    movwf TEMP

    goto CONT_DEC_3

TURN_ON_DISPLAYS
    call TURN_ON_0
    call TURN_ON_1
    call TURN_ON_2
    call TURN_ON_3
    return

BLINK_LED
    btfss PORTB, 5		    ; check 5th pin of PORTB
    goto $ + 3			    ; if the pin is LOW then pin is HIGH
    bcf PORTB, 5		    ; if the pin is HIGH then pin is LOW
    goto $ + 2
    bsf PORTB, 5
    return

DIVISION
    clrf QUOTIENT
DIVISION_CONT
    movf DIVIDEND, W		; h'2E'
    movwf REMAINDER		; h'31'	    REMAINDER = DIVIDEND
    movwf TEMP_DIVIDEND		; h'33'	    TEMP_DIVIDEND = DIVIDEND

    movf DIVISOR, W		; h'2F'

    subwf TEMP_DIVIDEND, W;	    TEMP_DIVIDEND -= DIVISOR
    movwf TEMP_DIVIDEND
    btfsc STATUS, 0
    goto INCREMENT_QUOTIENT
    return

INCREMENT_QUOTIENT
    movf TEMP_DIVIDEND, W
    movwf DIVIDEND		;	    DIVIDEND = TEMP_DIVIDEND

    incf QUOTIENT, F		; h'30'	    QUOTIENT += 1
    goto DIVISION_CONT


DELAY_A_LITTLE
    movlw d'255'
    movwf D1

LOOP1
    movlw d'255'
    movwf D2

LOOP2
    movlw d'25'
    movwf D3

LOOP3
    decfsz D3, F
    goto LOOP3
    decfsz D2, F
    goto LOOP2
    decfsz D1, F
    goto LOOP1

    return

DELAY_ONE_SECOND
    movlw d'255'
    movwf D1

DONGU1
    movlw d'239'
    movwf D2

DONGU2
    movlw d'26'
    movwf D3

DONGU3
    decfsz D3, F
    goto DONGU3
    decfsz D2, F
    goto DONGU2
    decfsz D1, F
    goto DONGU1

    return

DISPLAY
    clrf TEMP_X
    movf X, W
    movwf DIVIDEND

    movlw d'10'
    movwf DIVISOR

    call DIVISION

    movlw d'7'
    movwf TEMP

DISPLAY_CONT
    decfsz TEMP, F
    goto TEMP_IS_NOT_0

    movf TEMP_X, W
    addwf X, W
    movwf X
    swapf X, 1
    return

TEMP_IS_NOT_0
    movf QUOTIENT, W
    addwf TEMP_X, W		;	    TEMP_X += QUOTIENT
    movwf TEMP_X
    goto DISPLAY_CONT

    end
