`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2024 17:36:45
// Design Name: 
// Module Name: shuffledVNU
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


module shuffledVNU
    (
        input  logic        [8 : 0] i_LOVNU                     ,
        input  logic                clk                         , 
        input  logic [0 : 3][5 : 0] i_data                      ,
        output logic [0 : 4][9 : 0] o_data      
    );      

    logic  [0 : 3][5 : 0] varCompl                              ;
    logic  [0 : 1][6 : 0] sumFirst                              ;
    logic        [7 : 0] sumSecond                              ;   
    logic        [8 : 0] multip                                 ; 
    logic  [0 : 3][8 : 0] sumThird                              ;
    logic  [0 : 4][9 : 0] sumFourth                             ;
    logic  [0 : 4][8 : 0] afterMult                             ;
    logic  [0 : 3][7 : 0] invVarCompl                           ;
    generate        
        for (genvar i = 0; i < 4; i++) begin        
            conv_sm2compl #(6) conv_sm2compl        
            (       
                .i_sm_data      (i_data  [i])                   ,
                .o_compl_data   (varCompl[i])
            )                                                   ;
        end
        always_comb
        begin
            sumFirst[0][5 : 0] = (varCompl[0] + varCompl[1])             ;
            sumFirst[0][6] = sumFirst[0][5];
            sumFirst[1][5 : 0] = (varCompl[2] + varCompl[3])             ;
            sumFirst[1][6] = sumFirst[1][5];
            sumSecond[6 : 0]   = (sumFirst[0] + sumFirst[1])             ;
            sumSecond[7] = sumSecond[6];
            multip      = {sumSecond[7], sumSecond}                       ;

        end
        for (genvar i = 0; i < 4; i++) begin
            always_comb
            begin
                invVarCompl[i] = {~varCompl[i][5], ~varCompl[i][5], ~(varCompl[i] - 1'b1)}                ;
                sumThird[i][7 : 0] = (sumSecond + invVarCompl[i]) ;
                sumThird[i][8] = sumThird[i][7];
            end
            multiplier multiplier
            (
                .i_data (sumThird [i])                           ,
                .o_data (afterMult[i])
            )                                                   ;
        end
        multiplier multiplier
        (
            .i_data (multip      )                              ,
            .o_data (afterMult[4])
        )                                                       ;
        for (genvar i = 0; i < 5; i++) begin
            always_comb 
            begin
                sumFourth[i][8 : 0] = (afterMult[i] + i_LOVNU); 
                sumFourth[i][9] = sumFourth[i][8];
            end
        end
        for (genvar i = 0; i < 5; i++) begin
            conv_compl2sm #(10) conv_compl2sm
            (
                .i_compl_data   (sumFourth[i])                  ,
                .o_sm_data      (o_data[i])
            )                                                   ;
        end
    endgenerate
endmodule
