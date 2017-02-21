#!/usr/bin/env bash

# parse sym file to extract ROM offsets
ramcode_begin=`grep -rin ramcode_begin ./src/ramcode/ramcode.sym \
    | cut -f 4`
ramcode_end=`grep -rin ramcode_end ./src/ramcode/ramcode.sym \
    | cut -f 4`

# extract ramcode
begin=$((0x${ramcode_begin} & 0x1fff))
end=$((0x${ramcode_end} & 0x1fff))
size=$(expr $end - $begin)
dd if=./src/ramcode/ramcode.pce ibs=1 skip=$begin count=$size of=./data/ramcode.bin

# extract variables
rx=`grep -rin rx ./src/ramcode/ramcode.sym | cut -f 5`
ry=`grep -rin ry ./src/ramcode/ramcode.sym | cut -f 5`
rz=`grep -rin rz ./src/ramcode/ramcode.sym | cut -f 5`

screen_x=`grep -rin screen_x ./src/ramcode/ramcode.sym | cut -f 4`
screen_y=`grep -rin screen_y ./src/ramcode/ramcode.sym | cut -f 4`

vertex_x=`grep -rin vertex_x ./src/ramcode/ramcode.sym | cut -f 4`
vertex_y=`grep -rin vertex_y ./src/ramcode/ramcode.sym | cut -f 4`
vertex_z=`grep -rin vertex_z ./src/ramcode/ramcode.sym | cut -f 4`

cat > ./data/ramcode.inc << EOT
rx = \$${rx}
ry = \$${ry}
rz = \$${rz}
screen_x = \$${screen_x}
screen_y = \$${screen_y}
vertex_x = \$${vertex_x}
vertex_y = \$${vertex_y}
vertex_z = \$${vertex_z}
EOT
