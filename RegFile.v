// Module Name:    RegFile 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module is your register file.
// If you have more or less bits for your registers, update the value of D.
// Ex. If you only supports 8 registers. Set D = 3

/* parameters are compile time directives 
       this can be an any-size reg_file: just override the params!
*/
module RegFile (clk,branch_en, write_en,r_addr_a,r_addr_b,w_addr,data_in,data_out_a,data_out_b);
	parameter W=8, D=4;  // W = data path width (Do not change); D = pointer width (You may change)
	input                clk,
						 branch_en,
						 write_en;
	input        [D-1:0] r_addr_a,				  // address pointers
						 r_addr_b,
						 w_addr;
	input        [W-1:0] data_in;
	output reg   [W-1:0] data_out_a;			  
	output reg   [W-1:0] data_out_b;				

// W bits wide [W-1:0] and 2**4 registers deep 	 
reg [W-1:0] Registers[(2**D)-1:0];	  // or just registers[16-1:0] if we know D=4 always



// NOTE:
// READ is combinational
// WRITE is sequential

always@*
begin
 data_out_a = branch_en  ? Registers[8'd7] : Registers[r_addr_a]; //if branch_Enable is high, use the comparison register 
 data_out_b = branch_en  ? Registers[8'd0] : Registers[r_addr_b];    
end

// sequential (clocked) writes 
always @ (posedge clk)
  if (write_en)	                             // works just like data_memory writes
    Registers[w_addr] <= data_in;

endmodule
