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
	
Changes to TB
- added init flag
- changed output to be in decimal for readability

Difficulties
- I designed my entire ISA around branch conditions being decided by the sum of a negative number, generated performing twos complement,
and another number. Then, using the sign of the resulting sum, the branch would be taken or not taken. However, in the testbench provided,
one of the test values is an 8 bit number that has a value of 255, which means it must be unsigned. Thus, the calculation of 3/255 doesn't 
work. I didn't realize I would need to account for unsigned numbers until very late into the project, and by then it was too late to redesign.

- Debugging in general was extremely monotonous. It consisted of meticulously scanning through hundreds of instructions in modelsim, searching
for some string of bits that looked a little off, only to go back into the code hours later and find that it was just a typo causing the problem.

-I was unable to get prog 1 to work properly, due to the signed bit problem as previously mentioned. It does seem to operate optimally until there's a false
positive on a branch instruction, because the CPU thinks its reading signed numbers instead of unsigned. 

-I was unable to even get to attempt program 3, because I was so busy trying to get these other two programs to work first.

ROUNDING: I didn't really do any rounding, I just let the algorithm run until the bytes were filled.

Recording:
https://youtu.be/UJ194-dZpx4