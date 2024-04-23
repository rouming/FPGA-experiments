module top(
 input wire  clk,
 input wire  key_i,
 input wire  rst_i,
 output wire LED_R
			   );

   parameter  SIZE = 24;
   localparam N = $clog2(SIZE);

   reg [SIZE-1:0] cnt;
   reg [N-1:0]	  b;
   reg			  sw_minus, sw_plus;
   wire 		  minus_xor_plus;

   assign minus_xor_plus = sw_minus ^ sw_plus;
   assign LED_R = (b == 0 ? clk : cnt[b-1]);

   debouncer btn1(.clk(clk), .PB(key_i), .PB_state(sw_plus));
   debouncer btn2(.clk(clk), .PB(rst_i), .PB_state(sw_minus));

   always @(posedge clk) begin
	  cnt <= cnt + 1;
   end

   always @(negedge minus_xor_plus) begin
	  if (sw_plus && b < SIZE)
		b <= b + 1;
	  else if (sw_minus && b > 0)
		b <= b - 1;
   end


endmodule
