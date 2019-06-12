module registers(readReg1, readReg2, writeReg, writeData, regA, regB, regWrite);
	input [4:0] readReg1;					//Numero do registrador a ser lido
	input [4:0] readReg2;					//Numero do registrador a ser lido
	input [4:0] writeReg;					//Numero do registrador a ser escrito
	input [31:0] writeData;					//Dado a ser escrito
	output [31:0] regA;						//Saida para o registrador A
	output [31:0] regB;						//Saida para o Registrador A
	input regWrite;							//Sinal de controle para escrita
	reg [31:0] register [31:0];				//Registradores
	always @ (posedge regWrite) begin
		register[writeReg] = writeData;		//Escrita dos dados no registrador
	end
	assign regA = register[readReg1];		//Leitura do primeiro registrador
	assign regB = register[readReg2];		//Leitura do segundo registrador
endmodule
