`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 09:28:44 PM
// Design Name: 
// Module Name: segment_ascii
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


module segment_ascii(
    input clk,
    input [7:0] data_in, data_out,
    input data_in_ready, data_out_ready,
    output [6:0] seg,
    output dp,
    output [3:0] an
    );
    
    // data
    reg [7:0] data_in_reg, data_out_reg;
    always @(posedge data_in_ready) begin  
        data_in_reg = data_in;
    end
    always @(posedge data_out_ready) begin  
        data_out_reg = data_out;
    end
    
    // num
    wire [3:0] num3,num2,num1,num0; 
    assign num0 = data_in_reg[3:0];
    assign num1 = {data_in_reg[7:4]};
    assign num2 = data_out_reg[3:0];
    assign num3 = {data_out_reg[7:4]};
    
    // an
    wire an0,an1,an2,an3;
    assign an={an3,an2,an1,an0};
    
    // Clock
    wire targetClk;
    wire [18:0] tclk;
    
    assign tclk[0]=clk;
    
    genvar c;
    generate for(c=0;c<18;c=c+1) begin
        clock_div fDiv(tclk[c+1],tclk[c]);
    end endgenerate
    
    clock_div fdivTarget(targetClk,tclk[18]);
    /////////////////////////////////////
    
    quad_seven_seg q7seg(seg,dp,an0,an1,an2,an3,num0,num1,num2,num3,targetClk);
endmodule