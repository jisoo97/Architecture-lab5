//register part
module registerHandle(regWrite, readReg1, readReg2, writeReg, writeData, readData1, readData2, clk, reset_n);
	input regWrite;
	input [1:0]readReg1;
	input [1:0]readReg2;
	input [1:0]writeReg;
	input [15:0]writeData;
	output reg [15:0]readData1;
	output reg [15:0]readData2;
	input clk;
	input reset_n;

	reg [15:0] regfile[3:0];

	always @(posedge clk) begin
		if(regWrite == 1)begin
  			regfile[writeReg] = writeData;
		end
	end
	
	always @(reset_n) begin
		regfile[0] = 0;
		regfile[1] = 0;
		regfile[2] = 0;
		regfile[3] = 0;
	end

	always @(*) begin
		if ((regWrite)&&(writeReg == readReg1)) begin
			readData1 = writeData;
		end
		else begin
			readData1 = regfile[readReg1];
		end
		if ((regWrite)&&(writeReg == readReg2)) begin
			readData2 = writeData;
		end
		else begin
			readData2 = regfile[readReg2];
		end
	end
endmodule	
// internal forwarding for WB!!