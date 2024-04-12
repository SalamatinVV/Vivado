//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 14:55:28
// Design Name: 
// Module Name: adder_tree_csa_4_in
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

module adder_tree_csa_4_in
#(
    parameter  I_DATA_W       = 3                                                             , // Ширина слова
    parameter  I_DATA_N       = 4                                                            , // кол-во слов
    localparam    STAGES_N = StageCount(I_DATA_N) + 1                                        , // �'ызов функции подсч�'та сло�'в
    localparam O_DATA_W     = I_DATA_W + STAGES_N + 1                                             , // подсчёт размера выходного слова 
    localparam SUM_N        = 2 ** $clog2(I_DATA_N)                                               // размер массива sum
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
    if (data_n == 4) begin
        stage_n_res = 1;
    end else if (data_n == 5) begin
        stage_n_res = 2;
    end else begin
        while ( data_n != 3) begin      
            stage_n_res = stage_n_res + 1                                                       ;
            data_n      = w_remains   / 3 * 2 + remains                                         ;
            w_remains   = data_n      / 3 * 3                                                   ;
            remains     = data_n      % 3                                                       ;
        end     
    end
    return stage_n_res                                                                      ;
endfunction     
 

function automatic logic [31 : 0] [31 : 0] CsaCount(input logic [31 : 0] input_stage)       ; // Функция подсчёта csa на каждом слоё
    logic [0 : 31][31 : 0]        CSA_NUM  = '0                                             ;
    logic [0 : 31][1 : 0] remains_CSA_NUM  = '0                                             ;
        for (integer j = 0; j < STAGES_N; j++) begin
            if (j == 0) begin
                        CSA_NUM[j] = I_DATA_N / 3                                             ; 
                remains_CSA_NUM[j] = I_DATA_N % 3                                             ;
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

/////////////////////////////////////////ОБЪЯВЛЕН�?Е ПЕРЕМЕННЫХ////////////////////////////////////
logic signed [0 : STAGES_N][0 : SUM_N - 1][O_DATA_W - 1 : 0] sum         ;
logic signed [0 : STAGES_N][0 : 1        ][O_DATA_W - 1 : 0] remWire = '0;
/////////////////////////////////////////ГЕНЕРАЦ�?Я ДЕРЕВА СУММАТОРОВ /////////////////////////////
generate
    for(genvar stage = 0; stage <= STAGES_N; stage++) begin             // Генерация слоёв
        localparam   STAGE_W = I_DATA_W +  stage                      ;   // Т.к на выходе CSA слово увеличивается на 1 разряд по сравнению с входом, то данный параметр позволяет увеличвать размерность массивов на каждом слоё
        if (stage == 0) begin  
            always_comb begin                                          // Генерация 0 слоя, в которым мы входные данные записываем в массив sum
                if (I_DATA_N % 3 == 0) begin                            // Если у нас кол-во входных слов кратны 3, то мы не испоьзуем остаточные провода
                    for (int i = 0; i < I_DATA_N; i++) begin
                        sum[stage][i][I_DATA_W - 1 : 0] = i_data[i];
                    end
                end else if (I_DATA_N % 3 == 1) begin                   // Если у нас кол-во входных слов кратны 3 и остаток 1, то мы используем 1 остаточный провод
                    for (int i = 0; i < I_DATA_N - 1; i++) begin
                        sum[stage][i][I_DATA_W - 1 : 0] = i_data[i];
                    end
                    remWire[stage][0][I_DATA_W - 1 : 0] = i_data[I_DATA_N - 1] ;
                end else begin                                          // Если у нас ко-во входных слов кратны 3 и остаток 2, то мы используем 2 остаточных провода
                    for (int i = 0; i < I_DATA_N - 2; i++) begin
                        sum[stage][i][I_DATA_W - 1 : 0] = i_data[i];
                    end
                    remWire[stage][0][I_DATA_W - 1 : 0] = i_data[I_DATA_N - 2] ;
                    remWire[stage][1][I_DATA_W - 1 : 0] = i_data[I_DATA_N - 1] ;
                end
             end
        end else if (stage == 1) begin                                                  // Генерация слоёв с CSA
            localparam CSA_NUMBER = CsaCount (stage - 1)                        ;
            for(genvar i = 0; i < CSA_NUMBER; i++) begin
                CSA_ff #(STAGE_W - 1) stagenum
                (
                    .clk        (clk),
                    .i_f        (sum[stage - 1][3 * i    ][(STAGE_W - 1) - 1 : 0] )          ,
                    .i_s        (sum[stage - 1][3 * i + 1][(STAGE_W - 1) - 1 : 0] )          ,
                    .i_t        (sum[stage - 1][3 * i + 2][(STAGE_W - 1) - 1 : 0] )          ,
                    .o_stage_s  (sum[stage    ][2*i      ][(STAGE_W - 1)     : 0])          ,
                    .o_stage_c  (sum[stage    ][2*i + 1  ][(STAGE_W - 1)     : 0])      
                )       ;  
            end
        end else if (stage == 2) begin
            localparam CSA_NUMBER = CsaCount (stage - 1)                        ;
            always_comb begin
                sum[stage - 1][CSA_NUMBER * 3 - 1][STAGE_W - 1 : 0] = remWire [0][0][(STAGE_W - 1) - 1 : 0];
            end
            for(genvar i = 0; i < CSA_NUMBER; i++) begin
                CSA_ff #(STAGE_W - 1) stagenum
                (
                    .clk        (clk),
                    .i_f        (sum[stage - 1][3 * i    ][(STAGE_W - 1) - 1 : 0])          ,
                    .i_s        (sum[stage - 1][3 * i + 1][(STAGE_W - 1) - 1 : 0])          ,
                    .i_t        (sum[stage - 1][3 * i + 2][(STAGE_W - 1) - 1 : 0])          ,
                    .o_stage_s  (sum[stage    ][2*i      ][(STAGE_W - 1)     : 0])          ,
                    .o_stage_c  (sum[stage    ][2*i + 1  ][(STAGE_W - 1)     : 0])      
                )       ;  
            end
        end
    end
endgenerate
assign o_data = sum[STAGES_N][0][O_DATA_W - 1 - 1 : 0] + sum[STAGES_N][1][O_DATA_W - 1 - 1 : 0]; // Конечное суммирование последних 2 чисел
endmodule