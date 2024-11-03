module	PPR
#(
	parameter	int		N_CH		= 32,
	parameter	int		ADDR_SIZE	= 24
)
(
	input	wire			clk,
	input	wire			rst_n,
	input	wire			ppr_valid_i[N_CH],
	input	wire	[1:0]		ppr_type_i[N_CH],
	input	wire	[ADDR_SIZE-1:0]	ppr_addr_i[N_CH],

	input	wire			ppr_cmd_i,

	output	wire			ppr_type_o,
	output	wire			ppr_addr_o,
	output	wire			ppr_ch_o,

	output	wire			ppr_done_o
);
	localparam	int		PPR_SIZE	= 256;
	localparam	int		CH_WIDTH	= $clog2(N_CH);
	localparam	int		PPR_DEPTH	= $clog2(PPR_SIZE);

	logic				ppr_valid_buffer[PPR_SIZE];
	logic		[1:0]		ppr_type_buffer[PPR_SIZE];
	logic		[ADDR_SIZE-1:0]	ppr_addr_buffer[PPR_SIZE];
	logic		[CH_WIDTH-1:0]	ppr_ch_buffer[PPR_SIZE];

	logic		[PPR_DEPTH-1:0]	ppr_index, ppr_index_n;

	logic				ppr_cmd, ppr_cmd_n;
	logic				ppr_done;
	always @(posedge clk) begin
		if(!rst_n) begin
			for(integer index=0; index<PPR_SIZE; index=index+1) begin
				ppr_valid_buffer[index]=1'b0;
				ppr_type_buffer[index]=2'b0;
				ppr_addr_buffer[index]={(ADDR_SIZE){1'b0}};
				ppr_ch_buffer[index]={(CH_WIDTH){1'b0}};
				ppr_index = {(PPR_DEPTH){1'b0}};
			end
		end
		else begin
			ppr_index = ppr_index_n;
			ppr_cmd = ppr_cmd_n;
			for(integer ch=0; ch<N_CH; ch=ch+1) begin
				if(ppr_valid_i[ch]) begin
					ppr_valid_buffer[ppr_index] <= 1'b1;
					ppr_type_buffer[ppr_index] <= ppr_type_i[ch];
					ppr_addr_buffer[ppr_index] <= ppr_addr_i[ch];
					ppr_ch_buffer[ppr_index] <= ch;
				end
			end
		end
	end
	always_comb begin
		ppr_index_n = ppr_index;
		ppr_cmd_n = ppr_cmd;
		for(integer ch=0; ch<N_CH; ch=ch+1) begin
			if(ppr_valid_i[ch]) begin
				ppr_index_n = ppr_index +1;
			end
		end
		if(ppr_cmd_i) begin
			ppr_cmd_n = 1'b1;
			ppr_index_n = {(PPR_DEPTH){1'b0}};
			if(ppr_valid_buffer[ppr_index_n] == 1'b0) begin
				ppr_cmd_n = 1'b0;
				ppr_done = 1'b1;
			end
		end
		if(ppr_cmd) begin
			ppr_index_n = ppr_index + 1;
			if(ppr_valid_buffer[ppr_index_n] == 1'b0) begin
				ppr_cmd_n = 1'b0;
				ppr_index_n = {(PPR_DEPTH){1'b0}};
				ppr_done = 1'b1;
			end
		end
	end
	assign ppr_done_o = ppr_done;
	assign ppr_type_o = ppr_type_buffer[ppr_index];
	assign ppr_addr_o = ppr_addr_buffer[ppr_index];
	assign ppr_ch_o = ppr_ch_buffer[ppr_index];
endmodule
