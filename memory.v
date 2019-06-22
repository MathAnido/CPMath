module memory(adress, data, memOut, memRead, memWrite, clk, reset, rclk);
	input [31:0] adress;				//Endereço de escrite e leitura
	input [31:0] data;					//Dado a ser escrito
	input memWrite;						//Bit de controle de escrita
	input memRead;						//Bit de controle de leitura
	input clk;
	input rclk;
	input reset;
	output reg [31:0] memOut;			//Saida do dado lido
	reg [31:0] ram[199:0];				//Memoria
	initial begin
		ram[32'd0] = {6'b111111, 26'd107}; //jump to main
		ram[32'd105] = 32'd5;//valores do programa
		ram[32'd106] = 32'd4;//valores do programa
		ram[32'd107] = {6'b001000, 5'b00000, 5'b00010, 16'd105}; //lw
		ram[32'd108] = {6'b001000, 5'b00000, 5'b00011, 16'd106}; //lw
		ram[32'd109] = {6'b000000, 5'b00010, 5'b00011, 5'b00100, 5'b00000, 6'b000000};	//add
		ram[32'd110] = {6'b101000, 5'b00100, 5'b00100, 16'd0};
		ram[32'd111] = {6'b111111, 26'd107};
	end
	always @(posedge clk) begin
		if(memWrite)
			ram[adress] <= data;			//Escrita na memoria		
	end
	always @(posedge rclk) begin
		if(memRead)
			memOut <= ram[adress];			//Leitura da memoria
	end
endmodule
