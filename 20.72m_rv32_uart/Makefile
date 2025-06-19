PROJECT=project
VFILES := $(wildcard src/*.v)
CFILES := $(wildcard c_code/*) $(wildcard c_code/lib/*)
all: sram

impl/pnr/$(PROJECT).fs: $(VFILES) src/top.cst src/inc/sys_parameters.v
	gw_sh build.tcl

src/inc/sys_parameters.v: $(CFILES)
	cd c_code && make
sram: impl/pnr/$(PROJECT).fs
	openFPGALoader impl/pnr/$(PROJECT).fs
	make screen
flash: impl/pnr/$(PROJECT).fs
	openFPGALoader -f impl/pnr/$(PROJECT).fs
	make screen

screen:
	screen /dev/tty.usb*1 115200
clean:
	rm -rf impl
	cd c_code && make clean
