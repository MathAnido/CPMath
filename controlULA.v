module controlULA(_input, output_, ulaOp, opcode);
	input [5:0] _input;
	output reg[5:0] output_;
	input [1:0] ulaOp;
	input [5:0] opcode;
	always @ (*) begin
		case(ulaOp)
			2'b00: output_ = _input; // Tipo R
			2'b10: output_ = 6'b000000; //soma
			2'b01: output_ = 6'b001111; //subtrai
			2'b11: 
					case (opcode[5:0])
						6'b100000: output_ = 6'b000000;//soma imediato
						6'b100001: output_ = 6'b000001;//and imediato
						6'b100010: output_ = 6'b001000;//or imediato
						6'b100011: output_ = 6'b001111;//sub imediato
						6'b100100: output_ = 6'b001101;//set less than imediato
						6'b100101: output_ = 6'b001001;//set greater than imediato
						default: output_ = 6'b000000;//soma imediato
					endcase
		endcase
	end
endmodule 