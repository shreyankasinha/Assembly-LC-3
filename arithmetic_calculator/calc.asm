
.ORIG x3000
	
; In this MP, subroutines were constructed to handle individual computations. 
; If the input character was determined to be a number, it was pushed to the stack. 
; Additionally, an assessment was made to identify whether an operand had been provided, and if so, two values were popped from the stack. 
; The subroutine was subsequently invoked based on the operand, and its computed answer was pushed onto the stack. 
; Ultimately, a single value remained on the stack at the conclusion of the process, and this value was printed to the screen.
	

	
	JSR EVALUATE
	AND R3, R3, #0
	ADD R3, R5, #0
	JSR PRINT_HEX

TERMINATE HALT;

	
;input R3, R4
;out R5-answer
POW	
	ST R7, POW_SAVER7	;save R7
	ST R3, POW_SAVER3   ;
	ST R4, POW_SAVER4   ;
	NOT R4, R4 		;R4 = -R4
	ADD R4, R4, #1		;R4 = -R4
	AND R2, R2, #0      ;
	ADD R2, R2, R3      ;

POW_LOOP	
			ST R4, POW_SAVER4_AGAIN
			AND R4, R4, #0      ; Copying R2 into R3 for the multiplication
			ADD R4, R4, R2      ; Copying R2 into R3 for the multiplication
			JSR MULT
			AND R3, R3, #0      ; Copying the multiplication result into R5
			ADD R3, R3, R0      ; 
			ADD R3, R3, R5      ; Copying the multiplication result into R5
			LD R4, POW_SAVER4_AGAIN
            ADD R4, R4, #1 		;increment counter
	        BRn POW_LOOP		;loop until R1 is negative
			
			ST R4, POW_SAVER4_AGAIN
			AND R4, R4, #0      ; Copying R2 into R4 for the multiplication
			ADD R4, R4, R2      ; Copying R2 into R4 for the multiplication
			JSR DIV
			AND R3, R3, #0      ; Copying the multiplication result into R5
			ADD R3, R3, R0      ; 
			ADD R3, R3, R5      ; Copying the multiplication result into R5
			LD R4, POW_SAVER4_AGAIN

	NOT R4, R4		    ; R4 = R4
	ADD R4, R4, #1		; R4 = R4
	
	AND R0, R0, #0      ; Clears R0 for the push
	ADD R0, R0, R3      ; Copies R3 into R0 for the push
	
	LD R7, POW_SAVER7	;save R7
	LD R3, POW_SAVER3   ;
	LD R4, POW_SAVER4   ;
	LD R2, POW_SAVER2   ;
	RET
	
POW_SAVER7 .BLKW #1
POW_SAVER3 .BLKW #1
POW_SAVER4 .BLKW #1
POW_SAVER2 .BLKW #1
POW_SAVER4_AGAIN .BLKW #1

number_2 .FILL x0002
number_3 .FILL x0003
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R3- value to print in hexadecimal
PRINT_HEX
	   ST R0, HEX_SAVE_R0	; Save R0 before modifying
	   ST R1, HEX_SAVE_R1	; Save R1 before modifying
	   ST R2, HEX_SAVE_R2	; Save R2 before modifying
	   ST R7, HEX_SAVE_R7	; Save R3 before modifying
	   AND R1,R1,#0         ; Initialize Digit Counter
	   ADD R1,R1,#-4

NEXT_DIGIT BRzp DONE		; Checks if digit counter is done

           AND R0,R0,#0 	; Initialize Current Digit
           AND R2,R2,#0 	; Initialize Bit Counter
	   ADD R2,R2,#-4	; Initializing bit counter to run through four bits

NEXT_BIT   BRzp CONVRT_ASC	; Checks if ready to move to Conver ASCII
           ADD R0,R0,R0		; Left Shifts R0
	   ADD R3,R3,#0		; Left Shifts R3
           BRzp ADD_0		; Checks if R3 is Positive or Negative
           ADD R0,R0,#1		; Adds 1
ADD_0	   ADD R0,R0,#0		; Adds 0
	   ADD R3,R3,R3		; Left Shifts R3
           ADD R2,R2,#1		; Increments bit counter
           BRnzp NEXT_BIT	; Moves to next bit

CONVRT_ASC ADD R0,R0, #-9	; Checks if char is number or letter
           BRnz NUMBER		; Checks if char is number or letter
           ADD R0,R0, #9	; Readds 9 from checking if num or letter
	   ADD R0,R0, #15	; Adds 'A'
           ADD R0,R0, #15	; Adds 'A'
           ADD R0,R0, #15	; Adds 'A'
           ADD R0,R0, #15	; Adds 'A'
           ADD R0,R0, #5	; Adds 'A'
           ADD R0,R0, #-10	; Adds 'A' - 10
           BRnzp DISPLAY	; Go to Display

NUMBER     ADD R0,R0, #9	; Readds 9 from checking if num or letter
	   ADD R0,R0, #15	; Adds '0'
           ADD R0,R0, #15	; Adds '0'
           ADD R0,R0, #15	; Adds '0'
           ADD R0,R0, #3	; Adds '0'

DISPLAY    OUT			; prints the character
           ADD R1,R1,#1		; increments digit counter
           BRn NEXT_DIGIT	; Moves to the next set of 4 bits (next digit)

DONE	   LD R0, HEX_SAVE_R0	; Restores modified register
	   LD R1, HEX_SAVE_R1	; Restores modified register
	   LD R2, HEX_SAVE_R2	; Restores modified register
	   LD R7, HEX_SAVE_R7	; Restores modified register
	   RET			; Returns back to the main code

HEX_SAVE_R0	.BLKW #1
HEX_SAVE_R1	.BLKW #1
HEX_SAVE_R2	.BLKW #1
HEX_SAVE_R7	.BLKW #1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - character input from keyboard
;R6 - current numerical output
;
;
EVALUATE
ST R7, EVALUATE_SAVER7


INPUT     AND R0, R0, #0                    ; Initialise R0 to 0
          IN                                ; Read and echo input
          LD R1, EQUAL_SIGN                 ; Checks if the input has encountered an equal sign
          NOT R1, R1                        ; Takes the two's complement of R1
          ADD R1, R1, #1                    ; Takes the two's complement of R1
          ADD R1, R1, R0                    ; Performs R1 = R0 - R1
          BRz INPUT_DONE                    ; An equal sign has been entered, end program
          LD R1, SPACE                      ; Checks if the input has encountered a space
          NOT R1, R1                        ; Takes the two's complement of R1
          ADD R1, R1, #1                    ; Takes the two's complement of R1
          ADD R1, R1, R0                    ; Performs R1 = R0 - R1
          BRz INPUT                         ; A space has been entered, take next input
		  ST R0, EVALUATE_SAVER0
		  ADD R0, R0, #-15
		  ADD R0, R0, #-15
		  ADD R0, R0, #-15
		  ADD R0, R0, #-3
		  BRn MOVE_ON
		  ADD R0, R0, #-9
          BRnz eval_NUMBER                  ; Goes to number
		 
MOVE_ON	   LD R0, EVALUATE_SAVER0
           LD R1, PLUS_SIGN                  ; Checks if the input has encountered a plus
          NOT R1, R1                        ; Takes the two's complement of R1
          ADD R1, R1, #1                    ; Takes the two's complement of R1
          ADD R1, R1, R0                    ; Performs R1 = R0 - R1
          BRz ADDITION                      ; 
		  LD R1, MINUS_SIGN                 ; Checks if the input has encountered a minus
          NOT R1, R1                        ; Takes the two's complement of R1
          ADD R1, R1, #1                    ; Takes the two's complement of R1
          ADD R1, R1, R0                    ; Performs R1 = R0 - R1
          BRz MINUS                         ; 
		  LD R1, MULTIPLICATION_SIGN   ; Checks if the input has encountered a MULTIPLICATION
          NOT R1, R1                        ; Takes the two's complement of R1
          ADD R1, R1, #1                    ; Takes the two's complement of R1
          ADD R1, R1, R0                    ; Performs R1 = R0 - R1
          BRz MULTIPLICATION                ; 
		  LD R1, DIVISION_SIGN              ; Checks if the input has encountered a DIVISION
          NOT R1, R1                        ; Takes the two's complement of R1
          ADD R1, R1, #1                    ; Takes the two's complement of R1
          ADD R1, R1, R0                    ; Performs R1 = R0 - R1
          BRz DIVISION                      ; 
		  LD R1, POWER_SIGN                 ; Checks if the input has encountered a POWER
          NOT R1, R1                        ; Takes the two's complement of R1
          ADD R1, R1, #1                    ; Takes the two's complement of R1
          ADD R1, R1, R0                    ; Performs R1 = R0 - R1
          BRz POWER                         ; 

INVALID	  LEA R0, INVALID_EXP
          PUTS 
          BRnzp TERMINATE
		  
		  
eval_NUMBER 
           ADD R0, R0, #9
           JSR PUSH
		   BRnzp INPUT
		   
ADDITION   JSR POP
           ADD R5, R5, #0
		   BRp INVALID
           ADD R4, R0, #0
		   JSR POP
		   ADD R5, R5, #0
		   BRp INVALID
		   ADD R3, R0, #0
           JSR PLUS
		   JSR PUSH
		   BRnzp INPUT

MINUS   JSR POP
           ADD R5, R5, #0
		   BRp INVALID
           ADD R4, R0, #0
		   JSR POP
		   ADD R5, R5, #0
		   BRp INVALID
		   ADD R3, R0, #0
           JSR MIN
		   JSR PUSH
		   BRnzp INPUT

MULTIPLICATION   JSR POP
           ADD R5, R5, #0
		   BRp INVALID
           ADD R4, R0, #0
		   JSR POP
		   ADD R5, R5, #0
		   BRp INVALID
		   ADD R3, R0, #0
           JSR MULT
		   JSR PUSH
		   BRnzp INPUT
		   
DIVISION   JSR POP
           ADD R5, R5, #0
		   BRp INVALID
           ADD R4, R0, #0
		   JSR POP
		   ADD R5, R5, #0
		   BRp INVALID
		   ADD R3, R0, #0
           JSR DIV
		   JSR PUSH
		   BRnzp INPUT
		   
POWER   JSR POP
           ADD R5, R5, #0
		   BRp INVALID
           ADD R4, R0, #0
		   JSR POP
		   ADD R5, R5, #0
		   BRp INVALID
		   ADD R3, R0, #0
           JSR POW
		   JSR PUSH
		   BRnzp INPUT
		  
INPUT_DONE LD R2, STACK_TOP                 ; Load STACK_TOP to R2
		   LD R3, STACK_START               ; Load STACK_START to R3
		   NOT R2, R2                       ; Takes the two's complement of R3
		   ADD R2, R2, #1                   ; Takes the two's complement of R3
		   ADD R3, R3, R2                   ; R3 = R3 - R2
		   ADD R3, R3, #-1
		   BRz FINAL
		   BRnzp INVALID
		   
FINAL   JSR POP
        ADD R5, R0, #0
		   
eval_DONE    LD R7, EVALUATE_SAVER7  
        RET
SPACE         .FILL x0020
EQUAL_SIGN     .FILL x003D
PLUS_SIGN      .FILL x002B
MINUS_SIGN          .FILL x002D
MULTIPLICATION_SIGN .FILL x002A
DIVISION_SIGN       .FILL x002F
POWER_SIGN          .FILL x005E
INVALID_EXP .STRINGZ "Invalid Expression"

EVALUATE_SAVER7  .BLKW #1
EVALUATE_SAVER0  .BLKW #1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
PLUS	
;your code goes here
	ST R7, ADD_SAVER7	; Save R7
	ST R6, ADD_SAVER6	; Save R6
	ST R4, ADD_SAVER4	; Save R1
	ST R3, ADD_SAVER3	; Save R0

	AND R5, R5, #0		; Initialize R5
	ADD R0, R3, R4		; Add two numbers	
	ADD R5, R0, #0		; Move result to R5
	
	LD R7, ADD_SAVER7	; Restore registers
	LD R6, ADD_SAVER6	;
	LD R4, ADD_SAVER4	;
	LD R3, ADD_SAVER3	;
	
	RET

ADD_SAVER7 .BLKW #1		
ADD_SAVER6 .BLKW #1
ADD_SAVER4 .BLKW #1
ADD_SAVER3 .BLKW #1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MIN	
;your code goes here
	ST R7, MIN_SAVER7	; Save R7
	ST R6, MIN_SAVER6	; Save R6
	ST R4, MIN_SAVER4	; Save R4
	ST R3, MIN_SAVER3	; Save R3


	AND R5, R5, #0		; Initialize R5
	
	NOT R4, R4		; Negate R1
	ADD R4, R4, #1		;
	ADD R0, R3, R4		; Subtract two numbers

	LD R7, MIN_SAVER7	; Restore registers
	LD R6, MIN_SAVER6	;
	LD R4, MIN_SAVER4	;
	LD R3, MIN_SAVER3	;
	
	RET

MIN_SAVER7 .BLKW #1
MIN_SAVER6 .BLKW #1
MIN_SAVER4 .BLKW #1
MIN_SAVER3 .BLKW #1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MULT	
;your code goes here
	ST R7, MULT_SAVER7	; Save R7
	ST R3, MULT_SAVER3   ;
	ST R4, MULT_SAVER4   ;
	ST R2, MULT_SAVER2   ; 
	AND R0, R0, #0		;initialize R0 (answer)
	NOT R4, R4 		    ;R4 = -R4
	ADD R4, R4, #1		;R4 = -R4
	AND R2, R2, #0      ;
	ADD R2, R2, R3      ;

MULT_LOOP	ADD R3, R3, R2		;R3 = R3 + R2
            ADD R4, R4, #1 		;increment counter
	        BRn MULT_LOOP		;loop until R1 is negative
			
			NOT R2, R2          ;Two's complement of R2  
			ADD R2, R2, #1      ;Two's complement of R2  
			ADD R3, R3, R2      ;subtracting the extra iteration from answer

	NOT R4, R4		    ; R4 = R4
	ADD R4, R4, #1		; R4 = R4
	
	AND R0, R0, #0      ; Clears R0 for the push
	ADD R0, R0, R3      ; Copies R3 into R0 for the push
	
	LD R7, MULT_SAVER7	;save R7
	LD R3, MULT_SAVER3   ;
	LD R4, MULT_SAVER4   ;
	LD R2, MULT_SAVER2   ;
	RET
	
MULT_SAVER7 .BLKW #1
MULT_SAVER3 .BLKW #1
MULT_SAVER4 .BLKW #1
MULT_SAVER2 .BLKW #1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
DIV	
;your code goes here
	ST R2, DIV_SAVER2	; save R2
	ST R7, DIV_SAVER7	; save R7
	ST R3, DIV_SAVER3   	; save R3

	AND R0, R0, #0		; initialize R0 (quotient)
	AND R1, R1, #0 		; initialize R1 (remainder)
	ADD R1, R1, R3		; initializing R1 to R3
	NOT R4, R4 		; R4 = -R4
	ADD R4, R4, #1		; R4 = -R4

LOOP	ADD R0, R0, #1 		; increment quotient
	ADD R1, R1, R4		; R1 = R1 - R4
	BRzp LOOP		; loop until R1 is negative

	NOT R4, R4		; R4 = R4
	ADD R4, R4, #1		; R4 = R4
	ADD R1, R1, R4		; cleanup R1
	AND R2, R2, #0     	; Clears R2 temporarily
	ADD R2, R2, R0     	; Copies R0 (quotient) into R2 temporarily
	AND R0, R0, #0     	; Clears R0 for the push
	ADD R0, R0, R1      	; Copies R1 into R0 for the push
	ADD R2, R2, #-1		; decrement quotient
	AND R0, R0, #0      	;
	ADD R0, R0, R2     	; copies quotient into R0
	
	LD R7, DIV_SAVER7	; restore R7
	LD R3, DIV_SAVER3   	; restores R3
	LD R2, DIV_SAVER2	; restores R2
	RET

DIV_SAVER3  	.BLKW #1    	; saves previous R3
DIV_SAVER7 	.BLKW #1	; saves previous R7
DIV_SAVER2	.BLKW #1	; saves previous R2
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
EXP
;your code goes here
	
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH	
	ST R3, PUSH_SaveR3	;save R3
	ST R4, PUSH_SaveR4	;save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACk_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz OVERFLOW		;stack is full
	STR R0, R4, #0		;no overflow, store value in the stack
	ADD R4, R4, #-1		;move top of the stack
	ST R4, STACK_TOP	;store top of stack pointer
	BRnzp DONE_PUSH		;
OVERFLOW
	ADD R5, R5, #1		;
DONE_PUSH
	LD R3, PUSH_SaveR3	;
	LD R4, PUSH_SaveR4	;
	RET


PUSH_SaveR3	.BLKW #1	;
PUSH_SaveR4	.BLKW #1	;


;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP	
	ST R3, POP_SaveR3	;save R3
	ST R4, POP_SaveR4	;save R3
	AND R5, R5, #0		;clear R5
	LD R3, STACK_START	;
	LD R4, STACK_TOP	;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz UNDERFLOW		;
	ADD R4, R4, #1		;
	LDR R0, R4, #0		;
	ST R4, STACK_TOP	;
	BRnzp DONE_POP		;
UNDERFLOW
	ADD R5, R5, #1		;
DONE_POP
	LD R3, POP_SaveR3	;
	LD R4, POP_SaveR4	;
	RET


POP_SaveR3	.BLKW #1	;
POP_SaveR4	.BLKW #1	;
STACK_END	.FILL x3FF0	;
STACK_START	.FILL x4000	;
STACK_TOP	.FILL x4000	;


.END
