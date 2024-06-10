module sign_adder                                                // Сумматор sign
    ( 
        input  logic [3 : 0] i_data                         ,
        output logic [2 : 0] o_data                         
    )                                                       ;

    logic [0 : 1][1 : 0] data                               ;

    always_comb
    begin
        data[0] = i_data[0] + i_data[1]                      ;
        data[1] = i_data[2] + i_data[3]                      ;
        o_data  = data[0]   + data[1]                        ;
    end

endmodule