module mux32(_input0, _input1, sel, output_, clk);
	input [31:0] _input0;		//Entrada 0 do Mux
	input [31:0] _input1;		//Entrada 1 do Mux
	input sel;					//Bit de seleção
	input clk;
	output reg[31:0] output_;
	always @ (posedge clk) begin
		if(sel)					//Atribuição da saida correspondente
			output_ = _input1;
		else output_ = _input0;
	end
endmodule
