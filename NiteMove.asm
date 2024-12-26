        ORG $2134
        SETDP 0
BEGIN   LBSR INSTR
        ;************************
        ;* Setup Semi Graphics 24
        ;************************
SEMI24  LDX #$600
        LDA #$80
LOOP    STA ,X+
        CMPX #$1E00
        BCS LOOP
        LDA #$0D
        STA $FF22
        STA $FFC0
        STA $FFC3
        STA $FFC5
        STA $FFC7
        ;**********************
        ; ONSCREEN INSTRUCTIONS
        ;**********************
CONTRL  LDX #$600                       ;Clear screen
        LDA #$80
LOOP1   STA ,X+
        CMPX #$1E00
        BNE LOOP1
        LDX #$0671                      ;Position on screen for instructions to be written
        STX $88
        CLRB                            ;Reset number of characters drawn
        LEAY PRINT,PCR                  ;Point to Instructions
LOOP2   LDA ,Y+                         ;Get next character of instruction 
        ANDA #$BF
        STA ,X+                         ;Write to screen
        STA $1F,X
        STA $3F,X
        STA $5F,X
        STA $7F,X
        STA $9F,X
        STA $BF,X
        CMPX #6269                      ;Finished writing instructions? (HEX $187D)
        BEQ SCORE                       ;Yes 
        INCB                            ;No - incease number of characters drawn       
        CMPB #13                        ;Finished writing all characters for line
        BNE LOOP2                       ;No - write next character
LINE    CLRB                            ;Yes - reset character count for line
        LEAX 755,X                      ;Reposition point of screen for character to be drawn
        BNE LOOP2                       ;Write next line of characters
PRINT   FCB /CONTROLS:-   /
        FCB /CURSOR KEYS  /
        FCB /FOR MOVEMENT./
        FCB /PRESS ENTER  /
        FCB /TO CHANGE.   /
        FCB /"R" RESTARTS /
        FCB /"Q" QUITS    /
        ;*********************
        ; SCORE INITIALIZATION
        ;*********************
SCORE   LDX #6244                       ;Position on screen for Score to be written
        STX $88                         
        CLRB                            ;Reset number of characters drawn
        LEAY SCORE1,PCR                 ;Point to Score text
LOOP3   LDA ,Y+                         ;Get next character
        ANDA #$BF
        STA ,X+                         ;Write to screen
        STA $1F,X
        STA $3F,X
        STA $5F,X
        STA $7F,X
        STA $9F,X
        STA $BF,X
        INCB                            ;Increase number of characters drawn
        CMPB #8                         ;Fisnished writing all characters?
        BNE LOOP3                       ;No - continue writing score text
        LDD #$3030                      ;Write "00" 
        STD $1F00                       ;To screen score position
        BRA BOARD                       
SCORE1  FCB /MOVES 00/
        ;***************
        ; SET UP DISPLAY
        ;***************
BOARD   LDX #$0660
        LDD #$0000
        LDY #$CFCF                      ;White Square
        LDU #$AFAF                      ;Blue Square
ROWS    STY ,X++                        ;Draw white square pixel
        STU ,X++                        ;Draw Blue square pixel
        INCA
        CMPA #4                         ;Have we drawn 8 columns?
        BNE ROWS                        ;No - draw next two columns
        LEAX 16,X                       ;Yes - go down a row in cell
        CLRA                            ;Reset column count
        INCB                            ;Increase row count
        CMPB #16                        ;Have we drawn all rows in cell?
        BNE ROWS                        ;No 
        EXG Y,U                         ;Yes - switch cell colours
        CLRB                            ;reset cell row count
        CMPX #$1660                     ;Finished all cells?
        BNE ROWS                        ;No
        ;*************************
        ; RANDOMISE START POSITION
        ;*************************
        LDA $1F80
        CMPA #50                        ;Level "2" selected
        BEQ START2
        LDX #$0E64                      ;Level 1 - start position (change to 0660 for top level position)
        BNE START1
START2  JSR $978E                       ;RANDOM NUMBER: Generates an 8 bit random number and puts it in location 278
        LDB 278                         ; Produces one of: 60,62,64,66,68,6A,6C,6E
        ANDB #$07
        ASLB
        ADDB #$60
        PSHS B
        JSR $978E                       ;RANDOM NUMBER: Generates an 8 bit random number and puts it in location 278
        LDA 278                         ;Produces one of: 06,08,0A,0C,0E,10,12,14
        ANDA #$07
        ASLA
        ADDA #$06
        PULS B
        TFR D,X
        LDY ,X
        CMPY #$AFAF
START1  LBEQ FSTCHK                     ;First check?
        LBNE NXTCHK
        ;********************
        ; MAIN CONTOL ROUTINE
        ;********************
WAIT    LDU $1F30
        LEAU -1538,U
        BSR CHECK
        LEAU 4,U
        BSR CHECK
        LEAU 506,U
        BSR CHECK
        LEAU 8,U
        BSR CHECK
        LEAU 1016,U
        BSR CHECK
        LEAU 8,U
        BSR CHECK
        LEAU 506,U
        BSR CHECK
        LEAU 4,U
        BSR CHECK
        LBSR NOMOVE
CHECK   LDD ,U
        CMPA #$AF
        LBEQ CYAN
        CMPA #$CF
        LBEQ ORANGE
        PULS PC
KEYS    JSR $8006            ; POLCAT:Keyboard input:put into Register A
        BEQ KEYS
        CMPA #81
        LBEQ QUIT
        CMPA #82
        LBEQ BEGIN
        CMPA #$5E
        BNE DOWN
        LDD -544,X
        CMPA #$80
        BEQ KEYS
        LBSR CHEK
        LEAX -1024,X
        LDD ,X
        LBNE CHEK2
DOWN    CMPA #$0A
        BNE LEFT
        LDD 32,X
        CMPA #$80
        BEQ KEYS
        LBSR CHEK
        LDD ,X
        LBSR CHEK2
LEFT    CMPA #$08
        BNE RIGHT
        LDD -33,X
        CMPA #$80
        BEQ KEYS
        LBSR CHEK
        LEAX -514,X
        LDD ,X
        LBSR CHEK2
RIGHT   CMPA #$09
        BNE ENTER
        LDD -30,X
        CMPA #$80
        BEQ KEYS
        LBSR CHEK
        LEAX -510,X
        LDD ,X
        LBSR CHEK2
ENTER   CMPA #$0D
        BNE KEYS
        LDU $1F20
        LEAU -1026,U
        STU $1F20
        CMPX $1F20
        LBEQ CANGO
        LEAU 4,U
        STU $1F20
        CMPX $1F20
        LBEQ CANGO
        LEAU 506,U
        STU $1F20
        CMPX $1F20
        LBEQ CANGO
        LEAU 8,U
        STU $1F20
        CMPX $1F20
        LBEQ CANGO
        LEAU 1016,U
        STU $1F20
        CMPX $1F20
        LBEQ CANGO
        LEAU 8,U
        STU $1F20
        CMPX $1F20
        LBEQ CANGO
        LEAU 506,U
        STU $1F20
        CMPX $1F20
        LBEQ CANGO
        LEAU 4,U
        STU $1F20
        CMPX $1F20
        LBEQ CANGO
        LEAU -1026,U
        STU $1F20
NOGO    STX $1F60
        LDX #$1B66
        STX $88
        CLRB
        LEAY CANT,PCR
LOOP4   LDA ,Y+
        ANDA #$BF
        STA ,X+
        STA $1F,X
        STA $3F,X
        STA $5F,X
        STA $7F,X
        STA $9F,X
        STA $BF,X
        INCB
        CMPB #19
        BNE LOOP4
        LDY #$FFFF
DELAY   LEAY -1,Y
        BNE DELAY
        LDX $1F60
        LBSR CHEK
        LDA #255
        LDX #200
        LBSR SOUND
        LDA #125
        LDX #100
        LBSR SOUND
        LDX #$1B66
        LDA #$80
LOOP5   STA ,X+
        CMPX #$1E00
        BNE LOO P5
        LDX $1F30
        STX $1F20
        LEAX -512,X
        LDD ,X
        LBNE CHEK2
CANGO   LEAX -512,X
        LDD ,X
        CMPD #$AAAA
        BEQ FSTCHK
        CMPD #$CACA
        BEQ NXTCHK
        LEAX 512,X
        LBNE NOGO
FSTCHK  LDY #$FFFF
        LBSR MOVE
        LBSR UNITS
        PSHS X
        LDA #187
        LDX #85
        LBSR SOUND
        PULS X
        STX $1F20
        STX $1F30
        LEAX -512,X
        LBNE WAIT
NXTCHK  LDY #$DFDF
        LBSR MOVE
        LBSR UNITS
        PSHS X
        LDA #187
        LDX #85
        LBSR SOUND
        PULS X
        STX $1F20
        STX $1F30
        LEAX -512,X
        LBNE WAIT
SCRCHK  LDD $1F00
        CMPA #54
        LBNE KEYS
        CMPB #52
        LBEQ ENDING
        LBNE KEYS
CANT    FCB /YOU CAN T GO THER/
        FCB /E!/
        ;*************
        ;COLOUR CHANGE
        ;*************
CHEK    LEAX -512,X
        LDD ,X
        CMPA #$DF
        BNE FF
        LDY #$DFDF
        BRA MOVE
FF      CMPA #$FF
        BNE AA
        LDY #$FFFF
        BRA MOVE
AA      CMPA #$AA
        BNE CA
        LDY #$AFAF
        BRA MOVE
CA      CMPA #$CA
        BNE DA
        LDY #$CFCF
        BRA MOVE
DA      CMPA #$DA
        BNE FA
        LDY #$DFDF
        BRA MOVE
FA      CMPA #$FA
        LDY #$FFFF
MOVE    CLRB
LOOP6   STY ,X
        LEAX 32,X
        INCB
        CMPB #16
        BNE LOOP6
        PULS PC
        ;***********************
        ; CURSOR COLOUR CONTROLS
        ;***********************
CHEK2   CMPA #$AF
        BEQ BLUE
        CMPA #$CF
        BEQ BUFF
        CMPA #$DF
        BEQ CYAN
        CMPA #$FF
        BEQ ORANGE
BLUE    LDY #$AAAA
        LDU #$A5A5
        BRA MOVE2
BUFF    LDY #$CACA
        LDU #$C5C5
        BRA MOVE2
CYAN    LDY #$DADA
        LDU #$D5D5
        BRA MOVE2
ORANGE  LDY #$FAFA
        LDU #$F5F5
        BRA MOVE2
MOVE2   CLRA
        CLRB
LOOP7   STY ,X
        LEAX 32,X
        INCB
        CMPB #4
        BNE LOOP7
        INCA
        CMPA #4
        BNE SWOP
        PSHS X
        LDA #31
        LDX #69
        LBSR SOUND
        PULS X
        LBRA SCRCHK
SWOP    EXG U,Y
        CLRB
        BRA LOOP7
        ;*****************
        ; COUNTING ROUTINE
        ;*****************
UNITS   PSHS A,B,X
        LDX #6218
COUNT   LDD $1F00
        CMPB #57
        BEQ TENS
        INCB
LOOP8   STD ,X
        LEAX 32,X
        CMPX #6456
        BLO LOOP8
        STD $1F00
        PULS X,A,B,PC
TENS    INCA
        LDB #47
        STD $1F00
        BRA COUNT
        ;***************
        ; SOUND ROUTINES
        ;***************
SOUND   PSHS A
        LDA $FF01
        ANDA #247
        STA $FF01
        LDA $FF03
        ANDA #247
        STA $FF03
        LDA $FF23
        ORA #8
        STA $FF23
        ORCC #$50
        PULS A
        PSHS X
        LDB #252
SD1     STB $FF20
SD2     LEAX -1,X
        BNE SD2
        LDX ,S
        CLR $FF20
SD3     LEAX -1,X
        BNE SD3
        LDX ,S
        DECA
        BNE SD1
        ANDCC #$AF
        PULS X,PC
NOMOVE  LDA #131
        LDX #102
        LBSR SOUND
        LDA #200
        LDX #225
        LBSR SOUND
FINISH  LDX #$1B66
        STX $88
        CLRB
        LEAY TYPE,PCR
LOOP9   LDA ,Y+
        ANDA #$BF
        STA ,X+
        STA $1F,X
        STA $3F,X
        STA $5F,X
        STA $7F,X
        STA $9F,X
        STA $BF,X
        INCB
        CMPB #19
        BCS LOOP9
        LDX $1F20
        LEAX -512,X
        LDD ,X
        LBRA CHEK2
TYPE    FCB /SORRY NO MOVES/
        FCB / LEFT/
        ;************
        ;ANOTHER GAME
        ;************
ENDING  LDX #$1B60
        STX $88
        CLRB
        LEAY AGAIN,PCR
LOOP10  LDA ,Y+
        ANDA #$BF
        STA ,X+
        STA $1F,X
        STA $3F,X
        STA $5F,X
        STA $7F,X
        STA $9F,X
        STA $BF,X
        INCB
        CMPB #31
        BCS LOOP10
LOOP11  JSR $8006               ; POLCAT:Keyboard input:put into Register A
        CMPA #$59
        LBEQ BEGIN
        CMPA #$4E
        LBEQ QUIT
        BNE LOOP11
AGAIN   FCB /WELL DONE ANOTHER/
        FCB / GAME (Y OR N)/
        ;*********************
        ; INITIAL TEXT DISPLAY
        ;*********************
INSTR   JSR $BA77               ; CLEAR SCREEN: clears screen to space and 'homes' cursor
        LDX #$04A2
        STX $88
        LEAX RULES,PCR
        JSR $90E5               ;Write Rules
        JSR $90E5              	;Write Rules
	LDX #$400		;Invert screen green/black to black/green
LOOP12  LDA ,X
        EORA #$40
        STA ,X+
        CMPX #$5FF
        BLS LOOP12
        LDX #$400		;Draw Top Blue scrolling border
        LDA #$AF
LOOP13  STA ,X+
        CMPX #$41E
        BLS LOOP13
        LDX #$5A2               ;Draw bottom Yellow text border
        LDA #156
LOOP14  STA ,X+
        CMPX #$5BD
        BLS LOOP14
        LDA #152
        STA $5BE
        LDX #$41F               ;Draw right White Scolling Border
        LDA #$CF
LOOP15  STA ,X
        LEAX 32,X
        CMPX #$5DF
        BLS LOOP15
        LDA #146
        STA $43E
        LDX #$45E               ;Draw right Yellow text border 
        LDA #154
LOOP16  STA ,X
        LEAX 32,X
        CMPX #$59E
        BLS LOOP16
        LDX #$5E1               ;Draw Bottom Cyan Scolling border
        LDA #$DF
LOOP17  STA ,X+
        CMPX #$600
        BLS LOOP17
        LDA #145
        STA $421
        LDX #$422               ;Draw top yellow text border
        LDA #147
LOOP18  STA ,X+
        CMPX #$43D
        BLS LOOP18
        LDX #$420               ;Draw Left Orange scrolling border
        LDA #$FF
LOOP19  STA ,X
        LEAX 32,X
        CMPX #$5E0
        BLS LOOP19
        LDA #148
        STA $5A1
        LDX #$441               ;Draw Left yellow text border
        LDA #149
LOOP20  STA ,X
        LEAX 32,X
        CMPX #$581
        BLS LOOP20
LOOP21  JSR $8006               ; POLCAT:Keyboard input:put into Register A
        CMPA #49                ;Check for "1"
        LBEQ LEVEL
        CMPA #50                ;check for "2"
        LBEQ LEVEL
        CMPA #32                ;Check for Space
        LBEQ CKLEVL             
        LDA #1
LOOP22  PSHS A
        LDB #2
LOOP23  PSHS B
        LDX #$400               ;Scroll to line left
        LDY #$401
        LDA #31
LOOP24  LDB ,Y+
        STB ,X+
        DECA
        BNE LOOP24
        PULS B
        DECB
        BNE LOOP23
        LDX #$41F               ;Scroll right line Up
        LDY #$43F
        LDA #$15
LOOP25  LDB ,Y
        STB ,X
        LEAY 32,Y
        LEAX 32,X
        DECA
        BNE LOOP25
        LDB #2
LOOP26  LDX #$600               ;Scroll bottom line right
        LDY #$5FF
        LDA #31
        PSHS B
LOOP27  LDB ,-Y
        STB ,-X
        DECA
        BNE LOOP27
        PULS B
        DECB
        BNE LOOP26
        LDX #$5E0               ;Scroll left line down
        LDY #$5C0
        LDA #15
LOOP28  LDB ,Y
        STB ,X
        LEAY -32,Y
        LEAX -32,X
        DECA
        BNE LOOP28
        PULS A
        DECA
        BNE LOOP22
        LDA #28                 ;Scroll text left
        LDX #$5C1
        LDY #$5C2
        LDU ,X
LOOP29  LDB ,Y+
        STB ,X+
        DECA
        BNE LOOP29
        STU $5DD
        LDY #12000              ;Slow things down
SLOW    LEAY -1,Y
        BNE SLOW
        LBRA LOOP21
        ;***************        
        ; SCROLLS SCREEN
        ;***************
SCROLL  CLR $1F70
        LDB #32
LOOP30  LDX #$400
        LDA #$80
LOOP31  STA ,X
        LEAX 32,X
        CMPX #$601
        BLS LOOP31
        LDX #$400
        LDY #$401
LOOP32  LDA ,Y+
        STA ,X+
        CMPX #$600
        BLS LOOP32
        PSHS Y
        LDY #$1500
LOOP33  LEAY -1,Y
        BNE LOOP33
        PSHS B
        LDA #100
        LDX #36
        LBSR SOUND
        PULS B
        DECB
        BNE LOOP30
        LBRA SEMI24
        ;*****************
        ;START LEVEL CHECK
        ;*****************
LEVEL   STA $1F70
        STA $1F80
        LDX #$5C1
        STX $88
        LEAX SPCBAR,PCR
        JSR $90E5                   ; Replace "enter level" text with "press spacebar"
        LDA #200
        LDX #25
        LBSR SOUND
        LBRA LOOP21
SPCBAR  FCB /       PRESS SPAC/
        FCB /EBAR TO START/,0
CKLEVL  LDA $1F70
        CMPA #49
        LBEQ SCROLL
        CMPA #50
        LBEQ SCROLL
        LBNE LOOP21
RULES   FCB /  CHANGE THE B/
        FCB /OARD FROM BLUE  /
        FCB /    & WHITE TO O/
        FCB /RANGE AND CYAN  /
        FCB /                /
        FCB /                /
        FCB /    USING THE CU/
        FCB /RSOR KEYS MOVE  /
        FCB /    AS THE KNIGH/
        FCB /T CAN IN CHESS  /
        FCB /                /
        FCB /                /
        FCB /                /
        FCB /                /
        FCB /                /
        FCB /                /
        FCB /                /
        FCB /                /
        FCB /    ENTER SKILL /
        FCB /LEVEL 1 OR 2 ?/,0
        ;***********************
        ; FINISH RETURN TO BASIC
        ;***********************
QUIT    JSR $B3B4             ; RESET:resets whole works, as if reset button has been pressed

