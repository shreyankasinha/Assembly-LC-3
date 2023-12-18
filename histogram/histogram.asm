; ss189
; The code given to you here implements the histogram calculation that 
; we developed in class.  In programming lab, we will add code that
; prints a number in hexadecimal to the monitor.
;
; Your assignment for this program is to combine these two pieces of 
; code to print the histogram to the monitor.
;
; If you finish your program, 
;    ** commit a working version to your repository  **
;    ** (and make a note of the repository version)! **


	.ORIG	x3000		; starting address is x3000


;
; Count the occurrences of each letter (A to Z) in an ASCII string 
; terminated by a NUL character.  Lower case and upper case should 
; be counted together, and a count also kept of all non-alphabetic 
; characters (not counting the terminal NUL).
;
; The string starts at x4000.
;
; The resulting histogram (which will NOT be initialized in advance) 
; should be stored starting at x3F00, with the non-alphabetic count 
; at x3F00, and the count for each letter in x3F01 (A) through x3F1A (Z).
;
; table of register use in this part of the code
;    R0 holds a pointer to the histogram (x3F00)
;    R1 holds a pointer to the current position in the string
;       and as the loop count during histogram initialization
;    R2 holds the current character being counted
;       and is also used to point to the histogram entry
;    R3 holds the additive inverse of ASCII '@' (xFFC0)
;    R4 holds the difference between ASCII '@' and 'Z' (xFFE6)
;    R5 holds the difference between ASCII '@' and '`' (xFFE0)
;    R6 is used as a temporary register
;

	LD R0,HIST_ADDR      	; point R0 to the start of the histogram
	
	; fill the histogram with zeroes 
	AND R6,R6,#0		; put a zero into R6
	LD R1,NUM_BINS		; initialize loop count to 27
	ADD R2,R0,#0		; copy start of histogram into R2

	; loop to fill histogram starts here
HFLOOP	STR R6,R2,#0		; write a zero into histogram
	ADD R2,R2,#1		; point to next histogram entry
	ADD R1,R1,#-1		; decrement loop count
	BRp HFLOOP		; continue until loop count reaches zero

	; initialize R1, R3, R4, and R5 from memory
	LD R3,NEG_AT		; set R3 to additive inverse of ASCII '@'
	LD R4,AT_MIN_Z		; set R4 to difference between ASCII '@' and 'Z'
	LD R5,AT_MIN_BQ		; set R5 to difference between ASCII '@' and '`'
	LD R1,STR_START		; point R1 to start of string

	; the counting loop starts here
COUNTLOOP
	LDR R2,R1,#0		; read the next character from the string
	BRz PRINT_HIST		; found the end of the string

	ADD R2,R2,R3		; subtract '@' from the character
	BRp AT_LEAST_A		; branch if > '@', i.e., >= 'A'
NON_ALPHA
	LDR R6,R0,#0		; load the non-alpha count
	ADD R6,R6,#1		; add one to it
	STR R6,R0,#0		; store the new non-alpha count
	BRnzp GET_NEXT		; branch to end of conditional structure
AT_LEAST_A
	ADD R6,R2,R4		; compare with 'Z'
	BRp MORE_THAN_Z         ; branch if > 'Z'

; note that we no longer need the current character
; so we can reuse R2 for the pointer to the correct
; histogram entry for incrementing
ALPHA	ADD R2,R2,R0		; point to correct histogram entry
	LDR R6,R2,#0		; load the count
	ADD R6,R6,#1		; add one to it
	STR R6,R2,#0		; store the new count
	BRnzp GET_NEXT		; branch to end of conditional structure

; subtracting as below yields the original character minus '`'
MORE_THAN_Z
	ADD R2,R2,R5		; subtract '`' - '@' from the character
	BRnz NON_ALPHA		; if <= '`', i.e., < 'a', go increment non-alpha
	ADD R6,R2,R4		; compare with 'z'
	BRnz ALPHA		; if <= 'z', go increment alpha count
	BRnzp NON_ALPHA		; otherwise, go increment non-alpha

GET_NEXT
	ADD R1,R1,#1		; point to next character in string
	BRnzp COUNTLOOP		; go to start of counting loop



PRINT_HIST 

; you will need to insert your code to print the histogram here

; do not forget to write a brief description of the approach/algorithm
; for your implementation, list registers used in this part of the code,
; and provide sufficient comments

; Subroutine Register Table
; R0 holds digit character 
; R1 digit counter 
; R2 bit counter 
; R3 as pointer for character frequency memory address + holds frequency of character 
; R4 offset counter
; R5 hold hex value of character
; '@-->z' counter
	
	ST R3, SAVE_R3		; Saves registers before modifying
	ST R4, SAVE_R4		
	ST R5, SAVE_R5		
	LDI R3, HIST_ADDR	; Indirect memory load of @ into R2
	LD R5, BIN_START	; Direct load of @ character into R4

	AND R6, R6, #0 		; Clearing R6 with 0
	ADD R6, R6, #15 	; Initializing it to 27
	ADD R6, R6, #12		; 27 =15+12, max value in one step is 15.

	AND R4, R4, #0		; Initialize offset counter

LOOP	ADD R4, R4, #1		; Adding 1 to R5. (offset counter)
	ADD R6, R6, #-1		; Adding -1 to ASCII char counter
	BRn OVER		; Checks if '@-->Z' counter is done
	JSR SUBTR		; Calls for subroutine to print hexadecimal value
	LD R0, NEWLINE		; Loads newline character into R0
	OUT			; Prints newline character
	LD R3, HIST_ADDR	; Loads memory address of frequency for '@' into R3
	LD R5, BIN_START	; Loads hex of '@' into R5
	ADD R3, R3, R4		; Increments memory address of frequency for the character
	ADD R5, R5, R4		; Increments character hex value by offset
	LDR R3, R3, #0		; Loads new character into R3
	BRnzp LOOP		; Loops back

	LD R3, SAVE_R3		; Restores Register Values 
	LD R4, SAVE_R4		
	LD R5, SAVE_R5		
OVER	HALT 			; done

; the data needed by the program
NUM_BINS	.FILL #27	; 27 loop iterations
NEG_AT		.FILL xFFC0	; the additive inverse of ASCII '@'
AT_MIN_Z	.FILL xFFE6	; the difference between ASCII '@' and 'Z'
AT_MIN_BQ	.FILL xFFE0	; the difference between ASCII '@' and '`'
HIST_ADDR	.FILL x3F00     ; histogram starting address
STR_START	.FILL x4000	; string starting address
NEWLINE 	.FILL x000A     ; new line character
BIN_START	.FILL x0040     ; @ character
SPACE		.FILL x0020	; Space character

; for testing, you can use the lines below to include the string in this
; program...
; STR_START	.FILL STRING	; string starting address
; STRING		.STRINGZ "This is a test of the counting frequency code.  AbCd...WxYz."

;SUBTR Subroutine prints frequency of character
;In: R3, R5
;Out: R0
SUBTR
	   ST R0, SAVE_R0	; Save registers before modifying
	   ST R1, SAVE_R1	
	   ST R2, SAVE_R2	
	   ST R7, SAVE_R7	

	   ADD R0, R5, #0	; Loads current character from R5 into R0
	   OUT			; Outputs current character
	   LD R0, SPACE		; Loads Space character into R0
	   OUT			; Outputs space character
           
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

DONE	   LD R0, SAVE_R0	; Restores modified registers
	   LD R1, SAVE_R1	
	   LD R2, SAVE_R2	
	   LD R7, SAVE_R7	
	   RET			; Returns back to the main code


SAVE_R0 .BLKW #1
SAVE_R1 .BLKW #1
SAVE_R2 .BLKW #1
SAVE_R3 .BLKW #1
SAVE_R4 .BLKW #1
SAVE_R5 .BLKW #1
SAVE_R7 .BLKW #1
	.END
