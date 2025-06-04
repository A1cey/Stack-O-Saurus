JUMP_KEY	equ	P2.0

VAR	        equ	20h
AIRTIME	    equ	VAR.1
BLOCK_POS	equ	VAR.2
SCORE	    equ	VAR.3

; game_loop:
; shift block position
; decr airtime
; check for jump input
; animate everything
; inc score

init:
    mov     P0, #0
    mov     P1, #0
	mov	    P2, #0FFh
	mov     P3, #0
	clr     B.0
	mov	    AIRTIME, #0
	mov	    BLOCK_POS, #000000001b ; pos is instantly shifted left
	mov	    SCORE, #0

	; jmp to game start
	jmp	    shift_block_pos

shift_block_pos:
	mov	    A, BLOCK_POS
	rl	    A
	mov	    BLOCK_POS, A

	jmp	    update_airtime

update_airtime:
	mov	    A, AIRTIME
	cjne	A, #0, decr_airtime
	jmp	    check_jump_input

decr_airtime:
	dec	    AIRTIME
	jmp	    check_jump_input

check_jump_input:
	; if airtime not 0 you cannot jump
	mov     A, AIRTIME
	cjne	A, #0, animate_player

	mov	    A, P2
	mov	    P2, #0FFh

	; no jump input
	cjne	A, #11111110b, animate_player

	mov	    AIRTIME, #3

	jmp	    animate_player

animate_player:
	mov	    P0, #0		; prevents early values

	mov	    A, AIRTIME
	cjne	A, #0, check_1

	; animate player on ground
	mov	    P1, #01000000b
	mov	    P0, #00000110b
	jmp	    animate_block

check_1:
	cjne	A, #1, check_3
	jmp	    animate_player_air_1

check_3:
	cjne	A, #3, animate_player_air_2
	jmp	    animate_player_air_1

animate_player_air_1:
	; animate player one pixel in air
	mov	    P1, #01000000b
	mov	    P0, #00001100b

	jmp	    animate_block

animate_player_air_2:
	; animate player two pixels in air
	mov	    P1, #01000000b
	mov	    P0, #00011000b
	jmp	    animate_block

animate_block:
    ; if player in air, no collision
	mov	    A, AIRTIME
	cjne	A, #0, animate_block_normal

	; if player on ground and block on player x pos, collision else animate block and player bottom
	mov	    A, BLOCK_POS
	cjne	A, #01000000b, animate_block_bottom_player

	jmp	    game_over

animate_block_bottom_player:
    mov     P0, #00000010b
    mov	    A, BLOCK_POS
    setb    A.6
	mov	    P1, A

	jmp	    animate_floor

animate_block_normal:
	mov	    P0, #0
	mov	    P1, BLOCK_POS
	mov	    P0, #00000010b

	jmp	    animate_floor

animate_floor:
	mov	    P0, #0
	mov	    P1, #11111111b
	mov	    P0, #00000001b

	jmp	    inc_score

inc_score:
	inc	    SCORE
	jmp	    shift_block_pos


game_over:
	mov	    P0, #0
	mov	    P1, #0

	jmp     calc_score_digits

calc_score_digits:
    ; calculate digits
    mov     A, SCORE
    mov     B, #100
    div     AB              ; A: hundreds, B: remainder
    mov     R1, A           ; R1: hundreds digit
    mov     R4, B           ; R4: remainder

    mov     A, R4           ; A: remainder
    mov     B, #10
    div     AB              ; A: tens, B: units
    mov     R2, A           ; R2: tens digit
    mov     R3, B           ; R3: units digit

    ; get hex value for digits
    mov     DPTR, #segment_table
    mov     A, R1
    movc    A, @A+DPTR
    mov     R5, A           ; R5: hundreds

    mov     DPTR, #segment_table
    mov     A, R2
    movc    A, @A+DPTR
    mov     R6, A           ; R6: tens

    mov     DPTR, #segment_table
    mov     A, R3
    movc    A, @A+DPTR
    mov     R7, A           ; R7: units

    jmp     show_score_0

show_score_0:
    mov     P0, #0
    mov     P3, R5
	mov     P0, #00000100b ; activate hundreds

    jmp     show_score_1

show_score_1:
    mov     P0, #0
    mov     P3, R6
	mov     P0, #00000010b ; activate tens

    jmp     show_score_2

show_score_2:
    mov     P0, #0
    mov     P3, R7
	mov     P0, #00000001b ; activate units
    
    jmp     show_score_0

; lookup table for 7-segment display(ABCDEFG0)
segment_table:
    db     0FCH ; 0 = 11111100
    db     060H ; 1 = 01100000
    db     0DAH ; 2 = 11011010
    db     0F2H ; 3 = 11110010
    db     066H ; 4 = 01100110
    db     0B6H ; 5 = 10110110
    db     0BEH ; 6 = 10111110
    db     0E0H ; 7 = 11100000
    db     0FEH ; 8 = 11111110
    db     0F6H ; 9 = 11110110

end
