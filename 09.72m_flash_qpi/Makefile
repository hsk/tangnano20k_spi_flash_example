PROJECT=project
VFILES := $(wildcard *.v)
all: sram

impl/pnr/$(PROJECT).fs: $(VFILES) top.cst
	gw_sh build.tcl

sram: impl/pnr/$(PROJECT).fs
	openFPGALoader --external-flash -o 0x400000 test.txt
	openFPGALoader impl/pnr/$(PROJECT).fs
	make screen
flash: impl/pnr/$(PROJECT).fs
	openFPGALoader -f impl/pnr/$(PROJECT).fs
	make screen

screen:
	screen /dev/tty.usb*1 115200
clean:
	rm -rf impl
