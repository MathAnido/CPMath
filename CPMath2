module CPMath(clk, reset, switch, btn_enter, display2, display1, display0, pcAtual, resultado, estado, opcode2, instru);
		//teste
		output [31:0] pcAtual, resultado;
		output [3:0] estado;
		wire [3:0] estadoCU;
		output [5:0] opcode2;
		output [31:0] instru;
		//		
		input btn_enter, reset;
		input clk; 	//Clock 50Mhz
		reg [18:0] cont = 0;
		input [15:0] switch;
		output [6:0] display2, display1, display0;
		wire enter;
		//reg clk; //clock dividido
		wire toDisplay;
		wire [3:0] centena, dezena, unidade;
		//Entradas e Saidas PC
		wire [31:0] pcIn, pcOut;
		
		//Entradas e Saidas Memoria
		wire [31:0] adress, memOutput, memInput;
		
		//Entradas e Saidas IR
		wire [5:0] opcode;
		wire [4:0] rs, rt;
		wire [15:0] imme;
		
		//Entradas e Saidas banco de registradores
		wire [4:0] writeReg;
		wire [31:0] writeData;
		
		//Entradas e Saidas registradores A e B
		wire [31:0] inputA, inputB, outputA, outputB;
		
		//Entradas e Saidas Alu
		wire [31:0] aluA, aluB, result;
		wire zero;
		wire [5:0] aluOp;
		
		//Entradas e Saidas AluOut
		wire [31:0] aluOut;
		wire [31:0] immeExt, immeExt4, mdrOut, adressJ;
		wire [1:0] bSrc;
		wire pcSrc, regSrc, memSrc;
		wire [1:0] dataSrc;
		
		//Entrada
		wire [15:0] stdin; //entrada de dado dos switchs
		
		//Unidade de processamento
		wire pcWrite, memRead, memWrite, irWrite, regWrite, aSrc, pcCond, displayWrite, haveData;
		wire [1:0] ulaOp;
		wire switchRead, switchWrite;
		//Program Counter
		PC programCounter(._input(pcIn), .output_(pcOut), .clk(clk), .pcWrite(pcWrite), .reset(reset));
		
		//Mux para a Memoria
		mux32 muxMem(._input0(pcOut), ._input1(aluOut), .sel(memSrc), .output_(adress));
		
		//Memoria principal
		memory mem(.adress(adress), .data(memInput), .memOut(memOutput), .memRead(memRead),
	.memWrite(memWrite),.clk(clk), .reset(reset), .rclk(clk));
		
		//Instruction Register
		IR inst(.inst(memOutput), .opcode(opcode), .rs(rs), .rt(rt), .imme(imme), .irWrite(irWrite), .clk(clk));
		
		//Banco de registradores
		registers banco(.readReg1(rs), .readReg2(rt), .writeReg(writeReg), .writeData(writeData),
.regA(inputA), .regB(inputB), .regWrite(regWrite), .clk(clk));
		
		//Registradores A e B
		GPR A(._input(inputA), .output_(outputA), .reset(reset));
		GPR B(._input(inputB), .output_(outputB), .reset(reset));
		
		//Mux para entrada A da Ula
		mux32 muxA(._input0(pcOut), ._input1(outputA), .sel(aSrc), .output_(aluA));
		
		//Mux para a entrada B da Ula
		mux32B muxB(._input0(outputB), ._input1(32'd1), ._input2(immeExt), ._input3(immeExt4),
.sel(bSrc), .output_(aluB));
		
		//Unidade Logica Aritmetica
		ALU ula(.regA(aluA), .regB(aluB), .zero(zero), .result(result), .aluOp(aluOp));
		
		//Registrador UlaOut
		GPR ulaOut(._input(result), .output_(aluOut), .reset(reset));
		
		//Registrador MDR
		GPR MDR(._input(memOutput), .output_(mdrOut), .reset(reset));
		
		//Mux para a entrada do PC
		mux32B muxPC(._input0(result), ._input1(aluOut), ._input2({pcOut[31:26], rs, rt, imme}),
._input3({pcOut[31:26], rs, rt, imme}), .sel(pcSrc), .output_(pcIn));
		
		//Extensor de sinal
		signExtend se1(._input(imme), .output_(immeExt));
		
		//Shift esquerdo de 2 para o muxB
		SL2 sl1(._input(immeExt), .output_(immeExt4));
		
		//Mux para o dados a ser escrito no banco de registradores
		mux32B muxData(._input0(mdrOut), ._input1(aluOut), ._input2(stdin), ._input3(stdin), 
.sel(dataSrc), .output_(writeData));
		
		//Mux para o registrador a ser escrito do banco de registradores
		mux5 muxReg(._input0(rs), ._input1(imme[15:11]), .sel(regSrc), .output_(writeReg));
		
		//Unidade de controle
		controlUnit control(.opcode(opcode), .clk(clk), .reset(reset), .pcCond(pcCond),
.pcWrite(pcWrite), .pcSrc(pcSrc), .memSrc(memSrc), .memWrite(memWrite), .memRead(memRead),
.irWrite(irWrite), .regSrc(regSrc), .dataSrc(dataSrc), .regWrite(regWrite), .aSrc(aSrc),
.bSrc(bSrc), .ulaOp(ulaOp), .displayWrite(displayWrite), .estadoCU(estadoCU));
		
		//Controle da ula
		controlULA control1(._input(imme[5:0]), .output_(aluOp), .ulaOp(ulaOp), .opcode(opcode));
		
		//Saida de dados
		displayReg display(._input(aluOut), .output_(toDisplay), .clk(clk), .displayWrite(displayWrite), .reset(reset));
		
		//Encontrar digitos
		binToBCD saida1(._input(toDisplay), .digito2(centena), .digito1(dezena), .digito0(unidade));

		//Display
		seteSegmentos digito2(._input(centena), .output_(display2), .displayWrite(displayWrite), .clk(clk), .reset(reset)); //Centena
		seteSegmentos digito1(._input(dezena), .output_(display1), .displayWrite(displayWrite), .clk(clk), .reset(reset));  //Dezena
		seteSegmentos digito0(._input(unidade), .output_(display0), .displayWrite(displayWrite), .clk(clk), .reset(reset));	//unidade
		
		//Entrada de dados
		Entrada Buffer(._input(switch), .output_(stdin), .switchRead(switchRead),  .switchWrite(enter), .reset(reset), .clk(clk), .haveData(haveData));
		
		//Debounce enter
		DeBounce btnEnter(.clk(clk), .n_reset(1), .button_in(btn_enter), .DB_out(enter));
		assign pcAtual = pcOut;
		assign resultado = result;
		assign estado = estadoCU;
		assign opcode2 = opcode;
		assign instru = memOutput;
endmodule

