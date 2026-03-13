## How it works

This project implements a synchronous D flip-flop with an active-low reset and an active-high enable,
built for Tiny Tapeout using Verilog.

On every rising clock edge, the flip-flop behaves as follows:
- If `rst_n` is low, the output `q_o` is cleared to 0 regardless of the other inputs.
- If `en_i` is high, the output `q_o` captures the value of `d_i`.
- If `en_i` is low, the output `q_o` holds its current value unchanged.

The pin mapping is:
- `ui[0]` — `d_i`: data input
- `ui[1]` — `en_i`: enable (active high)
- `uo[0]` — `q_o`: flip-flop output
- `rst_n` — reset (active low, shared with the Tiny Tapeout infrastructure)
- `clk` — clock (shared with the Tiny Tapeout infrastructure)

## How to test

1. Hold `rst_n` low for at least one clock cycle to reset the flip-flop. After releasing reset, `uo[0]` should read 0.
2. Set `ui[1]` (enable) low and toggle `ui[0]` (data). Verify that `uo[0]` does not change — the flip-flop should hold its value when disabled.
3. Set `ui[1]` (enable) high. On the next rising clock edge, `uo[0]` should capture whatever value is present on `ui[0]`.
4. Toggle `ui[0]` while `ui[1]` remains high across several clock cycles and confirm `uo[0]` tracks `ui[0]` one cycle at a time.
5. Assert `rst_n` low at any point and confirm `uo[0]` returns to 0 on the next rising clock edge.

The included cocotb testbench (`test/test.py`) automates all of the above and will report pass or fail.

## External hardware

No external hardware is required. All inputs and outputs are driven through the standard Tiny Tapeout
I/O pins. An optional logic analyser or oscilloscope connected to `uo[0]` can be used to observe
the flip-flop output in real time on silicon.