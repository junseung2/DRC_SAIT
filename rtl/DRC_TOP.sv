module DRC_TOP 
#(
	parameter	int				N_WAY = 4,
	parameter	int				ADDR_SIZE = 24,
	parameter	int				TAG_SIZE = 20,
	parameter	int				IDX_SIZE = 4
)
(	
	input	wire					clk,
	input	wire					rst_n,

	input	wire	[ADDR_SIZE-1:0]			addr_i,

	input	wire					host_we_i,
	input	wire	[271:0]				host_data_i,
	input	wire					host_valid_i,

	input	wire	[31:0]				ecc_syndrome_i,
	input	wire	[271:0]				ecc_data_i,
	input	wire	[7:0]				ecc_err_i,
	input	wire					ecc_valid_i,

	output	wire	[271:0]				drc_data_o,
	output	wire					drc_hit_o,
	
	SRAM_IF.drc_rd					drc_rd_if,
	SRAM_IF.drc_wr					drc_wr_if
);
	localparam	int				WAY_WIDTH = $clog2(N_WAY);

	//Signal for decoder
	logic		[TAG_SIZE-1:0]			tag;
	logic		[IDX_SIZE-1:0]			index;
	//Signal for tag_comparator
	logic		[TAG_SIZE-1:0]			tag_delayed;
	logic		[IDX_SIZE-1:0]			index_delayed;
	logic		[271:0]				data_delayed;
	logic		[31:0]				syndrome_delayed;
	logic		[7:0]				err_delayed;

	logic						hit;
	logic		[WAY_WIDTH-1:0]			hit_way;
	logic						we;
	logic						ecc;
	//Signal for drc_manager(buffer)
	
	
	//Signal for drc_output
	logic		[271:0]				drc_data, drc_data_n;
	logic						drc_hit, drc_hit_n;;

	DRC_DECODER 
	#(
		.ADDR_SIZE	(ADDR_SIZE),
		.TAG_SIZE	(TAG_SIZE),
		.IDX_SIZE	(IDX_SIZE)
	) u_decoder
	(
		.addr_i		(addr_i),
		.tag_o		(tag),
		.index_o	(index)
	);
	DRC_TAG_COMPARATOR 
	#(
		.N_WAY		(N_WAY),
		.TAG_SIZE	(TAG_SIZE),
		.IDX_SIZE	(IDX_SIZE),
		.WAY_WIDTH	(WAY_WIDTH)
	) u_tag_comparator
	(
		.clk		(clk),
		.rst_n		(rst_n),
		
		.tag_i		(tag),
		.index_i	(index),
		
		.rdata_valid_i	(drc_rd_if.rdata_valid),
		.rdata_tag_i	(drc_rd_if.rdata_tag),

		.host_we_i	(host_we_i),
		.host_data_i	(host_data_i),
		.host_valid_i	(host_valid_i),

		.ecc_syndrome_i	(ecc_syndrome_i),
		.ecc_data_i	(ecc_data_i),
		.ecc_err_i	(ecc_err_i),
		.ecc_valid_i	(ecc_valid_i),

		.tag_delayed_o		(tag_delayed),
		.index_delayed_o	(index_delayed),
		.data_delayed_o		(data_delayed),
		.syndrome_delayed_o	(syndrome_delayed),
		.err_delayed_o		(err_delayed),

		.hit_o		(hit),
		.hit_way_o	(hit_way),
		.we_o		(we),
		.ecc_o		(ecc)
	);
	DRC_MANAGER 
	#(
		.N_WAY		(N_WAY),
		.TAG_SIZE	(TAG_SIZE),
		.IDX_SIZE	(IDX_SIZE),
		.WAY_WIDTH	(WAY_WIDTH)
	) u_manager
	(
		.clk		(clk),
		.rst_n		(rst_n),

		.hit_i		(hit),
		.hit_way_i	(hit_way),
		.we_i		(we),
		.ecc_i		(ecc),
		
		.rdata_valid	(drc_rd_if.rdata_valid),
		.rdata_type	(drc_rd_if.rdata_type),
		.rdata_syn	(drc_rd_if.rdata_syn),
		.rdata_cnt	(drc_rd_if.rdata_cnt),

		.tag_i		(tag_delayed),
		.index_i	(index_delayed),
		.data_i		(data_delayed),
		.syndrome_i	(syndrome_delayed),
		.err_i		(err_delayed),

		.drc_wr_if	(drc_wr_if)
	);

	always @(posedge clk) begin
		if(!rst_n) begin
			drc_data	<=272'b0;
			drc_hit		<=1'b0;
		end
		else begin
			drc_data	<=drc_data_n;
			drc_hit		<=drc_hit_n;
		end
	end

	always_comb begin
		drc_data_n = drc_data;
		drc_hit_n = drc_hit;

		if((host_valid_i==1'b1) && (host_we_i==1'b0)) begin
			drc_hit_n = 1'b0;
		end
		if((we == 1'b0) && (hit == 1'b1)) begin
			drc_hit_n = 1'b1;
			drc_data_n = drc_rd_if.rdata_data[hit_way];
		end
	end

	assign	drc_rd_if.rden				=host_valid_i || ecc_valid_i;
	assign 	drc_rd_if.raddr				=index;

	assign	drc_data_o				=drc_data;
	assign	drc_hit_o				=drc_hit;
endmodule


