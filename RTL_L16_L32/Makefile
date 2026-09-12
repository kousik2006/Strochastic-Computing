# Independent simulation targets. Each target has exactly one DUT top.
COMMON = common/sc_dff.v common/sc_lfsr8.v common/sc_comparator8_lt.v common/sc_sng8.v common/sc_stochastic_multiplier.v

sim16:
	iverilog -g2005-sv -s tb_sc_multiplier_16 -o sim16 $(COMMON) L16/sc_multiplier_16.v L16/tb_sc_multiplier_16.v
	vvp sim16

sim32:
	iverilog -g2005-sv -s tb_sc_multiplier_32 -o sim32 $(COMMON) L32/sc_multiplier_32.v L32/tb_sc_multiplier_32.v
	vvp sim32

clean:
	rm -f sim16 sim32
