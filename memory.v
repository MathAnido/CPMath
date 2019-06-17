module memory(adress, data, memOut, memRead, memWrite, clk, reset);
	input [31:0] adress;				//Endereço de escrite e leitura
	input [31:0] data;					//Dado a ser escrito
	input memWrite;						//Bit de controle de escrita
	input memRead;						//Bit de controle de leitura
	input clk;
	input reset;
	output reg [31:0] memOut;			//Saida do dado lido
	reg [31:0] ram[199:0];				//Memoria
	always @(posedge clk) begin
		if(memWrite)
			ram[adress] = data;			//Escrita na memoria
		if(memRead)
			memOut = ram[adress];			//Leitura da memoria
		if (reset) begin  //programa inicial
			ram[105] = 32'd5;//valores do programa
			ram[106] = 31'd4;//valores do programa
			ram[107] = 00100_00000_00010_0000000001101001; 		//lw
			ram[106] = 00100_00000_00011_0000000001101010; 		//lw
			ram[108] = 00000_00010_00011_00100_00000_000000;	//add
		end
	end
endmodule
