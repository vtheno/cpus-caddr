/*
 * $Id$
 */

/* 1kx32 synchronous static ram */

module part_1kx32ram_sync_a(CLK, A, DI, DO, CE_N, WE_N);

   input CLK;
   input [9:0] A;
   input [31:0] DI;
   input CE_N, WE_N;
   output reg [31:0] DO;

   reg [31:0] ram [0:1023];

  integer i;

  initial
    begin
      for (i = 0; i < 1024; i=i+1)
        ram[i] = 32'b0;
    end

   always @(posedge CLK)
     if (~CE_N && ~WE_N)
       begin
          ram[ A ] <= DI;
//	  if (A != 0)
//	  $display("     amem: W %t addr %o val 0x%x", $time, A, ram[ A ]);
       end

   always @(posedge CLK)
     if (~CE_N)
       begin
	  DO <= ram[ A ];
//	  if (A != 0)
//	  $display("     amem: R %t addr %o val 0x%x", $time, A, ram[ A ]);
       end

endmodule

/* 1kx32 asynchronous static ram */

module part_1kx32ram_async(A, DI, DO, CE_N, WE_N);

  input[9:0] A;
  input[31:0] DI;
  input CE_N, WE_N;
  output[31:0] DO;

  reg[31:0] ram [0:1023];

  integer i;

  initial
    begin
      for (i = 0; i < 1024; i=i+1)
        ram[i] = 32'b0;
    end

// I really want negedge(WE_N) + some time
//  always @(posedge WE_N)
always @(negedge WE_N)
    begin
      if (CE_N == 0)
        begin
          ram[ A ] = DI;
	   $display("pdl: W %t addr %o val %o", $time, A, DI);
        end
    end

  assign DO = ram[ A ];

  always @(A)
    begin
       $display("pdl: R %t addr %o val %o, CE_N %d", $time, A, ram[A], CE_N);
    end

endmodule

module part_1kx32ram_sync_p(CLK, A, DI, DO, CE_N, WE_N);

  input CLK;
  input [9:0] A;
  input [31:0] DI;
  input CE_N, WE_N;
  output reg [31:0] DO;

  reg[31:0] ram [0:1023];

  integer i;

  initial
    begin
      for (i = 0; i < 1024; i=i+1)
        ram[i] = 32'b0;
    end

   always @(posedge CLK)
     if (~CE_N && ~WE_N)
        begin
           ram[ A ] = DI;
	   $display("pdl: W %t addr %o val %o", $time, A, DI);
        end

   always @(posedge CLK)
     if (~CE_N)
       begin
	  DO <= ram[ A ];
	  if (A != 0)
	  $display("pdl: R %t addr %o val %o", $time, A, ram[A]);
       end

endmodule

/* 2kx5 static ram */

module part_2kx5ram_async(A, DI, DO, CE_N, WE_N);

  input[10:0] A;
  input[4:0] DI;
  input CE_N, WE_N;
  output[4:0] DO;

  reg[4:0] ram [0:2047];

  integer i;

  initial
    begin
      for (i = 0; i < 2048; i=i+1)
        ram[i] = 5'b0;
    end

  always @(/*posedge*/WE_N)
    begin
      if (CE_N == 0 && WE_N == 0)
        begin
          ram[ A ] = DI;
	   $display("vmem0: W %t addr %o <- val %o", $time, A, ram[ A ]);
        end
    end

  assign DO = ram[ A ];

endmodule

module part_2kx5ram_sync(CLK, A, DI, DO, CE_N, WE_N);

  input CLK;
  input [10:0] A;
  input [4:0] DI;
  input CE_N, WE_N;
  output reg [4:0] DO;

  reg[4:0] ram [0:2047];

  integer i;

  initial
    begin
      for (i = 0; i < 2048; i=i+1)
        ram[i] = 5'b0;
    end

   always @(posedge CLK)
     if (~CE_N && ~WE_N)
        begin
          ram[ A ] = DI;
	   $display("vmem0: W %t addr %o <- val %o", $time, A, ram[ A ]);
        end

   always @(posedge CLK)
     if (~CE_N)
       begin
	  DO <= ram[ A ];
       end

endmodule

/* 1kx24 asynchronous static ram */

module part_1kx24ram_async(A, DI, DO, CE_N, WE_N);

  input[9:0] A;
  input[23:0] DI;
  input CE_N, WE_N;
  output[23:0] DO;

  reg[23:0] ram [0:1023];

  integer i;

  initial
    begin
      for (i = 0; i < 1024; i=i+1)
        ram[i] = 24'b0;
    end

  always @(/*posedge*/WE_N)
    begin
      if (CE_N == 0 && WE_N == 0)
        begin
           ram[ A ] = DI;
	   $display("vmem1: W %t addr %o <- val %o (async)",
		    $time, A, ram[ A ]);
        end
    end

  assign DO = ram[ A ];

always @(A)
  begin
    $display("vmem1: R %t addr %o -> val %o", $time, A, ram[ A ]);
  end

endmodule

module part_1kx24ram_sync(CLK, A, DI, DO, CE_N, WE_N);

   input CLK;
   input [9:0] A;
   input [23:0] DI;
   input CE_N, WE_N;
   output reg [23:0] DO;

   reg [23:0] ram [0:1023];

   integer i;

   initial
     begin
	for (i = 0; i < 1024; i=i+1)
          ram[i] = 24'b0;
     end

   always @(posedge CLK)
     if (~CE_N && ~WE_N)
       begin
          ram[ A ] <= DI;
	  $display("vmem1: W %t addr %o <- val %o (sync)", $time, A, ram[ A ]);
       end

   always @(posedge CLK)
     if (~CE_N)
       begin
	  DO <= ram[ A ];
       end

endmodule



/* 2kx17 asynchronous static ram */

module part_2kx17ram(A, DI, DO,	CE_N, WE_N);

  input[10:0] A;
  input[16:0] DI;
  input CE_N, WE_N;
  output[16:0] DO;

  reg[16:0] ram [0:2047];

  integer i;

  initial
    begin
      for (i = 0; i < 2048; i=i+1)
        ram[i] = 17'b0;
    end

  always @(posedge WE_N)
    begin
      if (CE_N == 0)
          ram[ A ] = DI;
    end

//  assign DO = ram[ A ];
assign DO = (^A === 1'bX || A === 1'bz) ? 17'b0 : ram[A];

endmodule

/* 32x32 synchronous static ram */

module part_32x32ram_sync(CLK, A, DI, DO, CE_N, WE_N);

   input[4:0] A;
   input [31:0] DI;
   input CLK, WE_N, CE_N;
   output reg [31:0] DO;

   reg [31:0] ram [0:31];

   integer index;

   initial
    begin
      for (index = 0; index < 32; index=index+1)
        ram[index] = 32'b0;
    end

   always @(posedge CLK)
    if (~CE_N && ~WE_N)
     begin
	ram[ A ] = DI;
//	if (A != 0)
//	$display("     mmem: W %t addr %o val 0x%x", $time, A, ram[ A ]);
     end

   always @(A)
     begin
	DO <= ram[ A ];
//	if (A != 0)
//	$display("     mmem: R %t addr %o val 0x%x", $time, A, ram[ A ]);
     end
   
endmodule

module part_32x32ram(A, DI, DO, WCLK_N, CE, WE_N);

   input[4:0] A;
   input [31:0] DI;
   input WE_N, WCLK_N, CE;
   output reg [31:0] DO;

   reg [31:0] ram [0:31];

   integer index;

   initial
    begin
      for (index = 0; index < 32; index=index+1)
        ram[index] = 32'b0;
    end

   always @(posedge WCLK_N)
     begin
	if (CE == 1 && WE_N == 0)
	  begin
	     ram[ A ] = DI;
	     //$display("     mmem: W %t addr %o val 0x%x", $time, A, ram[ A ]);
	  end
     end

   always @(A)
     begin
	DO <= ram[ A ];
	//$display("     mmem: R %t addr %o val 0x%x", $time, A, ram[ A ]);
     end
   
endmodule

/* 32x19 synchronous static ram */

module part_32x19ram_sync(CLK, A, DI, DO, WE_N, CE_N);

   input [4:0] A;
   input [18:0] DI;
   input WE_N, CLK, CE_N;
   output reg [18:0] DO;

   reg [18:0] ram [0:31];

   initial
     begin
	ram[ 5'b00000 ] = 19'b0;
	ram[ 5'b11111 ] = 19'b0;
     end

   always @(posedge CLK)
     if (~CE_N && ~WE_N)
       begin
	  ram[ A ] = DI;
	  if (A != 0)
	    $display("spc: W %t addr %o val %o", $time, A, DI);
       end

   always @(posedge CLK)
     begin
	DO <= ram[ A ];
	if (A != 0)
	  $display("spc: R %t addr %o val %o", $time, A, ram[ A ]);
     end

endmodule

module part_32x19ram(A, DI, DO, WCLK_N, WE_N, CE);

   input [4:0] A;
   input [18:0] DI;
   input WE_N, WCLK_N, CE;
   output reg [18:0] DO;

   reg [18:0] ram [0:31];

   initial
     begin
	ram[ 5'b00000 ] = 19'b0;
	ram[ 5'b11111 ] = 19'b0;
     end

  always @(posedge WCLK_N)
     begin
	if (CE == 1 && WE_N == 0)
	  ram[ A ] = DI;
     end

   always @(A)
     DO <= ram[ A ];

endmodule

/* 16k49 sram */

module part_16kx49ram(A, DI, DO, CE_N, WE_N);

  input[13:0] A;
  input[48:0] DI;
  input CE_N, WE_N;
  output[48:0] DO;

//temp
//assign DO = 0;

  reg[48:0] ram [0:16383];

  integer i;
  initial
    begin
      for (i = 0; i < 16384; i=i+1)
        ram[i] = 49'b0;
    end

  always @(posedge WE_N)
    begin
      if (CE_N == 0)
	begin
           ram[ A ] = DI;
	   $display("iram: W %t addr %o val %o", $time, A, DI);
	end
    end

  assign DO = ram[ A ];

//always @(A)
//  begin
//    $display("iram: %t addr %o val 0x%x, CE_N %d", $time, A, ram[ A ], CE_N);
//  end

endmodule
