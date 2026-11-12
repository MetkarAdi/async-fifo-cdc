module sync_2ff #(parameter WIDTH = 1) (
    input                  clk,
    input                  rst_n,
    input      [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    reg [WIDTH-1:0] meta;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            meta <= 0;
            q    <= 0;
        end else begin
            meta <= d;   // first flop: may go metastable
            q    <= meta; // second flop: gives it a clock cycle to settle
        end
    end
endmodule