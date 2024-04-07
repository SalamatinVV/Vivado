`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.03.2024 23:19:39
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


module tb
    #(
        parameter DATA_W                   = 5                     ,           // Ширина i_data
        parameter DATA_N                   = 7                     ,           // Кол-во входов i_data
        localparam STAGES_N                = $clog2(DATA_N)        ,           // Кол-во слоёв дерева сумматоров (Определяется логарифмом от кол-ва входов i_data)
        parameter [STAGES_N - 1 : 0] FF_P  = '0                    ,           // Pасстановка регистров по слоям
        localparam O_DATA_W                = DATA_W + STAGES_N                 // Ширина выхода o_data
    )
    ()                                                             ;
    logic clk                                           = '0       ;
    logic [0 : DATA_N  - 1][DATA_W - 1   : 0] i_data    = '0       ;
    logic                  [O_DATA_W - 1 : 0] o_data               ;    
    logic                  [5            : 0] counter   = '0       ;
    always #1 clk = ~clk                                           ;
    always @(posedge clk)  
    begin      
    integer i                                                      ;
    counter += '1                                                  ;
        if (counter == 6'b111111) begin
            for (i = 0; i < DATA_N ; i++) begin
                i_data[i] <= $random                               ;
            end
        end
    end
    adder_tree_bin #(DATA_W, DATA_N, FF_P) adder_tree_inst   
    (  
        .i_data  (i_data)                                          ,
        .clk     (clk)                                             ,
        .o_data  (o_data)  
    )                                                              ;
endmodule