// Module Name:    CPU 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This is the TopLevel of your project
// Testbench will create an instance of your CPU and test it
// You may add a LUT if needed
// Set ack to 1 to alert testbench that your CPU finishes doing a program or all 3 programs



	 
module CPU(reset, start, clk, ack);

	input reset;		// init/reset, active high
	input start;		// start next program
	input clk;			// clock -- posedge used inside design
	output reg ack;   	// done flag from DUT

	
	
	wire [ 10:0] pgm_ctr,        // program counter
			    pc_targ;
	wire [ 8:0] instruction;   // our 9-bit instruction
	wire [ 2:0] instr_opcode;  // out 3-bit opcode
	wire [ 7:0] read_a, read_b;  // reg_file outputs
	wire [ 7:0] in_a, in_b, 	   // ALU operand inputs
				ALU_out;       // ALU result
	wire [ 7:0] reg_write_value, // data in to reg file
				mem_write_value, // data in to data_memory
				mem_read_value;  // data out from data_memory
	wire        mem_write,	   // data_memory write enable
				reg_wr_en,	      // reg_file write enable
				zero,		      // ALU output = 0 flag
				branch_en,	   // to program counter: branch enable
				load_inst,
				immed;
	reg  [15:0] cycle_ct;	      // standalone; NOT PC!

	// Fetch = Program Counter + instruction ROM
	// Program Counter
  InstFetch IF1 (
	.reset       (reset   ) , 
	.start       (start   ) ,  
	.clk         (clk     ) ,  
	.branch_en (branch_en) ,  // branch enable
	.ALU_flag	 (zero    ) ,
    .target      (pc_targ  ) ,
	.prog_ctr     (pgm_ctr  )	   // program count = index to instruction memory
	);	

	// Control decoder
  Ctrl Ctrl1 (
	.instruction  	(instruction),    // from instr_ROM
	.branch_en     (branch_en),		// to PC
	.ld_inst			(load_inst),
	.wrt_reg 		(reg_wr_en),
	.wrt_mem 		(mem_write),
	.immed			(immed)
  );
  assign pc_targ = {4'b0, instruction[5:0]};	//NOTE: Sign extend instead??
  
	// instruction ROM
  InstROM IR1(
	.inst_address   (pgm_ctr), 
	.inst_out       (instruction)
	);
	
	always@(*) begin
		ack = (instr_opcode == 3'b0) ? 1'b1  : 1'b0;
	end

	//Reg file
	// Modify D = *Number of bits you use for each register*
    // Width of register is 8 bits, do not modify
	RegFile #(.W(8),.D(3)) RF1 (
		.clk    		(clk),
		.write_en   (reg_wr_en), 
		.branch_en (branch_en),
		.r_addr_a    (instruction[5:3]),         
		.r_addr_b    (instruction[2:0]), 
		.w_addr     (instruction[5:3]), 	       
		.data_in    (reg_write_value) , 
		.data_out_a  (read_a        ) , 
		.data_out_b  (read_b		 )
	);
	
	
	//muxes
	assign in_a = read_a;						                    // connect RF out to ALU in
	assign in_b = immed ? instruction[2:0] : read_b;				//2:1 switch for immediate versus register out
	assign instr_opcode = instruction[8:6];
	assign reg_write_value = load_inst ? mem_read_value : ALU_out;  // 2:1 switch into reg_file

	// Arithmetic Logic Unit
	ALU ALU1(
		.input_a(in_a),      	  
		.input_b(in_b),
		.OP(instr_opcode),				  
		.out(ALU_out),		  			
		.zero()
	);
	 
	 
	 // Data Memory
	DataMem DM1(
		.data_address  (read_a)    , 
		.write_en      (mem_write), 
		.data_in       (mem_write_value), 
		.data_out      (mem_read_value)  , 
		.clk 		  (clk)     ,
		.reset		  (reset)
	);

	
	
// count number of instructions executed
// Help you with debugging
	always @(posedge clk)
	  if (start == 1)	   // if(start)
		 cycle_ct <= 0;
	  else if(ack == 0)   // if(!halt)
		 cycle_ct <= cycle_ct+16'b1;

endmodule