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
parameter BAUD_RATE,
parameter DATA_BITS)
(
    input logic clk,
    input logic reset,
    input logic [DATA_BITS -1:0] data_to_transmit = 0,
    input logic request_to_send = 1'b0,
    output logic transmitted_bit
    );
localparam int baud_divider = CLK_FREQUENCY/BAUD_RATE;    
localparam int width_of_counter = $clog2(baud_divider);
logic [width_of_counter - 1:0] counter = 0;

typedef enum logic [1:0] {
    IDLE,
    START,
    TRANSMISSION,
    STOP}uart_tx_state;
uart_tx_state current_state = IDLE;
uart_tx_state next_state = IDLE;
logic next_output = 1'b1;
logic [DATA_BITS-1:0] shift_register = data_to_transmit;
localparam int bit_counter_width = $clog2(DATA_BITS +1);
logic [bit_counter_width-1:0]  bit_counter = 0;

always_comb begin
    unique case (current_state)
        IDLE: begin
            if (request_to_send == 0) begin
                next_state = IDLE;
                next_output = 1'b1;
            end else begin
                next_state = START;
                next_output = 1'b1;
            end
        end START: begin
            next_state = TRANSMISSION;
            next_output = 1'b0;
        end TRANSMISSION: begin
            if (bit_counter == DATA_BITS -1) begin
                next_state = STOP;
                next_output = shift_register[bit_counter]; //MSB
            end else begin
                next_output = shift_register[bit_counter];
                next_state = TRANSMISSION;
            end
        end STOP: begin
            next_output = 1'b1;
            next_state = IDLE;
        end
    endcase
end
                

always_ff @(posedge clk) begin
    if (reset == 1) begin
        current_state <= IDLE;
        transmitted_bit <= 1'b1;
        shift_register <= 0;
        bit_counter <= 0;
    end else begin
        if (counter == baud_divider - 1) begin
            if (current_state ==  TRANSMISSION) begin
                bit_counter <= bit_counter +1;
            end else if (current_state == START) begin
                bit_counter <= 0;
                shift_register <= data_to_transmit;
            end
                   
            current_state <= next_state;
            transmitted_bit <= next_output;
            counter <=0;
        end else
        counter <= counter + 1;
    end
end 
endmodule

