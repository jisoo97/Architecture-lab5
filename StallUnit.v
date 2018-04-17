module StallUnit(EX_MemRead, EX_rt, ID_rs, ID_rt, opcode, PC_WriteEn, IFID_WriteEn, Stall_flush);
	input EX_MemRead;
	input EX_rt;
	input ID_rs;
	input ID_rt;
	input [3:0] opcode;
	output PC_WriteEn;
	output IFID_WriteEn;
	output Stall_flush;

	// ORI LHI ADI LWD use rt but don't read rt. opcode == 4,5,6,7
	assign Stall_flush = (EX_MemRead && (EX_rt == ID_rs || (EX_rt == ID_rt && opcode != 4'b0100 && opcode != 4'b0101 && opcode != 4'b0110 && opcode != 4'b0111)));
	assign PC_WrtieEn = ~Stall_flush;
	assign IFID_WriteEn = ~Stall_flush;
endmodule