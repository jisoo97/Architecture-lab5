module DiscardInstruction(Jump, bneControl, JRControl, IF_flush, ID_flush);
	input Jump; //  Jump includes J, JAL.
	input bneControl;
	input JRControl;
	output IF_flush;
	output ID_flush;

	assign IF_flush = Jump || bneControl || JRControl;
	assign ID_flush = bneControl || JRControl;
endmodule