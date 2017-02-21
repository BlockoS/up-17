    .zp
satb_addr .ds 2

    .code
;;---------------------------------------------------------------------
; name : sprite_load
; desc : Copy sprite data to VRAM
; in   :   X number of 16x16 blocs to copy
;        _si source
;        _di VRAM address
; out  :
;
sprite_load:
    lda    #MEMCPY_SRC_INC_DEST_ALT
    sta    _hrdw_memcpy_mode
    stw    <_si, _hrdw_memcpy_src
    stw    #video_data_l, _hrdw_memcpy_dst
    stw    #64, _hrdw_memcpy_len

    st0    #$00
    stw    <_di, video_data

@l0:
    st0    #$02
    jsr    hrdw_memcpy
    addw   #64, _hrdw_memcpy_src
    dex
    bne    @l0
    
    rts

;;---------------------------------------------------------------------
; name : satb_load
; desc : Copy sprite attribute table to VRAM
; in   :   X SATB entry count
;        _si source
;        _di VRAM address
; out  :
;
satb_load:
    stw    <_si, _hrdw_memcpy_src
    txa
    asl    A
    asl    A
    asl    A
    sta    _hrdw_memcpy_len
    cla
    rol    A
    sta    _hrdw_memcpy_len+1
    lda    <_di
    sta    <satb_addr
    sta    _hrdw_memcpy_dst
    lda    <_di+1
    sta    <satb_addr+1
    sta    _hrdw_memcpy_dst+1
    jmp    hrdw_memcpy

SPRITE_FLIP_Y    = %1_000_0000
SPRITE_FLIP_X    = %0000_1_000
SPRITE_HEIGHT_16 = %0_00_0_0000
SPRITE_HEIGHT_32 = %0_01_0_0000
SPRITE_HEIGHT_64 = %0_10_0_0000
SPRITE_WIDTH_16  = %0000_000_0
SPRITE_WIDTH_32  = %0000_000_1

SPRITE_PRIORITY_HI = %1_000_0000
SPRITE_PRIORITY_LO = %1_000_0000
