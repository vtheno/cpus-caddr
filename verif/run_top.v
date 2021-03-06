// run-top.v
// fpga test bench

`timescale 1ns / 1ns

`include "ram_s3board.v"
`include "ide_disk.v"
   
module run_top;

   // Inputs
   reg rs232_rxd;
   reg [3:0] button;
   reg 	     sysclk;
   reg 	     ps2_clk;
   reg 	     ps2_data;
   reg [7:0] slideswitch;

   // Outputs
   wire      rs232_txd;
   wire [7:0] led;
   wire       vga_red;
   wire       vga_blu;
   wire       vga_grn;
   wire       vga_hsync;
   wire       vga_vsync;
   wire [7:0] sevenseg;
   wire [3:0] sevenseg_an;
   wire [17:0] sram_a;
   wire        sram_oe_n;
   wire        sram_we_n;
   wire        sram1_ce_n;
   wire        sram1_ub_n;
   wire        sram1_lb_n;
   wire        sram2_ce_n;
   wire        sram2_ub_n;
   wire        sram2_lb_n;
   wire        ide_dior;
   wire        ide_diow;
   wire [1:0]  ide_cs;
   wire [2:0]  ide_da;

   // Bidirs
   wire [15:0] sram1_io;
   wire [15:0] sram2_io;
   wire [15:0] ide_data_bus;

   // Instantiate the Unit Under Test (UUT)
   top uut (
	    .rs232_txd(rs232_txd), 
	    .rs232_rxd(rs232_rxd), 
	    .button(button), 
	    .led(led), 
	    .sysclk(sysclk), 
	    .ps2_clk(ps2_clk), 
	    .ps2_data(ps2_data), 
	    .vga_red(vga_red), 
	    .vga_blu(vga_blu), 
	    .vga_grn(vga_grn), 
	    .vga_hsync(vga_hsync), 
	    .vga_vsync(vga_vsync), 
	    .sevenseg(sevenseg), 
	    .sevenseg_an(sevenseg_an), 
	    .slideswitch(slideswitch), 
	    .sram_a(sram_a), 
	    .sram_oe_n(sram_oe_n), 
	    .sram_we_n(sram_we_n), 
	    .sram1_io(sram1_io), 
	    .sram1_ce_n(sram1_ce_n), 
	    .sram1_ub_n(sram1_ub_n), 
	    .sram1_lb_n(sram1_lb_n), 
	    .sram2_io(sram2_io), 
	    .sram2_ce_n(sram2_ce_n), 
	    .sram2_ub_n(sram2_ub_n), 
	    .sram2_lb_n(sram2_lb_n), 
	    .ide_data_bus(ide_data_bus), 
	    .ide_dior(ide_dior), 
	    .ide_diow(ide_diow), 
	    .ide_cs(ide_cs), 
	    .ide_da(ide_da)
	    );


   // shared data bus
   wire [15:0] sram1_in;
   wire [15:0] sram2_in;

   wire [15:0] sram1_out;
   wire [15:0] sram2_out;
   
   assign sram1_in = sram1_io;
   assign sram1_io = sram_oe_n ? 16'bz : sram1_out;
		    
   assign sram2_in = sram2_io;
   assign sram2_io = sram_oe_n ? 16'bz : sram2_out;

   ram_s3board ram(
		   .ram_a(sram_a),
		   .ram_oe_n(sram_oe_n),
		   .ram_we_n(sram_we_n),
		   .ram1_in(sram1_in),
		   .ram1_out(sram1_out),
		   .ram1_ce_n(sram1_ce_n),
		   .ram1_ub_n(sram1_ub_n),
		   .ram1_lb_n(sram1_lb_n),
		   .ram2_in(sram2_in),
		   .ram2_out(sram2_out),
		   .ram2_ce_n(sram2_ce_n),
		   .ram2_ub_n(sram2_ub_n),
		   .ram2_lb_n(sram2_lb_n)
		   );


   wire [15:0] ide_data_in;
   wire [15:0] ide_data_out;

   assign ide_data_in = ide_data_bus;
   assign ide_data_bus = ide_dior ? 16'bz : ide_data_out;
   
   ide_disk ide(
		.ide_data_in(ide_data_in),
		.ide_data_out(ide_data_out),
		.ide_dior(ide_dior),
		.ide_diow(ide_diow),
		.ide_cs(ide_cs),
		.ide_da(ide_da)
		);

   initial begin
      // Initialize Inputs
      rs232_rxd = 0;
      button = 0;
      sysclk = 0;
      ps2_clk = 0;
      ps2_data = 0;
      slideswitch = 0;

      // Wait 100 ns for global reset to finish
      #100;

`ifdef test_reset_button
      #22000;
      button = 4'b1000;
      #2000000;
      button = 4'b0000;
      #100000;
      button = 4'b1000;
      #2000000;
      button = 4'b0000;
`endif
   end
   
   // 50mhz clock
   always
     begin
	#10 sysclk = 0;
	#10 sysclk = 1;
     end

endmodule

