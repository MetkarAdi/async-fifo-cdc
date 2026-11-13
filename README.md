# Async FIFO with Clock Domain Crossing

Parameterized asynchronous FIFO in Verilog. The write and read sides run on
unrelated clocks. Pointers cross between domains as gray code through
2-flop synchronizers.

## Features
- Parameterized data width and depth (`DATA_W`, `ADDR_W`)
- Gray-code read/write pointers with one extra bit to tell full from empty
- 2-flop synchronizers on each pointer crossing
- `wfull` is registered in the write domain, `rempty` in the read domain
- Self-checking testbench with a scoreboard and random traffic

## Run it
Requires Icarus Verilog and GTKWave (`sudo apt install iverilog gtkwave`).

    make sim     # run the self-checking testbench
    make wave    # open the waveform

## Verification
The testbench runs a 100 MHz write clock against a roughly 60 MHz read clock
and pushes 500 random words through. It first writes fast and reads slowly so
the FIFO fills, then reverses so it drains. Every word read is compared with
the word written, in order.

Result:

    words written : 500
    words read    : 500
    errors        : 0
    full cycles   : 1377   empty cycles: 734
    RESULT: PASS

## Synthesis (Yosys, generic gate library)
Default configuration (8-bit data, 16 entries):

| Metric | Value |
|---|---|
| Flip-flops | 168 |
| Total logic cells | 392 |
| Latches | 0 |

Flop breakdown: 128 memory, 18 pointers (the top gray bit merges with the
binary pointer), 2 status flags, 20 synchronizer flops.

Lint is clean under `make lint` (Verilator `-Wall`). Run `make synth` to
reproduce.

Note: this is generic-gate synthesis, so it gives structure and size but no
timing. The memory maps to flip-flops. A real implementation would use an
SRAM or block RAM macro.

## Design notes
- **Why gray code:** only one bit changes per increment, so a pointer sampled
  mid-transition by the other clock is off by at most one. That makes the
  full/empty flags conservative but never wrong.
- **Why 2 flops:** the first flop may go metastable, and the second gives it
  a clock cycle to settle before the logic uses the value.
- **Full vs empty:** pointers are ADDR_W+1 bits wide. Empty means they are
  equal. Full means the top two gray bits differ and the rest match.
- **Latency cost:** the synchronizers delay pointer updates, so the flags lag
  by a couple of cycles. The FIFO may report full or empty slightly late
  (pessimistic), but never early.

## File structure
    rtl/   synthesizable design (fifo_mem, wptr_full, rptr_empty, async_fifo, sync_2ff)
    tb/    self-checking testbench