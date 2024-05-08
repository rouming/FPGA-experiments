APICULA        ?= ../apicula
YOSYS          ?= ../yosys/yosys
NEXTPNR        ?= ../nextpnr/nextpnr-himbaechel
OPENFPGALOADER ?= ../openFPGALoader/build/openFPGALoader
GOWIN_PACK     ?= gowin_pack

BOARD   ?= tangnano20k
DEVICE  ?= GW2AR-LV18QN88C8/I7
FAMILY  ?= GW2A-18C
LEDS_NR ?= 6

OUTDIR = out

PROJECTS = lfsr square-wave
lfsr_SRCS = lfsr.sv
square-wave_SRCS = square-wave.sv

all: $(patsubst %,$(OUTDIR)/%.fs,$(PROJECTS))

%: $(OUTDIR)/%.fs ;

sim-%:
	iverilog -DTESTBENCH -o $(OUTDIR)/$*.isim -s testbench -g2012 $*.sv
	$(OUTDIR)/$*.isim

flash-%: $(OUTDIR)/%.fs
	$(OPENFPGALOADER) -b $(BOARD) $<

$(OUTDIR)/%.fs: $(OUTDIR)/%.json.pnr
	$(GOWIN_PACK) -d $(FAMILY) -o $@ $<

$(OUTDIR)/%.json.pnr: $(OUTDIR)/%.json $(APICULA)/examples/himbaechel/$(BOARD).cst
	$(NEXTPNR) --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(APICULA)/examples/himbaechel/$(BOARD).cst

.SECONDEXPANSION:
$(OUTDIR)/%.json: $$(%_SRCS) | $(OUTDIR)
	$(YOSYS) -D LEDS_NR=$(LEDS_NR) -p "read_verilog -sv $^; synth_gowin -json $@"

$(OUTDIR):
	mkdir -p $(OUTDIR)

clean:
	$(RM) $(OUTDIR)/*

# Don't delete intermediate files
.PRECIOUS: $(OUTDIR)/%.json $(OUTDIR)/%.json.pnr

.PHONY: clean all
