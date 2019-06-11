module signExtend(_input, output_);
	input [15:0] _input;						//Entrada
	output reg [31:0] output_;					//Saida
	always @ (_input) begin	
		if(_input[15])							//Verificar o primeiro bit
			output_ = {{16{1'b1}}, _input};		//Caso o primeiro bit seja 1
		else
			output_ = {{16{1'b0}}, _input};		//Caso o primeiro bit seja 0
	end
endmodule
