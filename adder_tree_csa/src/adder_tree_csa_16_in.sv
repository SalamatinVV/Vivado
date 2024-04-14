//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 14:55:28
// Design Name: 
// Module Name: adder_tree_csa_8_in
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

module adder_tree_csa_16_in
#(
    parameter  I_DATA_W     = 3                                                                 , // i_data width
    parameter  I_DATA_N     = 8                                                                 , // ���-�� ����
    localparam STAGES_N     = StageCount(I_DATA_N) + 1                                          , // ?'���� ������� �����?'�� ���?'�
    localparam O_DATA_W     = I_DATA_W + STAGES_N  + 1                                          , // ������� ������� ��������� ����� 
    localparam SUM_N        = 2 ** $clog2(I_DATA_N)                                               // ������ ������� sum
)                           
(                           
    input  logic                                     clk                                        , // �������� �������
    input  logic [0 : I_DATA_N  - 1][I_DATA_W - 1 : 0] i_data                                   , // ������� ������
    output logic                    [O_DATA_W - 1 : 0] o_data                                       // �������� ������
)                                                                                               ;

//////////////////////////////////////////////function/////////////////////////////////////////////
function automatic logic [31 : 0] StageCount(input logic [31 : 0] i_num)                        ; // ������� �������� ���-�� ����...
    logic [31 : 0] data_n           = '0                                                        ; // � ����� ������ ����������
    logic [31 : 0] w_remains        = i_num / 3 * 3                                             ;
    logic [31 : 0] remains          = i_num % 3                                                 ;                                           
    logic [31 : 0] stage_n_res      = '0                                                        ;
        while ( data_n != 3) begin      
            stage_n_res = stage_n_res + 1                                                       ;
            data_n      = w_remains   / 3 * 2 + remains                                         ;
            w_remains   = data_n      / 3 * 3                                                   ;
            remains     = data_n      % 3                                                       ;
        end     
    return stage_n_res                                                                          ;
endfunction     
 
task automatic RemainWireFunc                                                                   ;
input logic [31 : 0] i_stageFunc                                                                ;
output logic [31 : 0] m,n,f,g                                                                   ;
    localparam int NUMBER_OF_STAGES = StageCount(I_DATA_N) + 1                                  ;
    logic [0 : NUMBER_OF_STAGES - 1][0 : 1][O_DATA_W - 1 : 0] remWire_func = '0                 ; 
     $display("%0d", NUMBER_OF_STAGES)                                                          ;
    for (integer stage = 0; stage <= NUMBER_OF_STAGES; stage++) begin
   
        if (stage == 0) begin
                if(I_DATA_N % 3 == 0) begin
                    remWire_func[stage][0] = '0                                                 ;
                    remWire_func[stage][1] = '0                                                 ;
                end else if(I_DATA_N % 3 == 1) begin
                    remWire_func[stage][0] = '1                                                 ;
                    remWire_func[stage][1] = '0                                                 ;
                end else begin
                    remWire_func[stage][0] = '1                                                 ;
                    remWire_func[stage][1] = '1                                                 ;
                end   
                $display("%0d", remWire_func[stage][0])                                         ;
                $display("%0d", remWire_func[stage][1])                                         ;
        end else if(stage == 1) begin
            logic [0 : 31][31 : 0]        CSA_NUM  = '0                                         ;
            logic [0 : 31][1 : 0] remains_CSA_NUM  = '0                                         ;
                for (integer j = 0; j < STAGES_N; j++) begin
                    if (j == 0) begin
                                CSA_NUM[j] = I_DATA_N / 3                                       ; 
                        remains_CSA_NUM[j] = I_DATA_N % 3                                       ;
                        
                    end else begin
                                CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) / 3    ;
                        remains_CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) % 3    ;
                    end
                end         
                $display("%0d", CSA_NUM[stage - 1])                                             ;   
                $display("%0d", CSA_NUM[stage])                                                 ; 
                if ((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) <= 0) begin
                    remWire_func[stage][0] = '0                                                 ;
                    remWire_func[stage][1] = '0                                                 ;
                end else if((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) == 1) begin
                    remWire_func[stage][0] = '1                                                 ; 
                    remWire_func[stage][1] = '0                                                 ;
                end else if ((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) == 2) begin
                    remWire_func[stage][0] = '1                                                 ;
                    remWire_func[stage][1] = '1                                                 ;
                end
                $display("%0d", remWire_func[stage][0])                                         ; 
                $display("%0d", remWire_func[stage][1])                                         ; 
        end else if (stage >= 2) begin
            logic [0 : 31][31 : 0]        CSA_NUM  = '0                                         ;
            logic [0 : 31][1 : 0] remains_CSA_NUM  = '0                                         ;
                for (integer j = 0; j < STAGES_N; j++) begin
                    if (j == 0) begin
                                CSA_NUM[j] = I_DATA_N / 3                                       ; 
                        remains_CSA_NUM[j] = I_DATA_N % 3                                       ;
                    end else begin
                                CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) / 3    ;
                        remains_CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) % 3    ;
                    end
                end      
                $display("%0d", CSA_NUM[stage - 1])                                             ;
                if ((CSA_NUM[stage - 1] * 3 - CSA_NUM[stage - 2] * 2) == 1) begin
                    for (int j = 0; j < NUMBER_OF_STAGES; j++) begin
                     int flag ='0                                                               ;
                        for (int k = 0; k < 2; k++) begin
                            if (remWire_func[j][k] != 0) begin
                                remWire_func[j][k] = '0                                         ;
                                if (i_stageFunc == stage) begin
                                    m = j                                                       ;
                                    n = k                                                       ;
                                    end
                                    $display("%0d %0d", j,k)                                    ;
                                    flag = '1                                                   ;
                                    break                                                       ;
                              
                            end
                        end
                        if (flag != 0) break                                                    ;
                    end
                end else if ((CSA_NUM[stage - 1] * 3 - CSA_NUM[stage - 2] * 2) == 2) begin
                     for (int j = 0; j < NUMBER_OF_STAGES; j++) begin
                     int flag ='0                                                               ;
                                        for (int k = 0; k < 2; k++) begin
                                        $display("%0d", remWire_func[j][k])                     ;
                                            if (remWire_func[j][k] != 0) begin
                                            $display("%0d", remWire_func[j][k])                 ;
                                                remWire_func[j][k] = '0                         ;
                                                $display("%0d", remWire_func[j][k])             ;
                                                   if (i_stageFunc == stage) begin
                                                    f = j                                       ;
                                                    g = k                                       ;
                                                    end
                                                    flag = '1                                   ;
                                                    $display("%0d %0d", j,k)                    ;
                                                    break                                       ;
                                                    
                            end
                        end
                        if (flag != 0) break                                                    ;
                    end
                    for (int u = 0; u < NUMBER_OF_STAGES; u++) begin
                    int flag1 ='0                                                               ;
                        for (int h = 0; h < 2; h++) begin
                        $display("%0d", remWire_func[u][h])                                     ;
                            if (remWire_func[u][h] != 0) begin
                            $display("%0d", remWire_func[u][h])                                 ;
                                remWire_func[u][h] = '0                                         ;
                                $display("%0d", remWire_func[u][h])                             ;
                                    if (i_stageFunc == stage) begin
                                    m = u                                                       ;
                                    n = h                                                       ;
                                    end
                            flag1 = '1;
                            $display("%0d %0d", u,h)                                            ;
                            break                                                               ;
                            end
                        end
                       if (flag1 != 0) break                                                    ;
                     end
                    
                end

            if ((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) <= 0) begin
                remWire_func[stage][0] = '0                                                     ;
                remWire_func[stage][1] = '0                                                     ;
            end else if((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) == 1) begin
                remWire_func[stage][0] = '1                                                     ; 
                remWire_func[stage][1] = '0                                                     ;
            end else if ((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) == 2) begin
                remWire_func[stage][0] = '1                                                     ;
                remWire_func[stage][1] = '1                                                     ;
            end
        end
    end
endtask

function automatic logic [31 : 0] [31 : 0] CsaCount(input logic [31 : 0] input_stage)           ; // ������� �������� csa �� ������ ���
    logic [0 : 31][31 : 0]        CSA_NUM  = '0                                                 ;
    logic [0 : 31][1 : 0] remains_CSA_NUM  = '0                                                 ;
        for (integer j = 0; j < STAGES_N; j++) begin
            if (j == 0) begin
                        CSA_NUM[j] = I_DATA_N / 3                                               ; 
                remains_CSA_NUM[j] = I_DATA_N % 3                                               ;
            end else begin
                        CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) / 3            ;
                remains_CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) % 3            ;
            end
        end            
    return CSA_NUM[input_stage]                                                                 ;                   
endfunction    



/////////////////////////////////////////DECLARING VARIBLES////////////////////////////////////
logic signed [0 : STAGES_N][0 : SUM_N - 1][O_DATA_W - 1 : 0] sum                                ;
logic signed [0 : STAGES_N][0 : 1        ][O_DATA_W - 1 : 0] remWire = '0                       ;
/////////////////////////////////////////GENERATION ADDER TREE/////////////////////////////
generate
    for (genvar stage = 0; stage <= STAGES_N; stage++) begin
    localparam   STAGE_W = I_DATA_W +  stage                                                    ;
        if (stage == 0) begin
            always_comb begin
                if(I_DATA_N % 3 == 0) begin
                    for(int i = 0; i < I_DATA_N; i++ ) begin
                        sum[stage][i] = i_data[i]                                               ;
                    end
                end else if(I_DATA_N % 3 == 1) begin
                    for(int i = 0; i < I_DATA_N; i++ ) begin
                        sum[stage][i] = i_data[i]                                               ;
                    end
                    remWire[stage][0] = i_data[I_DATA_N - 1]                                    ;
                end else begin
                    for(int i = 0; i < I_DATA_N; i++ ) begin
                        sum[stage][i] = i_data[i]                                               ;
                    end
                    remWire[stage][0] = i_data[I_DATA_N - 1]                                    ;
                    remWire[stage][1] = i_data[I_DATA_N - 2]                                    ;
                end   
            end
        end else if(stage == 1) begin
            localparam CSA_CURR = CsaCount (stage - 1)                                          ;
            localparam CSA_NEXT = CsaCount (stage    )                                          ;
            localparam diff     = CSA_CURR * 2 - CSA_NEXT * 3                                   ;
            for (genvar i = 0; i < CSA_CURR; i++) begin
                CSA_ff #(STAGE_W - 1) stagenum
                (
                    .clk        (clk),
                    .i_f        (sum[stage - 1][3 * i    ][(STAGE_W - 1) - 1 : 0] )             ,
                    .i_s        (sum[stage - 1][3 * i + 1][(STAGE_W - 1) - 1 : 0] )             ,
                    .i_t        (sum[stage - 1][3 * i + 2][(STAGE_W - 1) - 1 : 0] )             ,
                    .o_stage_s  (sum[stage    ][2*i      ][(STAGE_W - 1)     : 0])              ,
                    .o_stage_c  (sum[stage    ][2*i + 1  ][(STAGE_W - 1)     : 0])          
                )                                                                               ;  
            end
            always_comb begin
                if          (diff == 1) begin
                    remWire[stage][0] = sum[stage][CSA_CURR * 2 - 1][(STAGE_W - 1)     : 0]     ; 
                end else if (diff == 2) begin
                    remWire[stage][0] = sum[stage][CSA_CURR * 2 - 1][(STAGE_W - 1)     : 0]     ;
                    remWire[stage][1] = sum[stage][CSA_CURR * 2 - 2][(STAGE_W - 1)     : 0]     ;
                end
            end
        end else begin
            localparam CSA_CURR = CsaCount (stage - 1)                                          ;
            localparam CSA_NEXT = CsaCount (stage    )                                          ;
            localparam CSA_BEF  = CsaCount (stage - 2)                                          ;
            localparam diff     = CSA_CURR * 2 - CSA_NEXT * 3                                   ;
            localparam diff_bef = CSA_CURR * 3 - CSA_BEF * 2                                    ;
            always_comb begin
                if (diff_bef == 1) begin      
                integer j,k,l,p                                                                 ;
                RemainWireFunc(stage, j,k,l,p)                                                              ;
                    sum[stage - 1][CSA_CURR * 3 - 1] = remWire[j][k][(STAGE_W - 1) : 0]         ;
                end else if (diff_bef == 2) begin
                integer j,k,l,p                                                                 ;
                RemainWireFunc(stage, j,k,l,p)                                                              ;
                    sum[stage - 1][CSA_CURR * 3 - 1] = remWire[j][k][(STAGE_W - 1) : 0]         ;
                    sum[stage - 1][CSA_CURR * 3 - 2] = remWire[l][p][(STAGE_W - 1) : 0]         ;
                end
            end
            for (genvar i = 0; i < CSA_CURR; i++) begin
                CSA_ff #(STAGE_W - 1) stagenum
                (
                    .clk        (clk),
                    .i_f        (sum[stage - 1][3 * i    ][(STAGE_W - 1) - 1 : 0] )             ,
                    .i_s        (sum[stage - 1][3 * i + 1][(STAGE_W - 1) - 1 : 0] )             ,
                    .i_t        (sum[stage - 1][3 * i + 2][(STAGE_W - 1) - 1 : 0] )             ,
                    .o_stage_s  (sum[stage    ][2*i      ][(STAGE_W - 1)     : 0])              ,
                    .o_stage_c  (sum[stage    ][2*i + 1  ][(STAGE_W - 1)     : 0])          
                )                                                                               ;  
            end
            always_comb begin
                if          (diff == 1) begin
                    remWire[stage][0] = sum[stage][CSA_CURR * 2 - 1][(STAGE_W - 1)     : 0]     ; 
                end else if (diff == 2) begin       
                    remWire[stage][0] = sum[stage][CSA_CURR * 2 - 1][(STAGE_W - 1)     : 0]     ;
                    remWire[stage][1] = sum[stage][CSA_CURR * 2 - 2][(STAGE_W - 1)     : 0]     ;
                end
            end
        end
    end
endgenerate
assign o_data = sum[STAGES_N][0][O_DATA_W - 1 - 1 : 0] + sum[STAGES_N][1][O_DATA_W - 1 - 1 : 0] ; // �������� ������������ ��������� 2 �����
endmodule