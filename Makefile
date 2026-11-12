RTL = rtl/sync_2ff.v rtl/fifo_mem.v rtl/wptr_full.v rtl/rptr_empty.v rtl/async_fifo.v
TB  = tb/tb_async_fifo.v

sim: $(RTL) $(TB)
	iverilog -g2012 -o fifo.vvp $(RTL) $(TB)
	vvp fifo.vvp

wave: sim
	gtkwave fifo.vcd

clean:
	rm -f *.vvp *.vcd