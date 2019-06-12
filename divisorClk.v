module divisorClk(clk_50mhz, clk, reset);
	input clk_50mhz;
	input reset;
	output reg clk = 0;
	reg [17:0] cont = 0;

	always @(posedge clk_50mhz or posedge reset) begin
		 if (reset) begin
			  cont <= 0;
			  clk <= 0;
		 end else begin
			  if (cont < 249999) begin
					cont <= cont + 18'd1;
			  end else begin
					cont <= 0;
					clk <= ~clk;
			  end
		 end
	end
endmodule 