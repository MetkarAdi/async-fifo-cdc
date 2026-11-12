module fifo_mem #(parameter DATA_W = 8, ADDR_W = 4) (
    input                   wclk,
    input                   wen,
    input  [ADDR_W-1:0]     waddr,
    input  [ADDR_W-1:0]     raddr,
    input  [DATA_W-1:0]     wdata,
    output [DATA_W-1:0]     rdata
);
    reg [DATA_W-1:0] mem [0:(1<<ADDR_W)-1];

    always @(posedge wclk)
        if (wen) mem[waddr] <= wdata;

    assign rdata = mem[raddr];
endmodule