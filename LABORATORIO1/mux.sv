module mux4to1_32bit
  (
    output logic [31:0] f,
    input  logic [31:0] a, b, c, d,
    input  logic sel1, sel2
  );

  logic n_sel1, n_sel2;
  logic [31:0] f1, f2, f3, f4;

  not g6(n_sel1, sel1);
  not g7(n_sel2, sel2);

  and g1[31:0](f1, n_sel1, n_sel2, a);
  and g2[31:0](f2, sel1,   n_sel2, b);
  and g3[31:0](f3, n_sel1, sel2,   c);
  and g4[31:0](f4, sel1,   sel2,   d);
      
  or  g5[31:0](f, f1, f2, f3, f4);

endmodule
