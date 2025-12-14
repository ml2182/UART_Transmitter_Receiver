`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2025 14:17:19
// Design Name: 
// Module Name: uart_tx
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


module uart_tx
#(parameter CLK_FREQUENCY,
parameter BAUD_RATE)
(
    input logic clk,
    input logic [2:0] data_to_transmit,
    output logic transmitted_bit
    );
localparam int baud_divider = CLK_FREQUENCY/BAUD_RATE;    
localparam int width_of_counter = $clog2(baud_divider);
logic [width_of_counter:0] counter = 0;
always_ff @(posedge clk) begin
    if (data_to_transmit == 0) begin
        transmitted_bit <= 1'b1;
    end else if (counter == baud_divider) begin           
        transmitted_bit <= data_to_transmit[0];
        data_to_transmit <= data_to_transmit >> 1;
        counter = 0;
    end else begin
        counter = counter + 1;
    end
end
        

endmodule

