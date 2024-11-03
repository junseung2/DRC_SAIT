module DRC_TOP_TB();
	//Number of Entry for each pseudo channel.
	parameter	N_ENTRY			= 64;
	parameter	N_WAY			= 4;
	parameter	DRC_HIT_RATE		= 0.01;
	parameter	FAULT_RATE		= 0.001;
	parameter	ERROR_RATE		= 0.01;
	parameter	NUM_ITER		= 10000;
	
	localparam	N_CH			= 32;
	localparam	ADDR_SIZE		= 24;
	localparam	IDX_SIZE		= $clog2(N_ENTRY/N_WAY);
	localparam	TAG_SIZE		= ADDR_SIZE - IDX_SIZE;
	
	logic					clk;
	logic					rst_n;
	
	//DRC Input
	logic		[ADDR_SIZE-1:0]		addr[N_CH];

	logic					host_we[N_CH];
	logic		[271:0]			host_data[N_CH];
	//Signal related to RAS/CAS(1cycle)
	logic					host_valid[N_CH];

	logic		[31:0]			ecc_syndrome[N_CH];
	logic		[255:0]			ecc_data[N_CH];
	logic		[7:0]			ecc_err[N_CH];
	//Signal related after CL(CAS Latency)(1cycle)
	logic					ecc_valid[N_CH];

	//DRC Output(Data)
	logic		[271:0]			drc_data_o[N_CH];
	logic					drc_hit_o[N_CH];	
	
	//PPR Input
	logic					ppr_valid[N_CH];
	logic		[1:0]			ppr_type[N_CH];
	logic		[ADDR_SIZE-1:0]		ppr_addr[N_CH];
	//SRAM Interface
	SRAM_IF 	#(N_ENTRY, N_WAY)	sram_if[N_CH]
	(
			.clk			(clk),
			.rst_n			(rst_n)
	);
	
	genvar ch;
	generate
		for(ch=0; ch<N_CH; ch++) begin : channel
			SECDED_encoder	u_ecc_encoder
			(
				.in		(),
				.out		()
			);
			SECDED_decoder	u_ecc_decoder
			(
				.in		(),
				.syndrome_o	(ecc_syndrome[ch]),
				.data_o		(ecc_data[ch]),
				.err_o		(ecc_err[ch])
			);
			DRC_TOP
			#(
				.N_WAY		(N_WAY),
				.ADDR_SIZE	(ADDR_SIZE),
				.IDX_SIZE	(IDX_SIZE),
				.TAG_SIZE	(TAG_SIZE)
			) u_drc
			(
				.clk		(clk),
				.rst_n		(rst_n),	
				.addr_i		(addr[ch]),

				.host_we_i	(host_we[ch]),
				.host_data_i	(host_data[ch]),
				.host_valid_i	(host_valid[ch]),

				.ecc_syndrome_i	(ecc_syndrome[ch]),
				.ecc_data_i	({ecc_data[ch],16'b0}),
				.ecc_err_i	(ecc_err[ch]),
				.ecc_valid_i	(ecc_valid[ch]),

				.drc_data_o	(drc_data_o[ch]),
				.drc_hit_o	(drc_hit_o[ch]),
				
				.drc_rd_if	(sram_if[ch].drc_rd),
				.drc_wr_if	(sram_if[ch].drc_wr)
			);
			SRAM_6T_ARRAY
			#(
				.N_WAY		(N_WAY),
				.ADDR_SIZE	(ADDR_SIZE),
				.IDX_SIZE	(IDX_SIZE),
				.TAG_SIZE	(TAG_SIZE)
			) u_sram
			(
				.clk		(clk),
				.rst_n		(rst_n),
				
				.ppr_valid_o	(ppr_valid[ch]),
				.ppr_type_o	(ppr_type[ch]),
				.ppr_addr_o	(ppr_addr[ch]),
				
				.sram_rd_if	(sram_if[ch].sram_rd),
				.sram_wr_if	(sram_if[ch].sram_wr)
			);
		end
	endgenerate
	PPR
	#(
		.N_CH		(N_CH),
		.ADDR_SIZE	(ADDR_SIZE)
	) u_ppr
	(
		.clk		(clk),
		.rst_n		(rst_n),

		.ppr_valid_i	(ppr_valid),
		.ppr_type_i	(ppr_type),
		.ppr_addr_i	(ppr_addr),

		.ppr_cmd_i	(),

		.ppr_type_o	(),
		.ppr_addr_o	(),
		.ppr_ch_o	(),
		
		.ppr_done_o	()
	);
endmodule
