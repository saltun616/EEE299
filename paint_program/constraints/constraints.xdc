## Basys3 100MHz system clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Buttons (btnC = draw/pen-down, btnL = clear canvas)
#set_property PACKAGE_PIN U18 [get_ports btnC]
set_property PACKAGE_PIN W19 [get_ports btnL]
set_property IOSTANDARD LVCMOS33 [get_ports {btnC btnL}]

## Switches (color select: sw[2:0])
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
## Switch 15 (Pen-Down Enable)
set_property PACKAGE_PIN R2 [get_ports sw15]
set_property IOSTANDARD LVCMOS33 [get_ports sw15]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]

## VGA Output
set_property PACKAGE_PIN G19 [get_ports {vga_r[0]}]
set_property PACKAGE_PIN H19 [get_ports {vga_r[1]}]
set_property PACKAGE_PIN J19 [get_ports {vga_r[2]}]
set_property PACKAGE_PIN N19 [get_ports {vga_r[3]}]

set_property PACKAGE_PIN J17 [get_ports {vga_g[0]}]
set_property PACKAGE_PIN H17 [get_ports {vga_g[1]}]
set_property PACKAGE_PIN G17 [get_ports {vga_g[2]}]
set_property PACKAGE_PIN D17 [get_ports {vga_g[3]}]

set_property PACKAGE_PIN N18 [get_ports {vga_b[0]}]
set_property PACKAGE_PIN L18 [get_ports {vga_b[1]}]
set_property PACKAGE_PIN K18 [get_ports {vga_b[2]}]
set_property PACKAGE_PIN J18 [get_ports {vga_b[3]}]

set_property PACKAGE_PIN P19 [get_ports vga_hs]
set_property PACKAGE_PIN R19 [get_ports vga_vs]

set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hs]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vs]

## JXADC Header - Dual Analog Potentiometers
## Potentiometer 1 (X-Axis) -> VAUX6 (JXADC Pin 1 & Pin 7)
set_property PACKAGE_PIN J3 [get_ports pot_x_vp]
set_property PACKAGE_PIN K3 [get_ports pot_x_vn]
set_property IOSTANDARD LVCMOS33 [get_ports pot_x_vp]
set_property IOSTANDARD LVCMOS33 [get_ports pot_x_vn]

## Potentiometer 2 (Y-Axis) -> VAUX14 (JXADC Pin 2 & Pin 8)
set_property PACKAGE_PIN L3 [get_ports pot_y_vp]
set_property PACKAGE_PIN M3 [get_ports pot_y_vn]
set_property IOSTANDARD LVCMOS33 [get_ports pot_y_vp]
set_property IOSTANDARD LVCMOS33 [get_ports pot_y_vn]