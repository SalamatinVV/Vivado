module led_blinker #(
    parameter int CLK_FREQ_HZ = 50_000_000,
    parameter int BLINK_HZ    = 1
) (
    input  logic clk,
    input  logic reset_n,
    output logic [2:0] led
);

    localparam int DIV_COUNT = CLK_FREQ_HZ / (2 * BLINK_HZ);
    localparam int CNT_WIDTH = $clog2(DIV_COUNT);

    logic [CNT_WIDTH-1:0] counter;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= '0;
            led     <= 3'b001;
        end else if (counter == DIV_COUNT - 1) begin
            counter <= '0;
            led     <= {led[1:0], led[2]};
        end else begin
            counter <= counter + 1'b1;
        end
    end
endmodule
