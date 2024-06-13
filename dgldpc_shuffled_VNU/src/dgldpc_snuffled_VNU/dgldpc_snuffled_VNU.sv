module dgldpc_shuffled_VNU
    (
        input  logic        [7 : 0] i_LOVNU                                ,
        input  logic                 clk                                    , 
        input  logic [0 : 3][5 : 0] i_data                                 ,
        output logic [0 : 4][8 : 0] o_data          
    )                                                                       ;      

        logic [0 : 3][5  : 0] varCompl                                      ;
        logic [0 : 1][6  : 0] sumFirst                                      ;
        logic        [7  : 0] sumSecond                                     ;
        logic        [7  : 0] sumThird                                      ;
        logic [0 : 4][7  : 0] sumFourth                                     ;
        logic [0 : 4][7  : 0] sumFifth                                      ;
        logic [0 : 4][8 : 0] sumSixth                                       ;
        logic        [3  : 0] sign_temp                                     ;
        logic        [2  : 0] sum_sign_temp                                 ;
        logic [0 : 3][5  : 0] inv_varCompl                                  ;   

    generate
        for(genvar i = 0; i < 4; i++ ) begin
            sm2compl sm2compl
            (
                .i_data (i_data   [i])                                      ,
                .o_data (varCompl [i])                                      ,
                .o_sign (sign_temp[i]) 
            )                                                               ;
        end

        sign_adder sign_adder
        (
            .i_data (sign_temp)                                             ,
            .o_data (sum_sign_temp)
        )                                                                   ;

        always_comb
        begin
            sumFirst[0] = ({varCompl[0][5], varCompl[0]} + {varCompl[1][5], varCompl[1]})                        ;
            sumFirst[1]  = ({varCompl[2][5],varCompl[2]} + {varCompl[3][5],varCompl[3]})                        ;
            sumSecond    = ({sumFirst[0][6], sumFirst[0]} + {sumFirst[1][6], sumFirst[1]})                        ; // ff
            sumThird     = ({sumSecond[7], sumSecond}   + sum_sign_temp)                      ;
            for (int i = 0; i < 4; i++) begin       
                inv_varCompl[i] = ~varCompl[i]                              ;
                sumFourth[i]    = ({sumThird[7], sumThird} + {{3{inv_varCompl[i][5]}} ,inv_varCompl[i]} + inv_varCompl[i][5])                ; // ff

            end
            sumFourth[4] = {sumThird[7], sumThird}                                         ;
            for (int i = 0; i < 5; i++) begin
                if(sumFourth[i][7] == 0) begin
                    sumFifth[i] = ({'0, sumFourth[i][7 : 1]} + {2'b00, sumFourth[i][7 : 2]});
                end else begin
                    sumFifth[i] = ({'1, sumFourth[i][7 : 1]} + {2'b11, sumFourth[i][7 : 2]});
                end
                //sumFifth[i] = $signed((sumFourth[i] >> 1) + (sumFourth[i] >> 2))     ;
                sumSixth[i] =  {sumFifth[i][7], sumFifth[i]} + {i_LOVNU[7], i_LOVNU}                ; // ff 
            end
        end

        for(genvar i = 0; i < 5; i++ ) begin
            compl2sm compl2sm
            (
                .i_data (sumSixth [i])                                      ,
                .o_data (o_data   [i])                                      
            )                                                               ;
        end

    endgenerate
endmodule