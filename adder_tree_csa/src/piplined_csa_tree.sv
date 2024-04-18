//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 14:55:28
// Design Name: 
// Module Name: piplined_csa_tree
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
// A pipelined tree-like CARRY SAVE ADDER with parameterized input data width and their number recorded in SystemVerilog
//////////////////////////////////////////////////////////////////////////////////

module piplined_csa_tree
    #(
        parameter                I_DATA_W = 3                                                       , // i_data width
        parameter                I_DATA_N = 16                                                     , // Number of i_data
        localparam               STAGES_N = StageCount(I_DATA_N) + 1                                , // Number of layers of the adder tree
        parameter [STAGES_N : 0] FF_P     = '1                                                      , 
        localparam               O_DATA_W = I_DATA_W + STAGES_N  + 1                                  // o_data output width
    )                           
    (                           
        input  logic                                       clk                                      , 
        input  logic [0 : I_DATA_N  - 1][I_DATA_W - 1 : 0] i_data                                   , 
        output logic                    [O_DATA_W - 1 : 0] o_data                                     
    )                                                                                               ;

//////////////////////////////////////////////function/////////////////////////////////////////////
    function automatic logic [31 : 0] StageCount(input logic [31 : 0] i_num)                        ; // the function of counting layers in the adder tree
        logic [31 : 0] data_n           = '0                                                        ; // the input value is I_DATA_N
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
 
    task automatic RemainWireFunc                                                                   ; // Variable selection function for automatic construction of the adder tree
        input logic [31 : 0] i_stageFunc                                                            ; // This function selects which wires need to be connected to a specific CSA
        output logic [31 : 0] m,n,f,g                                                               ; // The input value here is the number of the layer
        localparam int NUMBER_OF_STAGES = StageCount(I_DATA_N) + 1                                  ; // in which you need to select the missing inputs for the last adder
        logic [0 : NUMBER_OF_STAGES][0 : 1] remWire_func = '0                                       ; // At the output, it outputs wire indexes, 
        for (integer stage = 0; stage <= NUMBER_OF_STAGES; stage++) begin                             // which we will use as input for the last CSA
            if          (stage == 0) begin
                if          (I_DATA_N % 3 == 0) begin
                    remWire_func[stage][0] = '0                                                     ;
                    remWire_func[stage][1] = '0                                                     ;
                end else if (I_DATA_N % 3 == 1) begin
                    remWire_func[stage][0] = '1                                                     ;
                    remWire_func[stage][1] = '0                                                     ;
                end else                        begin   
                    remWire_func[stage][0] = '1                                                     ;
                    remWire_func[stage][1] = '1                                                     ;
                end
            end else if (stage == 1) begin
                logic [0 : 31][31 : 0]         CSA_NUM  = '0                                        ;
                logic [0 : 31][1  : 0] remains_CSA_NUM  = '0                                        ;
                    for (integer j = 0; j < STAGES_N; j++) begin
                        if (j == 0) begin
                                    CSA_NUM[j] = I_DATA_N / 3                                       ; 
                            remains_CSA_NUM[j] = I_DATA_N % 3                                       ;
                        end else    begin
                                    CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j - 1]) / 3  ;
                            remains_CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j - 1]) % 3  ;
                        end
                    end         
                    if          ((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) <= 0) begin
                        remWire_func[stage][0] = '0                                                 ;
                        remWire_func[stage][1] = '0                                                 ;
                    end else if ((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) == 1) begin
                        remWire_func[stage][0] = '1                                                 ; 
                        remWire_func[stage][1] = '0                                                 ;
                    end else if ((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) == 2) begin
                        remWire_func[stage][0] = '1                                                 ;
                        remWire_func[stage][1] = '1                                                 ;
                    end
            end else if (stage >= 2) begin
                logic [0 : 31][31 : 0]         CSA_NUM  = '0                                        ;
                logic [0 : 31][1  : 0] remains_CSA_NUM  = '0                                        ;
                    for (integer j = 0; j < STAGES_N; j++) begin
                        if (j == 0) begin
                                    CSA_NUM[j] = I_DATA_N / 3                                       ; 
                            remains_CSA_NUM[j] = I_DATA_N % 3                                       ;
                        end else begin
                                    CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) / 3    ;
                            remains_CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) % 3    ;
                        end
                    end
                    if          ((CSA_NUM[stage - 1] * 3 - CSA_NUM[stage - 2] * 2) == 1) begin
                        for (int j = 0; j < NUMBER_OF_STAGES; j++) begin
                         int flag ='0                                                               ;
                            for (int k = 0; k < 2; k++) begin
                                if (remWire_func[j][k] != 0) begin
                                    remWire_func[j][k] = '0                                         ;
                                    if (i_stageFunc == stage) begin
                                        m = j                                                       ;
                                        n = k                                                       ;
                                        end
                                        flag = '1                                                   ;
                                        break                                                       ;
                                    
                                end
                            end
                            if (flag != 0) break                                                    ;
                        end
                    end else if ((CSA_NUM[stage - 1] * 3 - CSA_NUM[stage - 2] * 2) == 2) begin
                        for (int j = 0; j < NUMBER_OF_STAGES; j++) begin
                            int flag ='0                                                            ;
                            for (int k = 0; k < 2; k++) begin
                                if (remWire_func[j][k] != 0) begin
                                    remWire_func[j][k] = '0                                         ;
                                    if (i_stageFunc == stage) begin             
                                        f = j                                                       ;
                                        g = k                                                       ;
                                    end             
                                        flag = '1                                                   ;
                                        break                                                       ;
                                end
                            end
                            if (flag != 0) break                                                    ;
                        end
                        for (int j = 0; j < NUMBER_OF_STAGES; j++) begin
                            int flag ='0                                                            ;
                            for (int k = 0; k < 2; k++) begin
                                if (remWire_func[j][k] != 0) begin
                                    remWire_func[j][k] = '0                                         ;
                                    if (i_stageFunc == stage) begin
                                        m = j                                                       ;
                                        n = k                                                       ;
                                    end
                                    flag = '1;
                                    break                                                           ;
                                end
                            end
                           if (flag != 0) break                                                     ;
                         end
                    end
                if          ((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) <= 0) begin
                    remWire_func[stage][0] = '0                                                     ;
                    remWire_func[stage][1] = '0                                                     ;
                end else if ((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) == 1) begin
                    remWire_func[stage][0] = '1                                                     ; 
                    remWire_func[stage][1] = '0                                                     ;
                end else if ((CSA_NUM[stage - 1] * 2 - CSA_NUM[stage] * 3) == 2) begin
                    remWire_func[stage][0] = '1                                                     ;
                    remWire_func[stage][1] = '1                                                     ;
                end
            end
        end
    endtask

function automatic logic [31 : 0] [31 : 0] CsaCount(input logic [31 : 0] input_stage)               ; // The function of counting the number of CSA on each layer
    logic [0 : 31][31 : 0]         CSA_NUM = '0                                                     ; // The input value is the number of the layer for which 
    logic [0 : 31][1  : 0] remains_CSA_NUM = '0                                                     ; // we need to find out the number of CSA
    for (integer j = 0; j < STAGES_N; j++) begin
        if (j == 0) begin
                    CSA_NUM[j] = I_DATA_N / 3                                                       ; 
            remains_CSA_NUM[j] = I_DATA_N % 3                                                       ;
        end else    begin      
                    CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) / 3                    ;
            remains_CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) % 3                    ;
        end
    end            
    return CSA_NUM[input_stage]                                                                     ;                   
endfunction    

/////////////////////////////////////////DECLARING VARIBLES////////////////////////////////////
    logic signed [0 : STAGES_N][0 : I_DATA_N - 1][O_DATA_W - 1 : 0] sum                             ;
    logic signed [0 : STAGES_N][0 : 1           ][O_DATA_W - 1 : 0] remWire = '0                    ;

/////////////////////////////////////////GENERATION ADDER TREE/////////////////////////////
    generate
        for (genvar stage = 0; stage <= STAGES_N; stage++) begin
        localparam   STAGE_W = I_DATA_W +  stage                                                        ;
            if          (stage == 0) begin  
                always_comb begin   
                    if         (I_DATA_N % 3 == 0) begin 
                        for(int i = 0; i < I_DATA_N; i++) begin    
                            sum[stage][i] = i_data[i]                                                   ;
                        end 
                    end else if(I_DATA_N % 3 == 1) begin    
                        for(int i = 0; i < I_DATA_N; i++) begin    
                            sum[stage][i] = i_data[i]                                                   ;
                        end 
                        remWire[stage][0] = i_data[I_DATA_N - 1]                                        ;
                    end else                       begin  
                        for(int i = 0; i < I_DATA_N; i++) begin    
                            sum[stage][i] = i_data[i]                                                   ;
                        end 
                        remWire[stage][0] = i_data[I_DATA_N - 1]                                        ;
                        remWire[stage][1] = i_data[I_DATA_N - 2]                                        ;
                    end   
                end
            end else if (stage == 1) begin
                localparam CSA_CURR = CsaCount(stage - 1)                                               ;
                localparam CSA_NEXT = CsaCount(stage    )                                               ;
                localparam diff     = CSA_CURR * 2 - CSA_NEXT * 3                                       ;
                for (genvar i = 0; i < CSA_CURR; i++) begin
                    CSA_ff #(STAGE_W - 1, FF_P[stage]) stagenum
                    (
                        .clk        (clk                                             )                  ,
                        .i_f        (sum[stage - 1][3 * i    ][(STAGE_W - 1) - 1 : 0])                  ,
                        .i_s        (sum[stage - 1][3 * i + 1][(STAGE_W - 1) - 1 : 0])                  ,
                        .i_t        (sum[stage - 1][3 * i + 2][(STAGE_W - 1) - 1 : 0])                  ,
                        .o_stage_s  (sum[stage    ][2 * i    ][(STAGE_W - 1)     : 0])                  ,
                        .o_stage_c  (sum[stage    ][2 * i + 1][(STAGE_W - 1)     : 0])              
                    )                                                                                   ;  
                end 
                always_comb begin   
                    if          (diff == 1) begin   
                        remWire[stage][0] = sum[stage][CSA_CURR * 2 - 1][(STAGE_W - 1) : 0]             ; 
                    end else if (diff == 2) begin
                        remWire[stage][0] = sum[stage][CSA_CURR * 2 - 1][(STAGE_W - 1) : 0]             ;
                        remWire[stage][1] = sum[stage][CSA_CURR * 2 - 2][(STAGE_W - 1) : 0]             ;
                    end 
                end 
            end else                 begin  
                localparam CSA_CURR = CsaCount (stage - 1)                                              ;
                localparam CSA_NEXT = CsaCount (stage    )                                              ;
                localparam CSA_BEF  = CsaCount (stage - 2)                                              ;
                localparam diff     = CSA_CURR * 2 - CSA_NEXT * 3                                       ;
                localparam diff_bef = CSA_CURR * 3 - CSA_BEF  * 2                                       ;
                always_comb begin
                    if          (diff_bef == 1) begin      
                    integer j,k,l,p                                                                     ;
                    RemainWireFunc(stage, j,k,l,p)                                                      ;
                        sum[stage - 1][CSA_CURR * 3 - 1] = remWire[j][k][(STAGE_W - 1) : 0]             ;
                    end else if (diff_bef == 2) begin
                    integer j,k,l,p                                                                     ;
                    RemainWireFunc(stage, j,k,l,p)                                                      ;
                        sum[stage - 1][CSA_CURR * 3 - 1] = remWire[j][k][(STAGE_W - 1) : 0]             ;
                        sum[stage - 1][CSA_CURR * 3 - 2] = remWire[l][p][(STAGE_W - 1) : 0]             ;
                    end
                end
                for (genvar i = 0; i < CSA_CURR; i++) begin
                    CSA_ff #(STAGE_W - 1, FF_P[stage]) stagenum
                    (
                        .clk        (clk                                             )                  ,
                        .i_f        (sum[stage - 1][3 * i    ][(STAGE_W - 1) - 1 : 0])                  ,
                        .i_s        (sum[stage - 1][3 * i + 1][(STAGE_W - 1) - 1 : 0])                  ,
                        .i_t        (sum[stage - 1][3 * i + 2][(STAGE_W - 1) - 1 : 0])                  ,
                        .o_stage_s  (sum[stage    ][2 * i    ][(STAGE_W - 1)     : 0])                  ,
                        .o_stage_c  (sum[stage    ][2 * i + 1][(STAGE_W - 1)     : 0])              
                    )                                                                                   ;  
                end 
                always_comb begin   
                    if          (diff == 1) begin   
                        remWire[stage][0] = sum[stage][CSA_CURR * 2 - 1][(STAGE_W - 1) : 0]             ; 
                    end else if (diff == 2) begin           
                        remWire[stage][0] = sum[stage][CSA_CURR * 2 - 1][(STAGE_W - 1) : 0]             ;
                        remWire[stage][1] = sum[stage][CSA_CURR * 2 - 2][(STAGE_W - 1) : 0]             ;
                    end
                end
            end
        end
    endgenerate
    assign o_data = $signed(sum[STAGES_N][0][(O_DATA_W - 1) - 1 : 0]) + $signed(sum[STAGES_N][1][(O_DATA_W - 1) - 1 : 0]) ; 
endmodule