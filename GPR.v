module GPR(_input, output_, clk, reset);
	input [31:0] _input;		//Entrada
	input clk;
	input reset;
	output reg [31:0] output_; 	//Saida
	always @(posedge clk) begin			
			output_ <= _input;	//Atribuição do valor de saida
			if(reset) output_ <= 32'd0;
	end
endmodule
