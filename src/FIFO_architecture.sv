`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.12.2025 13:50:28
// Design Name: 
// Module Name: FIFO_architecture
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
// enqueue, dequeue, isEmpty, isFull

module FIFO_architecture
#(parameter MAX_ELEMENTS,
parameter DATA_BITS 
)(
    input logic clk,
    input logic reset,
    input logic [DATA_BITS - 1:0] enqueue,
    input logic req_enqueue,
    input logic req_dequeue,
    output logic [DATA_BITS - 1:0] dequeue,
    output logic dequeuing_flag,
    output logic isEmpty,
    output logic isFull
    );

localparam int width_of_register = $clog2(MAX_ELEMENTS+1);
logic [width_of_register-1:0] num_of_elements;
logic [DATA_BITS-1:0] queue [MAX_ELEMENTS-1];
logic [width_of_register-1:0] front_pointer = 0;
logic [width_of_register-1:0] rear_pointer = 0;

always_comb begin
    isFull = (num_of_elements == MAX_ELEMENTS);
    isEmpty = (num_of_elements == 0);

     
end
int i;
always_ff @(posedge clk) begin
    if (reset == 1) begin
        num_of_elements <= 0;
        front_pointer <= 0;
        rear_pointer <= 0;
        for (i = 0; i < MAX_ELEMENTS; i =i +1) begin
            queue [i] <= '0;
        end
    end else begin
        if (req_enqueue == 1'b1)begin
           if (!isFull) begin
                queue[rear_pointer] <=enqueue;  
                num_of_elements <= num_of_elements +1;
                if (rear_pointer == MAX_ELEMENTS -1)
                    rear_pointer <= 0;
                else if (req_dequeue == 1'b0)
                    rear_pointer <= rear_pointer + 1;
           end                 
        end
        if (req_dequeue == 1'b1) begin
            dequeuing_flag <= 1;
            if (!isEmpty) begin
                dequeue <= queue[front_pointer];
                num_of_elements <= num_of_elements -1;
                if (front_pointer == MAX_ELEMENTS - 1)
                    front_pointer <= 0;
                else if (req_enqueue == 1'b0)
                    front_pointer <= front_pointer + 1;
            end
        end else
            dequeuing_flag <= 0;
        
            
            
            
    end
end
           
        
endmodule
