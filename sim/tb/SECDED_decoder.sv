module SECDED_decoder(
	input [287:0] in,
	output wire [255:0] data_o,
	output wire [31:0] syndrome_o,
	output wire [7:0] err_o
);
	genvar num;
	generate
		for(num=0; num<4; num++) begin: ch
			prim_secded_72_64_dec	ecc_decoder
			(
				.in		(in[num*72+:72]),
				.d_o		(data_o[num*64+:64]),
				.syndrome_o	(syndrome_o[num*8+:8]),
				.err_o		(err_o[num*2+:2])
			);
		end
	endgenerate
endmodule
