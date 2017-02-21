; [todo] constant for digit and letters

;;---------------------------------------------------------------------
; font.asm : font display routines
;
; (c) 2007 Vincent 'MooZ' Cruz
; (c) 2011 Vincent 'MooZ' Cruz
;
; LICENCE: [TODO]
;
;
; Routine list :
;   * putchar      Display a character.
;   * putdigit     Display a decimal digit [0,10]
;   * putbcd       Display a bcd number.
;   * putnumber8   Display a 8 bits decimal [0,255].
;   * putnumber16  Display a 16 bits decimal [0,65535].
;   * putstring    Display a null (0) terminated string.
;   * puthex       Display an 8 bits hexadecimal number.
;   * putnote      Display a note in english notation.
;;---------------------------------------------------------------------

    .zp
_font_base  .ds 2   ; font base vram address

    .code
DIGIT_START = $30
CHAR_START  = $41
    
;;---------------------------------------------------------------------
; name : load_font_1bpp
;
; description : Load a 8x8 1bpp font and set font base address for text
;               display routines.
;               The first 96 characters of the font must match the ones
;               of the [$20,$7A] range of the ASCII table. 
;
; in : _di = VRAM address
;      _bl data bank
;      _si data memory location
;      _cx number of bytes to copy
;      A   byte value for plane #1
;      X   byte value for plane #2
;      Y   byte value for plane #3
;;---------------------------------------------------------------------
load_font_1bpp:
    pha
    phx
    phy
    
    ; _font_base.w = <_di.w >> 4
    lda    <_di+1
    sta    <_font_base+1
    
    lda    <_di
    lsr    <_font_base+1
    ror    A
    lsr    <_font_base+1
    ror    A
    lsr    <_font_base+1
    ror    A
    lsr    <_font_base+1
    ror    A
    sta    <_font_base
    
    ply
    plx
    pla
    
    jmp    load_vram_1bpp

;;---------------------------------------------------------------------
; name : set_font_palette
;
; description: set font palette
;
; in :  A = palette to use
;;---------------------------------------------------------------------
set_font_palette
    ; font_base[1] = (A << 4) | (font_base[1] & 0x0f)
    asl    A
    asl    A
    asl    A
    asl    A
    sta    <_al
    lda    <_font_base+1
    and    #$0F
    ora    <_al
    sta    <_font_base+1    
    
    rts

;;---------------------------------------------------------------------
; name : _putchar (macro)
;
; description: Display a character.
;
; in :   A = Character to print
;      _bl = Palette
;;---------------------------------------------------------------------
_putchar .macro
    clc
    adc     <_font_base
    sta     video_data_l
    cla
    adc     <_font_base+1
    ora     <_bl
    sta     video_data_h
    .endm
    
;;---------------------------------------------------------------------
; name : putchar
;
; description: Display a character.
;              The char should've been scaled so that its value is in
;              the supported character range.
;              The VRAM write register must point to a valid BAT
;              location.
;
; in :   A = Character to print
;      _bl = Palette
;;---------------------------------------------------------------------
putchar:
    _putchar
    rts
    
;;---------------------------------------------------------------------
; name : _putdigit (macro)
;
; description: Display a decimal digit.
;
; in :   A = digit to print
;      _bl = Palette
;;---------------------------------------------------------------------
_putdigit .macro
    clc
    adc     #DIGIT_START
    _putchar
    .endm
    
;;---------------------------------------------------------------------
; name : putdigit
;
; description: Display a decimal digit [0,10].
;              The VRAM write register must point to a valid BAT
;              location.
;
; in :   A = number to display [0,10]
;      _bl = Palette
;;---------------------------------------------------------------------
putdigit:
    _putdigit
    rts

;;---------------------------------------------------------------------
; name : putbcd
;
; description: Display a bcd number.
;
; in : _bcd Array of BCD encoded number
;      X BCD array top element index
;      _bl = Palette
;;---------------------------------------------------------------------
putbcd:
_putbcd_hi:
    lda     _bcd, X
    lsr     A
    lsr     A
    lsr     A
    lsr     A
    _putdigit   

_putbcd_lo:
    lda     _bcd, X
    and     #$0f
    _putdigit
    
    dex
    bpl     _putbcd_hi
    
    rts

;;---------------------------------------------------------------------
; name : putnumber8
;
; description: Display an 8 bits decimal number [0,255].
;              The VRAM write register must point to a valid BAT
;              location.
;
; in :   A = number to display [0,255]
;      _bl = Palette
;;---------------------------------------------------------------------
putnumber8:
    ; Convert binary number to bcd (8 bits).
    jsr    binbcd8

    ; Only the 4th first bits of byte 1 are set for 8bits number.
    ldx    #1
    jmp    _putbcd_lo

;----------------------------------------------------------------------
; name : putnumber16
;
; description: Display a 16 bits decimal [0,65535].
;              The VRAM write register must point to a valid BAT
;              location.
;
; in : A/X = number to display [0,65535]
;      _bl = Palette
;;---------------------------------------------------------------------
putnumber16:
    ; Convert binary number to bcd (16 bits).
    jsr    binbcd16

    ; Only the 4th first bits of byte 2 are set for 16bits number.
    ldx    #2
    jmp    _putbcd_lo      

;;---------------------------------------------------------------------
; name : putstring
;
; description: Display a null (0) terminated string.
;              The characters must have been previously converted to 
;              fit to current font. Currently line feed and carriage
;              return are not supported. No clamping is performed. And
;              last but not least, the string must not exceed 256 char. 
;              String bank must have been previously mapped.
;              The VRAM write register must point to a valid BAT
;              location.
;
; in : _si = string address
;      _bl = Palette
;;---------------------------------------------------------------------
putstring:
    cly
.putstring_0:
    lda     [_si],Y         ; Get char
    beq     .putstring_1    ; Check for '\0' character
    
    _putchar
    
    iny                     ; Go to next char
    bne .putstring_0        ; Max 256 char
.putstring_1:
    rts

;;---------------------------------------------------------------------
; name : _puthex (macro)
;
; description: Display a hexadecimal digit [0-15].
;              The VRAM write register must point to a valid BAT
;              location.
;
; in :   A = Hexadecimal digit to display
;      _bl = Palette
;;---------------------------------------------------------------------    
_puthex .macro
    cmp    #$0A
    bcc    .put_hex\@
        ; Remember that the carry flag is set. 1 will be added to 
        ; adc operand.
        adc    #(CHAR_START - DIGIT_START - 10 - 1)
.put_hex\@:
    _putdigit
    .endm
    
;;----------------------------------------------------------------------
; name : puthex
;
; description: Display an 8 bits hexadecimal number.
;              The VRAM write register must point to a valid BAT
;              location.
;
; in :   A = Number to display
;      _bl = Palette
;;---------------------------------------------------------------------
puthex:
    pha                                 ; High nibble
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    _puthex
    
    pla
    and    #$0F                        ; Low nibble
    _puthex
    rts

;;----------------------------------------------------------------------
; name : putnote
;
; description: Display a note using english notation.
;
; in :   A = Note to display (octave + note)
;      _bl = Palette
;;---------------------------------------------------------------------
putnote:
    ; Check for "no note"
    cmp    #$ff
    beq    .no_note
    
    pha
    ; Note
    and    #$0F
    tax
    lda    tone_data, X
    _putchar
    lda    tone_data+12, X
    _putchar
    
    ; Octave
    pla
    lsr    A
    lsr    A
    lsr    A
    lsr    A
    _putdigit
    rts

.no_note:
    lda    #$0d
    _putchar
    sta     video_data_h
    sta     video_data_h
    rts
    
tone_data:
    ;    C-   C#   D-   D#   E-   F-   F#   G-   G#   A-   A#   B-
    .db $23, $23, $24, $24, $25, $26, $26, $27, $27, $21, $21, $22
    .db $0d, $03, $0d, $03, $0d, $0d, $03, $0d, $03, $0d, $03, $0d 
