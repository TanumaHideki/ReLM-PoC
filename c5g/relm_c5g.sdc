create_clock -name clk -period 50MHz [get_ports clk]
create_clock -name aud_bclk -period 3.072MHz [get_ports aud_bclk]
create_clock -name aud_dac_clk -period 48000Hz [get_nets aud_dac_clk]
derive_pll_clocks
derive_clock_uncertainty
