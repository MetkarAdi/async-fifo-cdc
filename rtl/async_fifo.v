module async_fifo #(parameter DATA_W = 8, ADDR_W = 4) (
    // write side
    input                   wclk,
    input                   wrst_n,
    input                   winc,
    input  [DATA_W-1:0]     wdata,
    output                  wfull,
    // read side
    input                   rclk,
    input                   rrst_n,
    input                   rinc,
    output [DATA_W-1:0]     rdata,
    output                  rempty
);
    wire [ADDR_W-1:0] waddr, raddr;
    wire [ADDR_W:0]   wptr, rptr, wq2_rptr, rq2_wptr;

    // read pointer crosses into the write clock domain
    sync_2ff #(ADDR_W+1) sync_r2w (
        .clk(wclk), .rst_n(wrst_n), .d(rptr), .q(wq2_rptr));

    // write pointer crosses into the read clock domain
    sync_2ff #(ADDR_W+1) sync_w2r (
        .clk(rclk), .rst_n(rrst_n), .d(wptr), .q(rq2_wptr));

    fifo_mem #(DATA_W, ADDR_W) u_mem (
        .wclk(wclk), .wen(winc & ~wfull),
        .waddr(waddr), .raddr(raddr),
        .wdata(wdata), .rdata(rdata));

    wptr_full #(ADDR_W) wctrl (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc),
        .wq2_rptr(wq2_rptr), .wfull(wfull),
        .waddr(waddr), .wptr(wptr));

    rptr_empty #(ADDR_W) rctrl (
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc),
        .rq2_wptr(rq2_wptr), .rempty(rempty),
        .raddr(raddr), .rptr(rptr));
endmodule
