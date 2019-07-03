module binToBCD(_input, digito0, digito1, digito2, signal);
	input [31:0] _input;
	output reg [31:0] digito0, digito1, digito2;
	output reg signal;
//	reg [31:0] binary = 0;
	integer i;
	always @(*) begin
//		digito0 = 4'd0;//1
//		digito1 = 4'd0;//10
//		digito2 = 4'd0;//100
//		if(_input[31]) begin 
//			binary = ~_input + 1; //caso negativo
//			signal = 1'b0;
//		end
//		else begin
//			binary = _input;	//positivo
//			signal = 1'b1;
//		end
//		
//		for(i = 7; i >= 0; i = i-1) begin
//			if(digito2 >= 4'd5) digito2 = digito2 + 4'd3;
//			if(digito1 >= 4'd5) digito1 = digito1 + 4'd3;
//			if(digito0 >= 4'd5) digito0 = digito0 + 4'd3;
//			digito2 = digito2 << 1;
//			digito2[0] = digito1[3];
//			digito1 = digito1 << 1;
//			digito1[0] = digito0[3];
//			digito0 = digito0 << 1;
//			digito0[0] = binary[i];
//		end
		digito2 = _input / 100;
		digito1 = _input % 100;
		digito0 = digito1 % 10;
		digito1 = digito1 / 10;
		signal = 1;
	end
endmodule 