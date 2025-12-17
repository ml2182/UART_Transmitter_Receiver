`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.12.2025 16:20:23
// Design Name: 
// Module Name: tb_uart_rx
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


module tb_uart_rx;
parameter int CLK_FREQUENCY = 50_000_000;
parameter int BAUD_RATE = 115_200; 
parameter int DATA_BITS = 7;
logic clk;
logic reset;
logic [DATA_BITS -1: 0] processed_data;



logic request_to_send;
logic [DATA_BITS -1:0] data_to_transmit;
logic transmitted_bit;
uart_tx
#(.CLK_FREQUENCY(CLK_FREQUENCY),
 .BAUD_RATE(BAUD_RATE),
 .DATA_BITS(DATA_BITS)
)uut2(
            .clk(clk),
            .reset(reset),
            .data_to_transmit(data_to_transmit),
            .request_to_send(request_to_send),
            .transmitted_bit(transmitted_bit));

uart_rx
#(.CLK_FREQUENCY(CLK_FREQUENCY),
.BAUD_RATE(BAUD_RATE),
.DATA_BITS(DATA_BITS)
)uut1(
    .clk(clk),
    .reset(reset),
    .received_bit(transmitted_bit),
    .processed_data(processed_data));
                
always begin
    #10 clk = ~clk;
end
always begin
    check_received_data;
end
initial begin
    clk = 0;
    reset = 1;
    repeat (2) @(posedge clk);
    reset = 0;
    repeat (10) begin
        data_to_transmit = $urandom_range(0,(1<<DATA_BITS)-1);
        request_to_send = 1;
        @(posedge clk);
        repeat(baud_divider) @(posedge clk);
        request_to_send = 0;
        repeat(10*baud_divider) @(posedge clk);
    end
        
end
logic number_of_pass_tests =0;
logic number_of_tests = 0;
localparam int baud_divider = CLK_FREQUENCY/BAUD_RATE;    
task check_received_data;
    $display("DATA TO TRANSMIT: %b",data_to_transmit);
    number_of_pass_tests = 0;
    number_of_tests = 0;
    repeat(baud_divider) @(posedge clk);
    repeat(baud_divider*(DATA_BITS -1)) @(posedge clk);                
    if (processed_data === data_to_transmit) begin
        $display("PASS: at %0t, value=%b", $time, processed_data);
        number_of_pass_tests = number_of_pass_tests +1;
    end else
        $display("FAIL: at %0t, expected=%b got=%b", $time, data_to_transmit, processed_data);
    number_of_tests = number_of_tests +1;
        
    
    
    
endtask    
endmodule
