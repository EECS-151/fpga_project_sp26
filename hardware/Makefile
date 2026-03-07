SHELL                   := $(shell which bash) -o pipefail
ABS_TOP                 := $(subst /cygdrive/c/,C:/,$(shell pwd))
SCRIPTS                 := $(ABS_TOP)/scripts
VIVADO                  ?= /share/instsww/xilinx/2025.2/Vivado/bin/vivado
VIVADO_OPTS             ?= -nolog -nojournal -mode batch
FPGA_PART               ?= xczu3eg-sfvc784-2-e
RTL                     += $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/src -type f -name "*.sv"))
CONSTRAINTS             += $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/src -type f -name "*.xdc"))
TOP                     ?= z1top
VCS                     := vcs -full64
VCS_OPTS                := -notice -line +lint=all,noVCDE,noNS,noSVA-UA -sverilog -kdb -timescale=1ns/10ps -debug +define+ABS_TOP=$(ABS_TOP) +incdir+$(ABS_TOP)/src/riscv_core
SIM_RTL                 := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/sim -type f -name "*.sv"))
SIM_MODELS              := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/sim_models -type f -name "*.sv"))
XPM_MODELS              := /share/instsww/xilinx/2025.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv \
                           /share/instsww/xilinx/2025.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv \
                           /share/instsww/xilinx/2025.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv
IVERILOG                := iverilog
IVERILOG_OPTS           := -Ttyp -D IVERILOG=1 -g2012 -gassertions -Wall -Wno-timescale -D ABS_TOP=$(ABS_TOP) -I $(ABS_TOP)/src/riscv_core -I $(ABS_TOP)/sim
VVP                     := vvp
VPD2FSDB                ?= /share/instsww/synopsys-new/verdi/T-2022.06-SP2/bin/vpd2fsdb
VERDI                   ?= /share/instsww/synopsys-new/verdi/T-2022.06-SP2/bin/verdi
ISA_TESTS               := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/../software/riscv-isa-tests -type f -name "*.hex"))
ISA_TESTS_FILES         := $(notdir $(ISA_TESTS))
ISA_TESTS_FST           := $(addprefix sim/isa/,$(subst .hex,.fst,$(ISA_TESTS_FILES)))
C_TESTS                 := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/../software/c_tests -type f -name "*.c"))
C_TESTS_FILES           := $(notdir $(C_TESTS))
C_TESTS_FST             := $(addprefix sim/c_tests/,$(subst .c,.fst,$(C_TESTS_FILES)))

sim/%.tb: sim/%.sv $(RTL) $(SIM_MODELS)
	cd sim && $(VCS) $(VCS_OPTS) -o $*.tb $(RTL) $(SIM_MODELS) $(XPM_MODELS) $*.sv -top $* -top glbl

sim/%.vpd: sim/%.tb
	cd sim && ./$*.tb +verbose=1 +vpdfile+$*.vpd |& tee $*.log

sim/%.fsdb: sim/%.vpd
	cd sim && $(VPD2FSDB) $*.vpd -o $*.fsdb

sim/%.tbi: sim/%.sv $(RTL)
	cd sim && $(IVERILOG) $(IVERILOG_OPTS) -o $*.tbi $*.sv $(RTL) $(SIM_MODELS) 

sim/%.fst: sim/%.tbi
	cd sim && $(VVP) $*.tbi -fst |& tee $*.log

# ISA Tests
sim/isa/isa_tb.tbi: sim/isa_tb.sv $(RTL) $(SIM_MODELS)
	mkdir -p sim/isa
	cd sim/isa && $(IVERILOG) $(IVERILOG_OPTS) -o isa_tb.tbi ../isa_tb.sv $(RTL) $(SIM_MODELS)

sim/isa/%.fst: sim/isa/isa_tb.tbi $(ABS_TOP)/../software/riscv-isa-tests/%.hex
	cd sim/isa && $(VVP) isa_tb.tbi -fst +hex_file=$(word 2,$^) +test_name=$(basename $(notdir $(word 2,$^))) |& tee $(basename $(notdir $(word 2,$^))).log

isa-tests: $(ISA_TESTS_FST)

### UNUSED TESTS IN RUN_ALL_SIMS

# ISA Tests - FPCPU
sim/isa/fpisa_tb.tbi: sim/fpisa_tb.sv $(RTL) $(SIM_MODELS)
	mkdir -p sim/isa
	cd sim/isa && $(IVERILOG) $(IVERILOG_OPTS) -o fpisa_tb.tbi ../fpisa_tb.sv $(RTL) $(SIM_MODELS)

sim/isa/%.fst: sim/isa/fpisa_tb.tbi $(ABS_TOP)/../software/riscv-isa-tests/%.hex
	cd sim/isa && $(VVP) fpisa_tb.tbi -fst +hex_file=$(word 2,$^) +test_name=$(basename $(notdir $(word 2,$^))) |& tee $(basename $(notdir $(word 2,$^))).log

isa-tests-fp: $(ISA_TESTS_FST)

# C Tests
sim/c_tests/c_tests_tb.tbi: sim/c_tests_tb.sv $(RTL) $(SIM_MODELS)
	mkdir -p sim/c_tests
	cd sim/c_tests && $(IVERILOG) $(IVERILOG_OPTS) -o c_tests_tb.tbi ../c_tests_tb.sv $(RTL) $(SIM_MODELS)

sim/c_tests/%.fst: sim/c_tests/c_tests_tb.tbi $(ABS_TOP)/../software/c_tests/%
	cd sim/c_tests && $(VVP) c_tests_tb.tbi -fst +hex_file=$(word 2,$^)/$*.hex +test_name=$(basename $(notdir $(word 2,$^))) |& tee $(basename $(notdir $(word 2,$^))).log

c-tests: $(C_TESTS_FST)

# C Tests - FPCPU
sim/c_tests/fpc_tests_tb.tbi: sim/fpc_tests_tb.sv $(RTL) $(SIM_MODELS) $(XPM_MODELS)
	mkdir -p sim/c_tests
	cd sim/c_tests && $(IVERILOG) $(IVERILOG_OPTS) -o fpc_tests_tb.tbi ../fpc_tests_tb.sv $(RTL) $(SIM_MODELS) $(XPM_MODELS)

sim/c_tests/%.fst: sim/c_tests/fpc_tests_tb.tbi $(ABS_TOP)/../software/c_tests/%
	cd sim/c_tests && $(VVP) fpc_tests_tb.tbi -fst +hex_file=$(word 2,$^)/$*.hex +test_name=$(basename $(notdir $(word 2,$^))) |& tee $(basename $(notdir $(word 2,$^))).log

c-tests: $(C_TESTS_FST)

# Single FP C test: fpmmult
sim/c_tests/fpmmult.fst: sim/c_tests/fpc_tests_tb.tbi $(ABS_TOP)/../software/fpmmult/fpmmult.hex
	cd sim/c_tests && $(VVP) fpc_tests_tb.tbi -fst +hex_file=$(word 2,$^) +test_name=fpmmult |& tee fpmmult.log

fpmmult-test: sim/c_tests/fpmmult.fst

# Single C test: mmult
sim/c_tests/mmult.fst: sim/c_tests/c_tests_tb.tbi $(ABS_TOP)/../software/mmult/mmult.hex
	cd sim/c_tests && $(VVP) c_tests_tb.tbi -fst +hex_file=$(word 2,$^) +test_name=mmult |& tee mmult.log

mmult-test: sim/c_tests/mmult.fst

### END UNUSED TESTS


build/target.tcl: $(RTL) $(CONSTRAINTS)
	mkdir -p build
	truncate -s 0 $@
	echo "set ABS_TOP                        $(ABS_TOP)"    >> $@
	echo "set TOP                            $(TOP)"    >> $@
	echo "set FPGA_PART                      $(FPGA_PART)"  >> $@
	echo "set_param general.maxThreads       4"    >> $@
	echo "set_param general.maxBackupLogs    0"    >> $@
	echo -n "set RTL { " >> $@
	FLIST="$(RTL)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	echo "}" >> $@
	echo -n "set CONSTRAINTS { " >> $@
	FLIST="$(CONSTRAINTS)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	echo "}" >> $@

setup: build/target.tcl

elaborate: build/target.tcl $(SCRIPTS)/elaborate.tcl
	mkdir -p ./build
	cd ./build && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/elaborate.tcl |& tee elaborate.log

build/synth/$(TOP).dcp: build/target.tcl $(SCRIPTS)/synth.tcl
	mkdir -p ./build/synth/
	cd ./build/synth/ && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/synth.tcl |& tee synth.log

synth: build/synth/$(TOP).dcp

build/impl/$(TOP).bit: build/synth/$(TOP).dcp $(SCRIPTS)/impl.tcl
	mkdir -p ./build/impl/
	cd ./build/impl && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/impl.tcl |& tee impl.log

impl: build/impl/$(TOP).bit
all: build/impl/$(TOP).bit

program: build/impl/$(TOP).bit $(SCRIPTS)/program.tcl
	@rm -f $(SCRIPTS)/assign_board_test_log.tmp; \
	assign-fpga-board > $(SCRIPTS)/assign_board_test_log.tmp 2>&1 & \
	ASSIGN_PID=$$!; \
	while ! grep -q "Vivado hw_server port:" $(SCRIPTS)/assign_board_test_log.tmp && ! grep -q "already have an instance" $(SCRIPTS)/assign_board_test_log.tmp; do \
		sleep 0.1; \
	done; \
	if grep -q "already have an instance" $(SCRIPTS)/assign_board_test_log.tmp; then \
		PORT=$$(cat $(SCRIPTS)/port.tmp); \
		SERIAL=$$(cat $(SCRIPTS)/serial.tmp); \
	else \
		sleep infinity | assign-fpga-board > $(SCRIPTS)/assign_board_log.tmp 2>&1 & \
		while ! grep -q "Vivado hw_server port:" $(SCRIPTS)/assign_board_log.tmp && ! grep -q "already have an instance" $(SCRIPTS)/assign_board_log.tmp; do \
			sleep 0.1; \
		done; \
		PORT=$$(grep -oP 'Vivado hw_server port: \K\d+' $(SCRIPTS)/assign_board_log.tmp); \
		SERIAL=$$(grep -oP 'serial \K[A-Z0-9]+' $(SCRIPTS)/assign_board_log.tmp); \
		echo $$PORT > $(SCRIPTS)/port.tmp; \
		echo $$SERIAL > $(SCRIPTS)/serial.tmp; \
		/share/instsww/xilinx/2025.2/Vivado/bin/hw_server -stcp:localhost:$$PORT > /dev/null 2>&1 & \
	fi; \
	echo "BOARD SERIAL: $$SERIAL"; \
	cd build/impl && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/program.tcl -tclargs $$PORT

program-force:
	cd build/impl && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/program.tcl

vivado: build
	cd build && nohup $(VIVADO) </dev/null >/dev/null 2>&1 &

lint:
	verilator -DABS_TOP=$(ABS_TOP) --lint-only --top-module $(TOP) $(RTL) -I$(ABS_TOP)/src/riscv_core $(ABS_TOP)/stubs/PLLE2_ADV.sv $(ABS_TOP)/sim_models/BUFG.sv

sim_build/compile_simlib/synopsys_sim.setup:
	mkdir -p sim_build/compile_simlib
	cd build/sim_build/compile_simlib && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/compile_simlib.tcl

compile_simlib: sim_build/compile_simlib/synopsys_sim.setup

screen:
	screen /dev/ttyUSB0 115200

clean-sim:
	rm -rf *.daidir sim/output.txt \
	sim/*.tb sim/*.daidir sim/csrc \
	sim/ucli.key sim/*.vpd sim/*.svcd \
	sim/*.tbi sim/*.fst sim/*.jou sim/*.log sim/*.out \
	sim/isa sim/c_tests

clean-build:
	rm -rf ./build

.PHONY: setup synth impl program program-force vivado all clean-build clean-sim %.tb
.PRECIOUS: sim/%.tb sim/%.tbi sim/%.fst sim/%.vpd
