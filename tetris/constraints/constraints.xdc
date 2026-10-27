
## Clock 100 MHz
set_property PACKAGE_PIN W5 [get_ports clk100]
set_property IOSTANDARD LVCMOS33 [get_ports clk100]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk100]

## Reset - center push button (btnC)
set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]

## ---------------- VGA port ----------------
set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]

set_property PACKAGE_PIN N18 [get_ports {vgaGreen[0]}]
set_property PACKAGE_PIN L18 [get_ports {vgaGreen[1]}]
set_property PACKAGE_PIN K18 [get_ports {vgaGreen[2]}]
set_property PACKAGE_PIN J18 [get_ports {vgaGreen[3]}]

set_property PACKAGE_PIN J17 [get_ports {vgaBlue[0]}]
set_property PACKAGE_PIN H17 [get_ports {vgaBlue[1]}]
set_property PACKAGE_PIN G17 [get_ports {vgaBlue[2]}]
set_property PACKAGE_PIN D17 [get_ports {vgaBlue[3]}]

set_property PACKAGE_PIN P19 [get_ports Hsync]
set_property PACKAGE_PIN R19 [get_ports Vsync]

set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports Hsync]
set_property IOSTANDARD LVCMOS33 [get_ports Vsync]

## ---------------- Keypad on Pmod JB ----------------
## JB1-JB4 = columns (outputs), JB7-JB10 = rows (inputs, pulled up)
set_property PACKAGE_PIN A14 [get_ports {kp_col[0]}]
set_property PACKAGE_PIN A16 [get_ports {kp_col[1]}]
set_property PACKAGE_PIN B15 [get_ports {kp_col[2]}]
set_property PACKAGE_PIN B16 [get_ports {kp_col[3]}]

set_property PACKAGE_PIN A15 [get_ports {kp_row[0]}]
set_property PACKAGE_PIN A17 [get_ports {kp_row[1]}]
set_property PACKAGE_PIN C15 [get_ports {kp_row[2]}]
set_property PACKAGE_PIN C16 [get_ports {kp_row[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {kp_col[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {kp_row[*]}]
set_property PULLUP true [get_ports {kp_row[0]}]
set_property PULLUP true [get_ports {kp_row[1]}]
set_property PULLUP true [get_ports {kp_row[2]}]
set_property PULLUP true [get_ports {kp_row[3]}]

## ---------------- LEDs ----------------
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property PACKAGE_PIN V13 [get_ports {led[8]}]
set_property PACKAGE_PIN V3  [get_ports {led[9]}]
set_property PACKAGE_PIN W3  [get_ports {led[10]}]
set_property PACKAGE_PIN U3  [get_ports {led[11]}]
set_property PACKAGE_PIN P3  [get_ports {led[12]}]
set_property PACKAGE_PIN N3  [get_ports {led[13]}]
set_property PACKAGE_PIN P1  [get_ports {led[14]}]
set_property PACKAGE_PIN L1  [get_ports {led[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]