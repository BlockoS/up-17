;;---------------------------------------------------------------------
; name : msx_balance_update
; desc : Update channel balance.
; in   : 
;        X Channel index.
; out  :
;;---------------------------------------------------------------------    
msx_balance_update:
    ; [todo]
    stx    psg_ch
    lda    #$ff
    sta    psg_pan
    rts

;;---------------------------------------------------------------------
; name : msx_volume_update
; desc : Update channel volume and activate channel.
; in   : envelope_volume Current envelope volume.
;        X Channel index.
; out  :
;;---------------------------------------------------------------------    
msx_volume_update:
    lda    envelope_volume, X
    lsr    A
    lsr    A
    lsr    A
    ora    #PSG_CTRL_CHAN_ON
    stx    psg_ch
    sta    psg_ctrl
    rts

;;---------------------------------------------------------------------    
; name : msx_frequency_update
; desc : Update frequency.
; in   : chn_freq.lo Channel frequency low nibble. 
;        chn_freq.hi Channel frequency high nibble.
;        X Channel index.
; out  :
;;---------------------------------------------------------------------    
msx_frequency_update:
    stx    psg_ch

    ldy    channel_note, X
    ; [todo] portamento
    lda    freq_table.lo, Y
    ; [todo] vibrato.lo
    sta    psg_freq.lo
    lda    freq_table.hi, Y
    ; [todo] vibrato.hi
    sta    psg_freq.hi
    rts
 

;;---------------------------------------------------------------------
; name : msx_channel_update
; desc : Update channel;
; in   : X Channel index.
; out  :
;;---------------------------------------------------------------------    
msx_channel_update:
    ; [todo] tempo
    lda    channel_delay, X
    beq    .release
        dec    channel_delay, X
.update:
        ; [todo] update portamento
        jsr    msx_balance_update
        ; [todo] update vibrato
        jsr    msx_envelope_update
        jsr    msx_volume_update
        jsr    msx_frequency_update
        clc
        rts
.release:
        lda     envelope_volume, X
        beq     .fetch
            lda    #$3                  ; [todo] enums for envelope states
            sta    envelope_state, X
            bra    .update 
.fetch:
    sec
    rts