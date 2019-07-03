module seteSegmentos (_input, output_) ;
	input [3:0] _input;
	output reg [6:0] output_;
	always@(*)begin
		case (_input)
			4'b0000 : output_ <= 7'b1000000;
			4'b0001 : output_ <= 7'b1111001;
			4'b0010 : output_ <= 7'b0100100;
			4'b0011 : output_ <= 7'b0110000;
			4'b0100 : output_ <= 7'b0011001;
			4'b0101 : output_ <= 7'b0010010;
			4'b0110 : output_ <= 7'b0000010;
			4'b0111 : output_ <= 7'b1111000;
			4'b1000 : output_ <= 7'b0000000;
			4'b1001 : output_ <= 7'b0011000;
			default: output_ <= 7'b1000000;
		endcase
	end
endmodule 