; [todo] move to math.asm
umul32TblLo:
    .db $00, $20, $40, $60, $80, $a0, $c0, $e0
    .db $00, $20, $40, $60, $80, $a0, $c0, $e0
    .db $00, $20, $40, $60, $80, $a0, $c0, $e0
    .db $00, $20, $40, $60, $80, $a0, $c0, $e0

umul32TblHi:
    .db $00, $00, $00, $00, $00, $00, $00, $00
    .db $01, $01, $01, $01, $01, $01, $01, $01
    .db $02, $02, $02, $02, $02, $02, $02, $02
    .db $03, $03, $03, $03, $03, $03, $03, $03
    
; [todo] mul5 table?

;;---------------------------------------------------------------------
; name : msx_instrument_load
; desc : 
; in   : A instrument index
; out  :
;;---------------------------------------------------------------------  
msx_instrument_load:    
    cmp    #$ff
    beq    .nop
.load_inst
        tay
        lda    #INST_ELEMENT_COUNT
        
        phx
        
        jsr    fastmul
        clc
        sax
        adc    #low(instrument_data)
        sta    <_cl
        sax
        adc    #high(instrument_data)
        sta    <_ch
        
        ; restore channel index.
        plx
                
        ldy    #instrument_wav_index
        lda    [_cx], Y
        cmp    <wav_index, X
        beq    .load_pan
.load_wav:
            sta    <wav_index, X
            stx    psg_ch
            
            ; Wav buffers are 32 bytes long.
            ; We'll use tables.
            tay
            clc
            lda    umul32TblLo, Y
            adc    #low(wav_data)
            sta    <_si
            lda    umul32TblHi, Y
            adc    #high(wav_data)
            sta    <_si+1
            
            jsr    copy_wavebuffer
.load_pan:
        ldy    #instrument_pan_index
        lda    [_cx], Y
        ; [todo] pan
        ldy    #instrument_env_index
        lda    [_cx], Y
        ; [todo] store envelope index in order to avoid loading the same envelope twice?
.load_envelope:
        tay
        ; [todo] inline code to save 6*jsr*rts
        jsr    msx_envelope_load
        
.load_gate:
        ldy    #instrument_gat_index
        lda    [_cx], Y 
        sta    channel_delay, X
        ldy    #instrument_vib_index
        lda    [_cx], Y
        ; [todo] vibrato index
        ; [todo] load vibrato
.nop:
    rts
