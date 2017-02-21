CC      := gcc
ECHO    := echo
RM      := rm
CD      := cd
TAR     := tar

CFLAGS  := -Wall -Wextra -std=gnu11 -I .
DEBUG   ?= 0
ifeq ($(DEBUG), 1)
	OUTDIR := $(OUTDIR)/Debug
	CFLAGS += -g -DDEBUG
else
	OUTDIR := $(OUTDIR)/Release
	CFLAGS += -O2
endif

LIBS   :=  -lm

SRC := utils/print.c paths/bounce.c objects/heart.c objects/torus.c objects/sphere.c objects/import.c
OBJ := $(SRC:.c=.o)

DEPEND = .depend

all: torus sphere heart import bounce

%.o: %.c
	@$(ECHO) "  CC        $@"
	@$(CC) $(CFLAGS) -c -o $@ $<

torus: objects/torus.o utils/print.o
	@$(ECHO) "  LD        $@"
	@$(CC) -o $@ $^ $(LIBS)

sphere: objects/sphere.o utils/print.o
	@$(ECHO) "  LD        $@"
	@$(CC) -o $@ $^ $(LIBS)

heart: objects/heart.o utils/print.o
	@$(ECHO) "  LD        $@"
	@$(CC) -o $@ $^ $(LIBS)

import: objects/import.o
	@$(ECHO) "  LD        $@"
	@$(CC) -o $@ $^ $(LIBS)

bounce: paths/bounce.o utils/print.o
	@$(ECHO) "  LD        $@"
	@$(CC) -o $@ $^ $(LIBS)

clean:
	@$(ECHO) "  CLEAN     object files"
	@find . -name "*.o" -exec $(RM) -f {} \;
