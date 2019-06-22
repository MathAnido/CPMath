module mux5(_input0, _input1, sel, output_);
	input [4:0] _input0;			//Entrada 0 do Mux
	input [4:0] _input1;			//Entrada 1 do Mux
	input sel;						//bit de seleção
	output reg [31:0] output_;
	always @ (*) begin				
		if(sel)						//Atribuição da saida correspondente
			output_ <= _input1;
		else output_ <= _input0;
	end
endmodule
