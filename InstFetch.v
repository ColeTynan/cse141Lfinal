// Module Name:    InstFetch 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module does not actually fetch the actual code
// It is responsible for providing which line number will be read next


	 
module InstFetch(reset,start,clk,branch_en,ALU_flag,target,prog_ctr);

	input           reset,			   // reset, init, etc. -- force PC to 0 
					start,			   // begin next program in series
					clk,			   // PC can change on pos. edges only
					branch_en,	   // jump conditionally to target + PC
					ALU_flag;		   // flag from ALU, e.g. zero, Carry, Overflow, Negative (from ARM)
  input [10:0] 		target;		       // jump ... "how high?"
  output reg[10:0]  prog_ctr ;         // the program counter register itself
  
  
  //// program counter can clear to 0, increment, or jump
	always @(posedge clk)
	begin 
		if(reset)
		  prog_ctr <= 0;				        // for first program; want different value for 2nd or 3rd
		else if(start)						     // hold while start asserted; commence when released
		  prog_ctr <= prog_ctr;
		else if(branch_en && ALU_flag)   // conditional relative jump
		  prog_ctr <= target + prog_ctr;
		else
		  prog_ctr <= prog_ctr+11'b1; 	        // default increment (no need for ARM/MIPS +4. Pop quiz: why?)
	end


endmodule

/* Note about start: if your programs are spread out, with a gap in your machine code listing, you will want 
to make start cause an appropriate jump. If your programs are packed sequentially, such that program 2 begins 
right after Program 1 ends, then you won't need to do anything special here. 
*/