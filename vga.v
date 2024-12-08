module vga(
    input clk,
    input reset,
    input [7:0] ascii,
    input ascii_ready,
    output hsync,      
    output vsync,       
    output [11:0] rgb   
    );
    
    // signals
    wire [9:0] w_x, w_y;
    wire w_video_on, w_p_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    wire [1023:0] ascii_flat;
    
    // ascii input
    ascii_input ai (
        .clk(clk), 
        .ascii(ascii), 
        .reset(reset),
        .ready_signal(ascii_ready), 
        .ascii_flat(ascii_flat)
    );
    
    // VGA Controller
    vga_controller vc(
        .clk_100MHz(clk), 
        .reset(reset), 
        .hsync(hsync), 
        .vsync(vsync),
        .video_on(w_video_on), 
        .p_tick(w_p_tick), 
        .x(w_x), .y(w_y)
    );
    
    // rgb generator
    rgb_generator rg(
        .clk(clk), 
        .video_on(w_video_on), 
        .x(w_x), 
        .y(w_y), 
        .rgb(rgb_next), 
        .ascii_flat(ascii_flat)
    );
    
    // rgb buffer
    always @(posedge clk)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    // output
    assign rgb = rgb_reg;
    
endmodule