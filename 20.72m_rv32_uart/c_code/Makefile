SRAM_ADDR_WIDTH = 12
CLK_FREQ = 72000000
COMMONFLAGS = -march=rv32i2p0 -mabi=ilp32
CFLAGS = -mno-save-restore $(COMMONFLAGS) -nostartfiles -nostdlib -static -O1
ASFLAGS = --defsym SRAM_ADDR_WIDTH=$(SRAM_ADDR_WIDTH) $(COMMONFLAGS)
CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
AS = riscv64-unknown-elf-as
LIBS = /usr/lib/gcc/riscv64-unknown-elf/10.2.0/rv32i/ilp32/libgcc.a
ifneq ($(OS),Windows_NT)
ifeq ($(shell uname -s),Darwin)
	LIBS = /opt/homebrew/Cellar/riscv-gnu-toolchain/main/lib/gcc/riscv64-unknown-elf/14.2.0/rv32i/ilp32/libgcc.a
endif
endif

all: impl/prog.bin

impl/prog.bin: impl/prog.elf conv_to_init Makefile
	$(OBJCOPY) impl/prog.elf -O binary impl/prog.bin
	rm -f ../src/inc/mem_init[0-3].ini ../src/inc/sys_parameters.v
	./conv_to_init $(CLK_FREQ) $(SRAM_ADDR_WIDTH) impl/prog.bin

impl/prog.elf: impl/startup.o impl/main.o impl/uart.o
	$(CC) $(CFLAGS) -Tlib/link_cmd.ld -o impl/prog.elf impl/*.o \
          $(LIBS)

impl/startup.o: lib/startup.s
	$(AS) $(ASFLAGS) -o impl/startup.o lib/startup.s

impl/%.o: %.c
	$(CC) $(CFLAGS) -DCLK_FREQ=$(CLK_FREQ) -c $< -o $@

conv_to_init: tools/conv_to_init.c
	gcc -o conv_to_init tools/conv_to_init.c

clean:
	rm -f impl/* *.o conv_to_init
