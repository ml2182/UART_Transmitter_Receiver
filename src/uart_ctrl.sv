`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2025 14:17:19
// Design Name: 
// Module Name: uart_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module uart_ctrl
#(parameter CLK_FREQUENCY,
parameter BAUD_RATE,
parameter DATA_BITS,
parameter MAX_ELEMENTS)(
    input logic clk,
    input logic reset,
    input logic [DATA_BITS-1:0] tx_data,
    output logic [DATA_BITS-1:0] rx_data,
    input logic tx_start,
    output logic tx_busy,
    // DATA LINES 
    output logic tx_serial,
    input logic rx_serial
    );
    

uart_tx
#(.CLK_FREQUENCY(CLK_FREQUENCY),
 .BAUD_RATE(BAUD_RATE),
 .DATA_BITS(DATA_BITS)
)tx(
            .clk(clk),
            .reset(reset),
            .data_to_transmit(tx_data),
            .tx_req(tx_req),
            .transmitted_bit(tx_serial),
            .tx_busy(tx_busy));

uart_rx
#(.CLK_FREQUENCY(CLK_FREQUENCY),
.BAUD_RATE(BAUD_RATE),
.DATA_BITS(DATA_BITS)
)rx(
    .clk(clk),
    .reset(reset),
    .received_bit(rx_serial),
    .processed_data(rx_data));
assign tx_req = tx_start & ~tx_busy; 

        
endmodule
