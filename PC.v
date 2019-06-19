module PC(_input, output_, clk, pcWrite, reset);
	input [31:0] _input;				//Endereço da proxima instrução
	output reg [31:0] output_;		//Endereço da instrução atual
	input pcWrite;						//Sinal de controle para escrita do PC
	input clk; 							//Clock
	input reset;
	always @(posedge clk) begin
		if(pcWrite)
			output_ = _input;				//Atribuição do valor de saida
		if(reset)
			output_ = 32'd107;
	end
endmodule
