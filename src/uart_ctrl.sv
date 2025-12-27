`timescale 1ns / 1ps

module uart_ctrl
#(parameter CLK_FREQUENCY,
parameter BAUD_RATE,
parameter DATA_BITS,
parameter MAX_ELEMENTS)(

    input logic clk,
    input logic reset,
    
    input logic [DATA_BITS - 1: 0] input_data,
    input logic request_to_send,
    output logic [DATA_BITS -1:0] output_data,
    output logic tx_busy,
    // DATA LINES 
    output logic tx_serial,
    input logic rx_serial
    );


logic [DATA_BITS-1:0] tx_data;
logic [DATA_BITS-1:0] rx_data;
logic input_buffer_isEmpty;
logic input_buffer_isFull;
logic input_buffer_enqueue;  

FIFO_architecture
#(.MAX_ELEMENTS(MAX_ELEMENTS),
  .DATA_BITS(DATA_BITS)
)input_buffer(
            .clk(clk),
            .reset(reset),
            .enqueue(input_data),
            .req_enqueue(input_buffer_enqueue),
            .req_dequeue(input_buffer_dequeue),
            .dequeue(tx_data),
            .isEmpty(input_buffer_isEmpty),
            .isFull(input_buffer_isFull),
            .dequeue_valid(input_buffer_dequeue_valid)
            );
           
uart_tx
#(.CLK_FREQUENCY(CLK_FREQUENCY),
 .BAUD_RATE(BAUD_RATE),
 .DATA_BITS(DATA_BITS)
)tx(
            .clk(clk),
            .reset(reset),
            .data_to_transmit(tx_data),
            .request_to_send(tx_req),
            .transmitted_bit(tx_serial),
            .tx_busy(tx_busy));

assign input_buffer_enqueue = request_to_send & ~input_buffer_isFull;
assign tx_req = input_buffer_dequeue_valid;
assign input_buffer_dequeue = !input_buffer_isEmpty && !tx_busy && !tx_req;
 
logic output_buffer_dequeue;
assign output_buffer_dequeue = ~output_buffer_isEmpty;

FIFO_architecture
#(.MAX_ELEMENTS(MAX_ELEMENTS),
  .DATA_BITS(DATA_BITS)
)output_buffer(
            .clk(clk),
            .reset(reset),
            .enqueue(rx_data),
            .req_enqueue(rx_ready),
            .req_dequeue(output_buffer_dequeue),
            .dequeue(output_data),
            .isEmpty(output_buffer_isEmpty),
            .isFull(output_buffer_isFull),
            .dequeue_valid(output_buffer_dequeue_flag)
            );
           
uart_rx
#(.CLK_FREQUENCY(CLK_FREQUENCY),
.BAUD_RATE(BAUD_RATE),
.DATA_BITS(DATA_BITS)
)rx(
    .clk(clk),
    .reset(reset),
    .received_bit(rx_serial),
    .processed_data(rx_data),
    .processed_data_flag(rx_ready));



        
endmodule
