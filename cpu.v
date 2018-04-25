`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size
//`include "Multiplexer16bit2to1.v"
module cpu(clk, reset_n, readM1, address1, data1, readM2, writeM2, address2, data2, num_inst, output_port, is_halted);
	input clk;
	wire clk;
	input reset_n;
	wire reset_n;

	output readM1;
	wire readM1;
	output [`WORD_SIZE-1:0] address1;
	wire [`WORD_SIZE-1:0] address1;
	output readM2;
	wire readM2;
	output writeM2;
	wire writeM2;
	output [`WORD_SIZE-1:0] address2;
	wire [`WORD_SIZE-1:0] address2;

	input [`WORD_SIZE-1:0] data1;
	wire [`WORD_SIZE-1:0] data1;
	inout [`WORD_SIZE-1:0] data2;
	wire [`WORD_SIZE-1:0] data2;

	output [`WORD_SIZE-1:0] num_inst;
	wire [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	wire [`WORD_SIZE-1:0] output_port;
	output is_halted;
	wire is_halted;
	
	//wire declaration
	//IF
	wire [`WORD_SIZE-1:0] PCin;
	wire [`WORD_SIZE-1:0] PC;
	wire [`WORD_SIZE-1:0] IF_PC4;
	wire [`WORD_SIZE-1:0] IF_instruction;
	//ID
	wire [`WORD_SIZE-1:0] ID_PC4;
	wire [`WORD_SIZE-1:0] ID_instruction;
	wire [3:0]opcode;
	wire [5:0]funct;
	wire RegWrite;
	wire MemtoReg;
	wire MemWrite;
	wire MemRead;
	wire Branch;
	wire ALUSrc;
	wire RegDst;
	wire JRControl;
	wire JLControl;
	wire [16:0]ControlInput;
	wire [16:0]ID_ControlInput;
	wire [1:0] ID_rs,ID_rt,ID_rd;
	wire [`WORD_SIZE-1:0] readData1,readData2;
	wire [7:0] ID_immediate;
	wire [`WORD_SIZE-1:0] im16_ext;
	//EX
	wire [1:0] WB;
	wire [1:0] MEM;
	wire [1:0] EX_WB;
	wire EX_Branch, EX_ALUSrc, EX_RegDst;
	wire [3:0] EX_opcode;
	wire[5:0] EX_funct;
	wire EX_JRControl;
	wire EX_JLControl;
	wire [15:0] EX_PC4;
	wire [15:0] EX_im16_ext, EX_ReadData1, EX_ReadData2;
	wire [1:0] EX_rs, EX_rt, EX_rd;
	wire [`WORD_SIZE-1:0] branch_addr;
	wire [`WORD_SIZE-1:0] BusA_ALU,BusB_ALU,BusB_forwarded;
	wire [3:0] aluControlInput;
	wire bcond;
	wire [`WORD_SIZE-1:0] EX_ALUResult;
	wire [1:0] EX_RegDstResult;
	wire [1:0] EX_WriteRegister;
	wire bneControl;
	wire [`WORD_SIZE-1:0] PC1,PC2,PCj,EX_PC1,EX_PC2;
	wire Jump, JumpFlush;
	//MEM
	wire [1:0] WB_forwarded;
	wire MEM_MemWrite, MEM_MemRead;
	wire [15:0] MEM_PC4, MEM_ALUResult, MEM_BusB_forwarded;
	wire[1:0] MEM_WriteRegister;
	wire MEM_JLControl;
	wire [`WORD_SIZE-1:0] MEM_ReadDataOfMem;
	wire [1:0] ForwardA, ForwardB;
	//WB
	wire WB_RegWrite;
	wire WB_MemtoReg;
	wire [`WORD_SIZE-1:0] WB_PC4, WB_ReadDataOfMem, WB_ALUResult;
	wire [1:0] WB_WriteRegister;
	wire WB_JLControl;
	wire [`WORD_SIZE-1:0] WB_WriteData_tmp;
	wire [`WORD_SIZE-1:0] WB_WriteData;

	//discard,stall,flush
	wire PC_WriteEn;
	wire IF_flush;
	wire IFID_WriteEn;
	wire IFID_flush;
	wire ID_flush;
	wire Stall_flush;
	wire flush;
//----------------------------------------------
	//call PC
	PC_Register PC_call(clk, PCin, PC_WriteEn, PC);

	//add 4 to PC
	ADD ADD_PC_4(PC,16'h0004,IF_PC4);

	//Instruction Memory - Instruction in data1
	Memory IF(clk, reset_n, readM1, address1, data1, readM2, writeM2, address2, data2);

	//PC update
	PC_Register PC_update(clk, PCin, PC_WriteEn, PC);
//-------------------------------------------------------------------
	//IF_ID Register
	assign IF_instruction = data1;
	IFID_Register IFID_register_update(clk, IF_PC4, IF_instruction , IF_flush, IFID_WriteEn, ID_PC4, ID_instruction);
	
	//ControlUnit
	assign opcode = ID_instruction[15:12];
	assign funct = ID_instruction[5:0];
	ControlUnit controlUnit_call(opcode, funct, ControlInput,Jump);
	assign ID_ControlInput = ControlInput;
	seventeenBitMultiplexer2to1 controlInput_select(ControlInput, 17'h00, flush, ID_ControlInput);


	//Reg File **WB_regwrite,writeReg,wirteData, 
	assign ID_rs=ID_instruction[11:10];
	assign ID_rt=ID_instruction[9:8];
	assign ID_rd =ID_instruction[7:6];
	registerHandle register_file_call(WB_RegWrite, ID_rs, ID_rt, WB_WriteRegister, WB_WriteData, readData1, readData2, clk, reset_n);
	
	//signExtend
	assign ID_immediate = ID_instruction[7:0];
	SignExtend immediate_extend(ID_immediate, im16_ext);
	
	//JR Control
	JRControlBlock JRControl_call(opcode, funct, JRControl);
	//JL Control
	JLControlBlock JLControl_call(opcode, funct, JLControl);
	
//-----------------------------------------------
	//ID_EX Register
	IDEX_Register IDEX_Register_update(clk, ID_PC4, ID_ControlInput, readData1, readData2, im16_ext, ID_rs, ID_rt, ID_rd, JRControl, JLControl, //control and data input
		     WB, MEM, //bunch output
		     EX_Branch, EX_ALUSrc, EX_RegDst, EX_opcode, EX_funct, EX_JRControl, EX_JLControl, //control output
		     EX_PC4, EX_im16_ext, EX_ReadData1, EX_ReadData2, EX_rs, EX_rt, EX_rd);

	//ADD EX_PC4, Ex_im16_Ext
	ADD ADD_EX_PC4(EX_PC4,EX_im16_ext,branch_addr);

	//Choose A for ALU
	sixteenBitMultiplexer4to1 MUX_A_ALU(EX_ReadData1, WB_WriteData, MEM_ALUResult, 16'h0, ForwardA,BusA_ALU);
	
	//Choose B for ALU
	sixteenBitMultiplexer4to1 MUX_B_tmp_ALU(EX_ReadData2, WB_WriteData, MEM_ALUResult, 16'h0, ForwardB ,BusB_forwarded);
	sixteenBitMultiplexer2to1 MUX_B_ALU(BusB_forwarded, EX_im16_ext, EX_ALUSrc, BusB_ALU);

	//ALU control input
	aluControl aluControl_call(EX_funct, EX_opcode, aluControlInput);
	//ALU 
	ALU ALU_call(BusA_ALU,BusB_ALU,aluControlInput,bcond,EX_ALUResult);

	//Choose RegDst
	twoBitMultiplexer2to1 MUX_EX_RegDst(EX_rt, EX_rd, EX_RegDst, EX_RegDstResult);
	//Choose EX_WriteRegister
	twoBitMultiplexer2to1 MUX_EX_JLContorl(EX_RegDstResult, 2'b10, EX_JLControl, EX_WriteRegister);
	
	//UPPER branch part
	assign bneControl = EX_Branch&bcond;
	assign JumpFlush = Jump&(~IFID_flush);
	assign PCjControl = JumpFlush&bneControl;
	sixteenBitMultiplexer2to1 MUX_bneControl(IF_PC4,branch_addr,bneControl,EX_PC1);
	sixteenBitMultiplexer2to1 MUX_PCjControl(PCj,EX_PC1,EX_PCjControl,EX_PC2);//******
	sixteenBitMultiplexer2to1 MUX_EX_JRControl(EX_PC2,BusA_ALU,EX_JRControl,PCin);

//----------------------------------------------------------------
	EXMEM_Register EXMEM_Register_update(clk, WB, MEM, EX_PC4, EX_ALUResult, BusB_forwarded, EX_WriteRegister, EX_JLControl, // input
		      WB_forwarded, MEM_MemWrite, MEM_MemRead, // control output
		      MEM_PC4, MEM_ALUResult, MEM_BusB_forwarded, MEM_WriteRegister, MEM_JLControl); // data output
	
	//Data memory
	assign address2 = MEM_ALUResult;
	assign data2 = writeM2 ? MEM_BusB_forwarded: `WORD_SIZE'hzzzz;
	assign readM2 = MEM_MemRead; //iorD deleted ?????
	assign writeM2 = MEM_MemWrite;
	assign MEM_ReadDataOfMEM = data2;

	//forward unit
	ForwardingUnit ForwardingUnit_call(MEM_WriteRegister, MEM_RegWrite, WB_WriteRegister, WB_RegWrite, EX_rs, EX_rt, ForwardA, ForwardB);

//------------------------------------------------------------------------
	MEMWB_Register MEMWB_Register_update(clk, WB_forwarded, MEM_PC4, MEM_ReadDataOfMem, MEM_ALUResult, MEM_WriteRegister, MEM_JLControl,// input
		      WB_RegWrite, WB_MemtoReg, // control output
		      WB_PC4, WB_ReadDataOfMem, WB_ALUResult, WB_WriteRegister, WB_JLControl); // data output
	
	//Choose WB_WriteData
	sixteenBitMultiplexer2to1 MUX_WB_WriteData_tmp(WB_ReadDataOfMem, WB_ALUResult, WB_MemtoReg, WB_WriteData_tmp);
	sixteenBitMultiplexer2to1 MUX_WB_WriteData(WB_WriteData_tmp, WB_PC4, WB_JLControl, WB_WriteData);

//----------------------------------------------------------------------------
	//DiscardInstruction, Stall, flush
	DiscardInstruction discard_inst(Jump, bneControl, JRControl, IF_flush, ID_flush);
	StallUnit stall(EX_MemRead, EX_rt, ID_rs, ID_rt, opcode, PC_WriteEn, IFID_WriteEn, Stall_flush);
	Flush flush_call(IFID_flush, ID_flush, Stall_flush, flush);
	

//WB: RegWrite, MemtoReg
//MEM: MemWrite, MemRead
//EX: Branch, ALUSrc, RegDst, opcode, funct
endmodule
