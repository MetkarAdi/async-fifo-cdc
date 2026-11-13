`timescale 1ns/1ps
module tb_sync;
    reg clk = 0, rst_n = 0;
    reg [3:0] d = 0;
    wire [3:0] q;

    sync_2ff #(4) dut (.clk(clk), .rst_n(rst_n), .d(d), .q(q));

    always #5 clk = ~clk;   // 100 MHz clock

    initial begin
        $dumpfile("sync.vcd");
        $dumpvars(0, tb_sync);
        #22 rst_n = 1;
        #10 d = 4'b1010;
        #50 $finish;
    end
endmodule
