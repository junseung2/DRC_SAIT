
interface SRAM_IF
#(
	parameter	int	N_ENTRY		= 64,
	parameter	int	N_WAY		= 4
)
(
	input		wire	clk,
	input		wire	rst_n
);
	localparam	int	ADDR_SIZE	= 24;
	localparam	int	IDX_SIZE	= $clog2(N_ENTRY/N_WAY);
	localparam	int	TAG_SIZE	= ADDR_SIZE - IDX_SIZE;
	localparam	int	WAY_WIDTH	= $clog2(N_WAY);
	//NOTE : SRAM Read returns data after 1 cycle.
	logic		[IDX_SIZE-1:0]		raddr;
	logic					rden;
	logic					rdata_valid[N_WAY];
	logic		[1:0]			rdata_type[N_WAY];
	logic		[31:0]			rdata_syn[N_WAY];
	logic		[TAG_SIZE-1:0]		rdata_tag[N_WAY];
	logic		[14:0]			rdata_cnt[N_WAY];
	logic		[271:0]			rdata_data[N_WAY];

	//NOTE : SRAM Write returns data after 1 cycle.
	logic		[IDX_SIZE-1:0]		waddr;
	logic					wren;
	logic		[1:0]			wdata_type;
	logic		[31:0]			wdata_syn;
	logic		[TAG_SIZE-1:0]		wdata_tag;
	logic		[14:0]			wdata_cnt;
	logic		[271:0]			wdata_data;
	logic		[WAY_WIDTH-1:0]		wdata_line;

	modport sram_rd(
		input	raddr, rden,
		output	rdata_valid, rdata_type, rdata_syn, rdata_tag, rdata_cnt, rdata_data
	);

	modport sram_wr(
		input	waddr, wren, wdata_type, wdata_syn, wdata_tag, wdata_cnt, wdata_data, wdata_line
	);

	modport drc_rd(
		output	raddr, rden,
		input	rdata_valid, rdata_type, rdata_syn, rdata_tag, rdata_cnt, rdata_data
	);

	modport drc_wr(
		output	waddr, wren, wdata_type, wdata_syn, wdata_tag, wdata_cnt, wdata_data, wdata_line
	);
	
endinterface	

