; [todo] : allow to modify plot center
; [todo] : do some gfx
; [todo] : fix colors
; [todo] : add a 4th object

    .include "config.inc"
    
    .include "system.inc"

    .include "equ.inc"
    .include "macro.inc"
    .include "vdc.inc"
    .include "psg.inc"
    .include "ramcpy.inc"
    
    .include "interrupts.asm"
    .include "gfx.asm"
    .include "math.asm"
    .include "vgm.asm"
    .include "datastorm2017.asm"
    .include "weareback.asm"
    .include "same.asm"
    .include "alaska.asm"
    
    .zp
_x    .ds 1
_y    .ds 1
_addr .ds 2

center.x .ds 1
center.y .ds 1

    .code
main:
    stwz   <_addr

    jsr    vgm_setup
    
    ; [todo]
    lda    #bank(plot)
    tam    #page(plot)
    
    setbgmap #BGMAP_SIZE_32x32

    jsr    bat_set

    jsr    setup_ramcode
    
    ; set vdc control register
    vreg  #5
    ; enable bg, enable sprite, vertical blanking and scanline interrupt
    lda   #%11001100
    sta    <vdc_crl
    sta   video_data_l
    st2   #$00

    set_vec #VSYNC, main_vsync
    vec_on  #VSYNC
    set_vec #HSYNC, _hsync_handler
    vec_on  #HSYNC

    ; ---- screen 0 : it's coming...
    jsr    screen.0

    ; ---- screen 1 : bounce
    lda    #$01
    tam    #$02

    stw    #$00e2, bounce.bg
    stw    #smurf.color, bounce.fg
    jsr    bounce

    ; -- screen 2...N
    stz    rx
    stz    ry
    stz    rz

    ; ---- object + txt
    stz    <_cl

    stw    #smurf.color, bounce.bg
    stw    #$01ff, bounce.fg

loop:
    lda    #128
    sta    <center.x
    lda    #(110+24)
    sta    <center.y

    jsr    datastorm2017
    jsr    display_object
    
    jsr    weareback
    jsr    display_object
    
    
    lda    #180
    sta    <center.x
    lda    #140
    sta    <center.y

    jsr    same
    jsr    display_object    
    jsr    same.brutal_clean

    jsr    alaska

    lda    #180
    sta    <center.x
    lda    #160
    sta    <center.y

    jsr    display_object    
    jsr    alaska.brutal_clean
        
    jmp    loop

display_object:
    st0    #7
    st1    #$00
    st2    #$00

    st0    #8
    st1    #$00
    st2    #$01

    set_vec #VSYNC, main_vsync
    vec_on  #VSYNC
    set_vec #HSYNC, _hsync_handler
    vec_on  #HSYNC

    lda    <_cl
    asl    A
    tax
    lda    obj_x, X
    sta    vertex_x 
    lda    obj_y, X
    sta    vertex_y 
    lda    obj_z, X
    sta    vertex_z 
    inx
    lda    obj_x, X
    sta    vertex_x+1
    lda    obj_y, X
    sta    vertex_y+1 
    lda    obj_z, X
    sta    vertex_z+1

    lda    #2
    sta    <_dx
bleep:
    stz    <_ch
display_loop:
    lda    #1
    jsr    wait_vsync

    inc    rz
    inc    rx
    jsr    transform_points
    
    jsr    clear_vram

    jsr    plot
    
    dec    <_ch
    bne    display_loop
    dec    <_dx
    bne    bleep
        
    stw    #main1.fad, <_si
    jsr    fade.init

    stw    #main2.fad, <_si
    jsr    fade.begin
    
@fade0:
    lda    #$02
    jsr    wait_vsync
    jsr    fade
    lda    fade.index
    bne    @fade0

    jsr    bounce

    set_vec #VSYNC, fade_vsync
    vec_on  #VSYNC
    set_vec #HSYNC, fade_hsync
    vec_on  #HSYNC
        
    stw    #main1.fad, <_si
    jsr    fade.init

    stw    #main0.fad, <_si
    jsr    fade.begin
    
@fade:
    lda    #$02
    jsr    wait_vsync
    jsr    fade
    lda    fade.index
    bne    @fade
    
    inc    <_cl
    lda    <_cl
    cmp    #$03
    bne    @nop
        stz   <_cl
@nop:
    rts

fade_vsync:

    st0    #6               ; restart the scanline counter on the first
    lda    #$40             ; line
    sta    video_data_l
    sta    <bounce_rcr
    st2    #$00
    stz    <bounce_rcr+1

    jsr    vgm_update

    st0    #7
    st1    #$00
    st2    #$00
    
    st0    #8
    st1    #(31*8)
    st2    #$00
    stz    irq_status
    irq1_end

fade_hsync:
    incw   <bounce_rcr
    st0    #6
    stw    <bounce_rcr, video_data

    st0    #7
    st1    #$00
    st2    #$00
    
    st0    #8
    st1    #(31*8)
    st2    #$00
    stz    irq_status
    irq1_end

main_vsync:
    jsr    vgm_update
    irq1_end

vgm_setup:
    lda    #low(song_base_address)
    sta    <vgm_base
    sta    <vgm_ptr
    
    lda    #high(song_base_address)
    sta    <vgm_base+1
    sta    <vgm_ptr+1
    
    lda    #song_bank
    sta    <vgm_bank
    
    lda    <vgm_base+1
    clc
    adc    #$20
    sta    <vgm_end
    
    lda    #song_loop_bank
    sta    <vgm_loop_bank
    stw    #song_loop, <vgm_loop_ptr
    rts

; [todo] rename
bat_set:
    st0    #$00
    st1    #$00
    st2    #$00
    
    stw    #(VRAM_START>>4), <_addr
    ldx    bat_height
@l0:
    ldy    bat_width
@l1:
        st0    #$02
        lda    <_addr
        sta    video_data_l
        lda    <_addr+1
        sta    video_data_h

        incw   <_addr
        dey
        bne    @l1
    dex
    bne    @l0
    
    rts

setup_ramcode:
    ; copy code for transform_points routine
    tii    ramcode_begin, transform_points, ramcode_end-ramcode_begin
    
    ; build clear_vram routine
    stw    #clear_vram, <_addr

    ldx    #(POINT_COUNT-1)
@l0:
    cly
    lda    #$03                 ; st0    #$00
    sta    [_addr], Y
    iny
    lda    #$00
    sta    [_addr], Y
    iny

    lda    #$13                 ; st1    #low(VRAM_START)
    sta    [_addr], Y
    iny
    lda    #low(VRAM_START)
    sta    [_addr], Y
    iny
    
    lda    #$23                 ; st2    #high(VRAM_START)
    sta    [_addr], Y
    iny
    lda    #high(VRAM_START)
    sta    [_addr], Y
    iny
    
    lda    #$03                 ; st0    #$02
    sta    [_addr], Y
    iny
    lda    #$02
    sta    [_addr], Y
    iny
    
    lda    #$13                 ; st1    #$00
    sta    [_addr], Y
    iny
    lda    #$00
    sta    [_addr], Y
    iny
    
    lda    #$23                 ; st2    #$00
    sta    [_addr], Y
    iny
    lda    #$00
    sta    [_addr], Y
    iny
    
    tya
    clc
    adc    <_addr
    sta    <_addr
    lda    <_addr+1
    adc    #$00
    sta    <_addr+1
    
    dex
    bpl    @l0

    lda    #$60         ; rts
    sta    [_addr]
    incw   <_addr
    
    rts

    .include "fade.asm"
    .include "screen0.asm"
    .include "bounce.asm"
    .include "objects.asm"

ramcode_begin:
    .incbin "data/ramcode.bin"
ramcode_end:

    .include "data/ramcode.inc"

    align_org 256
    .code
    .include "math_tbl.asm"
    
    .bank 1
    .org  $6000
    .include "plot.asm"

    .bank 2
    .org $8000
itscoming.dat:
    .incbin "data/itscoming.dat"
itscoming.pal:
    .incbin "data/itscoming.pal"
itscoming.fad:
    .incbin "data/itscoming.fad"
itscoming.f00:
    .db $04, $03, $02, $04, $03, $02, $04, $03, $02, $04, $03, $02
    .db $04, $03, $02, $04, $03, $02, $04, $03, $02, $04, $03, $02
    .db $04, $03, $02, $04, $03, $02, $04, $03, $02, $04, $03, $02
    .db $04, $03, $02, $04, $03, $02, $04, $03, $02, $04, $03, $02
black.fad:
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
datastorm2017.dat:
    .incbin "data/datastorm2017.dat"
weareback.dat:
    .incbin "data/weareback.dat"
    
    .db "Sneaky punk! You found the hidden gold ticket!!!"
    .db "Mail this code: g0ld3n7icK3t-pce to spotup@gmail.com"
    
same.dat:
    .incbin "data/same.dat"
datastorm2017.pal:
    .incbin "data/datastorm2017.pal"
main1.fad:
datastorm2017.fad:
    .incbin "data/datastorm2017.fad"
main0.fad:
    .db $07, $07, $07, smurf.red, smurf.green, smurf.blue, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
main2.fad:
    .db smurf.red, smurf.green, smurf.blue, smurf.red, smurf.green, smurf.blue 
    .db smurf.red, smurf.green, smurf.blue, smurf.red, smurf.green, smurf.blue 
    .db smurf.red, smurf.green, smurf.blue, smurf.red, smurf.green, smurf.blue 
    .db smurf.red, smurf.green, smurf.blue, smurf.red, smurf.green, smurf.blue 
    .db smurf.red, smurf.green, smurf.blue, smurf.red, smurf.green, smurf.blue 
    .db smurf.red, smurf.green, smurf.blue, smurf.red, smurf.green, smurf.blue 
    .db smurf.red, smurf.green, smurf.blue, smurf.red, smurf.green, smurf.blue 
    .db smurf.red, smurf.green, smurf.blue, smurf.red, smurf.green, smurf.blue 

    .bank 3
    .org $A000
alaska.dat:
    .incbin "data/alaska.dat"
    
    .include "data/vgm/song.inc"
