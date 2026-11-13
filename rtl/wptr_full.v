module wptr_full #(parameter ADDR_W = 4) (
    input                   wclk,
    input                   wrst_n,
    input                   winc,        // write request
    input  [ADDR_W:0]       wq2_rptr,    // read pointer (gray), already synchronized
    output reg              wfull,
    output [ADDR_W-1:0]     waddr,       // address into the memory
    output reg [ADDR_W:0]   wptr         // write pointer in gray code
);
    reg  [ADDR_W:0] wbin;                // write pointer in binary
    wire [ADDR_W:0] wbin_next, wgray_next;
    wire            wfull_val;

    assign waddr      = wbin[ADDR_W-1:0];
    wire winc_ok;
    assign winc_ok = winc & ~wfull;
    assign wbin_next = wbin + {{ADDR_W{1'b0}}, winc_ok};
    assign wgray_next = (wbin_next >> 1) ^ wbin_next;   // binary to gray

    // Full when the next write pointer would catch up to the read pointer
    // after wrapping around once: top two gray bits differ, the rest match.
    assign wfull_val = (wgray_next == {~wq2_rptr[ADDR_W:ADDR_W-1],
                                        wq2_rptr[ADDR_W-2:0]});

    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) {wbin, wptr} <= 0;
        else         {wbin, wptr} <= {wbin_next, wgray_next};

    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) wfull <= 1'b0;
        else         wfull <= wfull_val;
endmodule
