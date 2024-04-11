function automatic logic [31 : 0] _remainWire (input logic [31 : 0] x) // реализация лишних входов, которые выходят из сумматоров
                                                                       // на вход мы должны подавать колличество входов(для 1 цикла это колл-во sum[stage = 0])
    if (x % 3 == 0) begin
        _remainWire = 0                                                 ;
    end else begin
        if ((x - 1) % 3 == 0) begin 
            _remainWire = 2                                             ;       // 4, 7, 10, 13 ...
        end else begin
            _remainWire = 1                                             ;       // 2, 5, 8, 11 ...
        end
    end
    return _remainWire;
endfunction
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// реализация если у нас 0 лишних проводов, 1 лишний, 2 лишних

localparam [31 : 0] CSA_NUMBER = CSA_N(stage - 1)               ; 
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
                     if (_remainWire == 1) begin
                        localparam [31 : 0] CSA_NUMBER_INSERT = CSA_N(stage)    ;
                        always_comb begin
                            sum[stage + 1][][STAGE_W : 0] = sum[stage][2*i + 1][{'0, (STAGE_W - 1 : 0)}]
                        end
                     end else if(_remainWire == 2) begin
                        
                     end else begin
                        continue;
                     end
                end