DATASTORM_2017_X = 3 
DATASTORM_2017_Y = 3

DATASTORM_2017_VRAM = VRAM_START + (DATASTORM_2017_X + DATASTORM_2017_Y*32) * 16
DATASTORM_2017_NEXT_LINE = 32*16

datastorm2017:
    ; map text bank
    lda    #bank(datastorm2017.dat)
    tam    #page(datastorm2017.dat)

    ; copy data to vram
    st0 #$00
    st1 #low(DATASTORM_2017_VRAM)
    st2 #high(DATASTORM_2017_VRAM)
    st0 #$02
    tia datastorm2017.dat, video_data_l, 800
    
    st0 #$00
    st1 #low(DATASTORM_2017_VRAM + DATASTORM_2017_NEXT_LINE)
    st2 #high(DATASTORM_2017_VRAM + DATASTORM_2017_NEXT_LINE)
    st0 #$02
    tia datastorm2017.dat+800, video_data_l, 800

    stwz   color_reg
    tia    datastorm2017.pal, color_data, 32
    
    rts
