module lfsr_6bit(
   input logic		  clk,
   output logic [5:0] lfsr = 6'b111111);

   always @(posedge clk) begin
	  lfsr[0] <= lfsr[0] ^ lfsr[5];
	  lfsr[1] <= lfsr[0];
	  lfsr[2] <= lfsr[1];
	  lfsr[3] <= lfsr[2];
	  lfsr[4] <= lfsr[3];
	  lfsr[5] <= lfsr[4];
   end
endmodule // lfsr_6bit

(*top*)
module lfsr_for_tangnano20k(
    input logic 	   clk,
	output logic [5:0] led);

   reg [23:0]		   cnt;
   wire 			   clk_reduced;

   always @(posedge clk)
	 cnt <= cnt + 1;

   assign clk_reduced = cnt[22];

   lfsr_6bit lfsr(.clk(clk_reduced), .lfsr(led));
endmodule

`ifdef TESTBENCH
module testbench;
   reg clk;
   reg [5:0] cnt;
   reg [5:0] lfsr;

   lfsr_6bit lf(.clk(clk), .lfsr(lfsr));

   always @(posedge clk) begin
	  cnt <= cnt + 1;
   end

   always #1 clk = ~clk;

   initial begin
	  clk = 0;
	  cnt = 0;

	  $monitor("%b", lfsr);

	  repeat(63) @(posedge clk);
	  $finish;
   end
endmodule // testbench
`endif
