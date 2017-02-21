  .macro plot_code
    lda    screen_x + \1
    clc
    adc    <center.x
    tax

    lda    screen_y + \1
    clc
    adc    <center.y
    sta    <_y

    ; compute VRAM address
    stz    <_addr+1
    txa
    and    #$f8
    asl    A
    rol    <_addr+1
    sta    <_addr
    
    lda    <_y
    and    #$f8
    lsr    A
    lsr    A
    ora    <_addr+1
    clc
    adc    #high(VRAM_START)
    tay
    
    lda    <_y
    and    #$07
    ora    <_addr
    clc
    adc    #low(VRAM_START)
    
    ; set VRAM address
    st0    #$00
    sta    video_data_l
    sty    video_data_h

    st0    #$01
    sta    video_data_l
    sty    video_data_h

    ; save for latter use
    sta    (clear_vram + ((\1)*12) + 3)
    sty    (clear_vram + ((\1)*12) + 5)
    
    ; plot
    txa
    and    #$07
    tax
    
    st0    #$02
    lda    video_data_l
    ora    plot_bit, X
    sta    video_data_l
    st2    #$00
  .endmacro

plot_bit:
    .db $80, $40, $20, $10
    .db $08, $04, $02, $01
    
plot:
    plot_code 0
    plot_code 1
    plot_code 2
    plot_code 3
    plot_code 4
    plot_code 5
    plot_code 6
    plot_code 7
    plot_code 8
    plot_code 9
    plot_code 10
    plot_code 11
    plot_code 12
    plot_code 13
    plot_code 14
    plot_code 15
    plot_code 16
    plot_code 17
    plot_code 18
    plot_code 19
    plot_code 20
    plot_code 21
    plot_code 22
    plot_code 23
    plot_code 24
    plot_code 25
    plot_code 26
    plot_code 27
    plot_code 28
    plot_code 29
    plot_code 30
    plot_code 31
    plot_code 32
    plot_code 33
    plot_code 34
    plot_code 35
    plot_code 36
    plot_code 37
    plot_code 38
    plot_code 39
    plot_code 40
    plot_code 41
    plot_code 42
    plot_code 43
    plot_code 44
    plot_code 45
    plot_code 46
    plot_code 47
    plot_code 48
    plot_code 49
    plot_code 50
    plot_code 51
    plot_code 52
    plot_code 53
    plot_code 54
    plot_code 55
    plot_code 56
    plot_code 57
    plot_code 58
    plot_code 59
    plot_code 60
    plot_code 61
    plot_code 62
    plot_code 63
    plot_code 64
    plot_code 65
    plot_code 66
    plot_code 67
    plot_code 68
    plot_code 69
    plot_code 70
    plot_code 71
    plot_code 72
    plot_code 73
    plot_code 74
    plot_code 75
    plot_code 76
    plot_code 77
    plot_code 78
    plot_code 79
    plot_code 80
    plot_code 81
    plot_code 82
    plot_code 83
    plot_code 84
    plot_code 85
    plot_code 86
    plot_code 87
    plot_code 88
    plot_code 89
    plot_code 90
    plot_code 91
    plot_code 92
    plot_code 93
    plot_code 94
    plot_code 95
    rts
plot_end:
