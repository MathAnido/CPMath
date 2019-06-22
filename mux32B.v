module mux32B(_input0, _input1, _input2, _input3, sel, output_);
	input [31:0] _input0;				//Entrada 0 do Mux
	input [31:0] _input1;				//Entrada 1 do Mux
	input [31:0] _input2;				//Entrada 2 do Mux	
	input [31:0] _input3;				//Entrada 3 do Mux
	input [1:0] sel;					//2 bits de seleção
	output reg[31:0] output_;
	always @ (*) begin
		case(sel)						//Atribuição da saida correspondente
			2'b00: output_ <= _input0;
			2'b01: output_ <= _input1;
			2'b10: output_ <= _input2;
			2'b11: output_ <= _input3;
		endcase
	end
endmodule
