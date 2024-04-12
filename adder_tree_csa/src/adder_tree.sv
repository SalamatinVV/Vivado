//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 14:55:28
// Design Name: 
// Module Name: adder_tree
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
module adder_tree
    #(
        parameter  DATA_W       = 3                                                             ,
        parameter  DATA_N       = 21                                                             ,
        localparam LOG_DATA_N   = $clog2(DATA_N)                                                ,
        localparam O_DATA_W     = DATA_W + DATA_N                                           ,
        localparam SUM_N        = 2 ** LOG_DATA_N
    )                           
    (                           
        input  logic clk                                                                        ,
        input  logic [0 : DATA_N  - 1][DATA_W   - 1 : 0] i_data                                 ,
        output logic                  [O_DATA_W - 1 : 0] o_data
    );

///////////////////////////////////////////function///////////////////////////////////////////////
    function automatic logic [31 : 0] STAGE_NW(input logic [31 : 0] i_num)                      ; // funct comm
        logic [31 : 0] data_n           = i_num                                                 ;
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
       
    localparam    STAGES_N = STAGE_NW(DATA_N) + 1                                               ;
    
    function automatic logic [31 : 0] [31 : 0] CSA_N(input logic [31 : 0] input_stage)          ; // funct comm
    logic [0 : 31][31 : 0]        CSA_NUM  = '0                                                 ;
    logic [0 : 31][1 : 0] remains_CSA_NUM  = '0                                                 ;
        for (integer j = 0; j < STAGES_N; j++) begin
                    if (j == 0) begin
                                CSA_NUM[j] = DATA_N / 3                                         ; 
                        remains_CSA_NUM[j] = DATA_N % 3                                         ;
                    end else begin
                                CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) / 3    ;
                        remains_CSA_NUM[j] = (CSA_NUM[j - 1] * 2 + remains_CSA_NUM[j-1]) % 3    ;
                    end
        end            
        return CSA_NUM[input_stage]                                                             ;                   
    endfunction    
    function automatic logic [31 : 0] _remainWire (input int x) ;// реализация лишних входов, которые выходят из сумматоров
        logic [1 : 0] rW = '0;                                         // на вход мы должны подавать колличество входов(для 1 цикла это колл-во sum[stage = 0])
        if (x % 3 == 0) begin
            rW = 0                                                 ;
        end else begin
            if ((x - 1) % 3 == 0) begin 
                rW = 2                                             ;       // 4, 7, 10, 13 ...
            end else begin
                rW = 1                                             ;       // 2, 5, 8, 11 ...
            end
        end
        return rW;
    endfunction
    //////////////////////////////////////объявление переменных//////////////////////////////////////////////////////
    logic signed [0 : STAGES_N    ][0 : SUM_N             - 1][O_DATA_W - 1 : 0] sum            ;
    logic signed [0 : STAGES_N][0 : 1        ][O_DATA_W - 1 : 0] remWire = '0;
    ///////////////////////////////////////////////generate//////////////////////////////////////////////////////////
    generate
        for (genvar stage = 0; stage <= STAGES_N; stage++) begin

            localparam O_STAGE_N = SUM_N  >> stage                                               ;
            localparam   STAGE_W = DATA_W +  stage                                               ; // Increasing the word width on each layer
            if (stage == 0) begin
                for (genvar i = 0; i < SUM_N; i++) begin                                        
                    always_comb begin
                        if (i < DATA_N) begin
                            sum[stage][i][DATA_W - 1  : 0] = i_data[i][DATA_W - 1 : 0]          ;
                            sum[stage][i][O_DATA_W - 1 : DATA_W] = '0                           ;
                        end else begin
                            sum[stage][i] = '0                                                  ;
                        end
                    end
                end
                
            end else if ( stage == 1 ) begin
            localparam [31 : 0] CSA_NUMBER = CSA_N(stage - 1)               ; 
                localparam [31 : 0] remainWire = _remainWire(CSA_NUMBER * 2);
                
                for (genvar i = 0; i < CSA_NUMBER; i++) begin
                    CSA_ff #(STAGE_W - 1) stagenum
                    (
                        .clk        (clk),
                        .i_f        (sum[stage - 1][3 * i    ]                   )          ,
                        .i_s        (sum[stage - 1][3 * i + 1]                   )          ,
                        .i_t        (sum[stage - 1][3 * i + 2]                   )          ,
                        .o_stage_s  (sum[stage    ][2*i      ][(STAGE_W - 1) : 0])          ,
                        .o_stage_c  (sum[stage    ][2*i + 1  ][(STAGE_W - 1) : 0])      
                    )       ;  
                    if ( i == CSA_NUMBER - 1 ) begin
                        if(remainWire == 1) begin
                            always_comb begin
                                remWire[stage][0][STAGE_W - 1 : 0] = sum[stage][2*i + 1][STAGE_W - 1 : 0];
                            end
                        end else if(remainWire == 2) begin
                            always_comb begin
                                remWire[stage][0][STAGE_W - 1 : 0] = sum[stage][2*i    ][STAGE_W - 1 : 0];
                                remWire[stage][1][STAGE_W - 1 : 0] = sum[stage][2*i + 1][STAGE_W - 1 : 0];
                            end
                        end
                    end
                end
            end else begin
                localparam [31 : 0] CSA_NUMBER = CSA_N(stage - 1)               ;
                localparam [31 : 0] CSA_DIFF = CSA_N(stage - 2) ;
                localparam differ = 3 * CSA_NUMBER - 2 * CSA_DIFF; 
                localparam [31 : 0] remainWire = _remainWire(CSA_NUMBER * 2);
                if ( differ <= 0 ) begin
                    for (genvar i = 0; i < CSA_NUMBER; i++) begin
                        CSA_ff #(STAGE_W - 1) stagenum
                        (
                            .clk        (clk),
                            .i_f        (sum[stage - 1][3 * i    ]                   )          ,
                            .i_s        (sum[stage - 1][3 * i + 1]                   )          ,
                            .i_t        (sum[stage - 1][3 * i + 2]                   )          ,
                            .o_stage_s  (sum[stage    ][2*i      ][(STAGE_W - 1) : 0])          ,
                            .o_stage_c  (sum[stage    ][2*i + 1  ][(STAGE_W - 1) : 0])      
                        )       ;  
                        if ( i == CSA_NUMBER - 1 ) begin
                            if(remainWire == 1) begin
                                always_comb begin
                                    remWire[stage][0][STAGE_W - 1 : 0] = sum[stage][2*i + 1][STAGE_W - 1 : 0];
                                end
                            end else if(remainWire == 2) begin
                                always_comb begin
                                    remWire[stage][0][STAGE_W - 1 : 0] = sum[stage][2*i    ][STAGE_W - 1 : 0];
                                    remWire[stage][1][STAGE_W - 1 : 0] = sum[stage][2*i + 1][STAGE_W - 1 : 0];
                                end
                            end
                        end
                    end
                end else if (differ == 1) begin
                     for (genvar i = 0; i < CSA_NUMBER; i++) begin
                        
                        if (i == CSA_NUMBER - 1) begin
                        
                            for (genvar j = 0; j < STAGES_N - 1; j++) begin 
                                for (genvar k = 0; k < 2; k++) begin 
                                always_comb begin
                                        if ( remWire[j][k] != '0) begin
                                             
                                            sum[stage    ][2 * i    ][(STAGE_W - 1) : 0] = {'0, (sum[stage - 1][3 * i    ] ^ sum[stage - 1][3 * i + 1] ^ remWire[j][k])};
                                            sum[stage    ][2 * i + 1][(STAGE_W - 1) : 0] = {((sum[stage - 1][3 * i    ] & sum[stage - 1][3 * i + 1]) | (sum[stage - 1][3 * i    ] & remWire[j][k]) | (sum[stage - 1][3 * i + 1] & remWire[j][k])), '0};
                                            
                                                remWire[j][k] = '0 ;
                                           disable outher_loop;
                                        end
                                       end
                                    end
                                   
                                end
                            
                        end else begin
                            CSA_ff #(STAGE_W - 1) stagenum
                            (
                                .clk        (clk),
                                .i_f        (sum[stage - 1][3 * i    ]                   )          ,
                                .i_s        (sum[stage - 1][3 * i + 1]                   )          ,
                                .i_t        (sum[stage - 1][3 * i + 2]                   )          ,
                                .o_stage_s  (sum[stage    ][2 * i    ][(STAGE_W - 1) : 0])          ,
                                .o_stage_c  (sum[stage    ][2 * i + 1][(STAGE_W - 1) : 0])      
                            )       ;  
                        end
                        if ( i == CSA_NUMBER - 1 ) begin
                            if(remainWire == 1) begin
                                always_comb begin
                                    remWire[stage][0][STAGE_W - 1 : 0] = sum[stage][2*i + 1][STAGE_W - 1 : 0];
                                end
                            end else if(remainWire == 2) begin
                                always_comb begin
                                    remWire[stage][0][STAGE_W - 1 : 0] = sum[stage][2*i    ][STAGE_W - 1 : 0];
                                    remWire[stage][1][STAGE_W - 1 : 0] = sum[stage][2*i + 1][STAGE_W - 1 : 0];
                                end
                            end
                        end
                    end
                end else if (differ == 2) begin
                    for (genvar i = 0; i < CSA_NUMBER; i++) begin
   //                     if (i == CSA_NUMBER - 1) begin
     //                       for (int j = 0; j < STAGES_N - 1; j++) begin

       //                     end
         //               end else begin
                            CSA_ff #(STAGE_W - 1) stagenum
                            (
                                .clk        (clk),
                                .i_f        (sum[stage - 1][3 * i    ]                   )          ,
                                .i_s        (sum[stage - 1][3 * i + 1]                   )          ,
                                .i_t        (sum[stage - 1][3 * i + 2]                   )          ,
                                .o_stage_s  (sum[stage    ][2 * i    ][(STAGE_W - 1) : 0])          ,
                                .o_stage_c  (sum[stage    ][2 * i + 1][(STAGE_W - 1) : 0])      
                            )       ;  
                      //  end
                        if ( i == CSA_NUMBER - 1 ) begin
                            if(remainWire == 1) begin
                                always_comb begin
                                    remWire[stage][0][STAGE_W - 1 : 0] = sum[stage][2*i + 1][STAGE_W - 1 : 0];
                                end
                            end else if(remainWire == 2) begin
                                always_comb begin
                                    remWire[stage][0][STAGE_W - 1 : 0] = sum[stage][2*i    ][STAGE_W - 1 : 0];
                                    remWire[stage][1][STAGE_W - 1 : 0] = sum[stage][2*i + 1][STAGE_W - 1 : 0];
                                end
                            end
                        end
                    end
                end
            end
                end
     endgenerate
     assign o_data = sum[STAGES_N][0] + sum[STAGES_N][1];
endmodule

