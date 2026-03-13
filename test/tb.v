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

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Convenience wire: q_o is bit 0 of uo_out
  wire q_o = uo_out[0];

  // Helper task: wait for a falling clock edge
  task wait_negedge;
    @(negedge clk);
  endtask

  reg q_before, q_after, q_middle, q_bert;

  initial begin
    // Initialize
    ena    = 1;
    uio_in = 8'b0;
    ui_in  = 8'b0;
    rst_n  = 1;  // not in reset

    // Apply reset (active-low: pull rst_n low)
    wait_negedge;
    rst_n = 0;
    wait_negedge;
    wait_negedge;
    wait_negedge;
    rst_n = 1;

    // --- Reset test ---
    ui_in[0] = 0; // d_i
    ui_in[1] = 0; // en_i
    wait_negedge;
    if (q_o == 0)
      $display("PASS: reset test. q_o=%0b", q_o);
    else begin
      $display("FAIL: reset test. q_o=%0b", q_o);
      $finish;
    end

    // --- Enable=0 test ---
    ui_in[1] = 0; // en_i = 0
    ui_in[0] = 1; // d_i = 1 (should be ignored)
    wait_negedge;
    q_before = q_o;
    wait_negedge;
    q_after = q_o;
    if (q_before === q_after)
      $display("PASS: enable=0 test. q_o=%0b", q_o);
    else begin
      $display("FAIL: enable=0 test. q_before=%0b q_after=%0b", q_before, q_after);
      $finish;
    end

    // --- Enable=1 test ---
    ui_in[1] = 1; // en_i = 1
    ui_in[0] = 1; // d_i = 1
    wait_negedge;
    q_before = q_o;  // expect 1

    ui_in[0] = 0;    // d_i = 0
    wait_negedge;
    q_middle = q_o;  // expect 0

    ui_in[0] = 1;    // d_i = 1
    wait_negedge;
    q_after = q_o;   // expect 1

    // Test that reset overrides enable
    wait_negedge;
    rst_n = 0;       // assert reset
    #1;
    q_bert = q_o;    // expect 1 (reset is synchronous, not yet clocked)
    wait_negedge;

    if ((q_before === 1'b1) & (q_middle === 1'b0) & (q_after === 1'b1) & (q_bert === 1'b1))
      $display("PASS: enable=1 test. q_before=%0b q_middle=%0b q_after=%0b q_bert=%0b",
               q_before, q_middle, q_after, q_bert);
    else begin
      $display("FAIL: enable=1 test. q_before=%0b q_middle=%0b q_after=%0b q_bert=%0b",
               q_before, q_middle, q_after, q_bert);
      $finish;
    end

    $display("All tests passed!");
    $finish;
  end

endmodule
