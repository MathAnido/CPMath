module CPMath(clk, reset, switch, btn_enter, display2, display1, display0, pcAtual, resultado, estado, opcode, instru);
		input clk;
		input reset;
		input [15:0] switch;
		input btn_enter;
		output [31:0] pcAtual, resultado;
		output [3:0] estado;
		wire [3:0] estadoCU;
		output [5:0] opcode;
		output [31:0] instru;
		output [6:0] display2, display1, display0;
		//Registradores
		reg [31:0] PC, MDR, A, B, aluOut, IR, result;
		reg [5:0] aluOp;
		//Memorias
		reg [31:0] memoria[255:0];
		reg [31:0] registradores[31:0];		
		//Ula
		wire [31:0] regA;
		reg [31:0] regB;
		//Unidade de Controle
		wire pcWrite; //Sinal de escrita do PC
		wire regWrite; //Sinal de escrita nos registradores
		wire memRead; //Sinal de leitura da memoria
		wire memWrite; //Sinal de escrita da memoria
		wire irWrite; //Sinal de escrita do IR
		wire aSrc; //Sinal de selecao da entrada A da ula
		wire pcCond; //Sinal de instrucao condicional
		wire displayWrite; //Sinal para escrita no display
		wire haveData; 
		wire [1:0] pcSrc; //Sinal de selecao do novo PC
		wire memSrc;//Sinal de selecao do endereco de memoria
		wire regSrc; //sinal de selecao do registrador escrito
		wire [1:0] dataSrc; //Sinal de selecao do dado a ser escrito no registrador
		wire [1:0]bSrc; //Sinal de selecao da entrada B da ula
		//Wires
		reg [31:0] saidaMemoria;
		wire [31:0] adress;
		
		wire [1:0] ulaOp;
		wire switchRead, switchWrite;
		//Bloco da execucao do PC
		always @(posedge clk) begin
			if(reset)
				PC <= 32'b0;
			else if(pcWrite)												//Sinal de controle de escrita do PC
				case(pcSrc)													//Seleciona o novo PC
					2'b00: PC <= result;									//PC + 1
					2'b01: PC <= aluOut;									//Endereco B
					2'b10: PC <= {PC[31:26], IR[25:0]};	//Endereco J
					default: PC <= result; 								
				endcase
		end
		
		//Bloco da execucao da memoria
		assign adress = (memSrc)? PC : aluOut;
		always @(posedge clk) begin
			if(reset) begin
				memoria[0] <= {6'b111111, 26'd107}; //jump to main
				memoria[105] <= 32'd5;//valores do programa
				memoria[106] <= 32'd4;//valores do programa
				memoria[107] <= {6'b001000, 5'b00000, 5'b00010, 16'd105}; //lw
				memoria[108] <= {6'b001000, 5'b00000, 5'b00011, 16'd106}; //lw
				memoria[109] <= {6'b000000, 5'b00010, 5'b00011, 5'b00100, 5'b00000, 6'b000000};	//add
				memoria[110] <= {6'b101000, 5'b00100, 5'b00100, 16'd0};
				memoria[111] <= {6'b111111, 26'd107};
			end
			else if(memWrite)
				memoria[adress] <= B;										//Escrita da memoria
		end
		always @(posedge clk) begin
			saidaMemoria <= (memRead)? memoria[adress]: 32'bx; //Leitura da memoria
		end
		
		//Bloco da execucao do IR
		always @(posedge clk) begin
			if(irWrite) begin
				IR <= saidaMemoria;
			end
		end
		
		//Bloco do MDR
		always @(posedge clk) begin
			MDR <= saidaMemoria;												//Escrita do MDR
		end
		
		//Bloco dos registradores
		always @(posedge clk) begin
			if(regWrite)
				case({regSrc, dataSrc})
					3'b000: registradores[IR[20:16]] <= MDR;
					3'b001: registradores[IR[20:16]] <= aluOut;
					3'b010, 3'b011: registradores[IR[20:16]] <= switch; 
					3'b100: registradores[IR[15:11]] <= MDR;
					3'b101: registradores[IR[15:11]] <= aluOut;
					3'b110, 3'b111: registradores[IR[15:11]] <= switch;
				endcase
		end
		
		//A e B
		always @(posedge clk) begin
			A <= (IR[25:21]!= 0)? registradores[IR[25:21]]: 0; //Verificar se eh o registrador 0
			B <= (IR[20:16]!= 0)? registradores[IR[20:16]]: 0;
		end
		
		//
		assign regA = (aSrc)? PC : A;
		always @(B or IR) begin
			case(bSrc)
					2'b00: regB = B;							//Registrador B
					2'b01: regB = 32'd1;						//valor 1
					2'b10: regB = {{16{IR[15]}}, IR[15:0]}; //Extensao de sinal
					default: regB = B;
			endcase
		end
		
		always @(IR or ulaOp) begin
			case(ulaOp)
				2'b00: aluOp = IR[5:0]; // Tipo R
				2'b10: aluOp = 6'b000000; //soma
				2'b01: aluOp = 6'b001111; //subtrai
				2'b11: 
					case (IR[31:26])
						6'b100000: aluOp = 6'b000000;//soma imediato
						6'b100001: aluOp = 6'b000001;//and imediato
						6'b100010: aluOp = 6'b001000;//or imediato
						6'b100011: aluOp = 6'b001111;//sub imediato
						6'b100100: aluOp = 6'b001101;//set less than imediato
						6'b100101: aluOp = 6'b001001;//set greater than imediato
						default: aluOp = 6'b000000;//soma imediato
					endcase
			endcase
		end
		
		//Bloco da ULA
		always @(regA or regB or aluOp) begin
			case(aluOp[5:0])								
				6'b000000: result = regA + regB; 			//add
				6'b000001: result = regA && regB; 			//and
				6'b000010: result = regA / regB; 			//div
				6'b000011: result = regA % regB; 			//mod
				6'b000100: result = regA * regB; 			//mul
				6'b000101: result = !(regA && regB); 		//nand
				6'b000110: result = !(regA || regB); 		//nor
				6'b000111: result = !regA; 					//not
				6'b001000: result = regA || regB; 			//or
				6'b001001: result = regA > regB ? 1 : 0; 	//sgt
				6'b001010: result = regA >= regB ? 1 : 0; //sget
				6'b001011: result = regA << regB; 			//sll
				6'b001100: result = regA >> regB; 			//slr
				6'b001101: result = regA < regB ? 1 : 0;	//slt
				6'b001110: result = regA <= regB ? 1 : 0; //slteq
				6'b001111: result = regA - regB; 			//sub
				6'b010000: result = !(regA ^ regB); 		//xnor
				6'b010001: result = regA ^ regB;			//xor
				default: result = regA;						//Caso default
			endcase
		end
		
		always @(posedge clk) begin
			aluOut <= result;
		end
		
		//Unidade de controle
		controlUnit control(.opcode(IR[31:26]), .clk(clk), .reset(reset), .pcCond(pcCond), .pcWrite(pcWrite), .pcSrc(pcSrc),
.memSrc(memSrc), .memWrite(memWrite), .memRead(memRead), .irWrite(irWrite), .regSrc(regSrc), .dataSrc(dataSrc),
.regWrite(regWrite), .aSrc(aSrc), .bSrc(bSrc), .ulaOp(ulaOp), .displayWrite(displayWrite), .estadoCU(estadoCU));
		
		//Testes
		assign pcAtual = PC;
		assign resultado = result;
		assign estado = estadoCU;
		assign opcode = IR[31:26];
		assign instru = saidaMemoria;
		
endmodule 