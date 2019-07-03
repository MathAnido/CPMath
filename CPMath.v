module CPMath(clk_50Mhz, reset, switch, btn_enter, signal, display7, display6, display5, display2, display1, display0, estado);//, pc, ula, inputA, inputB, instrucao, regIN);
//		output [31:0] ula = aluOut;
//		output [31:0] pc = PC;
//		output [31:0] inputA = A;
//		output [31:0] inputB = B;
//		output [31:0] instrucao = IR;
//		output [31:0] regIN = regData;
//		
		//Inputs
		input clk_50Mhz; 		//Clock da fpga
		input reset;     		//Botao reset
		input btn_enter;		//Botao enter
		input [15:0] switch; //Teclado
		//Outputs
		output wire [4:0] estado; //Estado atual da Unidade de controle
		output wire [6:0] display2, display1, display0; //Display output
		output wire [6:0] display7, display6, display5; //Display PC
		output wire signal;										//Sinal
		//Registradores
		reg [31:0] PC, A, B, aluOut, IR, Display;
		reg [31:0] result;
		reg [31:0] MDR;
		reg [31:0] memOutput;
		reg [31:0] dispPC;
		
		//Memorias
		reg [31:0] memoria[255:0]; //Memória principal
		reg [31:0] registradores[31:0];		//Banco de registradores
		
		//Sinais de Controle
		wire pcWrite; //Sinal de escrita do PC
		wire regWrite; //Sinal de escrita nos registradores
		wire memRead; //Sinal de leitura da memoria
		wire memWrite; //Sinal de escrita da memoria
		wire irWrite; //Sinal de escrita do IR
		wire aSrc; //Sinal de selecao da entrada A da ula
		wire pcCond; //Sinal de instrucao condicional
		wire displayWrite; //Sinal para escrita no display
		wire memSrc;//Sinal de selecao do endereco de memoria
		wire [1:0] pcSrc; //Sinal de selecao do novo PC
		wire [1:0] regSrc; //sinal de selecao do registrador escrito
		wire [1:0] dataSrc; //Sinal de selecao do dado a ser escrito no registrador
		wire [1:0] bSrc; //Sinal de selecao da entrada B da ula
		wire [1:0] ulaOp;//Sinal de controle da ula
		
		//Wires
		wire clk; //Clock da fpga dividido
		wire [31:0] centena;
		wire [31:0] dezena;
		wire [31:0] unidade;
		wire [31:0] d2PC;
		wire [31:0] d1PC;
		wire [31:0] d0PC;
		wire signal1;
		wire jump = (IR[26])? ~result[0]: result[0];
		wire [31:0] adress = (memSrc)? aluOut : PC;
		wire [31:0] regA = (aSrc)? A : PC;  //Entrada A
		wire [31:0] regB = functionB(bSrc); //Entrada B
		wire [4:0]  regAddress = functionReg(regSrc);
		wire [31:0] regData = (dataSrc == 2'b00 ) ? MDR : (dataSrc == 2'b01)? aluOut: (dataSrc == 2'b10)? PC : (dataSrc == 2'b11)? {{16{1'b0}}, switch}: MDR;
		wire [5:0] aluOp = functionUla(ulaOp, IR[31:26]);
			
		function [5:0] functionUla (input [1:0] ulaOp, input [5:0] opcode);
			case(ulaOp)
				2'b00: functionUla = IR[5:0];   // Tipo R
				2'b10: functionUla = 6'b000000; //soma
				2'b01: functionUla = 6'b001111; //subtrai
				2'b11: 
					case (opcode)
						6'b100000: functionUla = 6'b000000;//soma imediato
						6'b100001: functionUla = 6'b000001;//and imediato
						6'b100010: functionUla = 6'b001000;//or imediato
						6'b100011: functionUla = 6'b001111;//sub imediato
						6'b100100: functionUla = 6'b001101;//set less than imediato
						6'b100101: functionUla = 6'b001001;//set greater than imediato
						6'b010000: functionUla = 6'b010010;//branch equal
						6'b010001: functionUla = 6'b010010;//branch not equal
						6'b100111: functionUla = 6'b010011;//load imediato
						default: functionUla = 6'b000000;  //soma imediato
					endcase
			endcase
		endfunction
		
		function [31:0] functionB(input [1:0] bSrc);
			case(bSrc)
					2'b00: functionB = B;								//Registrador B
					2'b01: functionB = 32'd1;							//valor 1
					2'b10: functionB = {{16{IR[15]}}, IR[15:0]};	//Extensao de sinal
					default: functionB = B;
			endcase
		endfunction
		
		function [4:0] functionReg(input [1:0] regSrc);
			case(regSrc)
				2'b00: functionReg = IR[20:16];
				2'b01: functionReg = IR[15:11];
				2'b10: functionReg = 5'b11111;
				default: functionReg = IR[20:16];
			endcase
		endfunction
			
		initial begin
			memoria[0] <= {6'b111110, 26'd107};//j to main
//			memoria[107] <= {6'b110000, 5'd5, 5'd5, 16'd0}; //Input n
//			memoria[108] <= {6'b010000, 5'd0, 5'd5, 16'd5}; //beq
//		   memoria[109] <= {6'b100111, 5'd0, 5'd6, 16'd1}; //load imediato 1 base
//			memoria[110] <= {6'b000000, 5'd5, 5'd6, 5'd6, 5'd0, 6'b000100}; //mult
//			memoria[111] <= {6'b100011, 5'd5, 5'd5, 16'd1}; //subi decremento o n
//			memoria[112] <= {6'b101000, 5'd6, 5'd6, 16'd0}; //output
//			memoria[113] <= {6'b010001, 5'd0, 5'd5, 16'b1111111111111100}; //beq 110
//			memoria[114] <= {6'b011000, 26'd0};//halt
			
//			//sintetico
			memoria[107] <= {6'b100111, 5'd0, 5'd5, 16'd2}; //load imediato
			memoria[108] <= {6'b100111, 5'd0, 5'd6, 16'd2}; //load imediato
			memoria[109] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b000000}; //add
			memoria[110] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[111] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b000001}; //and
			memoria[112] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[113] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b000010}; //div
			memoria[114] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[115] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b000011}; //mod
			memoria[116] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[117] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b000100}; //mul
			memoria[118] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[119] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b000101}; //nand
			memoria[120] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[121] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b000110}; //nor
			memoria[122] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[123] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b000111}; //not
			memoria[124] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[125] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b001000}; //or
			memoria[126] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[127] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b001001}; //sgt
			memoria[128] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[129] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b001010}; //sgteq
			memoria[130] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[131] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b001011}; //sll
			memoria[132] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[133] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b001100}; //slr
			memoria[134] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[135] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b001101}; //slt
			memoria[136] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[137] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b001110}; //slteq
			memoria[138] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[139] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b001111}; //sub
			memoria[140] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[141] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b010000}; //xnor
			memoria[142] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[143] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b010001}; //xor
			memoria[144] <= {6'b101000, 5'd7, 5'd7, 16'd0};   //output
			memoria[145] <= {6'b100000, 5'd5, 5'd7, 16'd2}; //addi
			memoria[146] <= {6'b101000, 5'd7, 5'd7, 16'd0}; //output
			memoria[147] <= {6'b100001, 5'd5, 5'd7, 16'd2}; //andi
			memoria[148] <= {6'b101000, 5'd7, 5'd7, 16'd0}; //output
			memoria[149] <= {6'b100010, 5'd5, 5'd7, 16'd2}; //ori
			memoria[150] <= {6'b101000, 5'd7, 5'd7, 16'd0}; //output
			memoria[151] <= {6'b100011, 5'd5, 5'd7, 16'd2}; //subi
			memoria[152] <= {6'b101000, 5'd7, 5'd7, 16'd0}; //output
			memoria[153] <= {6'b100100, 5'd5, 5'd7, 16'd2}; //slti
			memoria[154] <= {6'b101000, 5'd7, 5'd7, 16'd0}; //output
			memoria[155] <= {6'b100101, 5'd5, 5'd7, 16'd2}; //sgti
			memoria[156] <= {6'b101000, 5'd7, 5'd7, 16'd0}; //output
			memoria[157] <= {6'b110000, 5'd5, 5'd5, 16'd0};  //input
			memoria[158] <= {6'b001001, 5'd0, 5'd5, 16'd20}; //store word
			memoria[159] <= {6'b111111, 26'd115}; //jump link
			memoria[160] <= {6'b010000, 5'd7, 5'd9, 16'd3}; //beq
			memoria[161] <= {6'b011000, 26'd0};  //halt
			memoria[162] <= {6'b001000, 5'd0, 5'd8, 16'd20}; //load word
			memoria[163] <= {6'b000001, 5'd31, 5'd31, 16'd0};//jump register
			memoria[164] <= {6'b011000, 26'd0};//halt

			//calculo da area do triangulo
//			memoria[107] <= {6'b110000, 5'd5, 5'd5, 16'd0}; //Input t
//			memoria[108] <= {6'b110000, 5'd6, 5'd6, 16'd0}; //input a
//			memoria[109] <= {6'b100111, 5'd0, 5'd4, 16'd2}; //load imediato v0
//			memoria[110] <= {6'b000000, 5'd5, 5'd6, 5'd7, 5'd0, 6'b000100};//mult b*h
//			memoria[111] <= {6'b000000, 5'd7, 5'd4, 5'd8, 5'd0, 6'b000010};//div 2
//			memoria[112] <= {6'b101000, 5'd8, 5'd8, 16'd0};//Output v
//			memoria[113] <= {6'b011000, 26'd0}; //halt
		end
		
		//Bloco da execucao do PC
		always @(posedge clk or posedge reset) begin
			if(reset)
				PC <= 32'd0;
			else if(pcWrite | (pcCond & jump))					//Sinal de controle de escrita do PC
				case(pcSrc)													//Seleciona o novo PC
					2'b00: PC <= result;									//PC + 1
					2'b01: PC <= aluOut;									//Endereco B
					2'b10: PC <= {PC[31:26], IR[25:0]};				//Endereco J
					2'b11: PC <= A;										//Jr			
				endcase
		end
		
		//Bloco da execucao da memoria
		always @(posedge clk) begin
			if(memWrite)
				memoria[adress] <= B;										//Escrita da memoria
		end
		
		always @(negedge clk) begin
			memOutput <= memoria[adress];
		end
		
		//Bloco da execucao do IR
		always @(posedge clk) begin
			if(irWrite) 
				IR <= memOutput;
		end
		
		always @(posedge clk) begin
				MDR <= memOutput;
		end
		
		//Bloco dos registradores
		always @(posedge clk) begin
			if(regWrite)
				registradores[regAddress] <= regData;
		end
		
		//A e B
		always @(posedge clk) begin
			A <= (IR[25:21]!= 0)? registradores[IR[25:21]]: 0; //Verificar se eh o registrador 0
			B <= (IR[20:16]!= 0)? registradores[IR[20:16]]: 0;
		end		
		
		//Bloco da ULA
		always @(aluOp or regA or regB) begin
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
				6'b001001: result = regA > regB ? 1 : 0; //sgt
				6'b001010: result = regA >= regB ? 1 : 0;//sget
				6'b001011: result = regA << regB; 			//sll
				6'b001100: result = regA >> regB; 			//slr
				6'b001101: result = regA < regB ? 1 : 0;	//slt
				6'b001110: result = regA <= regB ? 1 : 0; //slteq
				6'b001111: result = regA - regB; 			//sub
				6'b010000: result = !(regA ^ regB); 		//xnor
				6'b010001: result = regA ^ regB;			//xor
				6'b010010: result = (regA == regB)? 1 : 0;//beq
				6'b010011: result = regB; 						//li
				default: result = regA;						   //Caso default
			endcase
		end 		
		
		always @(posedge clk) begin 
			aluOut <= result;
		end
		
		//Unidade de controle
		controlUnit control(.opcode(IR[31:26]), .clk(clk), .reset(reset), .pcCond(pcCond), .pcWrite(pcWrite), .pcSrc(pcSrc),
.memSrc(memSrc), .memWrite(memWrite), .memRead(memRead), .irWrite(irWrite), .regSrc(regSrc), .dataSrc(dataSrc),
.regWrite(regWrite), .aSrc(aSrc), .bSrc(bSrc), .ulaOp(ulaOp), .displayWrite(displayWrite), .estado(estado), .enter(btn_enter));
		
		//Saida de dados
		always @(posedge clk or posedge reset) begin
			if(reset)
				Display <= 32'd0;
			else if(displayWrite)
				Display <= result;
		end
		
		always@(posedge clk or posedge reset) begin
			if(reset)
				dispPC <= 32'd0;
			else if(pcWrite)
				dispPC <= PC;
		end
		
		//Encontrar digitos
		binToBCD toBCD(._input(Display), .digito2(centena), .digito1(dezena), .digito0(unidade), .signal(signal));
		binToBCD toBCD2(._input(dispPC), .digito2(d2PC), .digito1(d1PC), .digito0(d0PC), .signal(signal1));

		//Display
		seteSegmentos digito2(._input(centena[3:0]), .output_(display2)); //Centena
		seteSegmentos digito1(._input(dezena[3:0]), .output_(display1));  //Dezena
		seteSegmentos digito0(._input(unidade[3:0]), .output_(display0)); //Unidade
		
		seteSegmentos digito7(._input(d2PC[3:0]), .output_(display7)); //Centena
		seteSegmentos digito6(._input(d1PC[3:0]), .output_(display6)); //Dezena
		seteSegmentos digito5(._input(d0PC[3:0]), .output_(display5)); //Unidade
		
		divisorClk clk1(.clk_50mhz(clk_50Mhz), .clk(clk), .reset(reset));
//		assign clk = clk_50Mhz;
endmodule 