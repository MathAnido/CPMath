module GPR(_input, output_, reset);
	input [31:0] _input;		//Entrada
	input reset;
	output reg [31:0] output_; 	//Saida
	always @(*) begin			
			output_ <= _input;	//Atribuição do valor de saida
			if(reset) output_ <= 32'd0;
	end
endmodule
