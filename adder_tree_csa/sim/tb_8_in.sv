`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 23:19:39
// Design Name: 
// Module Name: tb_4_in
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


module tb_8_in
    #(
    parameter I_DATA_W = 3,
    parameter I_DATA_N = 8,
    localparam STAGES_N = StageCount(I_DATA_N) + 1                                        ,
    localparam O_DATA_W = I_DATA_W + STAGES_N + 1
    )
    ();
    function automatic logic [31 : 0] StageCount(input logic [31 : 0] i_num)                    ; // ������� �������� ���-�� ����...
        logic [31 : 0] data_n           = '0                                                    ; // � ����� ������ ����������
        logic [31 : 0] w_remains        = i_num / 3 * 3                                         ;
        logic [31 : 0] remains          = i_num % 3                                             ;                                           
        logic [31 : 0] stage_n_res      = '0                                                    ;
            while ( data_n != 3) begin      
                stage_n_res = stage_n_res + 1                                                       ;
                data_n      = w_remains   / 3 * 2 + remains                                         ;
                w_remains   = data_n      / 3 * 3                                                   ;
                remains     = data_n      % 3                                                       ;
            end     
        return stage_n_res                                                                      ;
    endfunction       
    logic clk = '0;
    logic [0 : I_DATA_N  - 1][I_DATA_W - 1 : 0] i_data = '0;
    logic [O_DATA_W - 1:0] o_data;
    logic [5:0] counter = '0;
    always #1 clk = ~clk;
    always @(posedge clk) 
    begin   
        integer i;
        counter += '1;
        if (counter == 6'b111111) begin
            for (i=0;i<I_DATA_N;i++) begin
                i_data[i] = $random;
            end
        end
    end
    adder_tree_csa_8_in #(I_DATA_W, I_DATA_N) adder_tree_inst
    (
        .i_data(i_data),
        .clk(clk),
        .o_data(o_data)
    );
endmodule