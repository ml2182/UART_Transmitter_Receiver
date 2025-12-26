`timescale 1ns / 1ps

module uart_tx
#(parameter CLK_FREQUENCY,
parameter BAUD_RATE,
parameter DATA_BITS)
(
    input logic clk,
    input logic reset,
    input logic [DATA_BITS -1:0] data_to_transmit,
    input logic request_to_send,
    output logic transmitted_bit,
    output logic tx_busy,
    output logic tx_accept
    );
localparam int baud_divider = CLK_FREQUENCY/BAUD_RATE;    
localparam int width_of_counter = $clog2(baud_divider +1);
logic [width_of_counter - 1:0] counter = 0;
typedef enum logic [1:0] {
    IDLE,
    START,
    TRANSMISSION,
    STOP}uart_tx_state;
uart_tx_state current_state = IDLE;
logic [DATA_BITS-1:0] shift_register;
localparam int bit_counter_width = $clog2(DATA_BITS +1);
logic [bit_counter_width-1:0]  bit_counter = 0;

logic pending;
logic [DATA_BITS -1 : 0] pending_data;              

always_ff @(posedge clk) begin
    if (reset == 1) begin
        current_state <= IDLE;
        transmitted_bit <= 1'b1;
        shift_register <= 0;
        counter <= 0;
        bit_counter <= 0;
        tx_busy <= 0;
        tx_accept <=0;
        pending <= 0;
    end else begin
        tx_accept <= 0;
        if (current_state == IDLE && !pending && request_to_send) begin
            tx_accept    <= 1;                  // single-cycle pulse
            pending      <= 1;
            pending_data <= data_to_transmit;   // latch immediately
        end
        if (counter == baud_divider - 1) begin
            counter <= 0;
            unique case (current_state)
                IDLE: begin
                    transmitted_bit <= 1'b1;
                    tx_busy <=0;
                    bit_counter <= 0;

                    if (pending) begin
                        current_state <= START;
                        tx_busy <= 1;
                        pending <= 0;
                        shift_register <= pending_data;
                    end
                end START: begin
                    current_state <= TRANSMISSION;
                    tx_busy <= 1;
                    transmitted_bit <= 1'b0;
                    bit_counter <= 0;
                    
                end TRANSMISSION: begin
                    if (bit_counter == DATA_BITS -1) begin
                        current_state <= STOP;
                        transmitted_bit <= shift_register[bit_counter]; //MSB
                        tx_busy <= 1;
                    end else begin
                        transmitted_bit <= shift_register[bit_counter];
                        current_state <= TRANSMISSION;
                        bit_counter <= bit_counter +1;
                        tx_busy <= 1;
                    end
                end STOP: begin
                    transmitted_bit <= 1'b1;
                    current_state <= IDLE;
                    tx_busy <= 1;
                    bit_counter <= 0;
                end
            endcase
        end else
            counter <= counter +1;
    end
end 


endmodule

