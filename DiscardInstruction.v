module DiscardInstruction(Jump, BranchControl, JRControl, IF_flush, ID_flush);
	input Jump; //  Jump includes J, JAL.
	input BranchControl;
	input JRControl;
	output IF_flush;
	output ID_flush;

	assign IF_flush = Jump || BranchControl || JRControl;
	assign ID_flush = BranchControl || JRControl;
endmodule