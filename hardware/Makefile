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
VCS_OPTS                := -fgp -notice -line +lint=all,noVCDE,noNS,noSVA-UA -sverilog -kdb -timescale=1ns/10ps -debug +define+ABS_TOP=$(ABS_TOP) +incdir+$(ABS_TOP)/src/riscv_core
SIM_RTL                 := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/sim -type f -name "*.sv"))
SIM_MODELS              := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/sim_models -type f -name "*.sv"))
# TODO (checkpoint 3) - Add to SIM_MODELS here

XPM_MODELS              := /share/instsww/xilinx/2025.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv \
                           /share/instsww/xilinx/2025.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv \
                           /share/instsww/xilinx/2025.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv
IVERILOG                := iverilog
IVERILOG_OPTS           := -Ttyp -D IVERILOG=1 -g2012 -gassertions -Wall -Wno-timescale -D ABS_TOP=$(ABS_TOP) -I $(ABS_TOP)/src/riscv_core -I $(ABS_TOP)/sim
VVP                     := vvp
VPD2FSDB                ?= /share/instsww/synopsys-new/verdi/T-2022.06-SP2/bin/vpd2fsdb
VERDI                   ?= /share/instsww/synopsys-new/verdi/T-2022.06-SP2/bin/verdi

# ISA Test Variables
ISA_TESTS               := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/../software/riscv-isa-tests -type f -name "*.hex"))
ISA_TESTS_FILES         := $(notdir $(ISA_TESTS))
ISA_TESTS_FST           := $(addprefix sim/isa/,$(subst .hex,.fst,$(ISA_TESTS_FILES)))
ISA_TESTS_VPD           := $(addprefix sim/isa/,$(subst .hex,.vpd,$(ISA_TESTS_FILES)))
ISA_TESTS_FSDB          := $(addprefix sim/isa/,$(subst .hex,.fsdb,$(ISA_TESTS_FILES)))

# C Test Variables
C_TESTS                 := $(subst /cygdrive/c/,C:/,$(shell find $(ABS_TOP)/../software/c_tests -type f -name "*.c"))
C_TESTS_FILES           := $(notdir $(C_TESTS))
C_TESTS_VPD             := $(addprefix sim/c_tests/,$(subst .c,.vpd,$(C_TESTS_FILES)))
C_TESTS_FSDB            := $(addprefix sim/c_tests/,$(subst .c,.fsdb,$(C_TESTS_FILES)))

XILINX_VIVADO := /share/instsww/xilinx/2025.2
UNISIM_LIB    := $(XILINX_VIVADO)/data/verilog/src/unisims
XIL_SIM_ARGS := -v $(UNISIM_LIB)/../glbl.v \
                -v $(UNISIM_LIB)/../retarget/CPU_GENERIC.v \
                -y $(UNISIM_LIB) +libext+.v \
                +incdir+$(UNISIM_LIB)

# ── Generic VCS compile ───────────────────────────────────────────────────────
sim/%.tb: sim/%.sv $(RTL) $(SIM_MODELS)
	cd sim && $(VCS) $(VCS_OPTS) -o $*.tb $(XIL_SIM_ARGS) $(RTL) $(SIM_MODELS) $(XPM_MODELS) $*.sv -top $* -top glbl

sim/%.vpd: sim/%.tb
	cd sim && ./$*.tb +verbose=1 +vpdfile+$*.vpd |& tee $*.log

sim/%.fsdb: sim/%.vpd
	cd sim && $(VPD2FSDB) $*.vpd -o $*.fsdb

verdi: sim/$(TB).fsdb
	$(VERDI) -dbdir sim/$(TB).tb.daidir -ssf sim/$(TB).fsdb &

# ── ISA Tests (VCS) ───────────────────────────────────────────────────────────
sim/isa/isa_tb.tb: sim/isa_tb.sv $(RTL) $(SIM_MODELS)
	@mkdir -p sim/isa
	@cd sim/isa && $(VCS) $(VCS_OPTS) +incdir+$(ABS_TOP)/sim -o isa_tb.tb $(XIL_SIM_ARGS) $(RTL) $(SIM_MODELS) $(XPM_MODELS) ../isa_tb.sv -top isa_tb -top glbl > isa_tb_compile.log 2>&1

sim/isa/%.vpd: sim/isa/isa_tb.tb $(ABS_TOP)/../software/riscv-isa-tests/%.hex
	@cd sim/isa && ./isa_tb.tb +verbose=1 +hex_file=$(word 2,$^) +test_name=$(basename $(notdir $(word 2,$^))) +vpdfile+$(ABS_TOP)/sim/isa/$*.vpd > $(basename $(notdir $(word 2,$^))).log 2>&1

sim/isa/%.fsdb: sim/isa/%.vpd
	@cd sim/isa && $(VPD2FSDB) $*.vpd -o $*.fsdb > /dev/null 2>&1

isa-tests-vcs: $(ISA_TESTS_FSDB)
	@echo ""
	@echo "============================================================"
	@echo " VCS ISA Test Results"
	@echo "============================================================"
	@printf "%-30s %8s  %s\n" "TEST" "CYCLES" "RESULT"
	@printf "%-30s %8s  %s\n" "----" "------" "------"
	@total=0; passed=0; failed=0; timeout=0; \
	for vpd in $(ISA_TESTS_VPD); do \
		test=$$(basename $$vpd .vpd); \
		log=sim/isa/$$test.log; \
		total=$$((total + 1)); \
		if [ ! -f $$log ]; then \
			printf "%-30s %8s  %s\n" "$$test" "-" "NO LOG"; \
		elif grep -q "\[passed\]" $$log; then \
			cycles=$$(grep "\[passed\]" $$log | grep -oP 'in\s+\K[0-9]+'); \
			printf "%-30s %8s  %s\n" "$$test" "$$cycles" "PASSED"; \
			passed=$$((passed + 1)); \
		elif grep -q "\[failed\]" $$log; then \
			printf "%-30s %8s  %s\n" "$$test" "-" "FAILED"; \
			failed=$$((failed + 1)); \
		elif grep -qiE "TIMEOUT|simulation time limit" $$log; then \
			printf "%-30s %8s  %s\n" "$$test" "-" "TIMEOUT"; \
			timeout=$$((timeout + 1)); \
		else \
			printf "%-30s %8s  %s\n" "$$test" "-" "UNKNOWN"; \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	echo "============================================================"; \
	printf "Total: $$total  |  Passed: $$passed  |  Failed: $$failed  |  Timeout: $$timeout\n"; \
	echo "============================================================"

isa-tests-vcs-fsdb: $(ISA_TESTS_FSDB)


# ── C Tests (VCS) ─────────────────────────────────────────────────────────────
sim/c_tests/c_tests_tb.tb: sim/c_tests_tb.sv $(RTL) $(SIM_MODELS)
	@mkdir -p sim/c_tests
	@cd sim/c_tests && $(VCS) $(VCS_OPTS) +incdir+$(ABS_TOP)/sim -o c_tests_tb.tb $(XIL_SIM_ARGS) $(RTL) $(SIM_MODELS) $(XPM_MODELS) ../c_tests_tb.sv -top c_tests_tb -top glbl > c_tests_tb_compile.log 2>&1

sim/c_tests/%.vpd: sim/c_tests/c_tests_tb.tb $(ABS_TOP)/../software/c_tests/%
	@cd sim/c_tests && ./c_tests_tb.tb +verbose=1 +hex_file=$(word 2,$^)/$*.hex +test_name=$(basename $(notdir $(word 2,$^))) +vpdfile+$(ABS_TOP)/sim/c_tests/$*.vpd > $(basename $(notdir $(word 2,$^))).log 2>&1

sim/c_tests/%.fsdb: sim/c_tests/%.vpd
	@cd sim/c_tests && $(VPD2FSDB) $*.vpd -o $*.fsdb > /dev/null 2>&1

c-tests: $(C_TESTS_FSDB)

# ── C Tests - FPCPU (VCS) ─────────────────────────────────────────────────────
sim/c_tests/fpc_tests_tb.tb: sim/fpc_tests_tb.sv $(RTL) $(SIM_MODELS) $(XPM_MODELS)
	@mkdir -p sim/c_tests
	@cd sim/c_tests && $(VCS) $(VCS_OPTS) +incdir+$(ABS_TOP)/sim -o fpc_tests_tb.tb $(XIL_SIM_ARGS) $(RTL) $(SIM_MODELS) $(XPM_MODELS) ../fpc_tests_tb.sv -top fpc_tests_tb -top glbl > fpc_tests_tb_compile.log 2>&1

sim/c_tests/fpmmult.vpd: sim/c_tests/fpc_tests_tb.tb $(ABS_TOP)/../software/fpmmult/fpmmult.hex
	@cd sim/c_tests && ./fpc_tests_tb.tb +verbose=1 +hex_file=$(word 2,$^) +test_name=fpmmult +vpdfile+$(ABS_TOP)/sim/c_tests/fpmmult.vpd > fpmmult.log 2>&1

fpmmult-test: sim/c_tests/fpmmult.fsdb

# ── FPGA Build Targets ────────────────────────────────────────────────────────
# ── FPGA Build Targets ────────────────────────────────────────────────────────
build/target.tcl: $(RTL) $(CONSTRAINTS)
	mkdir -p build
	truncate -s 0 $@
	echo "set ABS_TOP      $(ABS_TOP)"      >> $@
	echo "set TOP          $(TOP)"          >> $@
	echo "set FPGA_PART    $(FPGA_PART)"    >> $@
	echo "set_param general.maxThreads   4" >> $@
	echo "set_param general.maxBackupLogs 0" >> $@
	echo -n "set RTL { " >> $@
	FLIST="$(RTL)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	echo "}" >> $@
	echo -n "set CONSTRAINTS { " >> $@
	FLIST="$(CONSTRAINTS)"; for f in $$FLIST; do echo -n "$$f " ; done >> $@
	echo "}" >> $@

setup: build/target.tcl

# Actual Synthesis Recipe
build/synth/$(TOP).dcp: build/target.tcl $(SCRIPTS)/synth.tcl
	mkdir -p ./build/synth/
	cd ./build/synth/ && $(VIVADO) $(VIVADO_OPTS) -source $(SCRIPTS)/synth.tcl |& tee synth.log

synth: build/synth/$(TOP).dcp

# Actual Implementation Recipe
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

.PHONY: setup synth impl program program-force vivado all clean-build clean-sim isa-tests isa-tests-vcs isa-tests-vcs-fsdb %.tb
.PRECIOUS: sim/%.tb sim/%.tbi sim/%.fst sim/%.vpd sim/isa/isa_tb.tb sim/isa/%.vpd sim/isa/%.fsdb
