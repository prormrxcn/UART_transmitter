# Create the divided clock constraint
create_generated_clock -name uart_clk -source [get_ports clk] \
    -divide_by 4 [get_nets uart_clk]

# Relax the timing for the UART clock (40 ns period instead of 10 ns)
set_clock_uncertainty -setup 2.000 [get_clocks uart_clk]
# Input delays
set_input_delay -clock clk 1.000 [get_ports {enable rst}]
set_input_delay -clock clk 2.000 [get_ports {datain[*]}]

# Output delays  
set_output_delay -clock clk 2.000 [get_ports serial_tx]

# I/O Standards
set_property IOSTANDARD LVCMOS33 [get_ports {clk enable rst serial_tx}]
set_property IOSTANDARD LVCMOS33 [get_ports {datain[*]}]

# Pin locations
set_property PACKAGE_PIN W5 [get_ports clk]
set_property PACKAGE_PIN R2 [get_ports enable]
set_property PACKAGE_PIN U16 [get_ports rst]
set_property PACKAGE_PIN A18 [get_ports serial_tx]

set_property PACKAGE_PIN W13 [get_ports {datain[7]}]
set_property PACKAGE_PIN W14 [get_ports {datain[6]}]
set_property PACKAGE_PIN V15 [get_ports {datain[5]}]
set_property PACKAGE_PIN W15 [get_ports {datain[4]}]
set_property PACKAGE_PIN W17 [get_ports {datain[3]}]
set_property PACKAGE_PIN W16 [get_ports {datain[2]}]
set_property PACKAGE_PIN V16 [get_ports {datain[1]}]
set_property PACKAGE_PIN V17 [get_ports {datain[0]}]

# Timing optimizations
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]

# Multicycle paths for baud rate counter
set_multicycle_path -setup 4 -to [get_cells {transmitter/counter[*]}]
set_multicycle_path -hold 3 -to [get_cells {transmitter/counter[*]}]

# False path on the prescaler (not timing critical)
set_false_path -through [get_cells {transmitter/prescaler[*]}]

# Group related signals for better placement
group_path -name uart_tx -to [get_cells transmitter*]
