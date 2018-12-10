///////////////////////////////////////////////////////////////////////////////
// $Id: testbench.v 1887 2007-06-19 21:33:32Z grg $
//
// Testbench: testbench
// Project: CPCI (PCI Control FPGA)
// Description: Tests the reg_file module
//
// Change history:
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ns

module testbench ( );

// ==================================================================
// Constants
// ==================================================================

parameter Tpclk = 15;
parameter Tnclk = 8;
parameter Trst = 100;


reg pclk, nclk;

wire [31:0] AD;
wire  [3:0] CBE;
wire        PAR;
tri1        FRAME_N;
tri1        TRDY_N;
tri1        IRDY_N;
tri1        STOP_N;
tri1        DEVSEL_N;
tri1        INTR_A;
wire        RST_N;

// PCI ports from pci_top as generated by CoreGen
wire        IDSEL;
tri1        PERR_N;
tri1        SERR_N;
tri1        REQ_N;
tri1        GNT_N;

wire         cnet_reset;    // Reset signal to CNET
wire         phy_int_b;     // Interrupt signal from PHY

wire         cpci_rd_wr_L;  // Read/Write signal
wire         cpci_req;      // I/O request signal
wire [`CPCI_CNET_ADDR_WIDTH-1:0] cpci_addr;
wire [`CPCI_CNET_DATA_WIDTH-1:0] cpci_data;
wire         cpci_wr_rdy;   // Write ready from CNET
wire         cpci_rd_rdy;   // Read ready from CNET
wire [3:0]   cpci_tx_full;  // Indicates whether each MAC can
// accept a full-sized packet
wire         cnet_err;      // Error signal from CNET

wire [3:0]   cpci_dma_pkt_avail; // Packets waiting from MACs
wire [3:0]   cpci_dma_send; // Request next packet from MACs
wire         cpci_dma_wr_en; // Write stobe
wire [`CPCI_CNET_DATA_WIDTH-1:0] cpci_dma_data;
wire         cpci_dma_nearly_full;

// Reprogramming signals
wire         rp_cclk;
wire         rp_prog_b;
wire         rp_init_b;
wire         rp_cs_b;
wire         rp_rdwr_b;
wire [7:0]   rp_data;
wire         rp_done;

// Debug signals
wire         cpci_led;
wire [31:0]  cpci_debug_data;
wire [1:0]   cpci_debug_clk;

// Reserved for future use
wire [19:0]  cpci_cnet_rsvd;

// ==================================================================
// Generate a clock signal
// ==================================================================

always
begin
   pclk <= 1'b1;
   #Tpclk;
   pclk <= 1'b0;
   #Tpclk;
end

always
begin
   nclk <= 1'b1;
   #Tnclk;
   nclk <= 1'b0;
   #Tnclk;
end

//******************************************************************//
// Generate a reset signal for use by the module.  The nominal      //
// duration of the initial reset is Trst.                           //
//******************************************************************//


reg           rst;

initial
begin
   rst <= 1'b1;
   #Trst;
   rst <= 1'b0;
end


// ==================================================================
// Instantiate the CPCI module
// ==================================================================

cpci_top cpci_top(
            .AD (AD),
            .CBE (CBE),
            .PAR (PAR),
            .FRAME_N (FRAME_N),
            .TRDY_N (TRDY_N),
            .IRDY_N (IRDY_N),
            .STOP_N (STOP_N),
            .DEVSEL_N (DEVSEL_N),
            .IDSEL (IDSEL),
            .INTR_A (INTR_A),
            .PERR_N (PERR_N),
            .SERR_N (SERR_N),
            .REQ_N (REQ_N),
            .GNT_N (GNT_N),
            .RST_N (RST_N),
            .PCLK (pclk),
            .nclk (nclk),
            .cnet_reset (cnet_reset),
            .phy_int_b (phy_int_b),
            .cpci_rd_wr_L (cpci_rd_wr_L),
            .cpci_req (cpci_req),
            .cpci_addr (cpci_addr),
            .cpci_data (cpci_data),
            .cpci_wr_rdy (cpci_wr_rdy),
            .cpci_rd_rdy (cpci_rd_rdy),
            .cpci_tx_full (cpci_tx_full),
            .cnet_err (cnet_err),
            .cpci_dma_pkt_avail (cpci_dma_pkt_avail),
            .cpci_dma_send (cpci_dma_send),
            .cpci_dma_wr_en (cpci_dma_wr_en),
            .cpci_dma_data (cpci_dma_data),
            .cpci_dma_nearly_full (cpci_dma_nearly_full),
            .rp_cclk (rp_cclk),
            .rp_prog_b (rp_prog_b),
            .rp_init_b (rp_init_b),
            .rp_cs_b (rp_cs_b),
            .rp_rdwr_b (rp_rdwr_b),
            .rp_data (rp_data),
            .rp_done (rp_done),
            .cpci_led (cpci_led),
            .cpci_debug_data (cpci_debug_data),
            .cpci_debug_clk (cpci_debug_clk),
            .cpci_cnet_rsvd (cpci_cnet_rsvd)
          );

// ==================================================================
// Instantiate the "CNET"
// ==================================================================

cnet cnet(
            .cpci_rd_wr_L (cpci_rd_wr_L),
            .cpci_req (cpci_req),
            .cpci_addr (cpci_addr),
            .cpci_data (cpci_data),
            .cpci_wr_rdy (cpci_wr_rdy),
            .cpci_rd_rdy (cpci_rd_rdy),
            .cpci_dma_pkt_avail (cpci_dma_pkt_avail),
            .cpci_dma_send (cpci_dma_send),
            .cpci_dma_wr_en (cpci_dma_wr_en),
            .cpci_dma_data (cpci_dma_data),
            .cpci_dma_nearly_full (cpci_dma_nearly_full),
            .rp_prog_b (rp_prog_b),
            .rp_init_b (rp_init_b),
            .rp_cs_b (rp_cs_b),
            .rp_rdwr_b (rp_rdwr_b),
            .rp_data (rp_data),
            .rp_done (rp_done),
            .rp_cclk (rp_cclk),
            .cnet_err (cnet_err),
            .want_crc_error (want_crc_error),
            .reset (cnet_reset),
            .clk (nclk)
         );


// ==================================================================
// Instantiate the host
// ==================================================================

host32 CPU (
            .AD (AD),
            .CBE (CBE),
            .PAR (PAR),
            .FRAME_N (FRAME_N),
            .TRDY_N (TRDY_N),
            .IRDY_N (IRDY_N),
            .STOP_N (STOP_N),
            .DEVSEL_N (DEVSEL_N),
            .INTR_A (INTR_A),
            .RST_N (RST_N),
            .CLK (pclk)
         );

// ==================================================================
// Instantiate other modules
// ==================================================================

target32 TRG (
            .AD (AD),
            .CBE (CBE),
            .PAR (PAR),
            .FRAME_N (FRAME_N),
            .TRDY_N (TRDY_N),
            .IRDY_N (IRDY_N),
            .STOP_N (STOP_N),
            .DEVSEL_N (DEVSEL_N),
            .RST_N (RST_N),
            .CLK (pclk)
         );

assign IDSEL = AD[16];
assign GNT_N = REQ_N;
assign RST_N = !rst;

assign cnet_err = 1'b0;
assign phy_int_b = 1'b1;

//initial
//#1000 $finish;
endmodule // testbench

/* vim:set shiftwidth=3 softtabstop=3 expandtab: */
