//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 14:55:28
// Design Name: 
// Module Name: adder_tree_bin
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//  A pipelined tree-like adder with parameterized input data width and their number recorded in SystemVerilog
//  Number of inputs is NOT required to be power of two
//  The code has FF_P which arranges registers by layers
//  
//////////////////////////////////////////////////////////////////////////////////


module adder_tree_bin
    #(          
        parameter                DATA_W      = 13                                           ,        // i_data width
        parameter                DATA_N      = 11                                           ,        // Number of i_data
        localparam               STAGES_N    = $clog2(DATA_N)                               ,        // Number of layers of the adder tree (Determined by the logarithm of the number of i_data inputs)
        parameter [STAGES_N : 0] FF_P        = '0                                           ,        // Arranging registers by layers
        localparam               SUM_N       = 2 ** STAGES_N                                ,        // The dimension of the sum variable (Set by the power of two for further correct division by 2) 
        localparam               O_DATA_W    = DATA_W + STAGES_N                                     // o_data output width
    )                   
    (                   
        input  logic clk                                                                    ,
        input  logic [0 : DATA_N  - 1][DATA_W - 1   : 0]   i_data                           ,
        output logic                  [O_DATA_W - 1 : 0]   o_data                           
    )                                                                                       ;                  
    logic signed [0 : STAGES_N][0 : SUM_N - 1][O_DATA_W - 1 : 0] sum = '0                   ;    

    generate                    
        for (genvar stage = 0; stage <= STAGES_N; stage++) begin                                    // Generating layers of the adder tree
        localparam O_STAGE_N = SUM_N  >> stage                                              ;       // Dividing by 2 the number of adders on each layer
        localparam STAGE_W   = DATA_W +  stage                                              ;       // Increasing the word width on each layer
            if (stage == 0) begin                                                                   // The zero layer of the adder
                for (genvar i = 0; i < DATA_N; i++) begin                                        
                    always_comb begin
                        sum[stage][i][STAGE_W - 1  : 0] = i_data[i][DATA_W - 1 : 0]         ;
                    end
                end
            end else begin
                if          (FF_P[stage] == 1) begin                                                
                    for (genvar i = 0; i < O_STAGE_N; i++) begin
                        always_ff @(posedge clk) begin
                            sum[stage][i][STAGE_W - 1 : 0] <= $signed(sum[stage - 1][2*i][(STAGE_W - 1) - 1 : 0]) + $signed(sum[stage - 1][2*i + 1][(STAGE_W - 1) - 1 : 0]);
                        end
                    end
                end else if (FF_P[stage] == 0) begin
                    for (genvar i = 0; i < O_STAGE_N; i++) begin
                        always_comb begin
                            sum[stage][i][STAGE_W - 1 : 0] = $signed(sum[stage - 1][2*i][(STAGE_W - 1) - 1 : 0]) + $signed(sum[stage - 1][2*i + 1][(STAGE_W - 1) - 1 : 0]);
                        end
                    end
                end
            end
        end
    endgenerate
    assign o_data = sum[STAGES_N][0];
endmodule
