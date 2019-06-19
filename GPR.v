module GPR(_input, output_, clk);
	input [31:0] _input;		//Entrada
	input clk;
	output reg [31:0] output_; 	//Saida
	always @(posedge clk) begin			
			output_ <= _input;	//Atribuição do valor de saida
	end
endmodule
