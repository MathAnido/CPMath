module CPMath(clk_50mhz, btn_reset, switch, btn_enter, display0, display1, display2);
		//Entradas e Saidas do processador
		input clk_50mhz, btn_reset, btn_enter;
		wire reset, enter;
		input [15:0] switch;
		output [6:0] display0, display1, display2;
		wire clk;
		wire toDisplay;
		//Entradas e Saidas PC
		wire [31:0] pcIn, pcOut;
		
		//Entradas e Saidas Memoria
		wire [31:0] adress, memOutput, memInput;
		
		//Entradas e Saidas IR
		wire [4:0] opcode, rs, rt;
		wire [15:0] imme;
		
		//Entradas e Saidas banco de registradores
		wire [5:0] writeReg, writeData;
		
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
		wire [15:0] stdin;
		
		//Unidade de processamento
		wire pcWrite, memRead, memWrite, irWrite, regWrite, aSrc, pcCond;
		wire [1:0] ulaOp;
		wire switchRead, switchWrite;
		//Program Counter
		PC programCounter(._input(pcIn), .output_(pcOut), .pcWrite(pcWrite));
		
		//Mux para a Memoria
		mux32 muxMem(._input0(pcOut), ._input1(aluOut), .sel(memSrc), .output_(adress));
		
		//Memoria principal
		memory mem(.adress(adress), .data(memInput), .memOut(memOutput), .memRead(memRead),
	.memWrite(memWrite));
		
		//Instruction Register
		IR inst(.inst(memOutput), .opcode(opcode), .rs(rs), .rt(rt), .imme(imme), .irWrite(irWrite));
		
		//Banco de registradores
		registers banco(.readReg1(rs), .readReg2(rt), .writeReg(writeReg), .writeData(writeData),
.regA(inputA), .regB(inputB), .regWrite(regWrite), .clk(clk));
		
		//Registradores A e B
		GPR A(._input(inputA), .output_(outputA));
		GPR B(._input(inputB), .output_(outputB));
		
		//Mux para entrada A da Ula
		mux32 muxA(._input0(pcOut), ._input1(outputA), .sel(aSrc), .output_(aluA));
		
		//Mux para a entrada B da Ula
		mux32B muxB(._input0(outputB), ._input1(25'd4), ._input2(immeExt), ._input3(immeExt4),
.sel(bSrc), .output_(aluB));
		
		//Unidade Logica Aritmetica
		ALU ula(.regA(aluA), .regB(aluB), .zero(zero), .result(result), .aluOp(aluOp));
		
		//Registrador UlaOut
		GPR ulaOut(._input(result), .output_(aluOut));
		
		//Registrador MDR
		GPR MDR(._input(memOutput), .output_(mdrOut));
		
		//Mux para a entrada do PC
		mux32B muxPC(._input0(result), ._input1(aluOut), ._input2({PC[31:28], adressJ[27:0]}),
._input3({programCounter[31:28], adressJ[27:0]}), .sel(pcSrc), .output_(pcIn));
		
		//Extensor de sinal
		signExtend se1(._input(imme), .output_(immeExt));
		
		//Shift esquerdo de 2 para o muxB
		SL2 sl1(._input(imme), .output_(immeExt4));
		
		//Shift esquerdo de 2 para o AdressJ
		SL2 sl2(._input({{6{1'b0}}, rs, rs, imme}), .output_(adressJ));
		
		//Mux para o dados a ser escrito no banco de registradores
		mux32B muxData(._input0(mdrOut), ._input1(aluOut), ._input2(stdin), ._input3(stdin), 
.sel(dataSrc), .output_(writeData));
		
		//Mux para o registrador a ser escrito do banco de registradores
		mux5 muxReg(._input0(rs), ._input1(imme[15:11]), .sel(regSrc), .output_(writeReg));
		
		//Unidade de controle
		controlUnit control(.opcode(opcode), .clk(clk), .reset(reset), .pcCond(pcCond), .pcWrite(pcWrite), .pcSrc(pcSrc),
		.memSrc(memSrc), .memWrite(memWrite), .memRead(memRead), .irWrite(irWrite), .regSrc(regSrc), .dataSrc(dataSrc),
		.regWrite(regWrite), .aSrc(aSrc), .bSrc(bSrc), .ulaOp(ulaOp));
		
		//Controle da ula
		controlULA control1(._input(imme[6:0]), .output_(aluOp), .ulaOp(ulaOp), .opcode(opcode));
		
		//Encontrar digitos
		binToBCD saida1(.number(toDisplay), .hundreds(), .tens(), .ones());
				
		//Saida de dados
		GPR display(._input(aluOut), .output_(toDisplay));
		
		//Entrada de dados
		entrada Buffer(._input(switch), .output_(stdin), .switchRead(switchRead),  .switchWrite(enter), .reset(reset));
		
		//Divisor de frequencia
		divisorClk divClk1(.clk_50mhz(clk_50mhz), .clk(clk), .reset(reset)); 
		
		//Debounce reset
		DeBounce btnReset(.clk(clk_50mhz), .n_reset(reset), .button_in(btn_reset), .DB_out(reset));
		
		//Debounce enter
		DeBounce btnEnter(.clk(clk_50mhz), .n_reset(reset), .button_in(btn_enter), .DB_out(enter));
endmodule
