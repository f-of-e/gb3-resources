DESIGN = hardwareblink
GB3_ROOT = /gb3-resources
sail-nextpnr:
	mkdir -p $(GB3_ROOT)/build
	yosys -p "synth_ice40 -blif $(DESIGN).blif; write_json $(DESIGN).json" $(DESIGN).v
	nextpnr-ice40 --up5k --package uwg30 --json $(DESIGN).json --pcf $(DESIGN).pcf --asc $(DESIGN).asc
	icepack $(DESIGN).asc design.bin
	cp design.bin $(GB3_ROOT)/build/


clean:
	rm -f *.json *.blif *.asc *.bin