module signAdder
    (
        input  logic clk                , 
        input  logic [3 : 0] sign       ,
        output logic [2 : 0] sign_temp
    );
    assign sign_temp = (sign[0] + sign[1]) + (sign[2] + sign[3]);
endmodule