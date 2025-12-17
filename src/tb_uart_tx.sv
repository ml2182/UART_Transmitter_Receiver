`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.12.2025 15:39:00
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


module tb_uart_tx;

parameter int CLK_FREQUENCY = 50_000_000;
parameter int BAUD_RATE = 115_200; // typical baud rate 
parameter int DATA_BITS = 7;
logic clk;
logic reset;
logic request_to_send;
logic [DATA_BITS -1:0] data_to_transmit;
logic transmitted_bit;
uart_tx
#(.CLK_FREQUENCY(CLK_FREQUENCY),
 .BAUD_RATE(BAUD_RATE),
 .DATA_BITS(DATA_BITS)
)uut(
            .clk(clk),
            .reset(reset),
            .data_to_transmit(data_to_transmit),
            .request_to_send(request_to_send),
            .transmitted_bit(transmitted_bit));
always begin
    #10 clk = ~clk; // 50MHz clock
end
int number_of_tests = 0;
int number_of_pass_tests = 0;
initial begin
    clk = 0;
    reset = 1;
    data_to_transmit = 0;
    request_to_send = 0;
    repeat (2) @(posedge clk);
    reset = 0;
    repeat (100) begin
        data_to_transmit = $urandom_range(0,(1<<DATA_BITS)-1); //min to max value
        check_output_bit(data_to_transmit);
        
    end
    $display("Number of tests:", number_of_tests, " Number of passed tests:", number_of_pass_tests);
        
        
    
end
int index = 0;
localparam int baud_divider = CLK_FREQUENCY/BAUD_RATE;    
task check_output_bit (input [DATA_BITS -1: 0] transmitted); 
    $display("DATA TO TRANSMIT: %b",transmitted);
    request_to_send = 1;
    @(posedge clk);
    
    repeat(baud_divider) @(posedge clk);
    request_to_send = 0;
    index = 0;
    repeat(baud_divider/2) @(posedge clk);
    repeat (DATA_BITS + 2) begin
        repeat (baud_divider)@(posedge clk);
        if (index == 0) begin
            if (transmitted_bit === 0) begin
                $display("PASS: at %0t, value=%b", $time, transmitted_bit);
                number_of_pass_tests = number_of_pass_tests +1;
            end else
                $display("FAIL: at %0t, expected=%b got=%b", $time, 0, transmitted_bit);
        end else if (index == DATA_BITS + 1) begin
            if (transmitted_bit === 1) begin
                $display("PASS: at %0t, value=%b", $time, transmitted_bit);
                number_of_pass_tests = number_of_pass_tests +1;
            end else
                $display("FAIL: at %0t, expected=%b got=%b", $time, 1, transmitted_bit);         
        end else begin 
            if (transmitted[index -1] === transmitted_bit) begin
                $display("PASS: at %0t, value=%b", $time, transmitted_bit);
                number_of_pass_tests = number_of_pass_tests +1;
            end else
                $display("FAIL: at %0t, expected=%b got=%b", $time, transmitted[index -1], transmitted_bit); 
        end
        index = index + 1;
        number_of_tests = number_of_tests + 1;
        
            
    end
    repeat(3* baud_divider/2) @(posedge clk);
    
endtask
            
    
    
    


endmodule
