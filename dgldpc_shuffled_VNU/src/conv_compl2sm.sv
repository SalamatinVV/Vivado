/* Конвертор чиcла из дополнительного кода в прямой. */

module conv_compl2sm #(
    parameter DATA_W = 32
) (
    input  logic signed [DATA_W - 1 : 0] i_compl_data,
    output logic        [DATA_W - 1 : 0] o_sm_data    
);
    logic [DATA_W - 2 : 0] inverted_sig;
    logic [DATA_W - 2 : 0] sum_with_msb;
    logic [DATA_W - 2 : 0] saturated_sum;

    assign inverted_sig  = {(DATA_W - 1){i_compl_data[DATA_W - 1]}} ^ i_compl_data[DATA_W - 2 : 0];// Инвертируем биты, если число отрицательное.
    assign sum_with_msb  = inverted_sig + i_compl_data[DATA_W - 1];                             // Добавляем единицу, если число отрицательное.
    // assign saturated_sum = {(DATA_W - 1){i_compl_data[DATA_W - 1]}} | (|sum_with_msb[DATA_W - 2 : 0]);
    assign saturated_sum = (i_compl_data[DATA_W - 1] & ~(|sum_with_msb[DATA_W - 2 : 0])) ? '1 : sum_with_msb;
    assign o_sm_data     = {i_compl_data[DATA_W - 1], saturated_sum};                           // Объединяем со знаком

    // logic [DATA_W - 1 : 0] sm_data;

    // always_comb begin
    //     if (i_compl_data[DATA_W - 1]) 
    //         sm_data = -i_compl_data;
    //     else
    //         sm_data = i_compl_data;
    // end

    // assign o_sm_data = (sm_data[DATA_W - 2 : 0] == 0) ? '1 : sm_data;
endmodule