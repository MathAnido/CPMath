module PC(_input, output_, clk, pcWrite, reset);
	input [31:0] _input;				//Endereço da proxima instrução
	output reg [31:0] output_;		//Endereço da instrução atual
	input pcWrite;						//Sinal de controle para escrita do PC
	input clk; 							//Clock
	input reset;
	always @(negedge clk) begin
		if(reset == 1'b1)
			output_ <= 32'd0;
		else if(pcWrite == 1'b1)
			output_ <= _input;				//Atribuição do valor de saida
	end
endmodule
