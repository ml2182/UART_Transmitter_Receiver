`timescale 1ns / 1ps

module tb_uart_ctrl;
parameter int CLK_FREQUENCY_1 = 50_000_000;
parameter int CLK_FREQUENCY_2 = 49_500_000;
parameter int BAUD_RATE = 115_200; 
parameter int DATA_BITS = 7;
parameter int MAX_ELEMENTS = 10;

logic clk1;
logic reset1;
logic clk2;
logic reset2;
logic [DATA_BITS -1 : 0] input_data_1;
logic [DATA_BITS -1 : 0] input_data_2;
logic rts_1;
logic rts_2;
logic tx1_busy;
logic tx2_busy;
logic tx1_rx2;
logic tx2_rx1;
logic [DATA_BITS-1:0] output_data_1;
logic [DATA_BITS-1:0] output_data_2;

always begin 
    #10 clk1 = ~clk1;
end
uart_ctrl
#(.CLK_FREQUENCY(CLK_FREQUENCY_1),
  .BAUD_RATE(BAUD_RATE),
  .DATA_BITS(DATA_BITS),
  .MAX_ELEMENTS(MAX_ELEMENTS)
)uut1(
        .clk(clk1),
        .reset(reset1),
        .input_data(input_data_1),
        .request_to_send(rts_1),
        .output_data(output_data_1),
        .tx_busy(tx1_busy),
        .tx_serial(tx1_rx2),
        .rx_serial(tx2_rx1));
uart_ctrl
#(.CLK_FREQUENCY(CLK_FREQUENCY_2),
  .BAUD_RATE(BAUD_RATE),
  .DATA_BITS(DATA_BITS),
  .MAX_ELEMENTS(MAX_ELEMENTS)
)uut2(
        .clk(clk2),
        .reset(reset2),
        .input_data(input_data_2),
        .request_to_send(rts_2),
        .output_data(output_data_2),
        .tx_busy(tx2_busy),
        .tx_serial(tx2_rx1),
        .rx_serial(tx1_rx2));
logic [DATA_BITS-1:0] data_sent_1 [MAX_ELEMENTS-1];
localparam int width_of_register = $clog2(MAX_ELEMENTS+1);
logic [width_of_register-1:0] num_of_elements_1 =0;
logic [width_of_register-1:0] front_pointer_1 = 0;
logic [width_of_register-1:0] rear_pointer_1 = 0;

initial begin
    clk1 = 0;
    reset1 = 1;
    input_data_1 = 0;
    rts_1 = 0;
    repeat (3) @(posedge clk1);
    reset1 = 0;
    
    repeat (5) begin
        input_data_1 = $urandom_range(0,(1<<DATA_BITS)-1);
        rts_1 = 1;
        data_sent_1[rear_pointer_1] = input_data_1; 
        rear_pointer_1 = rear_pointer_1 +1;
        num_of_elements_1 = num_of_elements_1 +1;
        @(posedge clk1);
        rts_1 = 0;
        @(posedge clk1);
    end
end
always begin
    #10.101 clk2 = ~clk2; //49.5 MHz → 20.202 ns
end
initial begin
    clk2 = 0;
    reset2 = 1;
    input_data_2 = 0;
    rts_2 = 0;
    repeat(1) @(posedge clk2);
    reset2 = 0;
end
always @(posedge clk2) begin
    if (num_of_elements_1 > 0) begin
        check_received_data1;
    end
end
localparam int baud_divider_1 = CLK_FREQUENCY_1/BAUD_RATE;  
localparam int baud_divider_2 = CLK_FREQUENCY_2/BAUD_RATE;  
task check_received_data1;
    $display("DATA TO TRANSMIT: %b",data_sent_1[front_pointer_1]);
 //   number_of_pass_tests = 0;
   // number_of_tests = 0;
    repeat(baud_divider_2) @(posedge clk2);
    repeat(baud_divider_2*(DATA_BITS -1)) @(posedge clk2);                
    if (data_sent_1[front_pointer_1] === output_data_2) begin
        $display("PASS: at %0t, value=%b", $time, data_sent_1[front_pointer_1]);
        //number_of_pass_tests = number_of_pass_tests +1;
    end else
        $display("FAIL: at %0t, expected=%b got=%b", $time, data_sent_1[front_pointer_1], output_data_2);
    front_pointer_1 = front_pointer_1 + 1;
    num_of_elements_1 = num_of_elements_1 -1;
 //   number_of_tests = number_of_tests +1;
    
endtask

endmodule


