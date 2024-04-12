//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 14:55:28
// Design Name: 
// Module Name: adder_tree_csa
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

module adder_tree_csa
    #(
        parameter  I_DATA_W       = 3                                                             , // Ширина слова
        parameter  I_DATA_N       = 21                                                            , // кол-во слов
        localparam O_DATA_W     = I_DATA_W + I_DATA_N                                             , // подсчёт размера выходного слова 
        localparam SUM_N        = 2 ** $clog2(DATA_N)                                               // размер массива sum
    )                           
    (                           
        input  logic                                     clk                                      , // тактовая частота
        input  logic [0 : I_DATA_N  - 1][I_DATA_W - 1 : 0] i_data                                 , // входные данные
        output logic                    [O_DATA_W - 1 : 0] o_data                                   // выходные данные
    )                                                                                             ;

//////////////////////////////////////////////function/////////////////////////////////////////////
    function automatic logic [31 : 0] StageCount(input logic [31 : 0] i_num)                    ; // Функция подсчёта кол-во слоёв...
        logic [31 : 0] data_n           = i_num                                                 ; // в нашем дереве сумматоров
        logic [31 : 0] w_remains        = i_num                                                 ;
        logic [31 : 0] remains          = '0                                                    ;
        logic [31 : 0] stage_n_res      = '0                                                    ;

        while ( data_n != 3) begin      
            stage_n_res = stage_n_res + 1                                                       ;
            data_n      = w_remains   / 3 * 2 + remains                                         ;
            w_remains   = data_n      / 3 * 3                                                   ;
            remains     = data_n      % 3                                                       ;
        end     
        return stage_n_res                                                                      ;
    endfunction     
    localparam    STAGES_N = StageCount(DATA_N) + 1                                             ; // Вызов функции подсчёта слоёв

    function automatic logic [31 : 0] [31 : 0] CsaCount(input logic [31 : 0] input_stage)       ; // Функция подсчёта csa на каждом слоё
        logic [0 : 31][31 : 0]        CSA_NUM  = '0                                             ;
        logic [0 : 31][1 : 0] remains_CSA_NUM  = '0                                             ;
            for (integer j = 0; j < STAGES_N; j++) begin
                if (j == 0) begin
                            CSA_NUM[j] = DATA_N / 3                                             ; 
                    remains_CSA_NUM[j] = DATA_N % 3                                             ;
                end else begin
                            CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) / 3        ;
                    remains_CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) % 3        ;
                end
            end            
        return CSA_NUM[input_stage]                                                             ;                   
    endfunction    

    function automatic logic [31 : 0] RemainWire (input int x)                                  ;   // Функция подсчёта лишних провод на выходе CSA
        logic [1 : 0] rW = '0                                                                   ;                                         
        if (x % 3 == 0) begin
            rW = 0                                                                              ;
        end else begin
            if ((x - 1) % 3 == 0) begin 
                rW = 2                                                                          ;   // 4, 7, 10, 13 ...
            end else begin
                rW = 1                                                                          ;   // 2, 5, 8, 11 ...
            end
        end
        return rW;
    endfunction

    /////////////////////////////////////////ОБЪЯВЛЕНИЕ ПЕРЕМЕННЫХ////////////////////////////////////
    logic signed [0 : STAGES_N][0 : SUM_N - 1][O_DATA_W - 1 : 0] sum         ;
    logic signed [0 : STAGES_N][0 : 1        ][O_DATA_W - 1 : 0] remWire = '0;
    /////////////////////////////////////////ГЕНЕРАЦИЯ ДЕРЕВА СУММАТОРОВ /////////////////////////////
    generate
        for(genvar stage = 0; stage <= STAGES_N; stage++) begin             // Генерация слоёв
            if (stage = 0) begin                                            // Генерация 0 слоя, в которым мы входные данные записываем в массив sum
                for (genvar i = 0; i < I_DATA_N; i++) begin
                    sum[stage][i][I_DATA_W - 1 : 0] = i_data[i];
                end
            end else begin                                                  // Генерация слоёв с CSA
                
            end
        end
    endgenerate
endmodule