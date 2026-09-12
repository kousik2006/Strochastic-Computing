8x8 UNSIGNED STRUCTURAL BOOTH MULTIPLIER
=========================================

Specification
-------------
Inputs:
  multiplicand = 8 bits
  multiplier   = 8 bits

Output:
  product      = 16 bits

Architecture
------------
This project is deliberately separated into DATAPATH and CONTROL PATH.

DATAPATH:
  booth_datapath_8x8.v
    - 16-bit accumulator A
    - 8-bit multiplier Q
    - 1-bit Q-1
    - 8-bit multiplicand zero-extended to 16 bits
    - structural 16-bit ripple adder
    - structural 16-bit subtractor
    - structural operation selection
    - structural registers
    - arithmetic right shift

CONTROL:
  booth_controller_onehot.v
    - one-hot FSM
    - IDLE
    - LOAD
    - ADD
    - SUB
    - SHIFT

  booth_counter_onehot8.v
    - 8-position one-hot iteration counter
    - exactly 8 Booth iterations

STRUCTURAL BUILDING BLOCKS:
  booth_full_adder.v
  booth_adder16.v
  booth_mux2_1bit.v
  booth_dff.v
  booth_reg8.v
  booth_reg16.v
  booth_reg1.v

TOP:
  booth_8x8_structural.v

TESTBENCH:
  tb_booth_8x8_structural.v

Booth rules
-----------
Q0 Q-1
 01 -> A = A + M
 10 -> A = A - M
 00 -> no arithmetic operation
 11 -> no arithmetic operation
Then arithmetic right shift {A,Q,Q-1}.

Important
---------
The DUT contains NO multiplication (*) operator.
The testbench uses * only for the expected/reference value.

Vivado
------
Simulation top:
  tb_booth_8x8_structural

Synthesis top:
  booth_8x8_structural

Do NOT synthesize the testbench.

For area/power comparison, use the same Vivado part,
clock constraint, synthesis strategy, implementation strategy,
and activity assumptions for Booth, SC-L16 and SC-L32.

Expected maximum:
  255 x 255 = 65025 = 16'hFE01
