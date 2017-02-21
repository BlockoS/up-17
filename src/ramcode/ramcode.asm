    .include "../../include/config.inc"
    
mul_tbl = $fa00
sin_tbl = $fc00
cos_tbl = $fc40
    
    .bank   0
    .org    transform_points
ramcode_begin:
    .include "transform.asm"
ramcode_end:
