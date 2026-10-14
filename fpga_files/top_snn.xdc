## Pin configuration
## Clock (100 MHz oscillator)
set_property PACKAGE_PIN W5 [get_ports clk_100]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100]
create_clock -period 10.000 -name sys_clk_pin [get_ports clk_100]

## Reset - center pushbutton (BTNC)
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## sw_start -> start switch (SW15)
set_property PACKAGE_PIN R2 [get_ports sw_start]
set_property IOSTANDARD LVCMOS33 [get_ports sw_start]

## sw_0(input 0) -> (SW13)
set_property PACKAGE_PIN U1 [get_ports sw_0]
set_property IOSTANDARD LVCMOS33 [get_ports sw_0]

## sw_1(input 1) -> (SW12)
set_property PACKAGE_PIN W2 [get_ports sw_1]
set_property IOSTANDARD LVCMOS33 [get_ports sw_1]

## sw_2(input 2) -> (SW11)
set_property PACKAGE_PIN R3 [get_ports sw_2]
set_property IOSTANDARD LVCMOS33 [get_ports sw_2]

## LED 0 - decision bit 0
set_property PACKAGE_PIN U16 [get_ports {ld_0}]
set_property IOSTANDARD LVCMOS33 [get_ports {ld_0}]

## LED 1 - decision bit 1
set_property PACKAGE_PIN E19 [get_ports {ld_1}]
set_property IOSTANDARD LVCMOS33 [get_ports {ld_1}]

## LED 2 - decision bit 2
set_property PACKAGE_PIN U19 [get_ports ld_2]
set_property IOSTANDARD LVCMOS33 [get_ports ld_2]