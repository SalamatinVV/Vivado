function automatic logic [31 : 0] _remainWire (input logic [31 : 0] x) // реализация лишних входов, которые выходят из сумматоров
                              logic [31 : 0] rW;                                         // на вход мы должны подавать колличество входов(для 1 цикла это колл-во sum[stage = 0])
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// реализация если у нас 0 лишних проводов, 1 лишний, 2 лишних

localparam [31 : 0] CSA_NUMBER = CSA_N(stage - 1)               ; 
localparam [31 : 0] remainWire = _remainWire(CSA_NUMBER * 2);
logic [31 : 0][1 : 0][31 : 0] remWire = '0;
            if ( stage == 1 ) begin
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
                localparam [31 : 0] CSA_DIFF = CSA_N(stage - 2) ;
                always_comb begin
                    differ = 3 * CSA_NUMBER - 2 * CSA_DIFF;
                end
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
                            for (int j = 0; j < STAGES_N - 1; j++) begin
                                for (int k = 0; k < 2; k++) begin 
                                    if (remWire[j][k] != 0) begin
                                        CSA_ff #(STAGE_W - 1) stagenum
                                        (
                                            .clk        (clk),
                                            .i_f        (sum[stage - 1][3 * i    ]                   )          ,
                                            .i_s        (sum[stage - 1][3 * i + 1]                   )          ,
                                            .i_t        (remWire[j][k]                               )          ,
                                            .o_stage_s  (sum[stage    ][2 * i    ][(STAGE_W - 1) : 0])          ,
                                            .o_stage_c  (sum[stage    ][2 * i + 1][(STAGE_W - 1) : 0])      
                                        )       ;  
                                        break;
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
  //                  for (genvar i = 0; i < CSA_NUMBER; i++) begin
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
    //            end
      //      end