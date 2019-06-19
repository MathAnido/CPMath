module memory(adress, data, memOut, memRead, memWrite, clk, reset, clk_50mhz);
	input [31:0] adress;				//Endereço de escrite e leitura
	input [31:0] data;					//Dado a ser escrito
	input memWrite;						//Bit de controle de escrita
	input memRead;						//Bit de controle de leitura
	input clk;
	input reset;
	input clk_50mhz;
	output reg [31:0] memOut;			//Saida do dado lido
	reg [31:0] ram[199:0];				//Memoria
	always @(posedge clk) begin
		if(memWrite)
			ram[adress] = data;			//Escrita na memoria
		if (reset) begin  //programa inicial
			ram[105] = 32'd5;//valores do programa
			ram[106] = 32'd4;//valores do programa
			ram[107] = {6'b001000, 5'b00000, 5'b00010, 16'b0000000001101001}; //lw
			ram[108] = {6'b001000, 5'b00000, 5'b00011, 16'b0000000001101010}; //lw
			ram[109] = {6'b000000, 5'b00010, 5'b00011, 5'b00100, 5'b00000, 6'b000000};	//add
		end
	end
	always @(posedge clk_50mhz) begin
			memOut = ram[adress];			//Leitura da memoria
	end
endmodule
