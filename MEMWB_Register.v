module MEMWB_Register(clk, WB_forwarded, MEM_PC4, MEM_ReadDataOfMem, MEM_ALUResult, MEM_WriteRegister, MEM_JLControl,// input
		      WB_RegWrite, WB_MemtoReg, // control output
		      WB_PC4, WB_ReadDataOfMem, WB_ALUResult, WB_WriteRegister, WB_JLControl); // data output
	input clk;
	input [1:0] WB_forwarded;
	input [15:0] MEM_PC4, MEM_ReadDataOfMem, MEM_ALUResult;
	input [1:0] MEM_WriteRegister;
	input MEM_JLControl;
	output reg WB_RegWrite;
	output reg WB_MemtoReg;
	output reg [15:0] WB_PC4, WB_ReadDataOfMem, WB_ALUResult;
	output reg [1:0] WB_WriteRegister;
	output reg WB_JLControl;

	always @(*) begin
		WB_RegWrite = WB_forwarded[1];
		WB_MemtoReg = WB_forwarded[0];
		WB_PC4 = MEM_PC4;
		WB_ReadDataOfMem = MEM_ReadDataOfMem;
		WB_ALUResult = MEM_ALUResult;
		WB_WriteRegister = MEM_WriteRegister;
		WB_JLControl = MEM_JLControl;
	end
endmodule
		