module SRAM_6T_ARRAY
#(
	parameter		int		N_WAY = 4,
	parameter		int		ADDR_SIZE = 24,
	parameter		int		IDX_SIZE = 4,
	parameter		int		TAG_SIZE = 20
)
(
	input	wire				clk,
	input	wire				rst_n,

	output	wire				ppr_valid_o,
	output	wire		[1:0]		ppr_type_o,
	output	wire		[ADDR_SIZE-1:0]	ppr_addr_o,
	
	SRAM_IF.sram_rd				sram_rd_if,
	SRAM_IF.sram_wr				sram_wr_if
);
	localparam		int		NUM_IDX = (2**IDX_SIZE);
	
	logic					valid_array[NUM_IDX][N_WAY];
	logic	[1:0]				tp_array[NUM_IDX][N_WAY];
	logic	[31:0]				syn_array[NUM_IDX][N_WAY];
	logic	[TAG_SIZE-1:0]			tag_array[NUM_IDX][N_WAY];
	logic	[14:0]				cnt_array[NUM_IDX][N_WAY];
	logic	[271:0]				data_array[NUM_IDX][N_WAY];

	logic					rdata_valid[N_WAY];
	logic	[1:0]				rdata_tp[N_WAY];
	logic	[31:0]				rdata_syn[N_WAY];
	logic	[TAG_SIZE-1:0]			rdata_tag[N_WAY];
	logic	[14:0]				rdata_cnt[N_WAY];
	logic	[271:0]				rdata_data[N_WAY];

	always @(posedge clk)
	begin
		if (!rst_n) begin
			for(int index = 0; index < NUM_IDX; index++)
			begin
				for(int way = 0; way < N_WAY; way++)
				begin
					valid_array[index][way] <= 1'b0;
					tp_array[index][way]	<= 2'b0;
					syn_array[index][way]	<= 32'b0;
					tag_array[index][way]	<= {(TAG_SIZE){1'b0}};
					cnt_array[index][way]	<= 15'b0;
					data_array[index][way]	<= 272'b0;
				end
			end
		end
		else begin
			if (sram_rd_if.rden) begin
				rdata_valid	<= valid_array[sram_rd_if.raddr];
				rdata_tp	<= tp_array[sram_rd_if.raddr];
				rdata_syn	<= syn_array[sram_rd_if.raddr];
				rdata_tag	<= tag_array[sram_rd_if.raddr];
				rdata_cnt	<= cnt_array[sram_rd_if.raddr];
				rdata_data	<= data_array[sram_rd_if.raddr];
			end
			else if(sram_wr_if.wren) begin
				valid_array[sram_wr_if.waddr][sram_wr_if.wdata_line] <= 1'b1;
				tp_array[sram_wr_if.waddr][sram_wr_if.wdata_line] <= sram_wr_if.wdata_type;
				syn_array[sram_wr_if.waddr][sram_wr_if.wdata_line] <= sram_wr_if.wdata_syn;
				tag_array[sram_wr_if.waddr][sram_wr_if.wdata_line] <= sram_wr_if.wdata_tag;
				cnt_array[sram_wr_if.waddr][sram_wr_if.wdata_line] <= sram_wr_if.wdata_cnt;
				data_array[sram_wr_if.waddr][sram_wr_if.wdata_line] <= sram_wr_if.wdata_data;
				
				for(int way = 0; way < N_WAY; way++)
				begin
					rdata_valid[way]<= 'Z;
					rdata_tp[way]	<= 'Z;
					rdata_syn[way]	<= 'Z;
					rdata_tag[way]	<= 'Z;
					rdata_cnt[way]	<= 'Z;
					rdata_data[way]	<= 'Z;
				end
			end
			else begin
				for(int way = 0; way < N_WAY; way++)
				begin
					rdata_valid[way]<= 'Z;
					rdata_tp[way]	<= 'Z;
					rdata_syn[way]	<= 'Z;
					rdata_tag[way]	<= 'Z;
					rdata_cnt[way]	<= 'Z;
					rdata_data[way]	<= 'Z;
				end
			end
		end
	end
	
	assign sram_rd_if.rdata_valid = rdata_valid; 
	assign sram_rd_if.rdata_type = rdata_tp;
	assign sram_rd_if.rdata_syn = rdata_syn;
	assign sram_rd_if.rdata_tag = rdata_tag;
	assign sram_rd_if.rdata_cnt = rdata_cnt;
	assign sram_rd_if.rdata_data = rdata_data;

	assign ppr_valid_o = ^sram_wr_if.wdata_type;
	assign ppr_type_o = sram_wr_if.wdata_type;
	assign ppr_addr_o = {sram_wr_if.wdata_line, sram_wr_if.wdata_tag};
endmodule
