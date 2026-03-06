# Ensure these match the port names in your top-level HDL
set_property PACKAGE_PIN D7 [get_ports CLK_100_P]
set_property PACKAGE_PIN D6 [get_ports CLK_100_N]

# Define the differential I/O standard (LVDS)
set_property IOSTANDARD LVDS [get_ports CLK_100_P]
set_property IOSTANDARD LVDS [get_ports CLK_100_N]
# Define the timing constraint for the 100 MHz clock
create_clock -period 10.000 -name sys_clk_in [get_ports CLK_100_P]

## White LEDS (8 outputs)

set_property PACKAGE_PIN AF5 [get_ports {LEDS[0]}]
set_property PACKAGE_PIN AE7 [get_ports {LEDS[1]}]
set_property PACKAGE_PIN AH2 [get_ports {LEDS[2]}]
set_property PACKAGE_PIN AE5 [get_ports {LEDS[3]}]
set_property PACKAGE_PIN AH1 [get_ports {LEDS[4]}]
set_property PACKAGE_PIN AE4 [get_ports {LEDS[5]}]
set_property PACKAGE_PIN AG1 [get_ports {LEDS[6]}]
set_property PACKAGE_PIN AF2 [get_ports {LEDS[7]}]
set_property IOSTANDARD LVCMOS12 [get_ports LEDS*]

## RGB LEDS (12 outputs)

set_property PACKAGE_PIN AD7 [get_ports {RGB_LED0[0]}]
set_property PACKAGE_PIN AD9 [get_ports {RGB_LED0[1]}]
set_property PACKAGE_PIN AE9 [get_ports {RGB_LED0[2]}]

set_property PACKAGE_PIN AG9 [get_ports {RGB_LED1[0]}]
set_property PACKAGE_PIN AE8 [get_ports {RGB_LED1[1]}]
set_property PACKAGE_PIN AF8 [get_ports {RGB_LED1[2]}]

set_property PACKAGE_PIN AF7 [get_ports {RGB_LED2[0]}]
set_property PACKAGE_PIN AG8 [get_ports {RGB_LED2[1]}]
set_property PACKAGE_PIN AG6 [get_ports {RGB_LED2[2]}]

set_property PACKAGE_PIN AF6 [get_ports {RGB_LED3[0]}]
set_property PACKAGE_PIN AH6 [get_ports {RGB_LED3[1]}]
set_property PACKAGE_PIN AG5 [get_ports {RGB_LED3[2]}]
set_property IOSTANDARD LVCMOS12 [get_ports RGB_LED*]

## Pushbutton Switches (4 inputs)

set_property PACKAGE_PIN AB6 [get_ports {BUTTONS[0]}]
set_property PACKAGE_PIN AB7 [get_ports {BUTTONS[1]}]
set_property PACKAGE_PIN AB2 [get_ports {BUTTONS[2]}]
set_property PACKAGE_PIN AC6 [get_ports {BUTTONS[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports BUTTONS*]

## Slide Switches (8 inputs)

set_property PACKAGE_PIN AB1 [get_ports {SWITCHES[0]}]
set_property PACKAGE_PIN AF1 [get_ports {SWITCHES[1]}]
set_property PACKAGE_PIN AE3 [get_ports {SWITCHES[2]}]
set_property PACKAGE_PIN AC2 [get_ports {SWITCHES[3]}]
set_property PACKAGE_PIN AC1 [get_ports {SWITCHES[4]}]
set_property PACKAGE_PIN AD6 [get_ports {SWITCHES[5]}]
set_property PACKAGE_PIN AD1 [get_ports {SWITCHES[6]}]
set_property PACKAGE_PIN AD2 [get_ports {SWITCHES[7]}]
set_property IOSTANDARD LVCMOS12 [get_ports SWITCHES*]

## PMODS (22 pins)

# H11 = TXD
# H12 = RXD
set_property IOSTANDARD LVCMOS33 [get_ports {FPGA_SERIAL_TX}];
set_property IOSTANDARD LVCMOS33 [get_ports {FPGA_SERIAL_RX}];
set_property PACKAGE_PIN H12 [get_ports {FPGA_SERIAL_TX}];
set_property PACKAGE_PIN H11 [get_ports {FPGA_SERIAL_RX}];

# set_property PACKAGE_PIN J12 [get_ports {JA_tri_io[0]}]
# set_property PACKAGE_PIN H12 [get_ports {JA_tri_io[1]}]
# set_property PACKAGE_PIN H11 [get_ports {JA_tri_io[2]}]
# set_property PACKAGE_PIN G10 [get_ports {JA_tri_io[3]}]
# set_property PACKAGE_PIN K13 [get_ports {JA_tri_io[4]}]
# set_property PACKAGE_PIN K12 [get_ports {JA_tri_io[5]}]
# set_property PACKAGE_PIN J11 [get_ports {JA_tri_io[6]}]
# set_property PACKAGE_PIN J10 [get_ports {JA_tri_io[7]}]
# set_property IOSTANDARD LVCMOS33 [get_ports JA_tri_io*]

# set_property PACKAGE_PIN E12 [get_ports {JB_tri_io[0]}]
# set_property PACKAGE_PIN D11 [get_ports {JB_tri_io[1]}]
# set_property PACKAGE_PIN B11 [get_ports {JB_tri_io[2]}]
# set_property PACKAGE_PIN A10 [get_ports {JB_tri_io[3]}]
# set_property PACKAGE_PIN C11 [get_ports {JB_tri_io[4]}]
# set_property PACKAGE_PIN B10 [get_ports {JB_tri_io[5]}]
# set_property PACKAGE_PIN A12 [get_ports {JB_tri_io[6]}]
# set_property PACKAGE_PIN A11 [get_ports {JB_tri_io[7]}]
# set_property IOSTANDARD LVCMOS33 [get_ports JB_tri_io*]

# set_property PACKAGE_PIN F12 [get_ports {JAB_tri_io[0]}]
# set_property PACKAGE_PIN G11 [get_ports {JAB_tri_io[1]}]
# set_property PACKAGE_PIN E10 [get_ports {JAB_tri_io[2]}]
# set_property PACKAGE_PIN D10 [get_ports {JAB_tri_io[3]}]
# set_property PACKAGE_PIN F10 [get_ports {JAB_tri_io[4]}]
# set_property PACKAGE_PIN F11 [get_ports {JAB_tri_io[5]}]
# set_property IOSTANDARD LVCMOS33 [get_ports JAB_tri_io*]
