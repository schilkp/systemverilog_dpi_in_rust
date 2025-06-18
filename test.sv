module top (
    input  logic clk_i,
    input  logic rst_ni
);
    logic [31:0] cnt_q, cnt_d;
    assign cnt_d = cnt_q + 1;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            cnt_q <= 32'h0;
        end else begin
            cnt_q <= cnt_d;
        end
    end

    import "DPI-C" function void foo_c(input logic[31:0] arg_in, output logic[31:0] arg_out);
    import "DPI-C" function void foo_rs(input logic[31:0] arg_in, output logic[31:0] arg_out);
    logic [31:0] result_rs, result_c;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        logic [31:0] result_rs_d, result_c_d;
        if (!rst_ni) begin
            result_rs <= 'b0;
            result_c <= 'b0;
        end else begin
            foo_rs(cnt_q, result_rs_d);
            result_rs <= result_rs_d;
            foo_c(cnt_q, result_c_d);
            result_c <= result_c_d;
            if (result_rs_d !== result_c_d) begin
                $fatal(1, "ERROR: DPI function results mismatch! foo_rs returned 0x%08h, foo_c returned 0x%08h (input: 0x%08h)",
                       result_rs_d, result_c_d, cnt_q);
            end
        end
    end
endmodule
