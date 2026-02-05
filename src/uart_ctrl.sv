`timescale 1ns / 1ps

module uart_ctrl
#(parameter CLK_FREQUENCY = 100_000_000,
parameter BAUD_RATE = 115_200,
parameter DATA_BITS =  7,
parameter MAX_ELEMENTS = 20)(

    input logic clk,
    input logic reset,
    
    input logic [DATA_BITS - 1: 0] input_data,
    input logic request_to_send,
    output logic [DATA_BITS -1:0] output_data,
    output logic tx_busy,
    // DATA LINES 
    output logic tx_serial,
    input logic rx_serial,
    output logic output_buffer_dequeue_flag
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
logic output_buffer_dequeue_flag;
logic output_buffer_isFull;
logic output_buffer_isEmpty;
assign output_buffer_dequeue = ~output_buffer_isEmpty;
logic output_buffer_enqueue;
assign output_buffer_enqueue = ~output_buffer_isFull & rx_ready;
FIFO_architecture
#(.MAX_ELEMENTS(MAX_ELEMENTS),
  .DATA_BITS(DATA_BITS)
)output_buffer(
            .clk(clk),
            .reset(reset),
            .enqueue(rx_data),
            .req_enqueue(output_buffer_enqueue),
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
