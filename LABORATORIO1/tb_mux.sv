`timescale 1ns/1ps

module tb_mux4to1_32bit;
  logic [31:0] a, b, c, d;
  logic sel1, sel2;
  logic [31:0] f;

  mux4to1_32bit dut(.f(f), .a(a), .b(b), .c(c), .d(d), .sel1(sel1), .sel2(sel2));

  initial begin
    // Valores fixos
    a = 32'hAAAA_AAAA;
    b = 32'h5555_5555;
    c = 32'hFFFF_0000;
    d = 32'h0000_FFFF;

    $monitor($time, " ns | sel2=%b sel1=%b | f=%h", sel2, sel1, f);

    {sel2, sel1} = 2'b00; #10;
    {sel2, sel1} = 2'b01; #10;
    {sel2, sel1} = 2'b10; #10;
    {sel2, sel1} = 2'b11; #10;

    $stop;
  end

endmodule: tb_mux4to1_32bit
