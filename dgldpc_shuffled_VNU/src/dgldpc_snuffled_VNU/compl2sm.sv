module compl2sm                                                 // Из Дополнительного кода в Прямой код
    ( 
        input  logic [10 : 0] i_data                        ,
        output logic [10 : 0] o_data                                     
    )                                                       ;
    
    logic [9 : 0] sign_temp                                 ;

    always_comb
    begin
        if i_data[10] == 1 begin
            sign_temp = '1                                  ;
        end else           begin
            sign_temp = '0                                  ;
        end
        o_data = {i_data[10], i_data[9 : 0] ^ sign_temp}    ;
    end
endmodule