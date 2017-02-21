ALASKA_X = 2
ALASKA_Y = 2

ALASKA_VRAM = VRAM_START + (ALASKA_X + ALASKA_Y*32) * 16
ALASKA_NEXT_LINE = 32*16

alaska:
    ; map text bank
    lda    #bank(alaska.dat)
    tam    #page(alaska.dat)

    ; copy data to vram

    lda    #MEMCPY_SRC_INC_DEST_ALT
    sta    _hrdw_memcpy_mode
    stw    #alaska.dat, _hrdw_memcpy_src
    stw    #video_data_l, _hrdw_memcpy_dst
    stw    #544, _hrdw_memcpy_len

    stw    #ALASKA_VRAM, <_di

    ldx    #11
@l0:
    st0    #$00
    stw    <_di, video_data
    st0    #$02
    jsr    hrdw_memcpy
    
    addw   #ALASKA_NEXT_LINE, <_di
    addw   #544, _hrdw_memcpy_src
    
    dex
    bne    @l0
    
    stwz   color_reg
    tia    datastorm2017.pal, color_data, 32
    rts

alaska.brutal_clean:
    stw    #ALASKA_VRAM, <_di
    ldx    #11
@loop:
    st0    #$00
    lda    <_di
    sta    video_data_l
    clc
    adc    #low(ALASKA_NEXT_LINE)
    sta    <_di
    lda    <_di+1
    sta    video_data_h
    adc    #high(ALASKA_NEXT_LINE)
    sta    <_di+1
    
    st0 #$02
    tia $2400, video_data, 544
    
    dex
    bne    @loop
    rts
