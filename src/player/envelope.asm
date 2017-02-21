;;---------------------------------------------------------------------
; name : msx_envelope_update
; desc : Process current envelope.
; in   : envelope_volume Current envelope volume.
;        envelope_state  Current envelope state.
;        X Channel index.
; out  :
;;---------------------------------------------------------------------
msx_envelope_update:
    lda    envelope_volume, X
    ldy    envelope_state, X
    bne    .decay
.attack:
        clc
        adc    envelope_attack, X
        bcs    .skip
        cmp    #$ff
        bcc    .update
.skip:
            inc    envelope_state, X
            lda    #$ff
            bra    .update
.decay:
    dey
    bne    .sustain
        sec
        sbc    envelope_decay, X
        cmp    envelope_sustain, X
        bcs    .update
            inc    envelope_state, X
            lda    envelope_sustain, X
            bra    .update
.sustain:
    dey
    bne    .release
        lda    envelope_sustain, X
        sta    envelope_volume, X
        rts
.release:
    sec
    sbc    envelope_release, X
    bcs    .update
        cla
.update:
    sta    envelope_volume, X
    rts
    
;;---------------------------------------------------------------------
; name : msx_envelope_load
; desc : Load envelope.
; in   : X Channel index.
;        Y Envelope index.
; out  : envelope_volume  Current envelope volume.
;        envelope_state   Current envelope state.
;        envelope_attack
;        envelope_decay
;        envelope_sustain
;        envelope_release
;;---------------------------------------------------------------------
msx_envelope_load:
    phx
    
    lda    #ENVELOPE_ELEMENT_COUNT
    jsr    fastmul
    sax
    clc
    adc    #low(envelope_data)
    sta    <_si
    sax
    adc    #high(envelope_data)
    sta    <_si+1
    
    plx
    cly
    
    lda    [_si], Y
    sta    envelope_attack, X
    iny
    lda    [_si], Y
    sta    envelope_decay, X
    iny
    lda    [_si], Y
    sta    envelope_sustain, X
    iny
    lda    [_si], Y
    sta    envelope_release, X

    stz    envelope_state, X
    stz    envelope_volume, X

    rts