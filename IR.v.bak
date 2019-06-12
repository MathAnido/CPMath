module IR(inst, opcode, rs, rt, imme, irWrite);
	input [31:0] inst;					//Instrução vindo da memoria
	output reg [5:0] opcode;			//Campo Opcode
	output reg [4:0] rs;				//Campo RS
	output reg [4:0] rt;				//Campo RT
	output reg [15:0] imme;				//Campo Imediato
	input irWrite;						//bit de controle da escrita
	always @ (posedge irWrite) begin
		opcode = inst[31:26];			//Separação da instrução
		rs = inst[25:21];				//Nos respectivos campos
		rt = inst[20:16];
		imme = inst[15:0];
	end
endmodule
