module GPR(_input, output_);
	input [31:0] _input;		//Entrada
	output reg [31:0] output_; 	//Saida
	always @(*) begin			
			output_ = _input;	//Atribuição do valor de saida
	end
endmodule
