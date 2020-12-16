	README FOR CIBBA
	
	
ASSEMBLER
	To add comments into ISA code use '#'. Ensure there is whitespace/new line between any code and the start of a comment.
	
RULES
	1. Branches
		a. branches have a max relative addressing mode of 31 instructions apart
		b. load the comparison register $c before doing a bneg instruction
		c. Labels are specifically designated by a capital "L" character. if the label does not have this, it will not be recognized.

CHANGELOG
	1. ASSEMBLER: 
		a. switched from c++ to simply using c as there were deprecation issues in c++.
		b. added ability to specify input files via the command line upon running executable.
		c. added some error checking. 
	2. CPU
		a. Change addressing mode to absolute in branches.
		b. register "$zero" changed to "$fill" and is the inverse of a zero register: all 1s. This makes it easy to zero out registers
with a nor instruction, and frees up the 0 spot in data memory, which previously also contained zero and was read only.
	
