`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2024 17:41:15
// Design Name: 
// Module Name: tb
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


module tb();

    logic clk = '0;
    logic        [8 : 0] i_LOVNU = '0;
    logic [0 : 3][5 : 0] i_data  = '0;
    logic [0 : 4][9 : 0] o_data      ;
    logic [5:0] counter = '0         ;

    always #1 clk = ~clk             ;
    always @(posedge clk) 
    begin   
    integer i                        ;
    counter += '1                    ;
    if (counter == 6'b111111) begin
        i_LOVNU = $random            ;
        for (i=0; i < 4; i++) begin
                i_data[i] = $random  ;
                end
        end
    end

    shuffledVNU top
    (
        .i_data  (i_data )           ,
        .o_data  (o_data )           ,
        .i_LOVNU (i_LOVNU)
    )                                ;

endmodule
