module CSA_ff
    #(
        parameter DATA_W = 3                                            ,
        parameter FF_P   = 0
    )
    (
    input  logic                  clk                                   , 
    input  logic [DATA_W - 1 : 0] i_f                                   ,
    input  logic [DATA_W - 1 : 0] i_s                                   ,
    input  logic [DATA_W - 1 : 0] i_t                                   ,
    output logic [DATA_W     : 0] o_stage_s                             ,
    output logic [DATA_W     : 0] o_stage_c
    )                                                                   ;
    
    if (FF_P == 0) begin
        always_comb 
        begin  
            o_stage_s = {'0, (i_f ^ i_s ^ i_t)}                         ;
            o_stage_c = {(i_f & i_s) | (i_f & i_t) | (i_s & i_t), '0}   ;
        end
    end else begin
        always_ff @(posedge clk) begin
            o_stage_s <= {'0, (i_f ^ i_s ^ i_t)}                        ;
            o_stage_c <= {(i_f & i_s) | (i_f & i_t) | (i_s & i_t), '0}  ;
        end
    end


endmodule
