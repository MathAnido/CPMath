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
		reg [31:0] PC, MDR, A, B, aluOut, IR, result, saidaMemoria;
		reg [5:0] aluOp;
		
		//Memorias
		reg [31:0] memoria[255:0]; //Memória principal
		reg [31:0] registradores[31:0];		//Banco de registradores
		
		//Unidade de Controle
		wire pcWrite; //Sinal de escrita do PC
		wire regWrite; //Sinal de escrita nos registradores
		wire memRead; //Sinal de leitura da memoria
		wire memWrite; //Sinal de escrita da memoria
		wire irWrite; //Sinal de escrita do IR
		wire aSrc; //Sinal de selecao da entrada A da ula
		wire pcCond; //Sinal de instrucao condicional
		wire displayWrite; //Sinal para escrita no display
		wire [1:0] pcSrc; //Sinal de selecao do novo PC
		wire memSrc;//Sinal de selecao do endereco de memoria
		wire regSrc; //sinal de selecao do registrador escrito
		wire [1:0] dataSrc; //Sinal de selecao do dado a ser escrito no registrador
		wire [1:0] bSrc; //Sinal de selecao da entrada B da ula
		
		//Wires
		wire display;
		wire centena;
		wire dezena;
		wire unidade;
		wire enter;
		wire zero;
		wire [31:0] Display;
		wire [1:0] ulaOp;
		wire switchRead, switchWrite;
		wire jump = (IR[26])? ~result[0]: result[0];
		//wire [31:0] saidaMemoria = (memRead)? memoria[adress]: 32'b0; //Leitura da memoria
		wire [31:0] adress = (memSrc)? aluOut : PC;
		wire [31:0] regA = (aSrc)? A : PC; //Entrada A
		wire [31:0] regB = functionB(bSrc); //Entrada B
		function [31:0] functionB(input [1:0] bSrc);
			case(bSrc)
					2'b00: functionB = B;								//Registrador B
					2'b01: functionB = 32'd1;							//valor 1
					2'b10: functionB = {{16{IR[15]}}, IR[15:0]};	//Extensao de sinal
					default: functionB = B;
			endcase
		endfunction
		
		//Bloco da execucao do PC
		always @(posedge clk) begin
			if(reset)
				PC <= 32'b0;
			else if(pcWrite || (pcCond && jump))					//Sinal de controle de escrita do PC
				case(pcSrc)													//Seleciona o novo PC
					2'b00: PC <= result;									//PC + 1
					2'b01: PC <= aluOut;									//Endereco B
					2'b10: PC <= {PC[31:26], IR[25:0]};				//Endereco J
					2'b11: PC <= A;										//Jr			
				endcase
		end
		
		//Bloco da execucao da memoria
		always @(posedge clk) begin
			if(reset) begin
				$readmemb("jr.mif", memoria);
			end
			if(memWrite)
				memoria[adress] <= B;										//Escrita da memoria
				
			if(memRead)
				saidaMemoria <= memoria[adress];
		end
		
		//Bloco da execucao do IR
		always @(posedge clk) begin
			if(irWrite) begin
				IR <= saidaMemoria;
			end
		end
		
		//Bloco do MDR
		always @(posedge clk) begin
			MDR <= saidaMemoria;
			aluOut <= result;
		end
		
		//Bloco dos registradores
		always @(posedge clk) begin
			if(regWrite)
				case({regSrc, dataSrc})
					3'b000: registradores[IR[20:16]] <= MDR;
					3'b001: registradores[IR[20:16]] <= aluOut;
					3'b010, 3'b011: registradores[IR[20:16]] <= switch; //Entrada de dados
					3'b100: registradores[IR[15:11]] <= MDR;
					3'b101: registradores[IR[15:11]] <= aluOut;
					3'b110, 3'b111: registradores[31] <= PC; //Jump and link
				endcase
		end
		
		//A e B
		always @(IR) begin
			A <= (IR[25:21]!= 0)? registradores[IR[25:21]]: 0; //Verificar se eh o registrador 0
			B <= (IR[20:16]!= 0)? registradores[IR[20:16]]: 0;
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
						6'b010000: aluOp = 6'b010010;//branch equal
						6'b010001: aluOp = 6'b010010;//branch not equal
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
				6'b010001: result = regA ^ regB;				//xor
				6'b010010: result = (regA == regB)? 1 : 0;//beq
				default: result = regA;						//Caso default
			endcase
		end 		
		
		//Unidade de controle
		controlUnit control(.opcode(IR[31:26]), .clk(clk), .reset(reset), .pcCond(pcCond), .pcWrite(pcWrite), .pcSrc(pcSrc),
.memSrc(memSrc), .memWrite(memWrite), .memRead(memRead), .irWrite(irWrite), .regSrc(regSrc), .dataSrc(dataSrc),
.regWrite(regWrite), .aSrc(aSrc), .bSrc(bSrc), .ulaOp(ulaOp), .displayWrite(displayWrite), .estadoCU(estadoCU), .enter(btn_enter));
		
		//Saida de dados
		displayReg saida(._input(aluOut), .output_(display), .clk(clk), .displayWrite(displayWrite), .reset(reset));
		
		//Encontrar digitos
		binToBCD toBCD(._input(display), .digito2(centena), .digito1(dezena), .digito0(unidade));

		//Display
		seteSegmentos digito2(._input(centena), .output_(display2), .displayWrite(displayWrite), .clk(clk), .reset(reset)); //Centena
		seteSegmentos digito1(._input(dezena), .output_(display1), .displayWrite(displayWrite), .clk(clk), .reset(reset));  //Dezena
		seteSegmentos digito0(._input(unidade), .output_(display0), .displayWrite(displayWrite), .clk(clk), .reset(reset));
		
		DeBounce btnEnter(.clk(clk), .n_reset(1), .button_in(btn_enter), .DB_out(enter));
		
		//Testes
		assign pcAtual = PC;
		assign resultado = result;
		assign estado = estadoCU;
		assign opcode = IR[31:26];
		assign instru = saidaMemoria;
endmodule 