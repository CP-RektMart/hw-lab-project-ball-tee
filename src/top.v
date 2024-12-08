`timescale 1ns / 1ps

module top(
    input clk,          // 100MHz on Basys 3
    input reset,        // btnC on Basys 3
 
    input [11:0] sw,    // switch 12 bits
    input btnU,         // ascii input btn
    output hsync,       // to VGA connector
    output vsync,       // to VGA connector
    output [11:0] rgb,  // to DAC, to VGA connector
 
    input rx,           // uart rx  
    output tx,          // uart tx 
    output tx_putty,    // keyboard putty
    
    output [6:0] seg,   
    output dp,
    output [3:0] an,
    
    input PS2Data,      // keyboard data
    input PS2Clk        // keyboard clk
    );
    
    // signals
    // uart
    wire [7:0] uart_receive_buffer;
    wire uart_receive_ready;
    wire uart_receive_ready_bounced;
    reg [7:0] uart_transmit_buffer;
    wire uart_transmit_ready_bounced;
    wire tick;
    // keyboard
    wire [7:0] keyboard_data;
    wire [7:0] keyboard_ascii;
    wire keyboard_ready;
    wire keyboard_ready_bounced;
    wire ps2_ascii_ready;
    // ascii
    reg [7:0] ascii_buffer;
    wire ascii_ready;
    assign ascii_ready =  ps2_ascii_ready || uart_receive_ready_bounced;
    
    //uart
    // baud rate generator
    baud_rate_generator brg (
        .clk_100MHz(clk),       
        .reset(reset),          
        .tick(tick)             
    );
    
    // uart reciever
    uart_receiver ur (
        .clk_100MHz(clk),          
        .reset(reset),                    
        .rx(rx),                       
        .sample_tick(tick),              
        .data_ready(uart_receive_ready),          
        .data_out(uart_receive_buffer)
    );
    
    // sw to transmit buffer
    always @(posedge clk) begin
        uart_transmit_buffer <= sw[7:0];
    end
    
    // uart transmitter
    uart_transmitter ut (          
        .clk_100MHz(clk),               
        .reset(reset),                    
        .tx_start(uart_transmit_ready_bounced),                 
        .sample_tick(tick),              
        .data_in(uart_transmit_buffer),           
        .tx_done(),                
        .tx(tx)                       
    );
    
    // uart receive single pulser
    single_pulser sp_uart_receive_ready (
        .clk(clk),
        .pushed(uart_receive_ready),
        .d(uart_receive_ready_bounced)
    );
    
    // uart transmit single pulser
    single_pulser sp_uart_transmit_ready (
        .clk(clk),
        .pushed(btnU),
        .d(uart_transmit_ready_bounced)
    );
    
    // ps2 USB
    // keyboard data
    ps2 ps2(
        .reset(reset),
        .ps2_data(PS2Data),
        .ps2_clk(PS2Clk),
        .rx_data(keyboard_data),    // data with parity in MSB position
        .rx_ready(keyboard_ready)    // rx_data has valid/stable data
    );
    
    // single pulser keyboard ready
    single_pulser sp_keyboard_ready (
        .clk(clk),
        .pushed(keyboard_ready),
        .d(keyboard_ready_bounced)
    );
    
    // convert keyboard code to ascii
    ps2_to_ascii ps2_to_ascii(
        .clk(clk),
        .ps2_code_new(keyboard_ready_bounced),
        .ps2_code(keyboard_data),
        .ascii_code_new(ps2_ascii_ready),
        .ascii_code(keyboard_ascii)
    );
    
    // show in putty
    uart_transmitter ut_keyboard_putty (          
        .clk_100MHz(clk),               
        .reset(reset),                    
        .tx_start(keyboard_ascii_ready),                 
        .sample_tick(tick),              
        .data_in(keyboard_ascii),           
        .tx_done(),                
        .tx(tx_putty)                       
    );
    
    // display
    always @(posedge ps2_ascii_ready or posedge uart_receive_ready_bounced) begin
        ascii_buffer <= (ps2_ascii_ready) ? keyboard_ascii : uart_receive_buffer;
    end
    
    // vga
    vga v (
        .clk(clk),
        .reset(reset),
        .ascii(ascii_buffer),
        .ascii_ready(ascii_ready),
        .hsync(hsync),      
        .vsync(vsync),       
        .rgb(rgb)
    );
    
    // segment ascii display
    segment_ascii sa (
        .clk(clk), 
        .data_out(uart_transmit_buffer),
        .data_in(uart_receive_buffer), 
        .data_in_ready(uart_receive_ready_bounced), 
        .data_out_ready(uart_transmit_ready_bounced),
        .seg(seg),
        .dp(dp),
        .an(an)
    );    
    
endmodule