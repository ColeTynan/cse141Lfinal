// Module Name:    Ctrl 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module is the control decoder (combinational, not clocked)
// Out of all the files, you'll probably write the most lines of code here
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
// There may be more outputs going to other modules

module Ctrl (instruction, branch_en, ld_inst, wrt_reg, wrt_mem, immed);


  input[8:0] instruction;	   // machine code
  output 	  branch_en,
			  ld_inst,
			  wrt_reg,
			  wrt_mem,
			  immed;
  
	/*Opcodes
	000: stp (halt)
	001: shf
	011: nor
	010: bneg
	110: st
	100: add
	101: addi
	111: ld
	*/
	
	// jump on right shift that generates a zero

	reg[4:0] control_signals;
	always@(*) begin
		control_signals = 0;
		case (instruction[8:6])
			3'b000: control_signals = 5'b00000;	//stp
			3'b001: control_signals = 5'b00100;	//shf
			3'b011: control_signals = 5'b00100;	//nor
			3'b010: control_signals = 5'b10000;	//bneg
			3'b110: control_signals = 5'b00010;	//st
			3'b100: control_signals = 5'b00100;	//add
			3'b101: control_signals = 5'b00101;	//addi
			3'b111: control_signals = 5'b01100;	//ld
			default: control_signals = 5'b0;
		endcase
	end
	
	//assign control signals to individual outputs
	assign {branch_en, ld_inst, wrt_reg, wrt_mem, immed} = control_signals;
	//obviously can also write each control signal one at a time to make it easier to read.


endmodule

