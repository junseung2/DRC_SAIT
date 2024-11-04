module DRC_TOP_TB();
    // Number of Entries for each pseudo channel.
    parameter   N_ENTRY         = 64;
    parameter   N_WAY           = 4;
    
    localparam  N_CH            = 32;
    localparam  ADDR_SIZE       = 24;
    localparam  IDX_SIZE        = $clog2(N_ENTRY/N_WAY);
    localparam  TAG_SIZE        = ADDR_SIZE - IDX_SIZE;
    localparam  CH_WIDTH        = $clog2(N_CH);
    
    logic                   clk;
    logic                   rst_n;
    
    // DRC Inputs
    logic       [ADDR_SIZE-1:0]     addr[N_CH];
    logic                   host_we[N_CH];
    logic       [271:0]         host_data[N_CH];
    logic                   host_valid[N_CH];
    
    logic       [31:0]          ecc_syndrome[N_CH];
    logic       [255:0]         ecc_data[N_CH];
    logic       [7:0]           ecc_err[N_CH];
    logic                   ecc_valid[N_CH];
    
    // DRC Outputs
    logic       [271:0]         drc_data_o[N_CH];
    logic                   drc_hit_o[N_CH];   
    
    // PPR Outputs
    logic                   ppr_valid[N_CH];
    logic       [1:0]           ppr_type[N_CH];
    logic       [ADDR_SIZE-1:0]     ppr_addr[N_CH];

     // PPR Signals
    logic                   ppr_cmd_i;
    logic       [1:0]           ppr_type_o;
    logic       [ADDR_SIZE-1:0]     ppr_addr_o;
    logic       [CH_WIDTH-1:0]  ppr_ch_o;
    logic                   ppr_done_o;
    
    // //PPR Testbench
    // logic       [1:0]       ppr_type_buffer[N_CH][NUM_ITER];
    // logic       [ADDR_SIZE-1:0] ppr_addr_buffer[N_CH][NUM_ITER];
    // logic       [CH_WIDTH-1:0] ppr_ch_buffer[N_CH][NUM_ITER];
    // logic       [$clog2(NUM_ITER)-1:0] ppr_buffer_index[N_CH];
    // SRAM Interface
    SRAM_IF     #(N_ENTRY, N_WAY)    sram_if[N_CH]();
    
    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Reset Generation
    initial begin
        rst_n = 1;
        #10;
        rst_n = 0;
        #10;
        rst_n = 1;
    end
    
    // Test Scenario
    initial begin
        // Wait until reset is de-asserted
        wait(rst_n == 0);
        @(posedge clk);
    
        // Initialize all signals
        for (int i = 0; i < N_CH; i++) begin
            addr[i] = '0;
            host_we[i] = 0;
            host_data[i] = '0;
            host_valid[i] = 0;
            ecc_syndrome[i] = '0;
            ecc_data[i] = '0;
            ecc_err[i] = '0;
            ecc_valid[i] = 0;
            // ppr_buffer_index[i] = '0;
        end
        ppr_cmd_i   = 0;
    
        // // Wait for a few cycles
        repeat (2) @(posedge clk);
    
        // Perform test scenario for each channel
        for (int ch = 0; ch < N_CH; ch++) begin
            fork
                // Independent test scenario for each channel
                automatic int ch_idx = ch;
                begin
    
                    // **1. ECC Error Handling Test**
                    addr[ch_idx] = 24'h000200 + ch_idx;
                    ecc_syndrome[ch_idx] = 32'h00000001; // Single-bit error syndrome
                    ecc_err[ch_idx] = 8'b01010101; // Single-bit error indicator
                    ecc_data[ch_idx] = {272{1'b0}} | ch_idx; // Generate data using channel index
                    ecc_valid[ch_idx] = 1;
                    @(posedge clk);
                    ecc_valid[ch_idx] = 0;
    
                    // if(ppr_valid[ch_idx]==1'b1) begin
                    //     ppr_addr_buffer[ch_idx][ppr_buffer_index[ch_idx]] = ppr_addr[ch_idx];
                    //     ppr_type_buffer[ch_idx][ppr_buffer_index[ch_idx]] = ppr_type[ch_idx];
                    //     ppr_ch_buffer[ch_idx][ppr_buffer_index[ch_idx]] = ch_idx;
                    //     ppr_buffer_index[ch_idx] = ppr_buffer_index[ch_idx] + 1;
                    // end
                    // Wait for DRC and SRAM to handle error
                    repeat (10) @(posedge clk);
    
                    // **2. Host Read After Error Handling Test**
                    host_we[ch_idx] = 0;
                    host_valid[ch_idx] = 1;
                    @(posedge clk);
                    host_valid[ch_idx] = 0;
    
                    // Wait for DRC and SRAM to return data
                    repeat (10) @(posedge clk);
    
                    if (drc_hit_o[ch_idx]) begin
                        $display("Channel %0d: Host read after error handling success: Address %h", ch_idx, addr[ch_idx]);
                    end else begin
                        $display("Channel %0d: Host read after error handling failed: Cache miss occurred", ch_idx);
                    end

                    repeat (10) @(posedge clk);
                    // **3. PPR Request Generation and Testing**
                    // Simulate PPR request due to uncorrectable error
                
                end
            join
        end
        
        
        // repeat (10) @(posedge clk);
        ppr_cmd_i   = 1;
        for(int index = 0 ; index<256; index++)begin
            @(posedge clk);
            $display("Channel %0d have ADDR: %0h, Type: %0d error",ppr_ch_o,ppr_addr_o,ppr_type_o);
            if(ppr_done_o) break;
        end


        // for(int ch = 0 ; ch < N_CH ; ch++)begin
        //     for(int index=0 ; index<ppr_buffer_index[ch];index++) begin
        //         if((ppr_addr_o == ppr_addr_buffer[ch][index]) && (ppr_type_o == ppr_type_buffer[ch][index]) && (ppr_ch_o == ppr_ch_buffer[ch][index])) begin
        //             ppr_hit++;
        //             break;
        //         end
        //     end
        //     ppr_write = ppr_write + ppr_buffer_index[ch]; //SRAM에서 시도한 PPR에 적으려고 한 횟수
        // end
        
        // ppr_hit_rate = ppr_hit / ppr_write;

        // // Wait for PPR module to process the request
        // wait (ppr_done_o);

        // // Check if outputs match the inputs
        // if (ppr_type_o == ppr_type[ch_idx] && ppr_addr_o == ppr_addr[ch_idx] && ppr_ch_o == ch_idx) begin
        //     $display("Channel %0d: PPR processed correctly. Type: %0d, Address: %h", ch_idx, ppr_type_o, ppr_addr_o);
        // end 
        // else begin
        //     $display("Channel %0d: PPR processing error. Type: %0d, Address: %h", ch_idx, ppr_type_o, ppr_addr_o);
        // end
        // Wait for all tests to complete
        #1000;
        $finish;
    end
    
    // Module Instantiations
    genvar ch;
    generate
        for(ch = 0; ch < N_CH; ch++) begin : channel
            DRC_TOP
            #(
                .N_WAY      (N_WAY),
                .ADDR_SIZE  (ADDR_SIZE),
                .IDX_SIZE   (IDX_SIZE),
                .TAG_SIZE   (TAG_SIZE)
            ) u_drc
            (
                .clk        (clk),
                .rst_n      (rst_n),  
                .addr_i     (addr[ch]),
    
                .host_we_i  (host_we[ch]),
                .host_data_i    (host_data[ch]),
                .host_valid_i   (host_valid[ch]),
    
                .ecc_syndrome_i (ecc_syndrome[ch]),
                .ecc_data_i ({ecc_data[ch],16'b0}),
                .ecc_err_i  (ecc_err[ch]),
                .ecc_valid_i    (ecc_valid[ch]),
    
                .drc_data_o     (drc_data_o[ch]),
                .drc_hit_o  (drc_hit_o[ch]),
                
                .drc_rd_if  (sram_if[ch].drc_rd),
                .drc_wr_if  (sram_if[ch].drc_wr)
            );
            SRAM_6T_ARRAY
            #(
                .N_WAY      (N_WAY),
                .ADDR_SIZE  (ADDR_SIZE),
                .IDX_SIZE   (IDX_SIZE),
                .TAG_SIZE   (TAG_SIZE)
            ) u_sram
            (
                .clk        (clk),
                .rst_n      (rst_n),
                
                .ppr_valid_o    (ppr_valid[ch]),
                .ppr_type_o     (ppr_type[ch]),
                .ppr_addr_o     (ppr_addr[ch]),
                
                .sram_rd_if     (sram_if[ch].sram_rd),
                .sram_wr_if     (sram_if[ch].sram_wr)
            );
        end
    endgenerate
    
    // PPR Module Instantiation
    PPR
    #(
        .N_CH       (N_CH),
        .ADDR_SIZE  (ADDR_SIZE),
        .CH_WIDTH   (CH_WIDTH)
    ) u_ppr
    (
        .clk        (clk),
        .rst_n      (rst_n),
    
        .ppr_valid_i    (ppr_valid),
        .ppr_type_i     (ppr_type),
        .ppr_addr_i     (ppr_addr),
    
        .ppr_cmd_i      (ppr_cmd_i),
    
        .ppr_type_o     (ppr_type_o),
        .ppr_addr_o     (ppr_addr_o),
        .ppr_ch_o       (ppr_ch_o),
        
        .ppr_done_o     (ppr_done_o)
    );
endmodule
