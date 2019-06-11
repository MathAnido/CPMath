module controlUnit(opcode, clk, reset, pcCond, pcWrite, pcSrc, memSrc, memWrite, memRead,
 irWrite, regSrc, dataSrc, regWrite, aSrc, bSrc, ulaOp);
	input [5:0] opcode; //opcode
	input clk; //clock
	input reset; //reset button
	reg [3:0] estado; //estado atual
	output reg pcCond, pcWrite;
	output reg [1:0] pcSrc; //controle do PC
	output reg memSrc, memWrite, memRead; //controle memoria
	output reg irWrite; //controle IR
	output reg regSrc, regWrite; //controle banco registradores
	output reg dataSrc;
	output reg aSrc;
	output reg [1:0] bSrc, ulaOp; //controle ULA
	//definiçao dos estados
	parameter s0 = 4'd0, s1 = 4'd1, s2 = 4'd2, s3 = 4'd3, s4 = 4'd4, s5 = 4'd5, s6 = 4'd6,
	s7 = 4'd7, s8 = 4'd8, s9 = 4'd9, s10 = 4'd10, s11 = 4'd11;
	always @ (posedge clk) begin
		if(reset)
			estado <= s0;
		else
			case (estado)
				s0: estado <= s1;
				s1:
					case (opcode[5:3])
						 5'b000: estado <= s6; //Tipo R
             5'b100: estado <= s10;//Tipo I
             5'b010: estado <= s8; //Branch
						 5'b001: estado <= s2; //LW ou Sw
						 5'b111: estado <= s9; //Tipo J
					endcase
				s2:
					case (opcode[0])
						 1'b0: estado <= s3; //LW
						 1'b1: estado <= s5; //SW
					endcase
				s3: estado <= s4;
				s4: estado <= s0;
				s5: estado <= s0;
				s6: estado <= s7;
				s7: estado <= s0;
				s8: estado <= s0;
				s9: estado <= s0;
        s10: estado <= s11;
        s11: estado <= s0;
				default: estado <= s0;
			endcase
	end
	always @ (estado) begin
		case(estado)
			s0:
				begin
					memSrc = 1'b0;
					memRead = 1'b1;
					aSrc = 1'b0;
					bSrc = 2'b01;
					ulaOp = 2'b00;
					irWrite = 1'b1;
					pcSrc = 2'b00;
					pcWrite = 1'b1;
					pcCond = 1'b0;
					memWrite = 1'b0;
					regSrc = 1'b0;
					dataSrc = 1'b0;
					regWrite = 1'b0;
				end
			s1:
				begin
					aSrc = 1'b0;
					bSrc = 2'b11;
					ulaOp = 2'b00;

					memSrc = 1'b0;
					memRead = 1'b0;
					irWrite = 1'b0;
					pcSrc = 2'b00;
					pcWrite = 1'b0;
					pcCond = 1'b0;
					memWrite = 1'b0;
					regSrc = 1'b0;
					dataSrc = 1'b0;
					regWrite = 1'b0;
				end
			s2:
				begin
					aSrc = 1'b1;
					bSrc = 2'b10;
					ulaOp = 2'b00;

					memSrc = 1'b0;
					memRead = 1'b0;
					irWrite = 1'b0;
					pcSrc = 2'b00;
					pcWrite = 1'b0;
					pcCond = 1'b0;
					memWrite = 1'b0;
					regSrc = 1'b0;
					dataSrc = 1'b0;
					regWrite = 1'b0;
				end
			s3:
				begin
					memRead = 1'b1;
					memSrc = 1'b1;

					aSrc = 1'b0;
					bSrc = 2'b00;
					ulaOp = 2'b00;
					irWrite = 1'b0;
					pcSrc = 2'b00;
					pcWrite = 1'b0;
					pcCond = 1'b0;
					memWrite = 1'b0;
					regSrc = 1'b0;
					dataSrc = 1'b0;
					regWrite = 1'b0;
				end
			s4:
				begin
					regWrite = 1'b1;
					dataSrc = 1'b0;

					memSrc = 1'b0;
					memRead = 1'b0;
					aSrc = 1'b0;
					bSrc = 2'b00;
					ulaOp = 2'b00;
					irWrite = 1'b0;
					pcSrc = 2'b00;
					pcWrite = 1'b0;
					pcCond = 1'b0;
					memWrite = 1'b0;
					regSrc = 1'b0;
				end
			s5:
				begin
					memWrite = 1'b1;
					memSrc = 1'b1;

					memRead = 1'b0;
					aSrc = 1'b0;
					bSrc = 2'b00;
					ulaOp = 2'b00;
					irWrite = 1'b0;
					pcSrc = 2'b00;
					pcWrite = 1'b0;
					pcCond = 1'b0;
					regSrc = 1'b0;
					dataSrc = 1'b0;
					regWrite = 1'b0;
				end
			s6:
				begin
					aSrc = 1'b1;
					bSrc = 2'b00;
					ulaOp = 2'b10;

					memSrc = 1'b0;
					memRead = 1'b0;
					irWrite = 1'b0;
					pcSrc = 2'b00;
					pcWrite = 1'b0;
					pcCond = 1'b0;
					memWrite = 1'b0;
					regSrc = 1'b0;
					dataSrc = 1'b0;
					regWrite = 1'b0;
				end
			s7:
				begin
					regSrc = 1'b1;
					regWrite = 1'b1;
					dataSrc = 1'b1;

					memSrc = 1'b0;
					memRead = 1'b0;
					aSrc = 1'b0;
					bSrc = 2'b00;
					ulaOp = 2'b00;
					irWrite = 1'b0;
					pcSrc = 2'b00;
					pcWrite = 1'b0;
					pcCond = 1'b0;
					memWrite = 1'b0;
				end
			s8:
				begin
					aSrc = 1'b1;
					bSrc = 2'b00;
					ulaOp = 2'b01;
					pcCond = 1;
					pcSrc = 2'b01;

					memSrc = 1'b0;
					memRead = 1'b0;
					irWrite = 1'b0;
					pcWrite = 1'b0;
					memWrite = 1'b0;
					regSrc = 1'b0;
					dataSrc = 1'b0;
					regWrite = 1'b0;
				end
			s9:
				begin
					pcWrite = 1'b1;
					pcSrc = 2'b10;

					memSrc = 1'b0;
					memRead = 1'b0;
					aSrc = 1'b0;
					bSrc = 2'b00;
					ulaOp = 2'b00;
					irWrite = 1'b0;
					pcCond = 1'b0;
					memWrite = 1'b0;
					regSrc = 1'b0;
					dataSrc = 1'b0;
					regWrite = 1'b0;
				end
      s10:
				begin
					aSrc = 1'b1;
					bSrc = 2'b10;
					ulaOp = 2'b10;

					memSrc = 1'b0;
					memRead = 1'b0;
					irWrite = 1'b0;
					pcSrc = 2'b00;
					pcWrite = 1'b0;
					pcCond = 1'b0;
					memWrite = 1'b0;
					regSrc = 1'b0;
					dataSrc = 1'b0;
					regWrite = 1'b0;
				end
      s11:
        begin
          regSrc = 1'b0;
          regWrite = 1'b1;
          dataSrc = 1'b1;

          memSrc = 1'b0;
          memRead = 1'b0;
          aSrc = 1'b0;
          bSrc = 2'b00;
          ulaOp = 2'b00;
          irWrite = 1'b0;
          pcSrc = 2'b00;
          pcWrite = 1'b0;
          pcCond = 1'b0;
          memWrite = 1'b0;
        end
		endcase
	end
endmodule
