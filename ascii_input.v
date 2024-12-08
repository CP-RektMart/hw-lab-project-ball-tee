`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 03:31:23 PM
// Design Name: 
// Module Name: ascii_input
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


module ascii_input(
    input clk,
    input [7:0] ascii,
    input ready_signal,
    input reset,
    output reg [1023:0] ascii_flat
    );

    // ascii flat management
    integer row;
    integer col;
    wire [11:0] ascii_index;
    
    initial begin
        row = 0; 
        col = 0;
        ascii_flat = 0;
    end
    
    assign ascii_index = (1023) - (row*(8*32)) - (col*8);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row <= 0;
            col <= 0;
            ascii_flat <= 0;
        end else if (ready_signal) begin
            ascii_flat[ascii_index -: 8] <= ascii;
            col <= col + 1;
            
            if (ascii == 8'hE0 || ascii == 8'hB8) begin
                col <= col - 1;
            end
            
            // '\n' handler
            if (ascii == 8'd13) begin
                col <= 0;
                row <= row + 1;
            end
            
            
            // new row
            if (col >= 32) begin
                row <= row + 1;
                col <= 0;
            end
           
            // new page
            if (row >= 4) begin
                row <= 0;
            end
        end
    end

    
endmodule