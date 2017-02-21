SCREEN_O_TITLE_X = 3 
SCREEN_O_TITLE_Y = 12

SCREEN_O_TITLE_VRAM = VRAM_START + (SCREEN_O_TITLE_X + SCREEN_O_TITLE_Y*32) * 16
SCREEN_0_TITLE_NEXT_LINE = 32*16

screen.0:
    ; map text bank
    lda    #bank(itscoming.dat)
    tam    #page(itscoming.dat)

    ; copy data to vram
    st0 #$00
    st1 #low(SCREEN_O_TITLE_VRAM)
    st2 #high(SCREEN_O_TITLE_VRAM)
    st0 #$02
    tia itscoming.dat, video_data_l, 864
    
    st0 #$00
    st1 #low(SCREEN_O_TITLE_VRAM + SCREEN_0_TITLE_NEXT_LINE)
    st2 #high(SCREEN_O_TITLE_VRAM + SCREEN_0_TITLE_NEXT_LINE)
    st0 #$02
    tia itscoming.dat+864, video_data_l, 864
    
    st0 #$00
    st1 #low(SCREEN_O_TITLE_VRAM + SCREEN_0_TITLE_NEXT_LINE*2)
    st2 #high(SCREEN_O_TITLE_VRAM + SCREEN_0_TITLE_NEXT_LINE*2)
    st0 #$02
    tia itscoming.dat+(864*2), video_data_l, 864

    ; go!
    stw    #black.fad, <_si
    jsr    fade.init

    stw    #itscoming.fad, <_si
    jsr    fade.begin
    
@fade.in:
    lda    #$02
    jsr    wait_vsync
    jsr    fade
    lda    fade.index
    bne    @fade.in
    
    ldx    #$40
@rest:
    lda    #$02
    jsr    wait_vsync
    dex
    bne    @rest

    stw    #itscoming.f00, <_si
    jsr    fade.begin
@fade.out:
    lda    #$02
    jsr    wait_vsync
    jsr    fade
    lda    fade.index
    bne    @fade.out

    ; clear title with VRAM-VRAM DMA
    st0    #$0f
    st1    #$00
    st2    #$00

    st0    #$10
    st1    #low($1900)
    st2    #high($1900)
    
    st0    #$11
    st1    #low(SCREEN_O_TITLE_VRAM)
    st2    #high(SCREEN_O_TITLE_VRAM)
    
    st0    #$12
    st1    #low(32*16*3)
    st2    #high(32*16*3)
    
    rts
