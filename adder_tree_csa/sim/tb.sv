`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2024 23:19:39
// Design Name: 
// Module Name: adder_tree_tb
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


module adder_tree_tb
    #(
    parameter DATA_W = 3,
    parameter DATA_N = 9,
    localparam LOG_DATA_N = $clog2(DATA_N),
    localparam O_DATA_W = DATA_W + LOG_DATA_N
    )
    ();
    logic clk = '0;
    logic [0 : DATA_N  - 1][DATA_W - 1 : 0] i_data = '0;
    logic [O_DATA_W - 1:0] o_data;
    logic [5:0] counter = '0;
    always #1 clk = ~clk;
    always @(posedge clk) 
    begin   
    integer i;
    counter += '1;
    if (counter == 6'b111111) begin
        for (i=0;i<DATA_N;i++) begin
                i_data[i] = $random;
                end
        end
    end
    adder_tree #(DATA_W, DATA_N) adder_tree_inst(
    .i_data(i_data),
    .clk(clk),
    .o_data(o_data)
    );
endmodule