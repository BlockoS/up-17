; [todo] note_update
; [todo] everything else...

;;---------------------------------------------------------------------
; name : msx_pattern_note_load
; desc : 
; in   : X channel index
; out  :
;;---------------------------------------------------------------------  
msx_pattern_note_load:
    lda    pattern_pointer.lo, X
    sta    <player_ptr
    lda    pattern_pointer.hi, X
    sta    <player_ptr+1

    ldy    #pattern_note_index
    lda    [player_ptr], Y
    cmp    #$ff
    bne    .new_note
        lda    tempo
        sta    channel_delay, X
        bra    .read_cmd
.new_note:    
        ; [todo] add transpose
        sta    channel_note, X
            
        ldy    #pattern_instrument_index
        lda    [player_ptr], Y
        jsr    msx_instrument_load

.read_cmd:       
    ldy    #pattern_cmd_name_index
    lda    [player_ptr], Y
    cmp    #$ff
    beq    .next_pattern_entry
        ; [todo] command name
        
        ldy    #pattern_cmd_data_index
        lda    [player_ptr], Y
        ; [todo] command data
       
.next_pattern_entry:
    lda    <pattern_pos, X
    inc    A
    cmp    #MAX_PATTERN_LENGTH
    beq    .fetch
        sta    <pattern_pos, X

        ; go to next pattern entry.
        lda    pattern_pointer.lo, X
        clc
        adc    #PATTERN_ELEMENT_COUNT
        sta    pattern_pointer.lo, X
        lda    pattern_pointer.hi, X
        adc    #0
        sta    pattern_pointer.hi, X
            
        clc
        rts
.fetch:
        sec
        rts

