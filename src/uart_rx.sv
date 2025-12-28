`timescale 1ns / 1ps

module uart_rx
#(parameter CLK_FREQUENCY,
parameter BAUD_RATE,
parameter DATA_BITS)
(
    input logic clk,
    input logic reset,
    input logic received_bit,
    output logic [DATA_BITS-1:0] processed_data,
    output logic processed_data_flag
    );
localparam int baud_divider = CLK_FREQUENCY/BAUD_RATE;    
localparam int width_of_counter = $clog2(baud_divider);
logic [width_of_counter - 1:0] counter = 0;
localparam int width_of_baud_counter = $clog2((baud_divider/5)+1);
logic [width_of_baud_counter - 1:0] oversampling_counter = 0;       
typedef enum logic [1:0] {
    IDLE,
    START,
    RECEIVING,
    STOP}uart_rx_state; 
       
uart_rx_state current_state = IDLE;

localparam int bit_counter_width = $clog2(DATA_BITS +1);
logic [bit_counter_width-1:0]  bit_counter = 0;
localparam int num_samples = 5;
localparam int width_of_samples = $clog2(num_samples+ 1);
logic [num_samples -1:0] samples =0; 
logic [DATA_BITS-1:0] processing_data = 0;
int ones_count;
logic sampled_bit;
always_comb begin
    ones_count = samples[0] + samples[1] + samples[2] + samples[3] + samples[4];
    sampled_bit = (ones_count > num_samples/2) ? 1'b1 : 1'b0;
end
always_ff @(posedge clk) begin
    if (reset == 1) begin
        current_state <= IDLE;
        bit_counter <= 0;
        samples <= 0;
        oversampling_counter <= 0;
        processing_data <= 0;
        processed_data <=0;
        processed_data_flag <= 0;
        counter <= 0;
    end else begin
        unique case (current_state) 
            IDLE: begin
                bit_counter <= 0;
                if (received_bit == 0) begin
                    current_state <= START;
                end else begin
                    current_state <= IDLE;
                end
                processed_data_flag <= 0;
                counter <= 0;
                processed_data <=0;
                
            end START: begin
                processed_data_flag <= 0;
                bit_counter <= 0;
                if (counter == baud_divider -1) begin
                    current_state <= RECEIVING;
                    counter <= 0;
                    samples <= '0;
                    oversampling_counter <= 0;
                end else begin
                    current_state <= START;
                    counter <= counter +1;
                    
                end
            end RECEIVING: begin
                if (bit_counter == DATA_BITS) begin
                    current_state <= STOP;
                    counter <= 0;
                    
                end else if (counter == baud_divider -1) begin
                    bit_counter <= bit_counter +1;
                    processing_data <= {sampled_bit, processing_data[DATA_BITS-1:1]};
                    counter <= 0;
                    oversampling_counter <=0;
                    samples <= '0;
                end else begin
                    counter <= counter + 1;
                    if (oversampling_counter == (baud_divider/num_samples)-1) begin
                        samples  <= {samples[num_samples -2:0],received_bit};
                        oversampling_counter <= 0;
                    end else begin
                        oversampling_counter <= oversampling_counter + 1;
                    end
                end   
                processed_data_flag <= 0;
            end STOP: begin
                processed_data <= processing_data;
                samples <= '0;
                oversampling_counter <= 0;
                bit_counter <= 0;
                processed_data_flag <= 0;
                if (counter == 0) begin
                    processed_data_flag <= 1;
                end
                if (counter == baud_divider-1) begin
                    current_state <= IDLE;
                end else begin
                    counter <= counter +1;
                end
            end 
        endcase
    end
end
endmodule
