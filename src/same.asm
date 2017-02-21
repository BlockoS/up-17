SAME_X = 1
SAME_Y = 3

SAME_VRAM = VRAM_START + (SAME_X + SAME_Y*32) * 16
SAME_NEXT_LINE = 32*16

same:
    ; map text bank
    lda    #bank(same.dat)
    tam    #page(same.dat)

    ; copy data to vram
    st0 #$00
    st1 #low(SAME_VRAM)
    st2 #high(SAME_VRAM)
    st0 #$02
    tia same.dat, video_data_l, 800
    
    st0 #$00
    st1 #low(SAME_VRAM + SAME_NEXT_LINE)
    st2 #high(SAME_VRAM + SAME_NEXT_LINE)
    st0 #$02
    tia same.dat+800, video_data_l, 800

    stwz   color_reg
    tia    datastorm2017.pal, color_data, 32
    
    rts

same.brutal_clean:
    stw    #SAME_VRAM, <_di
    ldx    #$02
@loop:
    st0    #$00
    lda    <_di
    sta    video_data_l
    clc
    adc    #low(SAME_NEXT_LINE)
    sta    <_di
    lda    <_di+1
    sta    video_data_h
    adc    #high(SAME_NEXT_LINE)
    sta    <_di+1
    
    st0 #$02
    tia $2400, video_data, 800
    
    dex
    bne    @loop
    rts
