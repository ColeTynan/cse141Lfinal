//Assembler for CIBBA in C 
//Cole Tynan-Wood
//to compile: gcc cibasm.cpp -o cb
//to use: ./cb.exe input.txt

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>


// print machine code in binary to console ( debug)
void printBits(int lineNum, void const * const ptr)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, j;
    printf("%d: ", lineNum);
    for (i = 1; i >= 0; i--) {
        for (j = 7; j >= 0; j--) {
			if(i == 1 && j > 0)
				continue;
            byte = (b[i] >> j) & 1;
            printf("%u", byte);
        }
    }
    puts("");
}

//print to file
void fPrintBits(FILE* outFile, void const * const ptr)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, j;
    for (i = 1; i >= 0; i--) {
        for (j = 7; j >= 0; j--) {
			if(i == 1 && j > 0)
				continue;
            byte = (b[i] >> j) & 1;
            fprintf(outFile, "%u", byte);
        }
    }
}
  
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

int machProgram[1000];		//program in machine code
int progCtr = 0;
int lineCtr =0;

int decodeReg(char *reg) {
	if(strcmp(reg, "$0")== 0)
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
	else {
		printf("ERROR: unrecognized register %c at line %d", reg[1], lineCtr);
		exit(-1); //error
	}
}

	
int main(int argc, char* argv[]) {
	bool DEBUG = 1;
	//char* fileName = "test.txt";		//TODO: replace with user entered filename

	struct label labelTable[20];	//max branches = 20
	int numLabels = 0;		//number of labels
	
	struct branch branchTable[20];
	int numBranches = 0;
	
	char *inFileName = "test.txt";
	if (argc > 1) {
		inFileName	=(char*)malloc(sizeof(argv[1]));
		strcpy(inFileName, argv[1]);
	} else {
		printf("No input file entered, using test.txt\n");
		//inFileName = "test.txt";
		//strcpy(inFileName, "test.txt");
	}
	
	FILE *inFile;
	inFile = fopen(inFileName, "r");
	char line[100];

	char *cop1, *cop2, *label;
	int ops;
	int op1, op2;
	
	
	if (inFile == NULL) {
		printf( "input file failed to load\n");
		return -1;
	}
	
	//store contents of file, store all branch labels
	while( fgets(line, sizeof line, inFile) != NULL) {
		//parse individual line
		//printf("%s\n", line);
		lineCtr++;
		char* t = strtok(line, ":\t\n\r, ");

		while(t) {
			
			const char *cmt = "#";
			if  (strstr(t, cmt) != NULL) {
				break;
			}
			
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
				if (op2 < -4 || op2 > 3) {
					printf("ERROR: addi immediate value out of range (line = %d)", lineCtr);
					return -1;
				}
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
				const char *desig = "L";
				if  (strstr(label, desig) == NULL){
					printf("Label not detected, syntax error around line %d\n", lineCtr);
					printf("%d: %s\n", lineCtr, line);
					return -1;
				}
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
				//int branchConst = labelTable[j].location - branchTable[i].location;
				
				/*if (branchConst > 31) {	//TODO: change how branching works if this is too limiting
					printf("ERROR: Branch at location %d is too far from Label %c at location %d", branchTable[i].location,labelTable[i].name, labelTable[i].location);
					return -1;
				}*/
				//TODO: add checking to make sure that the branch and the label are within the same 64 instruction block
				
				if (DEBUG) 
					printf("Label %s at pgmctr %d, branch at location %d\n", labelTable[j].name, labelTable[j].location, branchTable[i].location);
				if (branchTable[i].location / 63 != labelTable[j].location / 63){
					printf("ERROR: branch at location %d not within same 64 bit block as label %s\n",branchTable[i].location, labelTable[j].name);
					exit(-1);
				}
				machProgram[branchTable[i].location] += ((labelTable[j].location)&0x03F);
			}
		}
	}
	
	fclose(inFile);
	
	//output to binary file
	FILE *outFile;
	outFile = fopen("simulation/modelsim/machine_code.txt", "w");
	
	for (int i = 0; i < progCtr; i++) {
		//fprintf(outFile, "%03x\n", machProgram[i]);
		fPrintBits(outFile, &machProgram[i]);
		fprintf(outFile, "\n");
	}
	
	if (DEBUG) {
		for (int i = 0; i < progCtr; i++) {
			//fprintf(outFile, "%03x\n", machProgram[i]);
			printBits(i, &machProgram[i]);
			
		}
	}
	return 0;
}
