module CPMath(clk, reset, switch, btn_enter, display2, display1, display0);
		input btn_enter, reset;
		input clk; 	//Clock 50Mhz
		reg [18:0] cont = 0;
		input [15:0] switch;
		output [6:0] display2, display1, display0;
		wire enter;
		reg clk_div; //clock dividido
		wire toDisplay;
		wire [3:0] centena, dezena, unidade;
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
		wire [15:0] stdin; //entrada de dado dos switchs
		
		//Unidade de processamento
		wire pcWrite, memRead, memWrite, irWrite, regWrite, aSrc, pcCond, displayWrite, haveData;
		wire [1:0] ulaOp;
		wire switchRead, switchWrite;
		//Program Counter
		PC programCounter(._input(pcIn), .output_(pcOut),.clk(clk_div), .pcWrite(pcWrite || (pcCond && zero)), .reset(reset));
		
		//Mux para a Memoria
		mux32 muxMem(._input0(pcOut), ._input1(aluOut), .sel(memSrc), .output_(adress), .clk(clk_div));
		
		//Memoria principal
		memory mem(.adress(adress), .data(memInput), .memOut(memOutput), .memRead(memRead),
	.memWrite(memWrite),.clk(clk_div), .reset(reset), .clk_50mhz(clk));
		
		//Instruction Register
		IR inst(.inst(memOutput), .opcode(opcode), .rs(rs), .rt(rt), .imme(imme), .irWrite(irWrite), .clk(clk_div));
		
		//Banco de registradores
		registers banco(.readReg1(rs), .readReg2(rt), .writeReg(writeReg), .writeData(writeData),
.regA(inputA), .regB(inputB), .regWrite(regWrite), .clk(clk_div));
		
		//Registradores A e B
		GPR A(._input(inputA), .output_(outputA), .clk(clk_div), .reset(reset));
		GPR B(._input(inputB), .output_(outputB), .clk(clk_div), .reset(reset));
		
		//Mux para entrada A da Ula
		mux32 muxA(._input0(pcOut), ._input1(outputA), .sel(aSrc), .output_(aluA), .clk(clk_div));
		
		//Mux para a entrada B da Ula
		mux32B muxB(._input0(outputB), ._input1(32'd1), ._input2(immeExt), ._input3(immeExt4),
.sel(bSrc), .output_(aluB), .clk(clk_div));
		
		//Unidade Logica Aritmetica
		ALU ula(.regA(aluA), .regB(aluB), .zero(zero), .result(result), .aluOp(aluOp));
		
		//Registrador UlaOut
		GPR ulaOut(._input(result), .output_(aluOut), .clk(clk_div), .reset(reset));
		
		//Registrador MDR
		GPR MDR(._input(memOutput), .output_(mdrOut), .clk(clk_div), .reset(reset));
		
		//Mux para a entrada do PC
		mux32B muxPC(._input0(result), ._input1(aluOut), ._input2({pcOut[31:28], adressJ[27:0]}),
._input3({pcOut[31:28], adressJ[27:0]}), .sel(pcSrc), .output_(pcIn), .clk(clk_div));
		
		//Extensor de sinal
		signExtend se1(._input(imme), .output_(immeExt), .clk(clk_div));
		
		//Shift esquerdo de 2 para o muxB
		SL2 sl1(._input(immeExt), .output_(immeExt4), .clk(clk_div));
		
		//Shift esquerdo de 2 para o AdressJ
		SL2 sl2(._input({{6{1'b0}}, rs, rt, imme}), .output_(adressJ), .clk(clk_div));
		
		//Mux para o dados a ser escrito no banco de registradores
		mux32B muxData(._input0(mdrOut), ._input1(aluOut), ._input2(stdin), ._input3(stdin), 
.sel(dataSrc), .output_(writeData), .clk(clk_div));
		
		//Mux para o registrador a ser escrito do banco de registradores
		mux5 muxReg(._input0(rs), ._input1(imme[15:11]), .sel(regSrc), .output_(writeReg), .clk(clk_div));
		
		//Unidade de controle
		controlUnit control(.opcode(opcode), .clk(clk_div), .reset(reset), .pcCond(pcCond),
.pcWrite(pcWrite), .pcSrc(pcSrc), .memSrc(memSrc), .memWrite(memWrite), .memRead(memRead),
.irWrite(irWrite), .regSrc(regSrc), .dataSrc(dataSrc), .regWrite(regWrite), .aSrc(aSrc),
.bSrc(bSrc), .ulaOp(ulaOp), .displayWrite(displayWrite));
		
		//Controle da ula
		controlULA control1(._input(imme[5:0]), .output_(aluOp), .ulaOp(ulaOp), .opcode(opcode));
		
		//Saida de dados
		displayReg display(._input(aluOut), .output_(toDisplay), .clk(clk_div), .displayWrite(displayWrite), .reset(reset));
		
		//Encontrar digitos
		binToBCD saida1(._input(toDisplay), .digito2(centena), .digito1(dezena), .digito0(unidade));

		//Display
		seteSegmentos digito2(._input(centena), .output_(display2), .displayWrite(displayWrite), .clk(clk), .reset(reset)); //Centena
		seteSegmentos digito1(._input(dezena), .output_(display1), .displayWrite(displayWrite), .clk(clk), .reset(reset));  //Dezena
		seteSegmentos digito0(._input(unidade), .output_(display0), .displayWrite(displayWrite), .clk(clk), .reset(reset));	//unidade
		
		//Entrada de dados
		Entrada Buffer(._input(switch), .output_(stdin), .switchRead(switchRead),  .switchWrite(enter), .reset(reset), .clk(clk_div), .haveData(haveData));
		
		//Debounce enter
		DeBounce btnEnter(.clk(clk), .n_reset(1), .button_in(btn_enter), .DB_out(enter));
		
		always @(posedge clk) begin
			 if (reset) begin
				  cont <= 0;
				  clk_div <= 0;
			 end else begin
				  if (cont < 499999) begin
						cont <= cont + 19'd1;
				  end else begin
						cont <= 0;
						clk_div <= ~clk_div;
				  end
			 end
		end
endmodule
