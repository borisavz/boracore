module cpu(
    input clk,
	output [7:0] a,
	output [7:0] b,
	output [7:0] c,
	output [7:0] ip
);
    wire [7:0] a;
	wire [7:0] b;
	wire [7:0] c;
	
	wire [7:0] ip;
	
	reg [18:0] instr_mem [0:254];
	
	wire [18:0] instr;
	
	initial begin		
		instr_mem[0] = 20'b111_00000010_00000011;
		instr_mem[1] = 20'b111_00000001_00000001;
		instr_mem[2] = 20'b010_00000010_00000001;
		instr_mem[3] = 20'b011_00000000_00000000;
		instr_mem[4] = 20'b101_00000000_00000010;
	end
	
	assign val = c;
	assign instr = instr_mem[ip];
	
	wire [7:0] alu_i1;
	wire [7:0] alu_i2;
	wire [7:0] alu_out;
	wire alu_op;
	
	wire [7:0] data_read_addr;
	wire [7:0] data_write_addr;
	wire [7:0] data_read_val;
	wire [7:0] data_write_val;
	wire write_enable;
	
	data_memory mem0(
		.clk(clk),
		.read_addr(data_read_addr),
		.write_addr(data_write_addr),
		.write_val(data_write_val),
		.write_enable(write_enable),
		.read_val(data_read_val)
	);
	
	control control0(
		.clk(clk),
		.a(a),
		.b(b),
		.c(c),
		.ip(ip),
		.instr(instr),
		.data_read_addr(data_read_addr),
		.data_write_addr(data_write_addr),
		.data_read_val(data_read_val),
		.data_write_val(data_write_val),
		.write_enable(write_enable),
		.alu_out(alu_out),
		.alu_i1(alu_i1),
		.alu_i2(alu_i2),
		.alu_op(alu_op)
	);
	
	alu alu0 (
	    .op(alu_op),
		.i1(alu_i1),
		.i2(alu_i2),
		.res(alu_out)
	);
endmodule

module control(
    input clk,
	output reg [7:0] a,
	output reg [7:0] b,
	output reg [7:0] c,
	output reg [7:0] ip,
	input [18:0] instr,
	output [7:0] data_read_addr,
	output [7:0] data_write_addr,
	input [7:0] data_read_val,
	input [7:0] data_write_val,
	output write_enable,
	input [7:0] alu_out,
	output [7:0] alu_i1,
	output [7:0] alu_i2,
	output alu_op
);
	initial begin
		ip = 0;
	end
	
	wire [2:0] op;
	wire [7:0] addr;
	wire [7:0] reg1;
	wire [7:0] reg2;
	wire [7:0] next_instr;
	wire [7:0] imm_val;
	
	assign op = instr[18:16];
	assign addr = instr[7:0];
	assign reg1 = instr[7:0];
	assign reg2 = instr[15:8];
	assign imm_val = instr[7:0];
	assign next_instr = instr[7:0];
	
	assign alu_op = op == ADD ? 0 : 1;
	
	assign alu_i1 = (reg2 == 0) ? a :
					(reg2 == 1) ? b :
	                (reg2 == 2) ? c : 0;
	
	assign alu_i2 = (reg1 == 0) ? a :
					(reg1 == 1) ? b :
	                (reg1 == 2) ? c : 0;
	
	assign data_read_addr = addr;
	assign data_write_addr = addr;
	assign data_write_val = c;
	assign write_enable = op == ST;
	
	parameter LD = 0;
	parameter ADD = 1;
	parameter SUB = 2;
	parameter JZ = 3;
	parameter JNZ = 4;
	parameter J = 5;
	parameter ST = 6;
	parameter STR = 7;
	
	always @(posedge clk) begin
		case(op)
			LD: begin
				if (reg2 == 0)
					a <= data_read_val;
				
				if (reg2 == 1)
					b <= data_read_val;
				
				if (reg2 == 2)
					c <= data_read_val;
				
				ip <= ip + 1;
			end
			
			ADD: begin
				c <= alu_out;
				ip <= ip + 1;
			end
			
			SUB: begin
				c <= alu_out;
				ip <= ip + 1;
			end
			
			JZ: begin
				ip <= c == 0 ? next_instr : (ip + 1);
			end
			
			JNZ: begin
				ip <= c != 0 ? next_instr : (ip + 1);
			end
			
			J: begin
				ip <= next_instr;
			end
			
			ST: begin
				ip <= ip + 1;
			end
			
			STR: begin
				if (reg2 == 0)
					a <= imm_val;
				
				if (reg2 == 1)
					b <= imm_val;
				
				if (reg2 == 2)
					c <= imm_val;
				
				ip <= ip + 1;
			end
		endcase
	end
endmodule

module alu(
	input op,
	input [7:0] i1,
	input [7:0] i2,
	output [7:0] res
);
    assign res = op ? (i1 - i2) : (i1 + i2);
endmodule

module data_memory(
	input clk,
	input [7:0] read_addr,
	input [7:0] write_addr,
	input [7:0] write_val,
	input write_enable,
	output [7:0] read_val
);
	reg [7:0] data_mem [0:254];
	
	initial begin
		data_mem[0] = 2;
		data_mem[1] = 3;
		data_mem[2] = 5;
		data_mem[3] = 5;
		data_mem[4] = 5;
		data_mem[5] = 5;
	end
	
	assign read_val = data_mem[read_addr];
	
	always @(posedge clk) begin
		if (write_enable)
			data_mem[write_addr] <= write_val;
	end
endmodule
