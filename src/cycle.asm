    .zp
cycle_index .ds 1
palette.index .ds 2

    .bss

palette.lo .ds 16
palette.hi .ds 16

    .code
    
;;---------------------------------------------------------------------
; name : cycle.init
; desc : initialize cycling effect
; in   : _si source palette
;          A palette id
; out  :
;    
cycle.init:
    stz    <palette.index+1
    asl    A
    asl    A
    asl    A
    asl    A
    sta    <palette.index
    rol    <palette.index+1
    incw   <palette.index
    
    cly
    clx
@copy
    lda    [_si], Y
    sta    palette.lo, X
    iny
    
    lda    [_si], Y
    sta    palette.hi, X
    iny
    
    inx
    cpx    #16
    bne    @copy
    
    lda    #$ff
    sta    <cycle_index
    
;;---------------------------------------------------------------------
; name : cycle
; desc : cycle palette colors except color #0.
;        color #i takes the value of color #i+1.
; in   : 
; out  :
;    
cycle:
    stw    <palette.index, color_reg
    
    lda    <cycle_index
    inc    A
    cmp    #15
    bne    @l0
        cla
@l0:
    sta    <cycle_index
    
    tax
@l1
    lda    palette.lo, X
    sta    color_data_l
    
    lda    palette.hi, X
    sta    color_data_h

    inx
    cpx    #$15
    bne    @l1

    clx
@l2:
    cpx    <cycle_index
    beq    @end
    
    lda    palette.lo, X
    sta    color_data_l
    
    lda    palette.hi, X
    sta    color_data_h
    
    inx
    bra    @l2
    
@end:
    rts
