module compl2sm                                                 // �?з Дополнительного кода в Прямой код
    ( 
        input  logic [8 : 0] i_data                        ,
        output logic [8 : 0] o_data                                     
    )                                                       ;
    
    logic [7 : 0] sign_temp                                 ;
    logic [7 : 0] data                                      ;
    always_comb
    begin
        if (i_data[8] == 1) begin
            sign_temp = '1                                  ;
        end else           begin
            sign_temp = '0                                  ;
        end
        data = (i_data[7 : 0] ^ sign_temp)                  ;
        o_data = {sign_temp, i_data[8] + data}              ;
    end
endmodule