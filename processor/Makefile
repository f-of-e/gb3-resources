DESIGN	= sail
GB3_ROOT = /gb3-resources

sail-nextpnr:
	mkdir -p $(GB3_ROOT)/build
	cp programs/data.hex verilog/
	cp programs/program.hex verilog/
	yosys -q $(GB3_ROOT)/processor/yscripts/$(DESIGN).ys
	nextpnr-ice40 --up5k --package uwg30 --json $(DESIGN).json --pcf pcf/$(DESIGN).pcf --asc $(DESIGN).asc
	icetime -p pcf/sail.pcf -P uwg30 -d up5k -t sail.asc
	icepack $(DESIGN).asc design.bin
	cp design.bin $(GB3_ROOT)/build/


clean:
	rm -f *.json *.blif *.asc *.bin
	rm -f programs/*.hex
	rm -f verilog/*.hex