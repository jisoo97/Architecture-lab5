module IFID_Register(clk, IF_PC4, IF_instruction, IF_flush, IFID_WriteEn, ID_PC4, ID_instruction);
	input clk;
	input [15:0] IF_PC4;
	input [15:0] IF_instruction;
	input IF_flush;
	input IFID_WriteEn;
	output reg [15:0] ID_PC4;
	output reg [15:0] ID_instruction;

	always @(posedge clk) begin
		if (IF_flush) begin
			ID_PC4 = 16'h0000;
			ID_instruction = 16'h0000;
		end
		else if (IFID_WriteEn) begin
			ID_PC4 = IF_PC4;
			ID_instruction = IF_instruction;
		end
	end 
endmodule