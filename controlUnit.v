module controlUnit(opcode, clk, reset, pcCond, pcWrite, pcSrc, memSrc, memWrite, memRead,
 irWrite, regSrc, dataSrc, regWrite, aSrc, bSrc, ulaOp, displayWrite, estado, enter);
 
	//Inputs
	input enter;
	input [5:0] opcode; //opcode
	input clk; //clock
	input reset; //reset button
	
	//OUtputs
	output reg [4:0] estado; //estado atual
	output reg pcCond;
	output reg pcWrite;
	output reg memSrc;
	output reg memWrite;
	output reg memRead; //controle memoria
	output reg irWrite; //controle IR
	output reg regWrite; //controle banco registradores
	output reg aSrc;
	output reg [1:0] pcSrc; //controle do PC
	output reg [1:0] bSrc;
	output reg [1:0] ulaOp; //controle ULA 
	output reg [1:0] dataSrc;
	output reg [1:0] regSrc;	
	output reg displayWrite;
	
	//Registradores
	reg [4:0] proxEstado;
	
	//Definiçao dos estados
	parameter s0 = 5'd0, s1 = 5'd1, s2 = 5'd2, s3 = 5'd3, s4 = 5'd4, s5 = 5'd5, s6 = 5'd6,
	s7 = 5'd7, s8 = 5'd8, s9 = 5'd9, s10 = 5'd10, s11 = 5'd11, s12 = 5'd12, s13 = 5'd13, 
	s14 = 5'd14, s15 = 5'd15, s16 = 5'd16;
	always @ (posedge clk) begin
		if(reset)
			estado <= s0;
		else
			estado <= proxEstado;
	end
	 
	always@(estado or opcode or enter) begin
		case (estado)
				s0: proxEstado <= s1;
				s1:
					case (opcode[5:3])
						3'b000: proxEstado <= s6; //Tipo R
						3'b001: proxEstado <= s2; //LW ou Sw
						3'b010: proxEstado <= s8; //Branch
						3'b011: proxEstado <= (enter)? s0 : s1; //halt
						3'b100: proxEstado <= s10;//Tipo I
						3'b101: proxEstado <= s12;//output
						3'b110: proxEstado <= (enter)? s14 : s1;//Input
						3'b111: proxEstado <= s9; //Tipo J
					endcase
				s2: proxEstado <= (opcode[0])? s5: s3;
				s3: proxEstado <= s4;
				s4: proxEstado <= s0;
				s5: proxEstado <= s0;
				s6: proxEstado <= (opcode[0])? s15: s7;
				s7: proxEstado <= s0;
				s8: proxEstado <= s0;
				s9: proxEstado <= s0;
				s10:proxEstado <= (opcode[2:0] == 3'b111)? s13: s11; 
				s11:proxEstado <= s0;
				s12:proxEstado <= s0; 
				s13:proxEstado <= s16;
				s14:proxEstado <= s0;
				s15:proxEstado <= s0;
				s16:proxEstado <= s0;
				default: proxEstado <= s0;
			endcase
	end	
	
	always @ (estado or opcode) begin //estado
		case(estado)
			s0://busca da instrucao e atualização do pc
				begin
					irWrite <= 1'b1; 	//escreve IR
					memSrc <= 1'b0;
					memRead <= 1'b1; //leitura da memoria
					pcSrc <= 2'b00;
					pcWrite <= 1'b1;	//escreve PC
					aSrc <= 1'b0;
					bSrc <= 2'b01;
					ulaOp <= 2'b10;
					pcCond <= 1'b0;
					memWrite <= 1'b0;
					regSrc <= 2'b00;
					dataSrc <= 2'b00;
					regWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
			s1: //decodificacao e calculo do endereço de branch
				begin
					aSrc <= 1'b0;
					bSrc <= 2'b10;
					ulaOp <= 2'b10;
					irWrite <= 1'b0;
					memSrc <= 1'b0;
					memRead <= 1'b0;
					pcSrc <= 2'b00;
					pcWrite <= 1'b0;
					pcCond <= 1'b0;
					memWrite <= 1'b0;
					regSrc <= 2'b00;
					dataSrc <= 2'b00;
					regWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
			s2:
				begin
					aSrc <= 1'b1;
					bSrc <= 2'b10;
					ulaOp <= 2'b10;

					memSrc <= 1'b0;
					memRead <= 1'b0;
					irWrite <= 1'b0;
					pcSrc <= 2'b00;
					pcWrite <= 1'b0;
					pcCond <= 1'b0;
					memWrite <= 1'b0;
					regSrc <= 2'b00;
					dataSrc <= 2'b00;
					regWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
			s3:
				begin
					memRead <= 1'b1;
					memSrc <= 1'b1;

					aSrc <= 1'b1;
					bSrc <= 2'b10;
					ulaOp <= 2'b10;
					irWrite <= 1'b0;
					pcSrc <= 2'b00;
					pcWrite <= 1'b0;
					pcCond <= 1'b0;
					memWrite <= 1'b0;
					regSrc <= 2'b00;
					dataSrc <= 2'b00;
					regWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
			s4:
				begin
					regWrite <= 1'b1;
					regSrc <= 2'b00;
					dataSrc <= 2'b00;

					memSrc <= 1'b0;
					memRead <= 1'b0;
					aSrc <= 1'b0;
					bSrc <= 2'b00;
					ulaOp <= 2'b00;
					irWrite <= 1'b0;
					pcSrc <= 2'b00;
					pcWrite <= 1'b0;
					pcCond <= 1'b0;
					memWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
			s5:  //store word exec
				begin
					memWrite <= 1'b1;
					memSrc <= 1'b1;

					memRead <= 1'b0;
					aSrc <= 1'b0;
					bSrc <= 2'b00;
					ulaOp <= 2'b00;
					irWrite <= 1'b0;
					pcSrc <= 2'b00;
					pcWrite <= 1'b0;
					pcCond <= 1'b0;
					regSrc <= 2'b00;
					dataSrc <= 2'b00;
					regWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
			s6: //tipo R exec
				begin
					aSrc <= 1'b1;
					bSrc <= 2'b00;
					ulaOp <= 2'b00;

					memSrc <= 1'b0;
					memRead <= 1'b0;
					irWrite <= 1'b0;
					pcSrc <= 2'b00;
					pcWrite <= 1'b0;
					pcCond <= 1'b0;
					memWrite <= 1'b0;
					regSrc <= 2'b00;
					dataSrc <= 2'b00;
					regWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
			s7:
				begin
					regSrc <= 2'b01;
					regWrite <= 1'b1;
					dataSrc <= 2'b01;

					memSrc <= 1'b0;
					memRead <= 1'b0;
					aSrc <= 1'b1;
					bSrc <= 2'b00;
					ulaOp <= 2'b00;
					irWrite <= 1'b0;
					pcSrc <= 2'b00;
					pcWrite <= 1'b0;
					pcCond <= 1'b0;
					memWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
			s8:
				begin
					aSrc <= 1'b1;
					bSrc <= 2'b00;
					ulaOp <= 2'b11;
					pcCond <= 1'b1;
					pcSrc <= 2'b01;

					memSrc <= 1'b0;
					memRead <= 1'b0;
					irWrite <= 1'b0;
					pcWrite <= 1'b0;
					memWrite <= 1'b0;
					regSrc <= 2'b00;
					dataSrc <= 2'b00;
					regWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
			s9: // end jump
				begin
					pcSrc <= 2'b10;
					pcWrite <= 1'b1;
					regSrc <= 2'b10;
					memSrc <= 1'b0;
					dataSrc <= 2'b10;
					regWrite <= (opcode[0])? 1'b1: 1'b0;
					memRead <= 1'b0;
					aSrc <= 1'b0;
					bSrc <= 2'b00;
					ulaOp <= 2'b00;
					irWrite <= 1'b0;
					pcCond <= 1'b0;
					memWrite <= 1'b0;					
					displayWrite <= 1'b0;
				end
			s10:
				begin
					aSrc <= 1'b1;
					bSrc <= 2'b10;
					ulaOp <= 2'b11;

					memSrc <= 1'b0;
					memRead <= 1'b0;
					irWrite <= 1'b0;
					pcSrc <= 2'b00;
					pcWrite <= 1'b0;
					pcCond <= 1'b0;
					memWrite <= 1'b0;
					regSrc <= 2'b00;
					dataSrc <= 2'b00;
					regWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
			s11:
			  begin
				 regSrc <= 2'b00;
				 regWrite <= 1'b1;
				 dataSrc <= 2'b01;
	
				 memSrc <= 1'b0;
				 memRead <= 1'b0;
				 aSrc <= 1'b0;
				 bSrc <= 2'b00;
				 ulaOp <= 2'b00;
				 irWrite <= 1'b0;
				 pcSrc <= 2'b00;
				 pcWrite <= 1'b0;
				 pcCond <= 1'b0;
				 memWrite <= 1'b0;
				 displayWrite <= 1'b0;
			  end
		  s12:
			  begin
				 regSrc <= 2'b00;
				 regWrite <= 1'b0;
				 dataSrc <= 2'b00;
				 memSrc <= 1'b0;
				 memRead <= 1'b0;
				 aSrc <= 1'b1;
				 bSrc <= 2'b10;
				 ulaOp <= 2'b10;
				 irWrite <= 1'b0;
				 pcSrc <= 2'b00;
				 pcWrite <= 1'b0;
				 pcCond <= 1'b0;
				 memWrite <= 1'b0;
				 displayWrite <= 1'b1;
			  end
		  s13: //LI
			  begin
				 regSrc <= 2'b00;
				 regWrite <= 1'b0;
				 dataSrc <= 2'b00;
				 memSrc <= 1'b0;
				 memRead <= 1'b0;
				 aSrc <= 1'b0;
				 bSrc <= 2'b10;
				 ulaOp <= 2'b11;
				 irWrite <= 1'b0;
				 pcSrc <= 2'b00;
				 pcWrite <= 1'b0;
				 pcCond <= 1'b0;
				 memWrite <= 1'b0;
				 displayWrite <= 1'b0;
			 end
			s14:
				begin
					dataSrc <= 2'b11;
					regSrc <= 2'b00;
					regWrite <= 1'b1;
					
					memWrite <= 1'b0;
					memSrc <= 1'b0;
					memRead <= 1'b0;
					aSrc <= 1'b1;
					bSrc <= 2'b00;
					ulaOp <= 2'b00;
					irWrite <= 1'b0;
					pcSrc <= 2'b00;
					pcWrite <= 1'b0;
					pcCond <= 1'b0;
					displayWrite <= 1'b0;
				end
			s15:
				begin
					pcWrite <= 1'b1;
					pcSrc <= 2'b11;
					
					dataSrc <= 2'b00;
					regSrc <= 2'b00;
					regWrite <= 1'b0;
					memWrite <= 1'b0;
					memSrc <= 1'b0;
					memRead <= 1'b0;
					aSrc <= 1'b0;
					bSrc <= 2'b00;
					ulaOp <= 2'b00;
					irWrite <= 1'b0;
					pcCond <= 1'b0;
					displayWrite <= 1'b0;
				end
			 s16:
			  begin
				 regSrc <= 2'b00;
				 regWrite <= 1'b1;
				 dataSrc <= 2'b01;
				 memSrc <= 1'b0;
				 memRead <= 1'b0;
				 aSrc <= 1'b0;
				 bSrc <= 2'b10;
				 ulaOp <= 2'b11;
				 irWrite <= 1'b0;
				 pcSrc <= 2'b00;
				 pcWrite <= 1'b0;
				 pcCond <= 1'b0;
				 memWrite <= 1'b0;
				 displayWrite <= 1'b0;
			 end
			 default: 
				begin
					irWrite <= 1'b1; 	//escreve IR
					memSrc <= 1'b0;
					memRead <= 1'b1; //leitura da memoria
					pcSrc <= 2'b00;
					pcWrite <= 1'b1;	//escreve PC
					aSrc <= 1'b0;
					bSrc <= 2'b01;
					ulaOp <= 2'b10;
					pcCond <= 1'b0;
					memWrite <= 1'b0;
					regSrc <= 2'b00;
					dataSrc <= 2'b00;
					regWrite <= 1'b0;
					displayWrite <= 1'b0;
				end
		endcase
	end
endmodule
