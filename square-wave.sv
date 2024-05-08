module debouncer(
    input  wire clk,
    input  wire PB,
	output wire PB_state);

   // Synchronize the switch input to the clock
   reg PB_sync_0, PB_sync_1;
   always @(posedge clk) begin
	  PB_sync_0 <= PB;
	  PB_sync_1 <= PB_sync_0;
   end

   reg PB_state_out = 0;

   assign PB_state = PB_state_out;

   // Debounce the switch
   reg [15:0] PB_cnt = 0;
   always @(posedge clk) begin
	  if (PB_state_out == PB_sync_1) begin
		 PB_cnt <= 0;
	  end else begin
		 PB_cnt <= PB_cnt + 1'b1;
		 if (PB_cnt == 16'hffff) begin
			PB_state_out <= ~PB_state_out;
		 end
	  end
   end
endmodule

(*top*)
module square_wave(
 input wire  clk,
 input wire  key_i,
 input wire  rst_i,
 output wire LED_R
			   );

   parameter  SIZE = 24;
   localparam N = $clog2(SIZE);

   reg [SIZE-1:0] cnt = 0;
   reg [N-1:0]	  b = 0;
   wire			  sw_minus;
   wire			  sw_plus;

   assign LED_R = (b == 0 ? clk : cnt[b-1]);

   debouncer btn1(.clk(clk), .PB(key_i), .PB_state(sw_plus));
   debouncer btn2(.clk(clk), .PB(rst_i), .PB_state(sw_minus));

   reg [1:0] sw_bits0;
   reg [1:0] sw_bits1;

   always_ff @(posedge clk) begin
	  cnt <= cnt + 1;

	  sw_bits0 <= {sw_plus, sw_minus};
	  sw_bits1 <= sw_bits0;
	  /* Detect posedge */
	  if (|sw_bits0 && !(|sw_bits1)) begin
		 case (sw_bits0)
		   2'b10:
			  if (b < SIZE)
				b <= b + 1;
		   2'b01:
			 if  (b > 0)
			   b <= b - 1;
		   default:
			 ;
		  endcase
	  end
   end
endmodule

`ifdef TESTBENCH
module testbench;
   reg clk, key_i, rst_i;
   time ts_clk, ts_clk_period;
   time ts, ts_period;
   wire LED_R;

   initial begin
	  clk = 0;
	  key_i = 0;
	  rst_i = 0;
	  ts_clk = 0;
	  ts_clk_period = 0;
   end

   always #10 clk = ~clk;

   square_wave sw(.clk(clk), .key_i(key_i),
				  .rst_i(rst_i), .LED_R(LED_R));

   always @(posedge LED_R) begin
	  ts_clk <= $time;
	  ts_clk_period <= $time - ts_clk;
   end

   initial begin
	  $dumpfile("square-wave.vcd");
	  $dumpvars(0, testbench);

	  /* Plus button */

	  ts = $time;
	  key_i = 1;
	  wait (ts_clk_period == 40);
	  $display("1. Observed +button press");
	  key_i = 0;
	  ts_period = $time - ts;
	  /* Button release should be observed */
	  #(ts_period);

	  key_i = 1;
	  wait (ts_clk_period == 80);
	  $display("2. Observed +button press");
	  key_i = 0;
	  /* Button release should be observed */
	  #(ts_period)

	  key_i = 1;
	  wait (ts_clk_period == 160);
	  $display("3. Observed +button press");
	  key_i = 0;
	  /* Button release should be observed */
	  #(ts_period)

	  /* Minus button */

	  rst_i = 1;
	  wait (ts_clk_period == 80);
	  $display("4. Observed -button press");
	  rst_i = 0;
	  /* Button release should be observed */
	  #(ts_period)

	  rst_i = 1;
	  wait (ts_clk_period == 40);
	  rst_i = 0;
	  /* Button release should be observed */
	  #(ts_period)

	  rst_i = 1;
	  wait (ts_clk_period == 20);
	  $display("5. Observed -button press");
	  rst_i = 0;
	  /* Button release should be observed */
	  #(ts_period)

	  rst_i = 1;
	  /* Press should be observed */
	  #(ts_period)
	  /* Stays the same */
	  wait (ts_clk_period == 20);
	  $display("6. Observed -button press");
	  rst_i = 0;
	  /* Button release should be observed */
	  #(ts_period)

	  $finish;
   end
endmodule
`endif
