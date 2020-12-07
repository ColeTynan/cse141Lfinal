//Assembler for CIBBA in C/C++ (NOTE: may run natively in C alone) (CSE 141L Lab3)
//Cole Tynan-Wood
//TODO:
//		- Add support for taking filenames from cmd line
//		- Error checking and detailed bug reports
//		- stricter syntax checking (namely for branch labels)
//		- output file format may need to be binary (rather than text with hex representation of machine code)

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

struct label
{
	int location;
	char* name;
};

struct branch
{
	int location;
	char* label;
};

//key is label, int value is location

//const unordered_map< const char*, int> regTable ( {{"$zero", 0}, {"$s1",1}, {"$s2", 2}, {"$t1", 3}, {"$t2", 4}, {"$t3", 5}, {"$t4", 6}, {"$c", 7}});

int decodeReg(char *reg) {
	if(strcmp(reg, "$zero") == 0)
		return 0;
	else if(strcmp(reg, "$s1") == 0)
		return 1;
	else if(strcmp(reg, "$s2") == 0)
		return 2;
	else if(strcmp(reg, "$t1") == 0)
		return 3;
	else if(strcmp(reg, "$t2") == 0)
		return 4;
	else if(strcmp(reg, "$t3") == 0)
		return 5;
	else if(strcmp(reg, "$t4") == 0)
		return 6;
	else if(strcmp(reg, "$c") == 0)
		return 7;
	else 
		return -1; //error
}

int main(int argc, char* argv[]) {
	
	//char* fileName = "test.txt";		//TODO: replace with user entered filename
	int machProgram[1000];		//program in machine code
	int progCtr = 0;
	
	struct label labelTable[20];	//max branches = 20
	int numLabels = 0;		//number of labels
	
	struct branch branchTable[20];
	int numBranches = 0;
	
	char *inFileName
	if (argc > 0) {
		inFileName	=(char*)malloc(sizeof(argv))
		strcpy(inFileName, argv);
	} else {
		inFileName = "test.txt";
	}
	
	FILE *inFile;
	inFile = fopen(inFileName, "r");
	char line[50];

	char *cop1, *cop2, *label;
	int ops;
	int op1, op2;
	
	if (inFile == NULL) {
		cout << "input file failed to load\n";
		return -1;
	}
	
	//store contents of file, store all branch labels
	while( fgets(line, sizeof line, inFile) != NULL) {
		//parse individual line
		char* t = strtok(line, ":\t\n\r, ");
		while(t) {
			if (strcmp(t, "add") == 0) {
				cop1 = strtok(NULL, "\t\n\r, ");
				op1 = decodeReg(cop1);
				cop2 = strtok(NULL, "\t\n\r, ");
				op2 = decodeReg(cop2);
				ops = (op1 << 3) | op2&0x7;
				machProgram[progCtr] = 0x100 + ((ops)&0x03F);
				progCtr++;
			}
			else if (strcmp(t, "st") == 0) {
				cop1 = strtok(NULL, "\t\n\r, ");
				op1 = decodeReg(cop1);
				cop2 = strtok(NULL, "\t\n\r, ");
				op2 = decodeReg(cop2);
				ops = (op1 << 3) | op2&0x7;
				machProgram[progCtr] = 0x180 + ((ops)&0x03F);
				progCtr++;
			}
			else if (strcmp(t, "ld") == 0) {
				cop1 = strtok(NULL, "\t\n\r, ");
				op1 = decodeReg(cop1);
				cop2 = strtok(NULL, "\t\n\r, ");
				op2 = decodeReg(cop2);
				ops = (op1 << 3) | op2&0x7;
				machProgram[progCtr] = 0x1C0 + ((ops)&0x03F);
				progCtr++;
			}
			else if (strcmp(t, "nor") == 0) {
				cop1 = strtok(NULL, "\t\n\r, ");
				op1 = decodeReg(cop1);
				cop2 = strtok(NULL, "\t\n\r, ");
				op2 = decodeReg(cop2);
				ops = (op1 << 3) | op2&0x7;
				machProgram[progCtr] = 0x0C0 + ((ops)&0x03F);
				progCtr++;
			}
			else if (strcmp(t, "shf") == 0) {
				cop1 = strtok(NULL, "\t\n\r, ");
				op1 = decodeReg(cop1);
				cop2 = strtok(NULL, "\t\n\r, ");
				op2 = decodeReg(cop2);
				ops = (op1 << 3) | op2&0x7;
				machProgram[progCtr] = 0x040 + ((ops)&0x03F);
				progCtr++;
			}
			else if (strcmp(t, "addi") == 0) {
				cop1 = strtok(NULL, "\t\n\r, ");
				op1 = decodeReg(cop1);
				cop2 = strtok(NULL, "\t\n\r, ");
				op2 = atoi(cop2);
				ops = (op1 << 3) | op2&0x7;
				machProgram[progCtr] = 0x140 + ((ops)&0x03F);
				progCtr++;
			}
			else if (strcmp(t, "bneg") == 0) {
				cop1 = strtok(NULL, "\t\n\r, ");
				cop2=(char*)malloc(sizeof(cop1));         //allocate space for the label                  
                strcpy(cop2,cop1);
				branchTable[numBranches].label = cop2;
				branchTable[numBranches].location = progCtr;
				machProgram[progCtr] = 0x080;		//just enter opcode, will fill in relative address later
				numBranches++;
				progCtr++;
			}
			else if (strcmp(t, "stp") == 0) {
				machProgram[progCtr] = 0;
				progCtr++;
			}
			else { //must be a LABEL (assuming no errors, TODO refine definition of label as strictly "{LABEL}:")
				label=(char*)malloc(sizeof(t));
                strcpy(label,t);
				labelTable[numLabels].name = label;
				labelTable[numLabels].location = progCtr;
				numLabels++;
			}	
			t = strtok(NULL, "\t\n\r, ");
		}
	}

	//Go through and fill out labels
	for (int i = 0; i < numBranches; i++) {
		for (int j = 0; j < numLabels; j++) {
			if (strcmp(branchTable[i].label, labelTable[j].name) == 0) {
				int branchConst = labelTable[j].location - branchTable[i].location;				
				machProgram[branchTable[i].location] += ((branchConst)&0x03F);
			}
		}
	}
	
	fclose(inFile);
	
	//output to binary file
	FILE *outFile;
	outFile = fopen("out.txt", "w");
	
	for (int i = 0; i < progCtr; i++) {
		fprintf(outFile, "%03x\n", machProgram[i]);
	}
	return 0;
}
