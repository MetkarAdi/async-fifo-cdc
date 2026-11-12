`timescale 1ns/1ps
module tb_async_fifo;
    parameter DATA_W    = 8;
    parameter ADDR_W    = 4;      // FIFO depth = 16
    parameter NUM_WORDS = 500;

    reg               wclk = 0, rclk = 0;
    reg               wrst_n = 0, rrst_n = 0;
    reg               winc = 0, rinc = 0;
    reg  [DATA_W-1:0] wdata = 0;
    wire [DATA_W-1:0] rdata;
    wire              wfull, rempty;

    async_fifo #(DATA_W, ADDR_W) dut (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc), .wdata(wdata), .wfull(wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc), .rdata(rdata), .rempty(rempty));

    // Two unrelated clocks
    always #5     wclk = ~wclk;   // 100 MHz
    always #8.333 rclk = ~rclk;   // about 60 MHz

    // Scoreboard: what we wrote is what we expect to read back, in order
    reg [DATA_W-1:0] exp_mem [0:NUM_WORDS-1];
    integer wr_count = 0, rd_count = 0;
    integer errors = 0, full_cnt = 0, empty_cnt = 0;

    // Writer: random write requests; records each write the FIFO accepts
    always @(posedge wclk) begin
        if (wrst_n) begin
            if (winc && !wfull) begin
                exp_mem[wr_count] = wdata;
                wr_count = wr_count + 1;
            end
            if (wfull) full_cnt = full_cnt + 1;
            // phase 1: write fast. phase 2: write slowly
            winc  <= (wr_count < NUM_WORDS) &&
                     (($random & 15) < ((rd_count < 150) ? 14 : 3));
            wdata <= $random;
        end
    end

    // Reader: random read requests; checks each word it receives
    always @(posedge rclk) begin
        if (rrst_n) begin
            if (rinc && !rempty) begin
                if (rd_count >= wr_count) begin
                    errors = errors + 1;
                    $display("ERROR: read word %0d but only %0d were written", rd_count, wr_count);
                end else if (rdata !== exp_mem[rd_count]) begin
                    errors = errors + 1;
                    $display("ERROR: word %0d expected %h got %h", rd_count, exp_mem[rd_count], rdata);
                end
                rd_count = rd_count + 1;
            end
            if (rempty && rd_count > 0) empty_cnt = empty_cnt + 1;
            // phase 1: read slowly (FIFO fills up). phase 2: read fast (FIFO drains)
            rinc <= (($random & 15) < ((rd_count < 150) ? 3 : 14));
        end
    end

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, tb_async_fifo);
        #50 wrst_n = 1; rrst_n = 1;      // release reset
        wait (rd_count == NUM_WORDS);
        #200;
        $display("----------------------------------------");
        $display("words written : %0d", wr_count);
        $display("words read    : %0d", rd_count);
        $display("errors        : %0d", errors);
        $display("full cycles   : %0d   empty cycles: %0d", full_cnt, empty_cnt);
        if (errors == 0 && wr_count == NUM_WORDS && rd_count == NUM_WORDS)
            $display("RESULT: PASS");
        else
            $display("RESULT: FAIL");
        $finish;
    end

    // Safety net in case something hangs
    initial begin
        #1000000;
        $display("RESULT: TIMEOUT (read %0d of %0d words)", rd_count, NUM_WORDS);
        $finish;
    end
endmodule