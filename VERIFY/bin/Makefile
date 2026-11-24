#===============================================================================
# MIPI DSI - VCS / UVM Makefile
#===============================================================================

# GIT_HOME defaults to the repo that contains this bin/ directory. A value from
# the environment or command line is used only if it really points at the repo.
GIT_HOME ?= $(abspath $(CURDIR)/../..)
ifeq ($(wildcard $(GIT_HOME)/RTL/design.sv),)
    override GIT_HOME := $(abspath $(CURDIR)/../..)
endif
ifeq ($(wildcard $(GIT_HOME)/RTL/design.sv),)
    $(error GIT_HOME ($(GIT_HOME)) does not contain RTL/design.sv)
endif

#-------------------------------------------------------------------------------
# TOOL PATHS
#-------------------------------------------------------------------------------

VCS_HOME   ?= /tools/synopsys/vcs/R-2020.12-SP2
VERDI_HOME ?= /tools/synopsys/verdi/R-2020.12-SP2
RTL_HOME   ?= $(GIT_HOME)/RTL
TB_HOME    ?= $(GIT_HOME)/VERIFY
VIP_HOME   ?= /tools/synopsys/vc-vip_vV-2023.12/vip

# Tool environment, so make works without sourcing tool_setup.csh first
export VCS_HOME VERDI_HOME
export DESIGNWARE_HOME      ?= /tools/synopsys/vc-vip_vV-2023.12
export SNPSLMD_LICENSE_FILE ?= 27000@$(shell hostname -s)
export PATH := $(VCS_HOME)/bin:$(VERDI_HOME)/bin:$(PATH)

#-------------------------------------------------------------------------------
# TEST / RUN OPTIONS
#-------------------------------------------------------------------------------

UVM_TEST ?= mipi_test
SEED     ?= random
GUI      ?= 0

#-------------------------------------------------------------------------------
# SEED
#-------------------------------------------------------------------------------

ifeq ($(SEED),random)
    COMMON_RUN_OPTS += +ntb_random_seed_automatic
else
    COMMON_RUN_OPTS += +ntb_random_seed=$(SEED)
endif

#-------------------------------------------------------------------------------
# GUI
#-------------------------------------------------------------------------------

ifeq ($(GUI),1)
    COMMON_COMPILE_OPTS += -debug_access+drivers+line+class
    COMMON_RUN_OPTS     += -gui
    COMMON_RUN_OPTS     += -lca
endif

#===============================================================================
# COVERAGE
#===============================================================================

# Functional coverage comes from the scoreboard covergroups (dc_cg, ppi_cg),
# sampled explicitly in sb.sv. Only assertion coverage is enabled in VCS;
# code coverage (line/cond/fsm/tgl/branch) is left off.

COVERAGE_OPTS = assert

#-------------------------------------------------------------------------------
# Compilation Options
#-------------------------------------------------------------------------------

COMMON_COMPILE_OPTS += -full64
COMMON_COMPILE_OPTS += -sverilog
COMMON_COMPILE_OPTS += -l ./logs/compile.log
COMMON_COMPILE_OPTS += -lca
COMMON_COMPILE_OPTS += -kdb
COMMON_COMPILE_OPTS += +nospecify
COMMON_COMPILE_OPTS += +notimingchecks
COMMON_COMPILE_OPTS += +lint=none
COMMON_COMPILE_OPTS += -timescale=1ns/1ns
COMMON_COMPILE_OPTS += -debug_access+f
COMMON_COMPILE_OPTS += -partcomp=autopart_low
COMMON_COMPILE_OPTS += -fastpartcomp=j8
COMMON_COMPILE_OPTS += +libext+.v+.sv
COMMON_COMPILE_OPTS += -CFLAGS "-DVCS -fPIC"
COMMON_COMPILE_OPTS += +warn=noLCA_FEATURES_ENABLED

#-------------------------------------------------------------------------------
# ASSERTION COVERAGE ONLY
#-------------------------------------------------------------------------------

COMMON_COMPILE_OPTS += -cm assert

#-------------------------------------------------------------------------------
# TOP
#-------------------------------------------------------------------------------

COMMON_COMPILE_OPTS += -top top

#===============================================================================
# RTL
#===============================================================================

RTL_COMPILE_OPTS += +incdir+$(RTL_HOME)
RTL_COMPILE_OPTS += $(RTL_HOME)/design.sv

#===============================================================================
# AHB VIP
#===============================================================================

# Project VIP model directory, generated from the installed VIP by dw_vip_setup (make vip)
VIP_DIR ?= $(CURDIR)/vip

VIP_COMPILE_OPTS += +incdir+$(VIP_DIR)
VIP_COMPILE_OPTS += +incdir+$(VIP_DIR)/include/sverilog
VIP_COMPILE_OPTS += +incdir+$(VIP_DIR)/src/sverilog/vcs

VIP_COMPILE_OPTS += +define+SVT_VENDOR_LC=vcs
VIP_COMPILE_OPTS += +define+SVT_VENDOR=VCS

VIP_COMPILE_OPTS += +incdir+$(VIP_HOME)/svt/common/V-2023.12/sverilog
VIP_COMPILE_OPTS += +incdir+$(VIP_HOME)/svt/common/V-2023.12/sverilog/include
VIP_COMPILE_OPTS += +incdir+$(VIP_HOME)/svt/common/V-2023.12/sverilog/src
VIP_COMPILE_OPTS += +incdir+$(VIP_HOME)/svt/common/V-2023.12/sverilog/src/vcs

VIP_COMPILE_OPTS += +incdir+$(VIP_HOME)/svt/amba_svt
VIP_COMPILE_OPTS += +incdir+$(VIP_HOME)/svt/amba_svt/V-2023.12
VIP_COMPILE_OPTS += +incdir+$(VIP_HOME)/svt/amba_svt/V-2023.12/sverilog/src
VIP_COMPILE_OPTS += +incdir+$(VIP_HOME)/svt/amba_svt/V-2023.12/sverilog/include

VIP_COMPILE_OPTS += +incdir+$(VIP_HOME)/svt/amba_svt/V-2023.12/ahb_system_env_svt/sverilog/src

VIP_COMPILE_OPTS += +define+SVT_UVM_TECHNOLOGY
VIP_COMPILE_OPTS += +define+UVM_DISABLE_AUTO_ITEM_RECORDING
VIP_COMPILE_OPTS += +define+SYNOPSYS_SV

#===============================================================================
# UVM TB
#===============================================================================

TB_COMPILE_OPTS += -ntb_opts uvm-1.2

#-------------------------------------------------------------------------------
# UVM TB Directories
#-------------------------------------------------------------------------------

TB_COMPILE_OPTS += +incdir+$(TB_HOME)/uvm_tb/sb
TB_COMPILE_OPTS += +incdir+$(TB_HOME)/uvm_tb/env
TB_COMPILE_OPTS += +incdir+$(TB_HOME)/uvm_tb/test

#-------------------------------------------------------------------------------
# Agents
#-------------------------------------------------------------------------------


TB_COMPILE_OPTS += +incdir+$(TB_HOME)/uvc/agent_top/ahb_agent
TB_COMPILE_OPTS += +incdir+$(TB_HOME)/uvc/agent_top/dc_agent
TB_COMPILE_OPTS += +incdir+$(TB_HOME)/uvc/agent_top/ppi_agent

#-------------------------------------------------------------------------------
# Interfaces
#-------------------------------------------------------------------------------

TB_COMPILE_OPTS += $(TB_HOME)/uvc/agent_top/dc_agent/dc_if.sv
TB_COMPILE_OPTS += $(TB_HOME)/uvc/agent_top/ppi_agent/ppi_if.sv

#-------------------------------------------------------------------------------
# Test Package
#-------------------------------------------------------------------------------

TB_COMPILE_OPTS += $(TB_HOME)/uvm_tb/test/test_pkg.sv

#-------------------------------------------------------------------------------
# TOP
#-------------------------------------------------------------------------------

TB_COMPILE_OPTS += +incdir+$(TB_HOME)/bench
TB_COMPILE_OPTS += $(TB_HOME)/bench/top.sv

#===============================================================================
# RUNTIME OPTIONS
#===============================================================================

# VGA/HD/FULL_HD tests move millions of pixels: per-pixel messages and FSDB would be
# many GB, so they default to UVM_LOW with the per-pixel SB_MATCH message off and no
# dump (override with VERBOSITY=/DUMP=).
BIG_TESTS = resol_random_test resol_vga_test resol_hd_test resol_fullhd_test
ifneq ($(filter $(UVM_TEST),$(BIG_TESTS)),)
    VERBOSITY ?= UVM_LOW
    DUMP      ?= 0
    COMMON_RUN_OPTS += +uvm_set_verbosity=uvm_test_top.e_h.sb_h,SB_MATCH,UVM_NONE,run
endif
VERBOSITY ?= UVM_MEDIUM
DUMP      ?= 1

COMMON_RUN_OPTS += +UVM_NO_RELNOTES
COMMON_RUN_OPTS += +print_uvm_hier
COMMON_RUN_OPTS += +UVM_VERBOSITY=$(VERBOSITY)
ifeq ($(DUMP),1)
    COMMON_RUN_OPTS += +ENABLE_DUMP
endif

#-------------------------------------------------------------------------------
# ASSERTION COVERAGE DURING SIMULATION
#-------------------------------------------------------------------------------

COMMON_RUN_OPTS += -cm assert

#===============================================================================
# TEST TARGETS
#===============================================================================

.PHONY: help info clean vip compile run report functional_cov assertion_cov cov all regress run_test0 run_test1 run_test2 run_test3 run_test4 run_test5 run_test6 run_test7 run_test8 run_test9 run_test10 run_test11 run_test12 run_test13 run_test14 run_test15 run_test16 run_test17 run_test18 run_test19 run_test20 run_test21 run_test22 run_test23 run_test24 run_test25 run_test26

help:
	@echo ""
	@echo "MIPI DSI VCS/UVM Makefile"
	@echo "Usage: make <target> [GIT_HOME=/path/to/repo] [SEED=random|number]"
	@echo ""
	@echo "General targets:"
	@echo "  make compile        Compile RTL + UVM testbench"
	@echo "  make run            Run selected test (UVM_TEST=class_name)"
	@echo "  make regress        Compile once, then run every listed test separately"
	@echo "  make all            Clean + compile + run default test + report"
	@echo "  make clean          Remove generated files and logs"
	@echo "  make info           Show Makefile variables"
	@echo ""
	@echo "Individual test targets:"
	@echo "  make run_test0       mipi_test  (Base MIPI test)"
	@echo "  make run_test1       lane_0_test  (Lane 0)"
	@echo "  make run_test2       lane_1_test  (Lane 1)"
	@echo "  make run_test3       lane_2_test  (Lane 2)"
	@echo "  make run_test4       lane_3_test  (Lane 3)"
	@echo "  make run_test5       dsi_frame5_test  (DSI frame 5)"
	@echo "  make run_test6       frame_10_test  (Frame 10)"
	@echo "  make run_test7       vsync_random_test  (Random VSYNC)"
	@echo "  make run_test8       vsync_5_test  (VSYNC 5)"
	@echo "  make run_test9       vsync_10_test  (VSYNC 10)"
	@echo "  make run_test10      pixel_random_test  (Random pixel)"
	@echo "  make run_test11      pixel_white_test  (White pixel)"
	@echo "  make run_test12      pixel_black_test  (Black pixel)"
	@echo "  make run_test13      pixel_red_test  (Red pixel)"
	@echo "  make run_test14      pixel_green_test  (Green pixel)"
	@echo "  make run_test15      pixel_blue_test  (Blue pixel)"
	@echo "  make run_test16      pixel_low_test  (Low pixel)"
	@echo "  make run_test17      pixel_high_test  (High pixel)"
	@echo "  make run_test18      resol_random_test  (Random resolution)"
	@echo "  make run_test19      resol_normal_test  (Normal resolution)"
	@echo "  make run_test20      resol_hd_test  (HD resolution)"
	@echo "  make run_test21      resol_fullhd_test  (Full HD resolution)"
	@echo "  make run_test22      resol_vga_test  (VGA resolution)"
	@echo "  make run_test23      ahb_payloadreg_test  (AHB payload register)"
	@echo "  make run_test24      ahb_dsicmdreg_test  (AHB DSI command register)"
	@echo "  make run_test25      ahb_dsilngreg_test  (AHB DSI length register)"
	@echo "  make run_test26      ahb_ctrl0reg_test  (AHB control 0 register)"
	@echo ""
	@echo "Coverage/report targets: make report | make functional_cov | make assertion_cov | make cov"
	@echo ""

info:
	@echo ""
	@echo "---------------- Makefile variables ----------------"
	@echo "GIT_HOME  = $(GIT_HOME)"
	@echo "RTL_HOME  = $(RTL_HOME)"
	@echo "TB_HOME   = $(TB_HOME)"
	@echo "VIP_HOME  = $(VIP_HOME)"
	@echo "UVM_TEST  = $(UVM_TEST)"
	@echo "SEED      = $(SEED)"
	@echo "COVERAGE  = SystemVerilog Functional + Assertion"
	@echo "----------------------------------------------------"

# Generate the AHB VIP model directory once from the installed VIP
vip: $(VIP_DIR)/include/sverilog/svt_source_defines.svi

$(VIP_DIR)/include/sverilog/svt_source_defines.svi:
	$(DESIGNWARE_HOME)/bin/dw_vip_setup -path $(VIP_DIR) -add ahb_system_env_svt -svlog

compile: vip
	@mkdir -p logs
	@rm -f logs/compile.log
	vcs $(COMMON_COMPILE_OPTS) \
	    $(VIP_COMPILE_OPTS) \
	    $(RTL_COMPILE_OPTS) \
	    $(TB_COMPILE_OPTS)

# Run one test. Each test writes to a separate log and shares the coverage database.
run:
	@if [ ! -x ./simv ] || ldd ./simv | grep -q 'not found'; then \
	  echo "simv missing or built elsewhere (unresolved shared libraries) - recompiling"; \
	  rm -rf simv simv.daidir csrc partitionlib; \
	  $(MAKE) --no-print-directory compile; \
	fi
	@mkdir -p logs
	./simv +UVM_TESTNAME=$(UVM_TEST) $(COMMON_RUN_OPTS) -l ./logs/$(UVM_TEST).log -cm_dir ./mipi_cov.vdb

run_test0:clean
	@$(MAKE) --no-print-directory run UVM_TEST=mipi_test

run_test1:clean
	@$(MAKE) --no-print-directory run UVM_TEST=lane_0_test

run_test2:clean
	@$(MAKE) --no-print-directory run UVM_TEST=lane_1_test

run_test3:clean
	@$(MAKE) --no-print-directory run UVM_TEST=lane_2_test

run_test4:clean
	@$(MAKE) --no-print-directory run UVM_TEST=lane_3_test

run_test5:clean
	@$(MAKE) --no-print-directory run UVM_TEST=dsi_frame5_test

run_test6:clean
	@$(MAKE) --no-print-directory run UVM_TEST=frame_10_test

run_test7:clean
	@$(MAKE) --no-print-directory run UVM_TEST=vsync_random_test

run_test8:clean
	@$(MAKE) --no-print-directory run UVM_TEST=vsync_5_test

run_test9:clean
	@$(MAKE) --no-print-directory run UVM_TEST=vsync_10_test

run_test10:clean
	@$(MAKE) --no-print-directory run UVM_TEST=pixel_random_test

run_test11:clean
	@$(MAKE) --no-print-directory run UVM_TEST=pixel_white_test

run_test12:clean
	@$(MAKE) --no-print-directory run UVM_TEST=pixel_black_test

run_test13:clean
	@$(MAKE) --no-print-directory run UVM_TEST=pixel_red_test

run_test14:clean
	@$(MAKE) --no-print-directory run UVM_TEST=pixel_green_test

run_test15:clean
	@$(MAKE) --no-print-directory run UVM_TEST=pixel_blue_test

run_test16:clean
	@$(MAKE) --no-print-directory run UVM_TEST=pixel_low_test

run_test17:clean
	@$(MAKE) --no-print-directory run UVM_TEST=pixel_high_test

run_test18:clean
	@$(MAKE) --no-print-directory run UVM_TEST=resol_random_test

run_test19:clean
	@$(MAKE) --no-print-directory run UVM_TEST=resol_normal_test

run_test20:clean
	@$(MAKE) --no-print-directory run UVM_TEST=resol_hd_test

run_test21:clean
	@$(MAKE) --no-print-directory run UVM_TEST=resol_fullhd_test

run_test22:clean
	@$(MAKE) --no-print-directory run UVM_TEST=resol_vga_test

run_test23:clean
	@$(MAKE) --no-print-directory run UVM_TEST=ahb_payloadreg_test

run_test24:clean
	@$(MAKE) --no-print-directory run UVM_TEST=ahb_dsicmdreg_test

run_test25:clean
	@$(MAKE) --no-print-directory run UVM_TEST=ahb_dsilngreg_test

run_test26:clean
	@$(MAKE) --no-print-directory run UVM_TEST=ahb_ctrl0reg_test

# Run all test classes sequentially. Compile only once, then preserve one log per test.
regress: compile
	@set -e; \
	for test in mipi_test lane_0_test lane_1_test lane_2_test lane_3_test dsi_frame5_test frame_10_test vsync_random_test vsync_5_test vsync_10_test pixel_random_test pixel_white_test pixel_black_test pixel_red_test pixel_green_test pixel_blue_test pixel_low_test pixel_high_test resol_random_test resol_normal_test resol_hd_test resol_fullhd_test resol_vga_test ahb_payloadreg_test ahb_dsicmdreg_test ahb_dsilngreg_test ahb_ctrl0reg_test; do \
	  echo ""; echo "============================================================"; \
	  echo "REGRESSION: $$test"; \
	  echo "============================================================"; \
	  $(MAKE) --no-print-directory run UVM_TEST=$$test || exit $$?; \
	done

report:
	@echo "Generating assertion coverage report..."
	urg -dir ./mipi_cov.vdb -format both -report ./mipi_urg_report
	@echo "Report generated at ./mipi_urg_report"

functional_cov:
	@echo "Opening scoreboard functional coverage..."
	@firefox ./mipi_urg_report/groups.html &

assertion_cov:
	@echo "Opening assertion coverage..."
	@firefox ./mipi_urg_report/asserts.html &

cov:
	@firefox ./mipi_urg_report/groups.html &
	@firefox ./mipi_urg_report/asserts.html &

all: clean compile run report

clean:
	rm -rf simv simv.daidir csrc partitionlib logs
	rm -rf mipi_cov* mipi_urg_report* verdiLog DVEfiles
	rm -rf novas*gg ucli.key *.fsdb *.vpd *.log *.key *.vdb
	rm -rf diag_dir vc_hdrs.h vdCovLog verdi_config_file
	rm -rf $(VIP_DIR)
	@echo "Clean completed."
