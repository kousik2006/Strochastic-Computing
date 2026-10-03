# Addition_Comparison_New

Simplified parameterized RTL comparison of conventional binary addition, LFSR stochastic scaled addition, and Sobol stochastic scaled addition.

The SC adder implements Y=(A+B)/2 using a 2:1 MUX with a 50% toggle select stream. The output is evaluated over L cycles.

LFSR and Sobol SNGs use the same inclusive threshold convention: stochastic_bit=(sequence_value<=input_value). The LFSR uses non-zero states. The Sobol block is the compact 1-D base-2 form used for this architecture comparison.

The N-bit sequence generator and the L-cycle output probability estimator are separate. For L=16 the estimator counts 0..16; for L=32 it counts 0..32.

All RTL is intentionally modular so individual blocks can later be replaced by structural implementations.
