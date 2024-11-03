module SECDED_encoder(
	input [255:0] in, 
	output wire [287:0] out
);
	genvar num;
	generate
		for(num=0; num<4; num++) begin : ch
			prim_secded_72_64_enc	ecc_encoder
			(
				.in		(in[num*64+:64]),
				.out		(out[num*72+:72])	
			);
		end
	endgenerate
endmodule
