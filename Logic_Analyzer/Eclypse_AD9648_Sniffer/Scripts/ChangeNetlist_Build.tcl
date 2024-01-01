##################################################################
# Open synthesized design and change working directory
##################################################################
open_run synth_1 -name synth_1
cd [get_property DIRECTORY [current_project]]

##################################################################
# Connect the ADC_SDIO_spy port to the signal inside the Digitizer
# controller IP Core
##################################################################
# Disconnect the OBUF input pin
disconnect_net -pinlist [get_pins -of [get_cells OBUF_SDIO_inst] -filter name=~*I]
# Connect the OBUF input pin to the correct signal
connect_net -hierarchical -net ZmodDigitizerCtrl_inst/U0/InstConfigADC/ADC_SPI_inst/InstIOBUF/O -objects [get_pins -of [get_cells OBUF_SDIO_inst] -filter name=~*I]
# Set the package pin and IO standard properties for the port
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {ADC_SDIO_spy}]
# Create a checkpoint
write_checkpoint -force ../Output_Files/modified_netlist.dcp

##################################################################
# Run implementation for the design
##################################################################
opt_design
place_design
phys_opt_design
route_design
# Create a checkpoint
write_checkpoint -force ../Output_Files/implemented_design.dcp

##################################################################
# Generate bitstream and debug probes files
##################################################################
write_debug_probes -force ../Output_Files/QAM_MODEM.ltx
write_bitstream -force ../Output_Files/QAM_MODEM.bit