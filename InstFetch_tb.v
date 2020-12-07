`timescale 1ns/ 1ps

/*
module InstFetch(reset,start,clk,branch_en,ALU_flag,target,prog_ctr);

	input           reset,			   // reset, init, etc. -- force PC to 0 
					start,			   // begin next program in series
					clk,			   // PC can change on pos. edges only
					branch_en,	   // jump conditionally to target + PC
					ALU_flag;		   // flag from ALU, e.g. zero, Carry, Overflow, Negative (from ARM)
  input [10:0] 		target;		       // jump ... "how high?"
  output reg[10:0]  prog_ctr ;         // the program counter register itself
*/

module InstFetch_tb;
	parameter CLK_CYCLE_TIME = 10; //ns
	reg reset, start, clk, branch_en, ALU_flag;
	reg[10:0] target;
	wire[10:0] prog_ctr;
	wire[8:0] instruction;
	reg  [15:0] cycle_ct;
	
	//init
	
	
	
	InstFetch infe1(
		.reset(reset),
		.start(start),
		.clk(clk),
		.branch_en(branch_en),
		.ALU_flag(ALU_flag),
		.target(target),
		.prog_ctr(prog_ctr));
	
	//ROM instantiation
	InstROM inst1(
		.inst_address   (prog_ctr), 
		.inst_out       (instruction)
	);
	initial begin
		//initialize 
		reset = 1;
		start = 1;
		clk = 0;
		branch_en = 0;
		ALU_flag = 0;
		target = 0;
		#20; //begin prog ctr
		reset = 0;
		start = 0;
		#60
		//do a branch
		$display("Perfoming branch forward by 4 instructions");
		ALU_flag = 1;	
		branch_en = 1;
		target = 11'b100;	//branch forward by 4 instructions
		#20
		ALU_flag = 0;
		branch_en = 0;
		#500;
		$finish();
	end
	
	always@(posedge clk) begin
		if (prog_ctr == instruction)
			$display("All good! Prog Ctr: %d, Instruction: %b", prog_ctr, instruction);
		else
			$display("ERROR! Prog Ctr: %d, Instruction: %b", prog_ctr, instruction);
	end
	//clock logic (clogic)
	always@(clk) begin
		#CLK_CYCLE_TIME clk <= !clk;
	end
	
	always @(posedge clk)
	  if (start == 1)	   // if(start)
		 cycle_ct <= 0;
	  else
		cycle_ct <= cycle_ct+16'b1;
endmodule