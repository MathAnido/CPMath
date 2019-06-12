module memory(adress, data, memOut, memRead, memWrite, clk);
	input [31:0] adress;				//Endereço de escrite e leitura
	input [31:0] data;					//Dado a ser escrito
	input memWrite;						//Bit de controle de escrita
	input memRead;						//Bit de controle de leitura
	input clk;
	output reg [31:0] memOut;			//Saida do dado lido
	reg [31:0] ram[199:0];				//Memoria
	always @(posedge clk) begin
	if(memWrite)
		ram[adress] = data;			//Escrita na memoria
	if(memRead)
		memOut = ram[adress];			//Leitura da memoria
	end
endmodule
