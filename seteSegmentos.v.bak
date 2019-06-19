module seteSegmentos (_input, output_, displayWrite) ;
	input [3:0] _input;
	output reg [6:0] output_;
	input displayWrite;
	
	always@( * )begin
			if(displayWrite)
				case (_input)
					4'b0000 : output_ = 7'b0000001 ;
					4'b0001 : output_ = 7'b1001111 ;
					4'b0010 : output_ = 7'b0010010 ;
					4'b0011 : output_ = 7'b0000110 ;
					4'b0100 : output_ = 7'b1001100 ;
					4'b0101 : output_ = 7'b0100100 ;
					4'b0110 : output_ = 7'b0100000 ;
					4'b0111 : output_ = 7'b0001111 ;
					4'b1000 : output_ = 7'b0000000 ;
					4'b1001 : output_ = 7'b0001100 ;
					default : output_ = 7'b1111111 ;
				endcase
			else
				output_ = 7'b1111111 ;
		end
endmodule