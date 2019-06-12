module PC(_input, output_, pcWrite);
	input [31:0] _input;				//Endereço da proxima instrução
	output reg [31:0] output_;			//Endereço da instrução atual
	input pcWrite;						//Sinal de controle para escrita do PC
	always @(posedge pcWrite) begin
		output_ =  _input;				//Atribuição do valor de saida
	end
endmodule
