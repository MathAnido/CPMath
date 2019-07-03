module divisorClk(clk_50mhz, clk, reset);
	input clk_50mhz;
	input reset;
	output reg clk = 0;
	reg [25:0] cont = 0;

	always @(posedge clk_50mhz) begin
		 if (reset) begin
			  cont <= 20'd0;
			  clk <= 0;
		 end else begin
			  if (cont < 28000000) begin
					cont <= cont + 20'd1;
			  end else begin
					cont <= 0;
					clk <= ~clk;
			  end
		 end
	end
endmodule 