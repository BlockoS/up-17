    .bss
current.red   .ds 16
current.green .ds 16
current.blue  .ds 16

delta.red   .ds 16
delta.green .ds 16
delta.blue  .ds 16

fade.index .ds 1
    
    .zp
fade.tmp .ds 2

    .code

;;---------------------------------------------------------------------
; name : fade.init
; desc : initialize start palette
; in   : _si source palette
; out  :
;    
fade.init:
    stwz   color_reg ; [todo]

    cly
    clx
@loop:
    lda    [_si], Y
    iny
    asl    A
    asl    A
    asl    A
    sta    <fade.tmp+1
    asl    A
    sta    current.red, X

    lda    [_si], Y
    iny
    sta    <fade.tmp
    asl    A
    asl    A
    asl    A
    asl    A
    sta    current.green, X

    lda    [_si], Y
    iny
    asl    A
    asl    A
    asl    A
    asl    A
    sta    current.blue, X
    
    asl    A
    asl    A
    ora    <fade.tmp
    ora    <fade.tmp+1
    sta    color_data_l
    cla
    rol    A
    sta    color_data_h

    inx
    cpx    #$10
    bne    @loop
    
    rts

;;---------------------------------------------------------------------
; name : fade.begin
; desc : setup deltas
; in   : _si final palette
; out  :
;    
fade.begin:
    cly
@loop:
    lda    current.red, Y
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    sec
    sbc    [_si]
    sta    delta.red, Y
    
    incw   <_si

    lda    current.green, Y
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    sec
    sbc    [_si]
    sta    delta.green, Y
    
    incw   <_si

    lda    current.blue, Y
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    sec
    sbc    [_si]
    sta    delta.blue, Y
    
    incw   <_si

    iny
    cpy    #$10
    bne    @loop

    sty    fade.index
    rts

;;---------------------------------------------------------------------
; name : fade
; desc : update palette
; in   :
; out  :
;
fade:
    lda    fade.index
    beq    @end
    
    dec    fade.index
    
    stwz   color_reg ; [todo]

    clx
@l0:
    sec
    lda    current.red, X
    sbc    delta.red, X
    sta    current.red, X
    and    #$70
    lsr    A
    sta    <fade.tmp
    
    sec
    lda    current.blue, X
    sbc    delta.blue, X
    sta    current.blue, X
    and    #$70
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    sta    <fade.tmp+1

    sec
    lda    current.green, X
    sbc    delta.green, X
    sta    current.green, X
    and    #$70
    asl    A
    asl    A
    ora    <fade.tmp
    ora    <fade.tmp+1
    
    sta    color_data_l
    cla
    rol    A
    sta    color_data_h
    
    inx
    cpx    #$10
    bne    @l0
@end:
    rts
