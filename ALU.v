module ALU (regA, regB, zero, result, aluOp);
	input [31:0] regA;									//Entrada 1
	input [31:0] regB;									//Entrada 2
	input [5:0] aluOp;									//Operação
	output reg [31:0] result;							//Resultado da operação
	output zero;
	always @ (*) begin
		case(aluOp[5:0])								
			6'b000000: result = regA + regB; 			//add
			6'b000001: result = regA && regB; 			//and
			6'b000010: result = regA / regB; 			//div
			6'b000011: result = regA % regB; 			//mod
			6'b000100: result = regA * regB; 			//mul
			6'b000101: result = !(regA && regB); 		//nand
			6'b000110: result = !(regA || regB); 		//nor
			6'b000111: result = !regA; 					//not
			6'b001000: result = regA || regB; 			//or
			6'b001001: result = regA > regB ? 1 : 0; 	//sgt
			6'b001010: result = regA >= regB ? 1 : 0; //sget
			6'b001011: result = regA << regB; 			//sll
			6'b001100: result = regA >> regB; 			//slr
			6'b001101: result = regA < regB ? 1 : 0;	//slt
			6'b001110: result = regA <= regB ? 1 : 0; //slteq
			6'b001111: result = regA - regB; 			//sub
			6'b010000: result = !(regA ^ regB); 		//xnor
			6'b010001: result = regA ^ regB;			//xor
			default: result = regA;						//Caso default
		endcase		
	end	
	assign zero = (result == 0);
endmodule
