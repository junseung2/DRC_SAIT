module DRC_TAG_COMPARATOR
#(
	parameter	int		N_WAY = 4,
	parameter	int		TAG_SIZE = 20,
	parameter	int 		IDX_SIZE = 4,
	parameter	int		WAY_WIDTH = 2
)
(
	input	wire			clk,
	input	wire			rst_n,
	
	input	wire	[TAG_SIZE-1:0]	tag_i,
	input	wire	[IDX_SIZE-1:0]	index_i,

	input	wire			rdata_valid_i[N_WAY],
	input	wire	[TAG_SIZE:0]	rdata_tag_i[N_WAY],

	input	wire			host_we_i,
	input	wire	[271:0]		host_data_i,
	input	wire			host_valid_i,
	
	input	wire	[31:0]		ecc_syndrome_i,
	input	wire	[271:0]		ecc_data_i,
	input	wire	[7:0]		ecc_err_i,
	input	wire			ecc_valid_i,


	output	wire	[TAG_SIZE-1:0]	tag_delayed_o,
	output	wire	[IDX_SIZE-1:0]	index_delayed_o,
	output	wire	[271:0]		data_delayed_o,
	output	wire	[31:0]		syndrome_delayed_o,
	output	wire	[7:0]		err_delayed_o,

	output	wire			hit_o,
	output	wire	[WAY_WIDTH-1:0]	hit_way_o,
	output	wire			we_o,
	output	wire			ecc_o
);

	logic	[TAG_SIZE-1:0]		delayed_tag;
	logic	[IDX_SIZE-1:0]		delayed_index;
	logic	[271:0]			delayed_data;
	logic	[31:0]			delayed_syndrome;
	logic	[7:0]			delayed_err;
	
	logic				hit;
	logic	[WAY_WIDTH-1:0]		hit_way;
	logic				we;
	logic				ecc;
	
	logic	[271:0]			data_i;
	
	always @(posedge clk) begin
		if(!rst_n) begin
			delayed_tag	<={(TAG_SIZE){1'b0}};
			delayed_index	<={(IDX_SIZE){1'b0}};
			delayed_data	<=272'b0;
			delayed_syndrome<=32'b0;
			delayed_err	<=8'b0;
		end
		else begin
			delayed_tag	<=tag_i;
			delayed_index	<=index_i;
			delayed_data	<=data_i;
			delayed_syndrome<=ecc_syndrome_i;
			delayed_err	<=ecc_err_i;
		end
	end
	always_comb begin
		hit = 1'b0;
		hit_way = {WAY_WIDTH{1'b0}};
		we = 1'b0;
		ecc = 1'b0;
		if(host_valid_i | ecc_valid_i) begin
			for(integer i=0; i<N_WAY; i=i+1) begin
				if(rdata_valid_i[i] && (rdata_tag_i[i]==delayed_tag)) begin
					hit= 1'b1;
					hit_way = i;
				end
			end
		end
		if(host_valid_i & host_we_i) begin
			we = 1'b1;
		end
		if(ecc_valid_i) begin
			ecc = 1'b1;
		end
	end

	assign 	tag_delayed_o		=delayed_tag;
	assign	index_delayed_o		=delayed_index;
	assign	data_delayed_o		=delayed_data;
	assign	syndrome_delayed_o	=delayed_syndrome;
	assign	err_delayed_o		=delayed_err;

	assign  hit_o			=hit;
	assign	hit_way_o		=hit_way;
	assign	we_o			=we;
	assign	ecc_o			=ecc;
	
	assign	data_i			=(host_valid_i == 1) ? host_data_i : ecc_data_i;
endmodule
