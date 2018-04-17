module EXMEM_Register(clk, WB, MEM, EX_PC4, EX_ALUResult, BusB_forwarded, EX_WriteRegister, EX_JLControl, // input
		      WB_forwarded, MEM_MemWrite, MEM_MemRead, // control output
		      MEM_PC4, MEM_ALUResult, MEM_BusB_forwarded, MEM_WriteRegister, MEM_JLControl); // data output
	input clk;
	input [1:0] WB;
	input [1:0] MEM;
	input [15:0] EX_PC4, EX_ALUResult, BusB_forwarded;
	input [1:0] EX_WriteRegister;
	input EX_JLControl;
	output reg [1:0] WB_forwarded;
	output reg MEM_MemWrite, MEM_MemRead;
	output reg [15:0] MEM_PC4, MEM_ALUResult, MEM_BusB_forwarded;
	output reg [1:0] MEM_WriteRegister;
	output reg MEM_JLControl;

	always @(posedge clk) begin
		WB_forwarded = WB;
		MEM_MemWrite = MEM[1];
		MEM_MemRead = MEM[0];
		MEM_PC4 = EX_PC4;
		MEM_ALUResult = EX_ALUResult;
		MEM_BusB_forwarded = BusB_forwarded;
		MEM_WriteRegister = EX_WriteRegister;
		MEM_JLControl = EX_JLControl;
	end
endmodule

//Control Input WB, MEM, EX
//WB: RegWrite, MemtoReg
//MEM: MemWrite, MemRead
//EX: Branch, ALUSrc, RegDst, opcode, funct

//Forwarded Data: WriteRegister, PC4, JLControl