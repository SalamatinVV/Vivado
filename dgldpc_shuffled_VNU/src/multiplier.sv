`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2024 17:40:28
// Design Name: 
// Module Name: multiplier
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
// 
//////////////////////////////////////////////////////////////////////////////////


module multiplier
    (
        input  logic [8 : 0] i_data      ,
        output logic [8 : 0] o_data
    );

    always_comb
    begin
        if(i_data[8] == 0) begin
            o_data = ({'0, i_data[8 : 1]} + {2'b00, i_data[8 : 2]});
        end else begin
            o_data = ({'1, i_data[8 : 1]} + {2'b11, i_data[8 : 2]});
        end
    end

endmodule
