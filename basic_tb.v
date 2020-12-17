module basic_tb();
	parameter NUM_TESTS = 4;
	
  reg      clk   = 1'b0   ;      // advances simulation step-by-step
  reg      init  = 1'b1   ;      // init (reset) command to DUT
  reg      start = 1'b1   ;      // req (start program) command to DUT
  wire     done           ;      // done flag returned by DUT
  
  integer i;
    CPU dut(
    .clk     (clk  ),   // input: use your own port names, if different
    .reset   (init ),   // input: some prefer to call this ".reset"
    .start   (start),   // input: launch program
    .ack     (done )    // output: "program run complete"
  );


  reg[7:0] sum1 = 8'd25;
  reg[7:0] sum2 = 8'd45;
  reg[7:0] sub1 = 8'd14;
  reg[7:0] sub2 = 8'd9;
  reg[7:0] sub3 = 8'd27;
  reg[7:0] sub4 = 8'd30;
  reg[7:0] mult1 = 8'd3;
  //outputs from CPU
  reg[7:0] res[NUM_TESTS-1:0];
  reg[7:0] des[NUM_TESTS-1:0];

  
  
/*
	This TB tests the basic functions of the CPU.
	TESTS:
	
	test1:
		25 + 45 = 70
	test2:
		14 - 9 = 5
	test3:
		27 - 30 = -3
	test 4:
		5 * 3

	results for tests will be stored sequentially from memory location 10-13
*/

initial begin
	des[0] = sum1+ sum2;
	des[1] = sub1 - sub2;
	des[2] = sub3 - sub4;
	des[3] = mult1 * 5;

	#10; 
	start = 1;
	init = 1;
		
	#20; 
	start = 0;
	init = 0;
	dut.DM1.core[0] = sum1;
	dut.DM1.core[1] = sum2;
	dut.DM1.core[2] = sub1;
	dut.DM1.core[3] = sub2;
	dut.DM1.core[4] = sub3;
	dut.DM1.core[5] = sub4;
	dut.DM1.core[6] = mult1;
	#20
	wait(done);
	for (i = 0; i < NUM_TESTS; i = i +1) begin
		res[i] = dut.DM1.core[10 + i];
	end
	
	for (i = 0; i < NUM_TESTS; i = i +1) begin
			$display("Test %d\n", i);
		if (res[i] == des[i]) 
			$display("\tCorrect!");
		else
			$display("Woops! Expected = %d, Received = %d", des[i], res[i]);
	end
		
	#10
	$stop();
end


always begin
       clk = 0;
  #10; clk = 1;
  #10;
end


endmodule