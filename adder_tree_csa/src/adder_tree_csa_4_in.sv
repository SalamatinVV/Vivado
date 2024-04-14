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
    parameter  I_DATA_W       = 3                                                             , // ������ �����
    parameter  I_DATA_N       = 4                                                            , // ���-�� ����
    localparam    STAGES_N = StageCount(I_DATA_N) + 1                                        , // ?'���� ������� �����?'�� ���?'�
    localparam O_DATA_W     = I_DATA_W + STAGES_N + 1                                             , // ������� ������� ��������� ����� 
    localparam SUM_N        = 2 ** $clog2(I_DATA_N)                                               // ������ ������� sum
)                           
(                           
    input  logic                                     clk                                      , // �������� �������
    input  logic [0 : I_DATA_N  - 1][I_DATA_W - 1 : 0] i_data                                 , // ������� ������
    output logic                    [O_DATA_W - 1 : 0] o_data                                   // �������� ������
)                                                                                             ;

//////////////////////////////////////////////function/////////////////////////////////////////////
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
 

function automatic logic [31 : 0] [31 : 0] CsaCount(input logic [31 : 0] input_stage)       ; // ������� �������� csa �� ������ ���
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

function automatic logic [31 : 0] RemainWire (input int x)                                  ;   // ������� �������� ������ ������ �� ������ CSA
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

/////////////////////////////////////////DECLARING VARIBLES////////////////////////////////////
logic signed [0 : STAGES_N][0 : SUM_N - 1][O_DATA_W - 1 : 0] sum         ;
logic signed [0 : STAGES_N][0 : 1        ][O_DATA_W - 1 : 0] remWire = '0;
/////////////////////////////////////////GENERATION ADDER TREE/////////////////////////////
generate
    for(genvar stage = 0; stage <= STAGES_N; stage++) begin             // ��������� ����
        localparam   STAGE_W = I_DATA_W +  stage                      ;   // �.� �� ������ CSA ����� ������������� �� 1 ������ �� ��������� � ������, �� ������ �������� ��������� ���������� ����������� �������� �� ������ ���
        if (stage == 0) begin  
            always_comb begin                                          // ��������� 0 ����, � ������� �� ������� ������ ���������� � ������ sum
                if (I_DATA_N % 3 == 0) begin                            // ���� � ��� ���-�� ������� ���� ������ 3, �� �� �� ��������� ���������� �������
                    for (int i = 0; i < I_DATA_N; i++) begin
                        sum[stage][i][I_DATA_W - 1 : 0] = i_data[i];
                    end
                end else if (I_DATA_N % 3 == 1) begin                   // ���� � ��� ���-�� ������� ���� ������ 3 � ������� 1, �� �� ���������� 1 ���������� ������
                    for (int i = 0; i < I_DATA_N - 1; i++) begin
                        sum[stage][i][I_DATA_W - 1 : 0] = i_data[i];
                    end
                    remWire[stage][0][I_DATA_W - 1 : 0] = i_data[I_DATA_N - 1] ;
                end else begin                                          // ���� � ��� ��-�� ������� ���� ������ 3 � ������� 2, �� �� ���������� 2 ���������� �������
                    for (int i = 0; i < I_DATA_N - 2; i++) begin
                        sum[stage][i][I_DATA_W - 1 : 0] = i_data[i];
                    end
                    remWire[stage][0][I_DATA_W - 1 : 0] = i_data[I_DATA_N - 2] ;
                    remWire[stage][1][I_DATA_W - 1 : 0] = i_data[I_DATA_N - 1] ;
                end
             end
        end else if (stage == 1) begin                                                  // ��������� ���� � CSA
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
        end else begin
            localparam CSA_NUMBER = CsaCount (stage - 1)                        ;
            localparam CSA_CURR   = CsaCount (stage - 1)                        ;
            localparam CSA_PAST   = CsaCount (stage - 2)                        ;
            localparam diff       = CSA_CURR * 3 - CSA_PAST * 2                 ;
            always_comb begin
                if (diff == 1) begin
                    sum[stage - 1][CSA_NUMBER * 3 - 1][STAGE_W - 1 : 0] = remWire [0][0][(STAGE_W - 1) - 1 : 0];
                end else if (diff == 2) begin
                    sum[stage - 1][CSA_NUMBER * 3 - 1][STAGE_W - 1 : 0] = remWire [0][0][(STAGE_W - 1) - 1 : 0];
                    sum[stage - 1][CSA_NUMBER * 3 - 2][STAGE_W - 1 : 0] = remWire [0][1][(STAGE_W - 1) - 1 : 0];
                end
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
assign o_data = sum[STAGES_N][0][O_DATA_W - 1 - 1 : 0] + sum[STAGES_N][1][O_DATA_W - 1 - 1 : 0]; // �������� ������������ ��������� 2 �����
endmodule