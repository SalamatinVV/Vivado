module compl2sm                                                 // Из Дополнительного кода в Прямой код
    (
        input  logic [8 : 0] i_data                        ,
        output logic [8 : 0] o_data
    )                                                       ;

    logic [7 : 0] magnitude                                 ;

    always_comb begin
        if (i_data[8]) begin
            magnitude = (~i_data[7 : 0]) + 1                ;
        end else begin
            magnitude = i_data[7 : 0]                       ;
        end
        o_data = {i_data[8], magnitude}                     ;
    end

endmodule

