module DRC_MANAGER
#(
	parameter	int				N_WAY = 4,
	parameter	int				TAG_SIZE = 20,
	parameter	int				IDX_SIZE = 4,
	parameter	int				WAY_WIDTH = 2
)
(
	input	wire					clk,
	input	wire					rst_n,

	input	wire					hit_i,
	input	wire	[WAY_WIDTH-1:0]			hit_way_i,
	input	wire					we_i,
	input	wire					ecc_i,

	input	wire					rdata_valid[N_WAY],
	input	wire	[1:0]				rdata_type[N_WAY],
	input	wire	[31:0]				rdata_syn[N_WAY],
	input	wire	[14:0]				rdata_cnt[N_WAY],	

	input	wire	[TAG_SIZE-1:0]			tag_i,
	input	wire	[IDX_SIZE-1:0]			index_i,
	input	wire	[271:0]				data_i,
	input	wire	[31:0]				syndrome_i,
	input	wire	[7:0]				err_i,

	SRAM_IF.drc_wr					drc_wr_if
);
	localparam	int				DRC_MAX = 32767;
	localparam	int				DRC_INIT = 2048;
	localparam	int				FAULTY_INCREMENT = 2048;
	localparam	int				HEALTHY_DECREMENT = 256;
	localparam	int				DRC_LIMIT = DRC_MAX - FAULTY_INCREMENT;

	logic		[IDX_SIZE-1:0]			waddr; //index
	logic						wren;
	logic		[1:0]				wdata_type;
	logic		[31:0]				wdata_syn;
	logic		[TAG_SIZE-1:0]			wdata_tag;
	logic		[14:0]				wdata_cnt;
	logic		[271:0]				wdata_data;
	logic		[WAY_WIDTH-1:0]			wdata_line;

	//logic for cacheline eviction policy
	logic						invalid_line;
	always_comb begin
		wren = 1'b0;
		wdata_line = {(WAY_WIDTH){1'b0}};
		wdata_type = 2'b0;
		wdata_cnt = 32'b0;
		invalid_line = 1'b0;
		if(hit_i & we_i) begin
			wren = 1'b1;
			wdata_line = hit_way_i;	
			wdata_type = rdata_type[hit_way_i];
			wdata_cnt = rdata_cnt[hit_way_i];
		end
		if(ecc_i) begin
			if(hit_i) begin
				wren = 1'b1;
				wdata_line = hit_way_i;
				if(syndrome_i == 32'b0) begin
					wdata_type = rdata_type[hit_way_i];
					wdata_cnt = (rdata_cnt[hit_way_i] >= HEALTHY_DECREMENT) ? rdata_cnt[hit_way_i] - HEALTHY_DECREMENT : 15'b0;
				end
				else begin
					if(rdata_syn[hit_way_i] == syndrome_i) begin
						wdata_type = rdata_type[hit_way_i];
					end
					else begin 
						wdata_type =	(rdata_cnt[hit_way_i] >= DRC_LIMIT) ? 2'b11 :
								(err_i[7]|err_i[5]|err_i[3]|err_i[1]) ? 2'b10 :	
								((err_i[6]&err_i[4])|				
								(err_i[6]&err_i[2])|
								(err_i[6]&err_i[0])|
								(err_i[4]&err_i[2])|
								(err_i[4]&err_i[0])|
								(err_i[2]&err_i[0])) ? 2'b01 : 2'b00;	
					end
					wdata_cnt = (rdata_cnt[hit_way_i] <= DRC_LIMIT) ? rdata_cnt[hit_way_i] + FAULTY_INCREMENT : DRC_MAX;
				end
			end		
			else begin
				if(syndrome_i != 32'b0) begin
					wren = 1'b1;
					for(integer i=0 ; i<N_WAY; i++) begin
						if(!invalid_line) begin
							if(!rdata_valid[i]) begin
								wdata_line = i;
								invalid_line = 1'b1;
							end
							else if(rdata_type[i] < rdata_type[wdata_line]) begin
								wdata_line = i;
							end
							else if((rdata_type[i] == rdata_type[wdata_line]) & (rdata_cnt[i] < rdata_cnt[wdata_line])) begin
								wdata_line = i;
							end
						end
					end
					wdata_type = 	(err_i[7]|err_i[5]|err_i[3]|err_i[1]) ? 2'b10 :   	
							((err_i[6]&err_i[4])|				
							(err_i[6]&err_i[2])|
							(err_i[6]&err_i[0])|
							(err_i[4]&err_i[2])|
							(err_i[4]&err_i[0])|
							(err_i[2]&err_i[0])) ? 2'b01 : 2'b00;
					wdata_cnt = DRC_INIT;
				end
			end	
		end

	end

	assign drc_wr_if.waddr		= index_i;
	assign drc_wr_if.wren		= wren;
	assign drc_wr_if.wdata_type 	= wdata_type;
	assign drc_wr_if.wdata_syn	= ((hit_i & we_i)==1'b1) ? rdata_syn[hit_way_i] :
					  ((hit_i & ecc_i)==1'b1) ? syndrome_i : 32'b0;
	assign drc_wr_if.wdata_tag	= tag_i;
	assign drc_wr_if.wdata_cnt	= wdata_cnt;
	assign drc_wr_if.wdata_data	= data_i;
	assign drc_wr_if.wdata_line	= wdata_line;
endmodule
