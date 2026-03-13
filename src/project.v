/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  reg q;

  always @(posedge clk) begin
    if (!rst_n)        // rst_n is active-low
      q <= 1'b0;
    else if (ui_in[1]) // en_i
      q <= ui_in[0];   // d_i
  end

  assign uo_out  = {7'b0, q};
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  wire _unused = &{ena, ui_in[7:2], uio_in, 1'b0};

endmodule
