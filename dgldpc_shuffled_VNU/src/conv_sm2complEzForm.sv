module conv_sm2complEzForm #(
    parameter DATA_W = 32
) (
    input  logic        [DATA_W - 1 : 0] i_sm_data    ,
    output logic signed [DATA_W - 1 : 0] o_compl_data ,
    output logic                         sign
);

    assign o_compl_data = {i_sm_data[5] , (i_sm_data[4 : 0] ^ i_sm_data[5])};
    assign sign = 
endmodule