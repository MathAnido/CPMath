module displayReg(_input, output_, clk, displayWrite, reset);
	input [31:0] _input;				//
	output reg [31:0] output_;		//
	input displayWrite;				//
	input clk; 							//Clock
	input reset;
	always @(posedge clk) begin
		if(reset)
			output_ <= 31'd0;
		else if(displayWrite)
			output_ <= _input;				//Atribuição do valor de saida
	end
endmodule
