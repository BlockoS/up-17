VRAM_START  = $2000
POINT_COUNT = 96

clear_vram       = $2800
transform_points = $3000

smurf.red   = 1
smurf.green = 3
smurf.blue  = 5
smurf.color = ((smurf.green << 6) | (smurf.red << 3) | smurf.blue)
