// Module Name:    DataMem 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module is your Data memory
// Similar to instruction Memory, you may have a text file as your memory.
// You may hard code values into your memory. 
// Ex. If you just want the value 5 in memory 244 and 254 at position 16 when the progrghgam start,
// you may do so below.

module DataMem(clk,reset,write_en,data_address,data_in,data_out);
  input              clk,
                     reset,
                     write_en;
  input [7:0]        data_address,   // 8-bit-wide pointer to 256-deep memory
                     data_in;		   // 8-bit-wide data path, also
  output reg[7:0]    data_out;

  reg [7:0] core[256-1:0];			   // 8x256 two-dimensional array -- the memory itself

  integer i;
/* optional way to plant constants into DataMem at startup
    initial 
      $readmemh("dataram_init.list", core);
*/
  always@*                    // reads are combinational
  begin
    data_out = core[data_address];
  end
  
  always @ (posedge clk)		 // writes are sequential
/*( reset response is needed only for initialization (see inital $readmemh above for another choice)
  if you do not need to preload your data memory with any constants, you may omit the if(reset) and the else,
  and go straight to if(write_en) ...
*/
	begin
    if(reset) begin
// you may initialize your memory w/ constants, if you wish
      for(i=0;i<256;i = i + 1)
	      core[i] <= 0;
      core[ 16] <= 254;          // overrides the 0  ***sample only***
      core[244] <= 5;			   //    likewise
	end
    else if(write_en) 
      core[data_address] <= data_in;
	end
endmodule