module BCD(_input, digito0, digito1, digito2);
	input [31:0] _input;
	reg [31:0] binary;
	output reg [4:0] digito0, digito1, digito2;
	integer i;
	always @(_input) begin
		digito0 = 4'd0;//1
		digito1 = 4'd0;//10
		digito2 = 4'd0;//100
		if(_input[31]) binary = ~_input + 1; //caso negativo
		else binary = _input;	//positivo
		
		for(i = 7; i >= 0; i = i-1)
		begin
			if(digito2 >= 5) digito2 = digito2 + 3;
			if(digito1 >= 5) digito1 = digito1 + 3;
			if(digito0 >= 5) digito0 = digito0 + 3;
			digito2 = digito2 << 1;
			digito2[0] = digito1[3];
			digito1 = digito1 << 1;
			digito1[0] = digito0[3];
			digito0 = digito0 << 1;
			digito0[0] = binary[i];
		end
	end
endmodule 