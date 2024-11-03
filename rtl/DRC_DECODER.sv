module DRC_DECODER
#(
	parameter	int			ADDR_SIZE = 24,
	parameter	int			TAG_SIZE = 20,
	parameter	int			IDX_SIZE = 4
)
(
	input		wire	[ADDR_SIZE-1:0]	addr_i,

	output		wire	[TAG_SIZE-1:0]	tag_o,
	output		wire	[IDX_SIZE-1:0]	index_o
);
	assign		tag_o	= addr_i[TAG_SIZE-1:0];
	assign		index_o	= addr_i[ADDR_SIZE-1:TAG_SIZE];
	
endmodule
