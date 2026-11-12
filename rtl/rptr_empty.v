module rptr_empty #(parameter ADDR_W = 4) (
    input                   rclk,
    input                   rrst_n,
    input                   rinc,        // read request
    input  [ADDR_W:0]       rq2_wptr,    // write pointer (gray), already synchronized
    output reg              rempty,
    output [ADDR_W-1:0]     raddr,       // address into the memory
    output reg [ADDR_W:0]   rptr         // read pointer in gray code
);
    reg  [ADDR_W:0] rbin;                // read pointer in binary
    wire [ADDR_W:0] rbin_next, rgray_next;
    wire            rempty_val;

    assign raddr      = rbin[ADDR_W-1:0];
    assign rbin_next  = rbin + (rinc & ~rempty);
    assign rgray_next = (rbin_next >> 1) ^ rbin_next;

    // Empty when the next read pointer has caught up with the write pointer
    assign rempty_val = (rgray_next == rq2_wptr);

    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) {rbin, rptr} <= 0;
        else         {rbin, rptr} <= {rbin_next, rgray_next};

    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) rempty <= 1'b1;     // FIFO starts empty
        else         rempty <= rempty_val;
endmodule