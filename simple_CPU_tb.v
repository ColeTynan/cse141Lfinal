// CSE141L  Fall 2020
// test bench to be used to verify student projects
// pulses start while loading program 2 operand into DUT
//  waits for done pulse from DUT
//  reads and verifies result from DUT against its own computation
// Based on SystemVerilog source code provided by John Eldon
 
module simple_CPU_tb();


  reg      clk   = 1'b0   ;      // advances simulation step-by-step
  reg      init  = 1'b1   ;      // init (reset) command to DUT
  reg      start = 1'b1   ;      // req (start program) command to DUT
  wire     done           ;      // done flag returned by DUT
  
// ***** instantiate your top level design here *****
  CPU dut(
    .clk     (clk  ),   // input: use your own port names, if different
    .reset   (init ),   // input: some prefer to call this ".reset"
    .start   (start),   // input: launch program
    .ack     (done )    // output: "program run complete"
  );


// program 1 variables
/*
reg[63:0] dividend;      // fixed for pgm 1 at 64'h8000_0000_0000_0000;
reg[15:0] divisor1;	   // divisor 1 (sole operand for 1/x) to DUT
reg[63:0] quotient1;	   // internal wide-precision result
reg[15:0] result1,	   // desired final result, rounded to 16 bits
          result1_DUT;   // actual result from DUT
real quotientR;			   // quotient in $real format
*/

// program 2 variables
reg[7:0] dividend;	   // dividend 2 to DUT
reg[7:0] divisor;	   // divisor 2 to DUT
reg[7:0] quotient_exp, remainder_exp;
reg[7:0] remainder_rec, quotient_rec;
			
// clock -- controls all timing, data flow in hardware and test bench
always begin
       clk = 0;
  #10; clk = 1;
  #10;
end

initial begin

// preload operands and launch program 2
  #10; start = 1;
	    init = 1;
// The test below is calculating 3/255
// insert dividend and divisor
  dividend = 8'd43;	   	// *** try various values here ***
  divisor = 8'd12;		   // *** try various values here ***
// *** change names of memory or its guts as needed ***
  quotient_exp = dividend/divisor;
  remainder_exp = dividend%divisor;
  #20; start = 0;
	init = 0;
	dut.DM1.core[0] = dividend;
	dut.DM1.core[1] = divisor;
  #20; wait(done);
// *** change names of memory or its guts as needed ***
  quotient_rec = dut.DM1.core[4];
  remainder_rec = dut.DM1.core[5];
  $display ("dividend = %d, divisor = %d, quotient = %d, remainder = %d",
    dividend, divisor , quotient_rec, remainder_rec); 
  if(quotient_exp==quotient_rec) $display("success -- match");
  else $display("Quotient off! expected %d, got %d",quotient_exp,quotient_rec); 
  if(remainder_rec==remainder_exp) $display("success -- match");
  else $display("remainder off! expected %d, got %d",remainder_exp,remainder_rec); 
  #10;
  $stop;
end

endmodule