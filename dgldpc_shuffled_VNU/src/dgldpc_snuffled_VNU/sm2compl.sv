module sm2compl
    ( 
        input  logic [5 : 0] i_data                         ,
        output logic [5 : 0] o_data                         ,
        output logic         o_sign             
    )                                                       ;

    logic [4 : 0] compl_data                                ;

    always_comb             
    begin               
        compl_data = | i_data[4 : 0]                        ;
        o_data     = {i_data[5], i_data[4 : 0] ^ i_data[5]} ;
        o_sign     = compl_data & i_data[5]                 ;                         
    end


endmodule