AS = ~/Dev/bin/pceas
SRCDIR = ./src
INCLUDE = -I . -I ./src/ -I ./include/
EMU = mednafen

main.pce:
	$(AS) -l 3 $(INCLUDE) -I ./src/ramcode/ -raw ./src/ramcode/ramcode.asm
	@bash ./tools/ramcode.sh
	$(AS) -l 3 $(INCLUDE) -raw ./src/main.asm 

run:
#	$(EMU) $(SRCDIR)/main.pce

clean:
#	rm $(SRCDIR)/*.sym
