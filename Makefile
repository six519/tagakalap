AS := nasm

BIN := tagakalap
SRC := $(wildcard *.asm)
OBJ := ${SRC:%.asm=%.o}

ASFLAGS += -felf64

${BIN}: ${OBJ}
	gcc -no-pie -g -o $@ $^

%.o: %.asm
	$(AS) -o $@ $(ASFLAGS) $<

clean:
	$(RM) ${BIN} ${OBJ}

.PHONY: clean