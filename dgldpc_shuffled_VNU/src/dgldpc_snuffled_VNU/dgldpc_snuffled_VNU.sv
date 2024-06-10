module dgldpc_shuffled_VNU
    (
        input  logic        [8 : 0] i_LOVNU                     ,
        input  logic                clk                         , 
        input  logic [0 : 3][5 : 0] i_data                      ,
        output logic [0 : 4][9 : 0] o_data      
    );    

        logic [0 : 3][5 : 0] varCompl;
        logic [0 : 1][6 : 0] sumFirst;
        logic []

    generate
        for(genvar i = 0; i < 4; i++ ) begin
            sm2compl sm2compl
            (
                .i_data (i_data[i]  )   ,
                .o_data (varCompl[i])
            );
        end
        always_comb
        begin
            sumFirst[0] = varCompl[0] + varCompl[1];
            sumFirst[1] = varCompl[2] + varCompl[3];
            sumSecond   = sumFirst[0] + sumFirst[1];
        end
    endgenerate
endmodule