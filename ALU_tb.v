`timescale 1ns/ 1ps



//Test bench
//Arithmetic Logic Unit
/*
* INPUT: A, B
* op: 00, A PLUS B
* op: 01, A AND B
* op: 10, A OR B
* op: 11, A XOR B
* outPUT A op B
* equal: is A == B?
* even: is the output even?
*/


module ALU_tb;
reg [ 7:0] input_a;     	  // data inputs
reg [ 7:0] input_b;
reg [ 7:0] test;
reg [ 2:0] op;		// ALU opcode, part of microcode
wire[ 7:0] out;		  

  wire zero;    
 
 reg [ 7:0] expected;
 
// CONNECTION
ALU uut(
  .input_a(input_a),      	  
  .input_b(input_b),
  .OP(op),				  
  .out(out),		  			
  .zero(zero)
    );
	 
initial begin

	test = 8'b1;
	input_a = 8'b00101101;
	input_b = 8'b10110100;  //expected 0100 0010
	op= 'b011; // NOR
	test_alu_func; // void function call
	#5;
	
	test = 8'd2;
	input_a = 8'b01011100;
	input_b = 8'b00000100; //shift left by 4, expected = 1100 0000
	op= 'b001; // shift
	test_alu_func; // void function call
	#5;
	
	test = 8'd3;
	input_a = 8'b01011100;
	input_b = 8'b00001100; //right shift by 4, expected = 0000 0101
	op= 'b001; // shift
	test_alu_func; // void function call
	#5;
	
	test = 8'd4;
	input_a = 8'b01011100; //92
	input_b = 8'b00001001; // expected = 1
	op= 'b010; // bneg
	test_alu_func; // void function call
	#5;
	
	test = 8'd5;
	input_a = 8'b11011100; //-36
	input_b = 8'b00001001; // expected = 0
	op= 'b010; // bneg
	test_alu_func; // void function call
	#5;
	
	test = 8'd6;
	input_a = 8'b00011100; //28
	input_b = 8'b00001001; //9 expected = 10 0101
	op= 'b100; // add
	test_alu_func; // void function call
	#5;
	
	test = 8'd7;
	input_a = 8'b00011100; //28
	input_b = 8'b10001001; //-119 expected = (-91) 1010 0101
	op= 'b100; // add
	test_alu_func; // void function call
	#5;
	end
	
	
	/*
		3'b1xx: out = input_a + input_b; 	// All R-type operations (besides shift)
		3'b011: out = !(input_a | input_b); // Nor
		3'b001: out = (input_b[3] == 1'b0) ? input_a << input_b[3:0] : input_a >>> input_b[3:0]  ;				// Shift 
		3'b010: out = (input_a < 8'b0) ? 8'b0 : 8'b1;	//bneg
	*/
	task test_alu_func;
	begin
	  case (test)
		1: expected = 8'b01000010;	//nor
		2: expected = 8'b11000000;	//shf left
		3: expected = 8'b00000101; //shf right
		4: expected = 8'b1;			//bneg
		5: expected = 8'b0;
		6: expected = 8'b100101; 	//add 
		7: expected = 8'b10100101;
	  endcase
	  #1; if(expected == out)
		begin
			$display("%t YAY!! inputs = %b %b, opcode = %b, zero %b, out = %b",$time, input_a,input_b,op, zero, out);
		end
	    else begin $display("%t FAIL! inputs = %b %b, opcode = %b, zero = %b, out = %b ",$time, input_a,input_b,op, zero, out);end
		
	end
	endtask



endmodule