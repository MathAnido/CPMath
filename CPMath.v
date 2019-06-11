module CPMath();
		wire [31:0] pcIn, pcOut; //PC
		wire [31:0] adress, memOutput, memInput; //memoria
		wire [5:0] opcode, rs, rt, imme; //intruction register
		wire [5:0] writeReg, writeData; //register bench
		wire [31:0] inputA, inputB, outputA, outputB; //A e B
		wire [31:0] aluA, aluB, result; // alu
		wire zero;
		wire [5:0] aluOp;
		wire [31:0] aluOut;
		wire [31:0] immeExt, immeExt4, adressJ, mdrOut;
		wire bSrc,pcSrc, dataSrc, regSrc;
		//Sinais de controle
		wire pcWrite, memRead, memWrite, irWrite, regWrite, aSrc;
		PC programCounter(pcIn, pcOut, pcWrite);
		mux32 muxMem(pcOut, aluOut, adress);
		memory mem(adress, memInput, memOutput, memRead, memWrite);
		IR inst(memOutput, opcode, rs, rt, imme, irWrite);
		register banco(rs, rt, writeReg, writeData, inputA, inputB, regWrite);
		GPR A(inputA, outputA);
		GPR B(inputB, outputB);
		mux32 muxA(pcOut, outputA, aSrc, aluA);
		mux32B muxB(outputA, 25'd4, immeExt, immeExt4, bSrc, aluB);
		ALU ula(aluA, aluB, zero, result, aluOp);
		GPR ulaOut(result, aluOut);
		GPR MDR(memOutput, mdrOut);
		mux32b muxPC(result, aluOut, {PC[31:28], adressJ[27:0]}, {PC[31:28], adressJ[27:0]}, pcSrc, pcIn);
		signExtend se1(imme, immeExt);
		SL2 sl1(imme, immeExt4);
		SL2 sl2({{6{1'b0}}, rs, rs, imme}, adressJ);
		mux32 muxData(mdrOut, aluOut, dataSrc, writeData);
		mux5 muxReg(rs, imme[15:11], regSrc, writeReg);
endmodule
