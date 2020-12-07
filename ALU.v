// Module Name:    ALU 
// Project Name:   CSE141L 
//
// Revision Fall 2020
// Student: Cole W. Tynan-Wood
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// 


	 
module ALU(input_a,input_b,OP,out,zero);

	input [7:0] input_a;
	input [7:0] input_b;
	input [2:0] OP;
	output reg [7:0] out; // logic in SystemVerilog
	output reg zero;

	/* Opcodes
	000: stp (halt)
	001: shf
	011: nor
	010: bneg
	110: st
	100: add
	101: addi
	111: ld
	*/
	always@* // always_comb in systemverilog
	begin 
		out = 0;
		casex (OP)
		3'b11x: out = input_b;			 //ld/st
		3'b10x: out = input_a + input_b; // add operations
		3'b011: out = ~(input_a | input_b); // Nor
		3'b001: out = (input_b[3] == 1'b0) ? input_a << input_b[3:0] : input_a >> (~input_b[3:0] + 1'b1) ;				// Shift 
		3'b010: out = (input_a[7] == 1) ? 8'b0 : 8'b1; //bneg
		default: out = 0;
	  endcase
	
	end 

	always@*							  // assign zero = !out;
	begin
		case(out)
			'b0     : zero = 1'b1;
			default : zero = 1'b0;
      endcase
	end


endmodule