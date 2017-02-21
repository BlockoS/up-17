WEAREBACK_X = 3
WEAREBACK_Y = 3

WEAREBACK_VRAM = VRAM_START + (WEAREBACK_X + WEAREBACK_Y*32) * 16
WEAREBACK_NEXT_LINE = 32*16

weareback:
    ; map text bank
    lda    #bank(weareback.dat)
    tam    #page(weareback.dat)

    ; copy data to vram
    st0 #$00
    st1 #low(WEAREBACK_VRAM)
    st2 #high(WEAREBACK_VRAM)
    st0 #$02
    tia weareback.dat, video_data_l, 800
    
    st0 #$00
    st1 #low(WEAREBACK_VRAM + WEAREBACK_NEXT_LINE)
    st2 #high(WEAREBACK_VRAM + WEAREBACK_NEXT_LINE)
    st0 #$02
    tia weareback.dat+800, video_data_l, 800

    stwz   color_reg
    tia    datastorm2017.pal, color_data, 32
    
    rts
