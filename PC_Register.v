module PC_Register(clk, PCin, PC_WriteEn, PC);
	input clk;
	input [15:0] PCin;
	input PC_WriteEn;
	output reg [15:0] PC;

	always @(posedge clk) begin
		if (PC_WriteEn) begin
			PC = PCin;
		end
	end
endmodule
