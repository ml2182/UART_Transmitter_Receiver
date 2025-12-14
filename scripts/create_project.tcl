# create_project.tcl

create_project UART ./UART_TX_RX -part xc7a35tcpg236-1 -force

# Add your HDL source files
add_files ./src/uart_ctrl.sv
add_files ./src/uart_rx.sv
add_files ./src/uart_tx.sv
#set_property top tb_Divide_By_Four [get_filesets sim_1]
#launch_simulation