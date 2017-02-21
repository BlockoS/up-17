bounce_vram_tile = $1800
bounce_palette   = $00

    .zp
bounce_rcr      .ds 2
bounce_scanline .ds 1
bounce_max      .ds 1
bounce_index    .ds 1

    .bss
bounce.bg       .ds 2
bounce.fg       .ds 2

    .code

bounce:
    jsr    bounce_setup
    
    stz    <_al

    stz    <bounce_index

    set_vec #VSYNC, bounce_vsync
    vec_on  #VSYNC
    set_vec #HSYNC, bounce_hsync
    vec_on  #HSYNC
    
bounce.loop:
    ; setup palette
    stwz   color_reg
    stw    bounce.bg, color_data
    stw    bounce.fg, color_data

    ; loop
@l0:
    lda    #1
    jsr    wait_vsync
    inc    <bounce_index
    bne    @l0

    ; invert bg and fg colors
    stz    <_al
    stz    <bounce_index
    lda    #1
    jsr    wait_vsync

    stwz   color_reg
    stw    bounce.fg, color_data
    stw    bounce.bg, color_data

    rts
    
bounce_setup:
    clx
    lda    #31
    jsr    calc_vram_addr
    jsr    set_write
    ldx    bat_width
@bat_init:
    st1    #low(bounce_vram_tile  >> 4)
    st2    #(high(bounce_vram_tile >> 4) | (bounce_palette << 4))
    dex
    bne    @bat_init
    
    _set_vram_addr VDC_WRITE, #bounce_vram_tile
    ; a blank tile with color 1 
    st0    #$02
    st1    #$ff
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st1    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    st2    #$00
    
    rts

bounce_hsync:
    incw   <bounce_rcr
    st0    #6
    stw    <bounce_rcr, video_data

    st0    #7
    st1    #$00
    st2    #$00
    
    inc    <bounce_scanline     ; set next hsync until we reached bounce
    lda    <bounce_scanline     ; max coord
    cmp    <bounce_max
    bcs    @l1
@l0:
   ; scroll to blank line
    st0    #8
    st1    #(31*8)
    st2    #$00
    stz    irq_status
    irq1_end
    
@l1:
    st0    #8
    st1    #$00
    st2    #$00
    stz    irq_status
    irq1_end

bounce_vsync:
    ldx    <bounce_index
    lda    bounce_tbl, X
    sta    <bounce_max

    st0    #7               ; scroll to blank line
    st1    #$00
    st2    #$01

    st0    #8
    st1    #(31*8)
    st2    #$00

    st0    #6               ; restart the scanline counter on the first
    lda    #$40             ; line
    sta    video_data_l
    sta    <bounce_rcr
    st2    #$00
    stz    <bounce_rcr+1

    stz    <bounce_scanline
    
    jsr    vgm_update

    irq1_end

bounce_tbl:
    .db $00,$00,$00,$00,$00,$00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05
    .db $06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$11,$12,$13,$15,$16,$18
    .db $19,$1b,$1d,$1f,$20,$22,$24,$26,$28,$2a,$2c,$2e,$31,$33,$35,$38
    .db $3a,$3c,$3f,$42,$44,$47,$4a,$4c,$4f,$52,$55,$58,$5b,$5e,$61,$64
    .db $67,$6b,$6e,$71,$75,$78,$7c,$7f,$83,$87,$8b,$8e,$92,$96,$9a,$9e
    .db $a2,$a6,$aa,$ae,$b3,$b7,$bb,$c0,$c4,$c9,$cd,$d2,$d6,$db,$d9,$d7
    .db $d5,$d3,$d1,$ce,$cc,$ca,$c8,$c7,$c5,$c3,$c1,$c0,$be,$bc,$bb,$b9
    .db $b8,$b7,$b5,$b4,$b3,$b2,$b0,$af,$ae,$ad,$ac,$ac,$ab,$aa,$a9,$a9
    .db $a8,$a7,$a7,$a6,$a6,$a6,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5,$a5
    .db $a5,$a5,$a6,$a6,$a6,$a7,$a7,$a8,$a8,$a9,$aa,$aa,$ab,$ac,$ad,$ae
    .db $af,$b0,$b1,$b2,$b4,$b5,$b6,$b8,$b9,$ba,$bc,$bd,$bf,$c1,$c2,$c4
    .db $c6,$c8,$ca,$cc,$ce,$d0,$d2,$d4,$d6,$d9,$db,$db,$d9,$d8,$d7,$d6
    .db $d5,$d5,$d4,$d3,$d2,$d2,$d1,$d1,$d0,$d0,$cf,$cf,$cf,$ce,$ce,$ce
    .db $ce,$ce,$ce,$ce,$ce,$ce,$ce,$cf,$cf,$cf,$d0,$d0,$d1,$d1,$d2,$d2
    .db $d3,$d4,$d5,$d6,$d6,$d7,$d8,$da,$db,$db,$db,$da,$da,$d9,$d9,$d9
    .db $d9,$d8,$d8,$d8,$d8,$d8,$d8,$d8,$d8,$d9,$d9,$d9,$da,$da,$da,$db
