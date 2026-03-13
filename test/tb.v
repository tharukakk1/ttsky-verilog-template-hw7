`default_nettype none
`timescale 1ns / 1ps

module tb ();
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Error counter for cocotb to read
  integer error_count;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  tt_um_example user_project (
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe),
      .ena    (ena),
      .clk    (clk),
      .rst_n  (rst_n)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  wire q_o = uo_out[0];

  task wait_negedge;
    @(negedge clk);
  endtask

  reg q_before, q_after, q_middle, q_bert;

  initial begin
    error_count = 0;
    ena    = 1;
    uio_in = 8'b0;
    ui_in  = 8'b0;
    rst_n  = 1;

    // Apply reset
    wait_negedge;
    rst_n = 0;
    wait_negedge;
    wait_negedge;
    wait_negedge;
    rst_n = 1;

    // --- Reset test ---
    ui_in[0] = 0;
    ui_in[1] = 0;
    wait_negedge;
    if (q_o == 0)
      $display("PASS: reset test. q_o=%0b", q_o);
    else begin
      $display("FAIL: reset test. q_o=%0b", q_o);
      error_count = error_count + 1;
    end

    // --- Enable=0 test ---
    ui_in[1] = 0;
    ui_in[0] = 1;
    wait_negedge;
    q_before = q_o;
    wait_negedge;
    q_after = q_o;
    if (q_before === q_after)
      $display("PASS: enable=0 test. q_o=%0b", q_o);
    else begin
      $display("FAIL: enable=0 test. q_before=%0b q_after=%0b", q_before, q_after);
      error_count = error_count + 1;
    end

    // --- Enable=1 test ---
    ui_in[1] = 1;
    ui_in[0] = 1;
    wait_negedge;
    q_before = q_o;

    ui_in[0] = 0;
    wait_negedge;
    q_middle = q_o;

    ui_in[0] = 1;
    wait_negedge;
    q_after = q_o;

    wait_negedge;
    rst_n = 0;
    #1;
    q_bert = q_o;
    wait_negedge;

    if ((q_before === 1'b1) & (q_middle === 1'b0) & (q_after === 1'b1) & (q_bert === 1'b1))
      $display("PASS: enable=1 test. q_before=%0b q_middle=%0b q_after=%0b q_bert=%0b",
               q_before, q_middle, q_after, q_bert);
    else begin
      $display("FAIL: enable=1 test. q_before=%0b q_middle=%0b q_after=%0b q_bert=%0b",
               q_before, q_middle, q_after, q_bert);
      error_count = error_count + 1;
    end

    $display("Tests complete. Total errors: %0d", error_count);
    // Do NOT call $finish here — let cocotb's Timer control when simulation ends
  end

endmodule
