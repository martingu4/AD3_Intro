create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list ZmodDigitizerCtrl_inst/U0/InstDataPath/InstDcoBufg_0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {ADCdata_d[0]} {ADCdata_d[1]} {ADCdata_d[2]} {ADCdata_d[3]} {ADCdata_d[4]} {ADCdata_d[5]} {ADCdata_d[6]} {ADCdata_d[7]} {ADCdata_d[8]} {ADCdata_d[9]} {ADCdata_d[10]} {ADCdata_d[11]} {ADCdata_d[12]} {ADCdata_d[13]} {ADCdata_d[14]} {ADCdata_d[15]} {ADCdata_d[16]} {ADCdata_d[17]} {ADCdata_d[18]} {ADCdata_d[19]} {ADCdata_d[20]} {ADCdata_d[21]} {ADCdata_d[22]} {ADCdata_d[23]} {ADCdata_d[24]} {ADCdata_d[25]} {ADCdata_d[26]} {ADCdata_d[27]} {ADCdata_d[28]} {ADCdata_d[29]} {ADCdata_d[30]} {ADCdata_d[31]}]]
