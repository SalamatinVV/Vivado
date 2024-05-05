/* Конвертор числа из прямого кода в дополнительный */

module conv_sm2compl #(
    parameter DATA_W = 32
) (
    input  logic        [DATA_W - 1 : 0] i_sm_data    ,
    output logic signed [DATA_W - 1 : 0] o_compl_data
);
    logic [DATA_W - 2 : 0] inverted_sig;
    logic [DATA_W - 2 : 0] sum_with_msb;
    logic                  all_magn_bits_or;
    logic                  new_sign;

    assign inverted_sig     = {(DATA_W - 1){i_sm_data[DATA_W - 1]}} ^ i_sm_data[DATA_W - 2 : 0]; // Инвертируем биты, если число отрицательное.
    assign sum_with_msb     = inverted_sig + i_sm_data[DATA_W - 1]                             ; // Добавляем единицу, если число отрицательное.
    assign all_magn_bits_or = | i_sm_data[DATA_W - 2 : 0]                                      ; // Сумма всех разрядов модуля. Нужна для корректной обработки отрицательного нуля.
    assign new_sign         = i_sm_data[DATA_W - 1] & all_magn_bits_or                         ; // Новый знак. Принудительно зануляем, если на входе отрицательный ноль.
    assign o_compl_data     = {new_sign, sum_with_msb}                                         ; // Объединяем со знаком

//    always_comb begin
//        if (i_sm_data[DATA_W - 1]) 
//            o_compl_data = i_sm_data;
//        else
//            o_compl_data = -i_sm_data;
//    end
endmodule