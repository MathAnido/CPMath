module SL2(_input, output_, clk);
	input [31:0] _input;		//Entrada do dado
	output reg [31:0] output_;	//Saida do dado
	input clk;
	always @ (posedge clk) begin
		output_ = _input << 2;	//Atribuindo entrada deslocada em 2 bits na saida
	end	
endmodule
