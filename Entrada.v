module entrada(_input, output_, switchRead, switchWrite, reset);
	input [15:0] _input;
	output reg [31:0] output_;
	input switchRead, switchWrite;
	input reset;
	reg[3:0] index;
	reg [31:0] ram[15:0];
	always @ (posedge switchRead or posedge switchWrite or posedge reset) begin  //Leitura da entrada
		if(switchRead) begin
			index = index + 4'd1;
			output_ = 32'd0;
			ram[index] = _input;
		end
		else if(switchWrite) begin
			output_ = ram[index];	
			index = index - 4'd1;
		end
		else if(reset)
			index = 4'b0000;
			output_ = 32'd0;
	end
endmodule
