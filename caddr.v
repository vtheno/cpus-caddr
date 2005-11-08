/*
 * caddr
 * 10/2005 brad parker brad@heeltoe.com
 *
 */

`timescale 1ns / 1ns

`include "74181.v"
`include "74182.v"

module caddr;

wire[13:0] npc;
wire[13:0] dpc;
wire[13:0] ipc;
wire[18:0] spc;

reg[48:0] ir;

wire[31:0] a;
reg[31:0] latched_amem;

// page actl

reg[9:0] wadr;
reg destd, destmd;

always @(posedge CLK3)
  begin
    // wadr 9  8  7  6  5  4  3  2  1  0
    //      0  0  0  0  0  18 17 16 15 14
    // ir   23 22 21 20 19 18 17 16 15 14
    wadr = destm ? { ir[23:14] } : { 5'b0, ir[18:14] };
    destd <= dest;
    destmd <= destm;
  end

initial
    wadr = 0;

wire apass, apass_n;

assign apass = destd && ( ir[41:32] == wadr[9:0] );
assign apass_n = ! apass;

wire amemenb_n, apassenb_n, apassenb;

assign amemenb_n  = ! (apass_n & tse);
assign apassenb_n  = ! (tse & apass);
assign apassenb  = tse & apass;

wire awp_n;

// xxx we can remove this, right?
wire wp1, wp2, wp3, wp3_n, wp4, tpwp_n;
assign tpwp_n = ~tpwp;
assign wp1 = ~tpwp_n;
assign wp2 = ~tpwp_n;
assign wp3 = ~tpwp_n;
assign wp4 = ~tpwp_n;

assign awp_n = wp3 & destd;

wire[9:0] aadr;
wire[9:0] aadr_n;

assign aadr = CLK3 ? { ir[41:32] } : wadr;
assign aadr_n = ~aadr;

// page ALATCH

//xxx bus
always @( amem or CLK3 )
  if (CLK3)
    latched_amem <= amem;

assign a = amemenb_n ? l : latched_amem;

// page ALU0-1

wire[7:0] aeqm_bits;
wire aeqm;

wire[32:0] alu;

assign aeqm = aeqm_bits == { 8'b00000000 };

ic_74S181  i_ALU1_2A03 (
  .B({3'b0,a[31]}),
  .A({3'b0,m[31]}),
  .S(aluf[3:0]),
  .CIN_N(cin32_n),
  .M(alumode),
  .F({3'b0,alu[32]})
);

ic_74S181  i_ALU1_2A08 (
  .B(a[31:28]),
  .A(m[31:28]),
  .S(aluf[3:0]),
  .CIN_N(cin28_n),
  .M(alumode),
//  .F(alu[31:28]),
  .F({alu[31],alu[30],alu[29],alu[28]}),
  .AEB(aeqm_bits[7]),
  .X(xout31),
  .Y(yout31)
);

ic_74S181  i_ALU1_2B08 (
  .B(a[27:24]),
  .A(m[27:24]),
  .S(aluf[3:0]),
  .CIN_N(cin28_n),
  .M(alumode),
//  .F(alu[27:24]),
  .F({alu[27],alu[26],alu[25],alu[24]}),
  .AEB(aeqm_bits[6]),
  .X(xout27),
  .Y(yout27)
);

ic_74S181  i_ALU1_2A13 (
  .B(a[23:20]),
  .A(m[23:20]),
  .S(aluf[3:0]),
  .CIN_N(cin20_n),
  .M(alumode),
//  .F(alu[23:20]),
  .F({alu[23],alu[22],alu[21],alu[20]}),
  .AEB(aeqm_bits[5]),
  .X(xout23),
  .Y(yout23)
);

ic_74S181  i_ALU1_2B13 (
  .B(a[19:16]),
  .A(m[19:16]),
  .S(aluf[3:0]),
  .CIN_N(cin20_n),
  .M(alumode),
//  .F(alu[19:16]),
  .F({alu[19],alu[18],alu[17],alu[16]}),
  .AEB(aeqm_bits[4]),
  .X(xout19),
  .Y(yout19)
);

ic_74S181  i_ALU0_2A23 (
  .A(m[15:12]),
  .B(a[15:12]),
  .S(aluf[3:0]),
  .CIN_N(cin12_n),
  .M(alumode),
//  .F({alu[15:12]}),
  .F({alu[15],alu[14],alu[13],alu[12]}),
  .AEB(aeqm_bits[3]),
  .X(xout15),
  .Y(yout15)
);

ic_74S181  i_ALU0_2B23 (
  .A(m[11:8]),
  .B(a[11:8]),
  .S(aluf[3:0]),
  .CIN_N(cin8_n),
  .M(alumode),
//  .F(alu[11:8]),
  .F({alu[11],alu[10],alu[9],alu[8]}),
  .AEB(aeqm_bits[2]),
  .X(xout11),
  .Y(yout11)
);

ic_74S181  i_ALU0_2A28 (
  .A(m[7:4]),
  .B(a[7:4]),
  .S(aluf[3:0]),
  .CIN_N(cin4_n),
  .M(alumode),
//  .F(alu[7:4]),
  .F({alu[7],alu[6],alu[5],alu[4]}),
  .AEB(aeqm_bits[1]),
  .X(xout7),
  .Y(yout7)
);

ic_74S181  i_ALU0_2B28 (
  .A(m[3:0]),
  .B(a[3:0]),
  .S(aluf[3:0]),
  .CIN_N(cin0_n),
  .M(alumode),
//  .F(alu[3:0]),
  .F({alu[3],alu[2],alu[1],alu[0]}),
  .AEB(aeqm_bits[0]),
  .X(xout3),
  .Y(yout3)
);

// page ALUC4

ic_74S182  i_ALUC4_2A20 (
  .Y( { yout15,yout11,yout7,yout3 } ),
  .X( { xout15,xout11,xout7,xout3 } ),
  .COUT2_N(cin12_n),
  .COUT1_N(cin8_n),
  .COUT0_N(cin4_n),
  .CIN_N(cin0_n),
  .XOUT(xx0),
  .YOUT(yy0)
);

ic_74S182  i_ALUC4_2A19 (
  .Y( { yout31,yout27,yout23,yout19 } ),
  .X( { xout31,xout27,xout23,xout19 } ),
  .COUT2_N(cin28_n),
  .COUT1_N(cin24_n),
  .COUT0_N(cin20_n),
  .CIN_N(cin16_n),
  .XOUT(xx1),
  .YOUT(yy1)
);

ic_74S182  i_ALUC4_2A18 (
  .Y( { 2'b00, yy1,yy0 } ),
  .X( { 2'b00, xx1,xx0 } ),
  .COUT1_N(cin32_n),
  .COUT0_N(cin16_n),
  .CIN_N(cin0_n)
);

wire divposlasttime_n, divsubcond, divaddcond, aluadd, alusub, mulnop_n;
wire mul_n, div_n, specalu_n;


assign divposlasttime_n  = ! (q[0] | ir[6]);
assign divsubcond = ! (div_n  | divposlasttime_n );

assign divaddcond = ! (div_n  | ! (ir[5] | divposlasttime_n ));

assign aluadd = !(mul_n & !(divsubcond & a[31]) & !(divaddcond & !a[31]));

assign mulnop_n = mul_n | q[0];

assign alusub = !(mulnop_n & !(!a[31] & divsubcond) &
	        !(divaddcond & a[31]) & irjump_n);

wire iralu;
assign iralu = ~iralu_n;

wire[1:0] osel;

assign osel[1] = ! (ir[13] & iralu);
assign osel[0] = ! (ir[12] & iralu);


wire[3:0] aluf;
wire alumode_n, cin0_n;

assign aluf =
	{aluadd,alusub} == 2'b00 ? { !ir[3], !ir[4], ir[6], ir[5] } :
	{aluadd,alusub} == 2'b01 ? { 1'b0,   1'b1,   1'b1,  1'b0 } :
	{aluadd,alusub} == 2'b10 ? { 1'b1,   1'b0,   1'b0,  1'b1 } :
	                           { 1'b0,   1'b0,   1'b0,  1'b1 };

assign alumode_n =
	{aluadd,alusub} == 2'b00 ? ir[7] :
	{aluadd,alusub} == 2'b01 ? 1'b1 :
	{aluadd,alusub} == 2'b10 ? 1'b1 :
	                           1'b0;

assign cin0_n =
	{aluadd,alusub} == 2'b00 ? !ir[2] :
	{aluadd,alusub} == 2'b01 ? 1'b1 :
	{aluadd,alusub} == 2'b10 ? irjump :
                                   1'b0;


// page AMEM0-1

wire[31:0] amem;

part_1kx32ram  i_AMEM (
  .A(aadr_n),
  .DO(amem),
  .DI(l),
  .WE_N(awp_n),
  .CE_N(1'b0)
);

wire aparok;
assign aparok = 1;

// page CONTRL

wire dfall_n, dispenb, ignpopj_n, jfalse, jcalf, jretf, jret, iwrite;
wire ipopj_n, popj_n, srcspcpopreal_n;
wire spop_n, spush_n;

assign dfall_n  = ! (dr & dp);
assign dispenb = irdisp & funct2_n;
assign ignpopj_n  = irdisp_n  | dr;
assign jfalse = irjump & ir[6];
assign jcalf = jfalse & ir[8];
assign jretf = jret & ir[6];

assign jret = ~ir[8] & irjump & ir[9];
assign iwrite = irjump & ir[8] & ir[9];

assign ipopj_n  = ! (ir[42] & nop_n );
assign popj_n  = ipopj_n  & iwrited_n ;

wire popj;
assign popj = ~popj_n;

assign srcspcpopreal_n  = srcspcpop_n  | nop;

assign spop_n = ! (
	( !(srcspcpopreal_n & popj_n ) & ignpopj_n ) |
	(dispenb & dr & ~dp) |
	(jret & ~ir[6] & jcond) |
	(jretf & ~jcond)
	);

assign spush_n = ! (
	destspc |
	(jcalf & ~jcond) |
	(dispenb & dp & ~dr) |
	(irjump & ~ir[6] & ir[8] & jcond)
	);

wire spcwpass_n, spcwpass, spcpass_n;
wire swp_n, spcenb, spcdrive_n, spcdrive, spcnt_n;

assign spcwpass_n = !(spushd & tse);
assign spcwpass = spushd & tse;
assign spcpass_n = !(spushd_n & tse);

assign swp_n = !(spushd & wp4);
assign spcenb = !(srcspc_n & srcspcpop_n);
assign spcdrive_n = !(spcenb & tse);
assign spcdrive = spcenb & tse;
assign spcnt_n = spush_n & spop_n;

reg inop, spushd, iwrited; 
wire inop_n, spushd_n, iwrited_n;

wire n, pcs1, pcs0;

assign inop_n = ~inop;
assign spushd_n = ~spushd;
assign iwrited_n = ~iwrited;

always @(posedge CLK3)
  begin
    inop <= n;
    spushd <= ~spush_n;
    iwrited <= iwrite;
  end

initial
  begin
   inop = 0;
   spushd = 0;
   iwrited = 0;
  end

// select new pc
// {pcs1,pcs0}
// 00 0 spc
// 01 1 ir
// 10 2 dpc
// 11 3 ipc

assign pcs1 = 
	(popj & ignpopj_n) |
	(jfalse & ~jcond) |
	(irjump & ~ir[6] & jcond) |
	(dispenb & dr & ~dp);

assign pcs0 = 
	(popj) |
	(dispenb & dfall_n) |
	(jretf & ~jcond) |
	(jret & ~ir[6] & jcond);

assign n =
	!(trap_n & 
	  ((iwrited) |
	   (dispenb & dn) |
	   (jfalse & ~jcond & ir[7]) |
	   (irjump & ~ir[6] & jcond & ir[7]))
	 );

wire nopa_n, nopa, nop, nop_n;

assign nopa_n  = inop_n & nop11_n;
assign nopa  = ~nopa_n;

assign nop = !(trap_n & nopa_n);
assign nop_n = ~nop;

// page DRAM0-2

wire[10:0] dadr_n;
wire dr, dp, dn;
wire daddr0;
wire[6:0] dmask;
wire dwe_n;

// dadr  10 9  8  7  6  5  4  3  2  1  0
// -------------------------------------
// ir    22 21 20 19 18 17 16 15 14 13 d
// dmask x  x  x  x  6  5  4  3  2  1  x
// r     x  x  x  x  6  5  4  3  2  1  x

assign daddr0 =
	(ir[8] & vmo[18]) |
	(ir[9] & vmo[19]) |
	(dmapbenb_n & dmask[0] & r[0]) |
	(ir[12]);

assign dadr_n = !( { ir[22:13], daddr0 } |
	   ({ 4'b0000, dmask[6:1], 1'b0 } &
            { 4'b0000, r[6:1],     1'b0 }));

assign dwe_n = !(dispwr & wp2);

part_2kx17ram  i_DRAM (
  .A(dadr_n),
  .DO({dr,dp,dn,dpc}),
  .DI(a[16:0]),
  .WE_N(dwe_n),
  .CE_N(1'b0)
);

// page DSPCTL

wire dparh_n, dparl, dpareven, dparok, dmapbenb_n, dispwr;

assign dparh_n = 1;
assign dparl = 0;
assign dpareven = dparh_n  ^ dparl;
assign dparok = !(dpareven & dispenb);
assign dmapbenb_n  = !(ir[8] | ir[9]);
assign dispwr = !(irdisp_n | funct2_n);

reg[9:0] dc;

always @(posedge CLK3)
  if (irdisp_n == 0)
    dc <= ir[41:32];

initial
  dc = 0;

part_32x8prom  i_DMASK (
  .A( {1'b0, 1'b0, ir[7], ir[6], ir[5]} ),
  .O( {nc_dmask, dmask[6:0]} ),
  .CE_N(1'b0)
);

// page FLAG

wire statbit_n, ilong_n, aluneg;
wire pgf_or_int, pgf_or_int_or_sb, sint;

assign statbit_n = !(nopa_n & ir[46]);
assign ilong_n  = !(nopa_n & ir[45]);

assign aluneg = !(aeqm | ~alu[32]);

assign pgf_or_int = sint | vmaok_n;
assign pgf_or_int_or_sb = (sequence_break | sint) | vmaok_n;
assign sint = sintr & int_enable;

wire[2:0] conds;
wire jcond;

assign conds = ir[2:0] & ir[5];

assign jcond = 
	conds == 3'b000 ? r[0] :
	conds == 3'b001 ? aluneg :
	conds == 3'b010 ? alu[32] :
	conds == 3'b011 ? aeqm :
	conds == 3'b100 ? vmaok_n :
	conds == 3'b101 ? pgf_or_int :
	conds == 3'b110 ? pgf_or_int_or_sb :
	                  1'b1;

reg lc_byte_mode, prog_unibus_reset, int_enable, sequence_break;

always @(posedge CLK3)
  begin
    lc_byte_mode <= ob[29];
    prog_unibus_reset <= ob[28];
    int_enable <= ob[27];
    sequence_break <= ob[26];
  end

initial
  begin
    lc_byte_mode = 0;
    prog_unibus_reset = 0;
    int_enable = 0;
    sequence_break = 0;
  end


// page IOR

wire[47:0] iob;
wire[31:0] ob;

// iob 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26
// i   47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26
// ob  21 20 19 18 17 16 15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0  

// iob 25 24 ... 1  0
// i   25 24 ... 1  0
// ob  25 24 ... 1  0

assign iob = i[47:0] | { ob[21:0], ob[25:0] };

// page IPAR

wire[3:0] ipar;
wire iparity, iparok;

assign ipar = 4'b0000;
assign iparity = 0;
assign iparok = imodd | iparity;

// page IREG

always @(posedge CLK3)
  begin
    ir[47:26] <= destimod1_n ? i[47:26] : iob[47:26]; 
    ir[25:0] <= destimod0_n ? i[25:0] : iob[25:0]; 
  end

initial
  ir = 0;

// page IWR

reg[47:0] iwr;

always @(posedge CLK2)
  begin
    iwr[47:32] <= a[15:0];
  end

always @(posedge CLK4)
  begin
    iwr[31:0] <= m[31:0];
  end

initial
  iwr[47:0] = 48'b0;


// page L

reg[31:0] l;

always @(posedge CLK3)
  begin
    l <= ob;
  end

initial
   l = 0;

wire lparl, lparm_n, lparity, lparity_n;

assign lparl = 0;
assign lparm_n = 0;
assign lparity = 0;
assign lparity_n = 1;


// page LC

reg[25:0] lc;

wire[3:0] lca;
wire lcry3;

always @(posedge CLK1)
  begin
    if (destlc_n == 0)
      lc <= ob;
    else
      // xxx lc[25:4] only
      lc[25:4] <= lc[25:4] + lcry3;
  end

assign {lcry3, lca[3:0]} =
	 lc[3:0] + { 3'b0, !(lcinc_n | lc_byte_mode) } + lcinc;

// xxx
// I think the above is really
// 
// always @(posedge CLK1)
//   begin
//     if (destlc_n == 0)
//       lc <= ob;
//     else
//       lc <= lc + 
//             !(lcinc_n | lc_byte_mode) ? 1 : 0 +
//             lcinc ? 1 : 0;
//
//   end
//

always @(posedge CLK2)
  begin
    lc[3:0] <= destlc_n == 0 ? ob[3:0] : lca[3:0];
  end

wire lcdrive_n, lcdrive;

assign lcdrive_n  = !(srclc & tse);
assign lcdrive = srclc & tse;

wire[31:0] mf;

// mux MF
assign mf =
	lcdrive_n == 0 ?
	  { needfetch, 1'b0, lc_byte_mode, prog_unibus_reset,
	    int_enable, sequence_break, lc[25:1], lc0b } :
        opcdrive_n == 0 ?
	  { 16'b0, 2'b0, opc[13:0] } :
// zero16_drive drives top 16 bits to zero
        zero12_drive ?
	  { 16'b0, 4'b0, 12'b0 } :
        dcdrive ?
	  { 16'b0, 4'b0, 2'b0, dc[9:0] } :
	ppdrive_n == 0 ?
	  { 16'b0, 4'b0, 2'b0, pdlptr[9:0] } :
	pidrive == 1 ?
	  { 16'b0, 4'b0, 2'b0, pdlidx[9:0] } :
	qdrive == 1 ?
	  q :
	mddrive_n == 0 ?
	  md_n :
	mpassl_n == 0 ?
	  l :
	vmadrive_n == 0 ?
	  vma :
	mapdrive_n == 0 ?
	  { pfw_n, pfr_n, 1'b1, vmap_n[4:0], vmo[23:0] } :
	32'b0;


// page LCC

wire lc0b, next_instr, newlc_in_n, have_wrong_word, last_byte_in_word;
wire needfetch, ifetch_n, spcmung, spc1a, lcinc, lcinc_n;
wire newlc_n;

assign lc0b = lc[0] & lc_byte_mode;
assign next_instr  = !(spop_n | !(srcspcpopreal_n & spc[14]));

assign newlc_in_n  = !(have_wrong_word & lcinc_n);
assign have_wrong_word = !(newlc_n & destlc_n);
assign last_byte_in_word  = !(lc[1] | lc0b);
assign needfetch = have_wrong_word | last_byte_in_word;

assign ifetch_n  = !(needfetch & lcinc);
assign spcmung = spc[14] & ~needfetch;
assign spc1a = spcmung | spc[1];

assign lcinc = next_instrd | (irdisp & ir[24]);
assign lcinc_n = !(next_instrd | (irdisp & ir[24]));

reg newlc, sintr, next_instrd;

//external
wire int;
assign int = 0;

always @(posedge CLK3)
  begin
    newlc <= newlc_in_n;
    sintr <= int;
    next_instrd <= next_instr;
  end

assign newlc_n = ~newlc;

always @(reset_n)
  if (reset_n == 0)
    begin
      newlc = 0;
      sintr = 0;
      next_instrd = 0;
    end

initial 
  begin
    newlc = 0;
    sintr = 0;
    next_instrd = 0;
  end

// mustn't depend on nop
wire lc_modifies_mrot_n, inst_in_left_half, inst_in_2nd_or_4th_quarter;
wire sh4_n, sh3_n;

assign lc_modifies_mrot_n  = !(ir[10] & ir[11]);

assign inst_in_left_half = !((lc[1] ^ lc0b) | lc_modifies_mrot_n);

assign sh4_n  = inst_in_left_half ^ ir[4];

// LC<1:0>
// +---------------+
// | 0 | 3 | 2 | 1 |
// +---------------+
// |   0   |   2   |
// +---------------+

assign inst_in_2nd_or_4th_quarter =
	!(lc[0] | lc_modifies_mrot_n) & lc_byte_mode;

assign sh3_n  = ~ir[3] ^ inst_in_2nd_or_4th_quarter;

//page LPC

reg[13:0] lpc;

always @(posedge CLK4)
  begin
    if (lpc_hold == 0)
      lpc <= pc;
  end

initial
  lpc = 0;

wire[13:0] wpc;

assign wpc = (irdisp & ir[25]) ? lpc : pc;

// page MCTL

wire mpass, mpass_n, mpassl, mpassl_n, mpassm_n;
wire srcm, mwp_n;
wire[4:0] madr_n;

assign mpass = { 1'b1, ir[30:26] } == { destmd, wadr[4:0] };
assign mpass_n = ~mpass;

assign mpassl_n = !(mpass & tse & ~ir[31]);
assign mpassl = mpass & tse & ~ir[31];
assign mpassm_n  = !(mpass_n & tse & ~ir[31]);

assign srcm = ~ir[31] & mpass_n;

assign mwp_n = !(destmd & tpwp);

assign madr_n = CLK4 ? ir[30:26] : wadr[4:0];

// page MD

reg[31:0] md_n;
reg mdhaspar, mdpar;
wire mddrive_n, mdgetspar, mdclk;

// external
wire mempar_in;
assign mempar_in = 0;

always @(posedge MDCLK)
  begin
    md_n <= mds_n;
    mdhaspar <= mdgetspar;
    mdpar <= mempar_in;
  end

initial
  md_n = 0;

//loadmd - external input (from dram?)
//ignpar_n - external input (from dram?)
wire loadmd, ignpar_n;
assign loadmd = 0;
assign ignpar_n = 1;

assign mddrive_n = !(~srcmd_n & tse);
assign mdgetspar = ignpar_n  & destmdr_n;
assign mdclk = !(loadmd | (~CLK2 & ~destmdr_n));

// page MDS

wire[31:0] mds_n;
wire[31:0] mem;
wire mempar_out;

assign mds_n = mdsel ? ob : mem;

wire mdparodd;
assign mdparodd = 1;

assign mempar_out = mdparodd;

// mux MEM
assign mem =
	memdrive_n == 0 ? md_n :
	mfdrive_n == 0 ? mf :
		         32'b0;

// page MF

wire mfenb, mfdrive, mfdrive_n;

assign mfenb = ~srcm & !(spcenb | pdlenb);
assign mfdrive = mfenb & tse;
assign mfdrive_n  = !(mfenb & tse);

// page MLATCH

reg[31:0] mmem_latched;

wire mmemparity;
assign mmemparity = 0;

always @(posedge CLK4)
  begin
    mmem_latched <= mmem;
    mparity <= mmemparity;
  end

wire mmemparok;
assign mmemparok = 1;

// mux M
wire[31:0] m;

assign m = 
	mpassm_n == 0 ? mmem_latched :
	pdldrive_n == 0 ? pdl_latched :
	spcdrive_n == 0 ? {3'b0, spcptr,
	                   5'b0, spco_latched} :
                        32'b0;

// page MMEM

wire[31:0] mmem;

part_2kx32ram  i_MMEM (
  .A(madr_n),
  .I(l),
  .D(mmem),
  .WCLK_N(mwp_n),
  .CE(1'b1)
);


// page MO

//for (i = 0; i < 31; i++)
//  assign a_bitsel[i] =
//	osel == 2'b00 ? (msk[i] ? r[i] : a[i]) : a[i];

// msk r  a       (msk&r)|(~msk&a)
//  0  0  0   0      0 0  0
//  0  0  1   1      0 1  1
//  0  1  0   0      0 0  0
//  0  1  1   1      0 1  1
//  1  0  0   0      0 0  0 
//  1  0  1   0      0 0  0
//  1  1  0   1      1 0  1 
//  1  1  1   1      1 0  1

wire[31:0] a_bitsel;

assign a_bitsel = (msk & r) | (~msk & a);

assign ob =
	osel == 2'b00 ? a_bitsel :
	osel == 2'b01 ? alu :
	osel == 2'b10 ? alu[32:1] :
	              /* 2'b11 */{alu[30:0],q[31]};

// page MSKG4

reg[31:0] msk;

part_prom  i_MSKG4 (
  .O(msk),
  .A(mskr),
  .CE_N(1'b0)
);

// page NPC

assign npc = 
    {trap,pcs1,pcs0} == 2'b000 ? { spc[13:1], spc1a } :
    {trap,pcs1,pcs0} == 2'b001 ? { ir[25:12] } :
    {trap,pcs1,pcs0} == 2'b010 ? dpc :
    {trap,pcs1,pcs0} == 2'b011 ? ipc :
                      /* 2'b111 */ 14'b0;

reg[13:0] pc;

always @(posedge CLK4)
  begin
    pc <= npc;
  end

initial
  pc = 0;

assign ipc = pc + 1;

// page OPCD

wire dcdrive, opcdrive_n, zero16, zero12_drive, zero16_drive, zero16_drive_n;

assign dcdrive = ~srcdc_n & tse;
assign opcdrive_n  = !(~srcopc_n & tse);

assign zero16 = !(srcopc_n  & srcpdlidx_n  & srcpdlptr_n & srcdc_n);

assign zero12_drive  = zero16 & srcopc_n & tse;
assign zero16_drive  = zero16 & tse;
assign zero16_drive_n  = !(zero16 & tse);

// page PDL

wire pdlparity;

assign pdlparity = 0;

wire[31:0] pdl;

part_1kx32ram  i_PDL (
  .A(pdla_n),
  .DO(pdl),
  .DI(l),
  .WE_N(pwp_n),
  .CE_N(1'b0)
);

// page PDLCTL

wire[9:0] pdla;
wire pdlp_n, pdlwrite;
wire pwp_n, pdlenb, pdldrive_n, pdlcnt_n;
wire pdlwrited_n, pwidx, imodd_n;
wire destspcd;

reg pdlwrited, pwidx_n, imodd, destspcd_n;

assign pdla = pdlp_n ? pdlidx : pdlptr;

assign pdlp_n = (CLK4 & ir[30]) | (~CLK4 & pwidx_n);
assign pdlwrite = !(destpdltop_n & destpdl_x_n & destpdl_p_n);

always @(posedge CLK4)
  begin
    pdlwrited <= pdlwrite;
    pwidx_n <= destpdl_x_n;
    imodd <= imod;
    destspcd_n <= destspc_n;
  end

assign pdlwrited_n = ~pdlwrited;
assign pwidx = ~pwidx_n;
assign imodd_n = ~imodd;

always @(reset_n)
  if (reset_n == 0)
    begin
      pdlwrited <= 0;
      pwidx_n <= 0;
      imodd <= 0;
      destspcd_n <= 0;
    end

initial
  begin
    pdlwrited = 0;
    pwidx_n = 0;
    imodd = 0;
    destspcd_n = 0;
  end

assign destspcd = ~destspcd_n;

assign pwp_n  = !(pdlwrited & wp4);

assign pdlenb = !(srcpdlpop_n  & srcpdltop_n);
assign pdldrive_n  = !(pdlenb & tse);

assign pdlcnt_n  = (srcpdlpop_n | nop) & destpdl_p_n;

// page PDLPTR

wire pidrive, ppdrive_n;

assign pidrive = tse & ~srcpdlidx_n;
assign ppdrive_n  = !(tse & ~srcpdlptr_n);

reg[9:0]pdlidx;

always @(posedge CLK3)
  begin
    pdlidx <= ob[9:0];
  end

initial
  pdlidx = 0;

reg[9:0] pdlptr;

always @(posedge CLK3)
  begin
     if (destpdlp_n == 0)
      pdlptr <= ob[9:0];
     else
      if (pdlcnt_n == 0)
        begin
          if (srcpdlpop_n)
            pdlptr = pdlptr - 1;
          else
            pdlptr = pdlptr + 1;
        end
  end

// page PLATCH

reg mparity;
reg[31:0] pdl_latched;

always @(posedge CLK4)
  begin
    mparity <= pdlparity;
    pdl_latched <= pdl;
  end

// page Q

reg[31:0] q;
wire qs1, qs0, srcq, qdrive;

always @(posedge CLK2)
  begin
    case ( {qs1,qs0} )
      2'b01: q <= { q[30:0], ~alu[31] };
      2'b10: q <= { alu[0], q[31:1] };
      2'b11: q <= alu;
    endcase
  end

assign qs1 = !(~ir[1] | iralu_n);
assign qs0 = !(~ir[0] | iralu_n);

assign srcq = ~srcq_n;
assign qdrive = srcq & tse;

// page SHIFT0-1

wire[31:0] sa;
wire[31:0] r;

assign sa =
	{s1,s0} == 2'b00 ? m :
	{s1,s0} == 2'b01 ? { m[30:0], m[31] } : 
	{s1,s0} == 2'b10 ? { m[29:0], m[31], m[30] } : 
	                   { m[28:0], m[31], m[30], m[29] };

assign {r[12],r[8],r[4],r[0]} =
	{s4,s3,s2} == 3'b000 ? { sa[12],sa[8],sa[4], sa[0] } :
	{s4,s3,s2} == 3'b001 ? { sa[8], sa[4],sa[0], sa[28] } :
	{s4,s3,s2} == 3'b010 ? { sa[4], sa[0],sa[28],sa[24] } :
	{s4,s3,s2} == 3'b011 ? { sa[0],sa[28],sa[24],sa[20] } :
	{s4,s3,s2} == 3'b100 ? { sa[28],sa[24],sa[20],sa[16] } :
	{s4,s3,s2} == 3'b101 ? { sa[24],sa[20],sa[16],sa[12] } :
	{s4,s3,s2} == 3'b110 ? { sa[20],sa[16],sa[12],sa[8] } :
                               { sa[16],sa[12],sa[8], sa[4] };

assign {r[13],r[9],r[5],r[1]} =
	{s4,s3,s2} == 3'b000 ? { sa[13],sa[9],sa[5], sa[1] } :
	{s4,s3,s2} == 3'b001 ? { sa[9], sa[5],sa[1], sa[29] } :
	{s4,s3,s2} == 3'b010 ? { sa[5], sa[1],sa[29],sa[25] } :
	{s4,s3,s2} == 3'b011 ? { sa[1],sa[29],sa[25],sa[21] } :
	{s4,s3,s2} == 3'b100 ? { sa[29],sa[25],sa[21],sa[17] } :
	{s4,s3,s2} == 3'b101 ? { sa[25],sa[21],sa[17],sa[13] } :
	{s4,s3,s2} == 3'b110 ? { sa[21],sa[17],sa[13],sa[9] } :
                               { sa[17],sa[13],sa[9], sa[5] };

assign {r[14],r[10],r[6],r[2]} =
	{s4,s3,s2} == 3'b000 ? { sa[14],sa[10],sa[6], sa[2] } :
	{s4,s3,s2} == 3'b001 ? { sa[10],sa[6], sa[2], sa[30] } :
	{s4,s3,s2} == 3'b010 ? { sa[6], sa[2], sa[30],sa[26] } :
	{s4,s3,s2} == 3'b011 ? { sa[2], sa[30],sa[26],sa[22] } :
	{s4,s3,s2} == 3'b100 ? { sa[30],sa[26],sa[22],sa[18] } :
	{s4,s3,s2} == 3'b101 ? { sa[26],sa[22],sa[18],sa[14] } :
	{s4,s3,s2} == 3'b110 ? { sa[22],sa[18],sa[14],sa[10] } :
                               { sa[18],sa[14],sa[10], sa[6] };

assign {r[15],r[11],r[7],r[3]} =
	{s4,s3,s2} == 3'b000 ? { sa[15],sa[11],sa[7], sa[3] } :
	{s4,s3,s2} == 3'b001 ? { sa[11],sa[7], sa[3], sa[31] } :
	{s4,s3,s2} == 3'b010 ? { sa[7], sa[3], sa[31],sa[27] } :
	{s4,s3,s2} == 3'b011 ? { sa[3], sa[31],sa[27],sa[23] } :
	{s4,s3,s2} == 3'b100 ? { sa[31],sa[27],sa[23],sa[19] } :
	{s4,s3,s2} == 3'b101 ? { sa[27],sa[23],sa[19],sa[15] } :
	{s4,s3,s2} == 3'b110 ? { sa[23],sa[19],sa[15],sa[11] } :
                               { sa[19],sa[15],sa[11], sa[7] };

//

assign {r[28],r[24],r[20],r[16]} =
	{s4,s3,s2} == 3'b000 ? { sa[28],sa[24],sa[20],sa[16] } :
	{s4,s3,s2} == 3'b001 ? { sa[24],sa[20],sa[16],sa[12] } :
	{s4,s3,s2} == 3'b010 ? { sa[20],sa[16],sa[12],sa[8] } :
	{s4,s3,s2} == 3'b011 ? { sa[16],sa[12],sa[8], sa[4] } :
	{s4,s3,s2} == 3'b000 ? { sa[12],sa[8],sa[4], sa[0] } :
	{s4,s3,s2} == 3'b001 ? { sa[8], sa[4],sa[0], sa[28] } :
	{s4,s3,s2} == 3'b010 ? { sa[4], sa[0],sa[28],sa[24] } :
	                       { sa[0],sa[28],sa[24],sa[20] };

assign {r[29],r[25],r[21],r[17]} =
	{s4,s3,s2} == 3'b000 ? { sa[29],sa[25],sa[21],sa[17] } :
	{s4,s3,s2} == 3'b001 ? { sa[25],sa[21],sa[17],sa[13] } :
	{s4,s3,s2} == 3'b010 ? { sa[21],sa[17],sa[13],sa[9] } :
	{s4,s3,s2} == 3'b010 ? { sa[17],sa[13],sa[9], sa[5] } :
	{s4,s3,s2} == 3'b100 ? { sa[13],sa[9],sa[5], sa[1] } :
	{s4,s3,s2} == 3'b101 ? { sa[9], sa[5],sa[1], sa[29] } :
	{s4,s3,s2} == 3'b110 ? { sa[5], sa[1],sa[29],sa[25] } :
	                       { sa[1],sa[29],sa[25],sa[21] };

assign {r[30],r[26],r[22],r[18]} =
	{s4,s3,s2} == 3'b000 ? { sa[30],sa[26],sa[22],sa[18] } :
	{s4,s3,s2} == 3'b001 ? { sa[26],sa[22],sa[18],sa[14] } :
	{s4,s3,s2} == 3'b010 ? { sa[22],sa[18],sa[14],sa[10] } :
	{s4,s3,s2} == 3'b011 ? { sa[18],sa[14],sa[10], sa[6] } :
	{s4,s3,s2} == 3'b100 ? { sa[14],sa[10],sa[6], sa[2] } :
	{s4,s3,s2} == 3'b101 ? { sa[10],sa[6], sa[2], sa[30] } :
	{s4,s3,s2} == 3'b110 ? { sa[6], sa[2], sa[30],sa[26] } :
	                       { sa[2], sa[30],sa[26],sa[22] };
	
assign {r[31],r[27],r[23],r[19]} =
	{s4,s3,s2} == 3'b000 ? { sa[31],sa[27],sa[23],sa[19] } :
	{s4,s3,s2} == 3'b001 ? { sa[27],sa[23],sa[19],sa[15] } :
	{s4,s3,s2} == 3'b010 ? { sa[23],sa[19],sa[15],sa[11] } :
	{s4,s3,s2} == 3'b011 ? { sa[19],sa[15],sa[11],sa[7] } :
	{s4,s3,s2} == 3'b100 ? { sa[15],sa[11],sa[7], sa[3] } :
	{s4,s3,s2} == 3'b101 ? { sa[11],sa[7], sa[3], sa[31] } :
	{s4,s3,s2} == 3'b110 ? { sa[7], sa[3], sa[31],sa[27] } :
	                       { sa[3], sa[31],sa[27],sa[23] };


// page SMCTL

wire mr_n, sr_n, s1, s0;

assign mr_n  = !(irbyte_n | ir[13]);
assign sr_n  = !(irbyte_n | ir[12]);

assign s0 = !(sr_n | ~ir[0]);
assign s1 = !(sr_n | ~ir[1]);

wire[4:0] mskr;

assign mskr[4] = !(mr_n | sh4_n);
assign mskr[3] = !(mr_n | sh3_n);
assign mskr[2] = !(mr_n | ~ir[2]);
assign mskr[1] = !(mr_n | ~ir[1]);
assign mskr[0] = !(mr_n | ~ir[0]);

wire s4, s4_n, s3, s2;

assign s4 = !(sr_n | sh4_n);
assign s4_n = sh4_n | sr_n;

assign s3 = !(sr_n | sh3_n);
assign s2 = !(sr_n | ~ir[2]);

wire[4:0] mskl;

assign mskl = mskr + ir[9:5];

// page SOURCE

wire irbyte_n, irdisp_n, irjump_n, iralu_n;
wire irdisp, irjump;

assign irdisp = ~irdisp_n;
assign irjump = ~irjump_n;

assign {irbyte_n,irdisp_n,irjump_n,iralu_n} =
  nop ? 4'b0000 :
	({ir[44],ir[43]} == 2'b00) ? 4'b0001 :
	({ir[44],ir[43]} == 2'b01) ? 4'b0010 :
	({ir[44],ir[43]} == 2'b10) ? 4'b0100 :
                                     4'b1000 ;

wire[3:0] funct;

assign funct = 
  nop ? 4'b0000 :
	({ir[11],ir[10]} == 2'b00) ? 4'b0001 :
	({ir[11],ir[10]} == 2'b01) ? 4'b0010 :
	({ir[11],ir[10]} == 2'b10) ? 4'b0100 :
                                     4'b1000 ;

wire funct2_n;
assign funct2_n = ~funct[2];

assign specalu_n  = !(ir[8] & iralu);

assign {div_n,mul_n} =
  specalu_n == 1 ? 2'b00 :
	({ir[4],ir[3]} == 2'b00) ? 2'b01 : 2'b10;

wire srcq_n, srcopc_n, srcpdltop_n, srcpdlpop_n,
	srcpdlidx_n, srcpdlptr_n, srcspc_n, srcdc_n;
wire srcspcpop_n, srclc_n, srcmd_n, srcmap_n, srcvma_n;

//xxx eliminate?
wire srclc;
assign srclc = ~srclc_n;

assign {srcq_n,srcopc_n,srcpdltop_n,srcpdlpop_n,
	srcpdlidx_n,srcpdlptr_n,srcspc_n,srcdc_n} =
  (~ir[31] | ir[29]) ? 8'b00000000 :
	({ir[28],ir[27],ir[26]} == 3'b000) ? 8'b00000001 :
	({ir[28],ir[27],ir[26]} == 3'b001) ? 8'b00000010 :
	({ir[28],ir[27],ir[26]} == 3'b010) ? 8'b00000100 :
	({ir[28],ir[27],ir[26]} == 3'b011) ? 8'b00001000 :
	({ir[28],ir[27],ir[26]} == 3'b100) ? 8'b00010000 :
	({ir[28],ir[27],ir[26]} == 3'b101) ? 8'b00100000 :
	({ir[28],ir[27],ir[26]} == 3'b110) ? 8'b01000000 :
	                                     8'b10000000;

assign {srcspcpop_n,srclc_n,srcmd_n,srcmap_n,srcvma_n} =
  (~ir[31] | ~ir[29]) ? 5'b00000 :
	({ir[28],ir[27],ir[26]} == 3'b000) ? 5'b00001 :
	({ir[28],ir[27],ir[26]} == 3'b001) ? 5'b00010 :
	({ir[28],ir[27],ir[26]} == 3'b010) ? 5'b00100 :
	({ir[28],ir[27],ir[26]} == 3'b011) ? 5'b01000 :
	({ir[28],ir[27],ir[26]} == 3'b100) ? 5'b10000 :
	                                     5'b00000 ;

wire imod;

assign imod = !((destimod0_n & iwrited_n) & destimod1_n & idebug_n);

wire destmem_n, destvma_n, destmdr_n, dest, destm;
wire destintctl_n, destlc_n;
wire destimod1_n, destimod0_n, destspc_n, destpdlp_n,
	destpdlx_n, destpdl_x_n, destpdl_p_n, destpdltop_n;

assign destmem_n = !(destm & ir[23]);
assign destvma_n = destmem_n | ir[22];
assign destmdr_n = destmem_n | ~ir[22];
assign dest = !(iralu_n & irbyte_n);
assign destm = dest & ~ir[25];

assign {destintctl_n,destlc_n} =
  !(destm & ~ir[23] & ~ir[22]) ? 2'b00 :
	({ir[21],ir[20],ir[19]} == 3'b001) ? 2'b01 :
	({ir[21],ir[20],ir[19]} == 3'b010) ? 2'b10 :
	                                     2'b00 ;

assign {destimod1_n,destimod0_n,destspc_n,destpdlp_n,
	destpdlx_n,destpdl_x_n,destpdl_p_n,destpdltop_n} =
  !(destm & ~ir[23] & ~ir[22]) ? 8'b00000000 :
	({ir[21],ir[20],ir[19]} == 3'b000) ? 8'b00000001 :
	({ir[21],ir[20],ir[19]} == 3'b001) ? 8'b00000010 :
	({ir[21],ir[20],ir[19]} == 3'b010) ? 8'b00000100 :
	({ir[21],ir[20],ir[19]} == 3'b011) ? 8'b00001000 :
	({ir[21],ir[20],ir[19]} == 3'b100) ? 8'b00010000 :
	({ir[21],ir[20],ir[19]} == 3'b101) ? 8'b00100000 :
	({ir[21],ir[20],ir[19]} == 3'b110) ? 8'b01000000 :
	                                     8'b10000000;

wire destspc;
assign destspc = ~destspc_n;

// page SPC

reg[4:0] spcptr;

wire [18:0] spcw;
wire [18:0] spco;

part_32x19ram  i_SPC (
  .A(spcptr),
  .I(spcw),
  .D(spco),
  .WCLK(swp_n),
  .WE_N(1'b0),
  .CE_N(1'b0)
);

always @(posedge CLK4)
  begin
    if (spcnt_n == 0)
      begin
        if (~spush_n == 0)
          spcptr = spcptr - 1;
        else
          spcptr = spcptr + 1;
      end
  end

initial
  spcptr = 0;

// page SPCLCH

reg[18:0] spco_latched;
reg spcpar;

// mux SPC
assign spc = 
  spcpass_n == 0 ? spco_latched :
  spcwpass_n == 0 ? spcw :
	32'b0;

wire spcopar;
assign spcopar = 0;

always @(posedge CLK4)
  begin
    spcpar <= spcopar;
    spco_latched <= spco;
  end


// page SPCPAR

wire spcwpar, spcwparl_n, spcwparh, spcparok;

assign spcwpar = 0;
assign spcwparl_n = 1;
assign spcwparh = 0;
assign spcparok = 1;

assign spcwpar = spcwparh ^ spcwparl_n;

// page SPCW

reg[13:0] reta;

assign spcw = 
	destspcd ? l[18:0] : { 5'b0, reta };

always @(posedge CLK4)
  begin
    reta <= n ? wpc : ipc;
  end

// page SPY1-2

wire[15:0] spy;

assign spy[15:0] =
	spy_irh_n == 0 ? ir[47:32] :
	spy_irm_n == 0 ? ir[31:16] :
	spy_irl_n == 0 ? ir[15:0] :
	spy_obh_n == 0 ? ob[31:16] :
	spy_obl_n == 0 ? ob[15:0] :
	spy_ah_n == 0 ? a[31:16] :
	spy_al_n == 0 ? a[15:0] :
	spy_mh_n == 0 ? m[31:16] :
	spy_ml_n == 0 ? m[15:0] :
	spy_flag2_n == 0 ?
			{ 2'b0,wmapd,destspcd,iwrited,imodd,pdlwrited,spushd,
			  2'b0,ir[48],nop,vmaok_n,jcond,pcs1,pcs0 } :
	spy_opc_n == 0 ?
			{ 2'b0,opc } :
	spy_flag1_n == 0 ?
			{ wait_n,v1pe_n,v0pe_n,promdisable,
			  stathalt_n, err, ssdone, srun,
			  higherr_n, mempe_n, ipe_n, dpe_n,
			  spe_n, pdlpe_n, mpe_n, ape_n } :
	spy_pc_n == 0 ?
			{ 2'b0,pc } :
	                 16'b0;

wire halt_n;
assign halt_n = 1;

// page TRAP

wire mdparerr, parerr_n, memparok_n, memparok, trap_n, trap;
reg boot_trap;

wire mdpareven;
assign mdpareven = 0;

assign mdparerr = mdpareven ^ mdpar;
assign parerr_n = !(mdparerr & mdhaspar & use_md & wait_n);
assign memparok = !memparok_n;

assign trap_n  = !( !(parerr_n | ~trapenb) | boot_trap );
assign trap = ~trap_n;
assign memparok_n = !(parerr_n | trapenb);

// page VCTRL1

reg memstart, mbusy_sync;
wire memop_n, memprepare, memstart_n, musy_sync_n;

assign memop_n  = memrd_n  & memwr_n  & ifetch_n;
assign memprepare = !(memop_n | CLK2);

always @(posedge MCLK1)
  begin
    memstart <= memprepare;
    mbusy_sync <= memrq;
  end

assign memstart_n = ~memstart;
//assign mbusy_sync_n = ~mbusy_sync;

always @(reset_n)
  if (reset_n == 0)
    begin
      memstart = 0;
      mbusy_sync = 0;
    end

initial
  begin
    memstart = 0;
    mbusy_sync = 0;
  end

reg wrcyc, wmapd, mbusy;
wire rdcyc, pfw_n, pfr_n, vmaok_n, wmapd_n, memrq;

assign pfw_n  = !(lvmo_n[22] & wrcyc);
assign vmaok_n  = !(pfr_n & pfw_n);

always @(posedge CLK2)
  begin
    wrcyc <= !((memprepare & memwr_n) | (~memprepare & rdcyc));
    wmapd <= wmap;
  end

always @(reset_n)
  if (reset_n == 0)
    begin
      wrcyc = 0;
      wmapd = 0;
    end

initial
  begin
    wrcyc = 0;
    wmapd = 0;
  end

assign rdcyc = ~wrcyc;
assign wmapd_n = ~wmapd;

assign memrq = mbusy | (memstart & pfr_n & pfw_n);

always @(posedge MCLK1 or mfinishd_n)
  begin
    if (mfinishd_n == 0)
      mbusy = 0;
    else
      if (MCLK1)
	mbusy <= memrq;
  end

wire set_rd_in_progess, mfinish_n;
reg rd_in_progress;

//external
wire memack_n, memgrant_n;
assign memack_n = 1;
assign memgrant_n = 1;

assign set_rd_in_progess = rd_in_progress | (memstart & pfr_n & rdcyc);
assign mfinish_n = memack_n & reset_n;

always @(posedge MCLK1 or rdfinish_n)
  begin
    if (rdfinish_n == 0)
      rd_in_progress = 0;
    else
      if (MCLK1)	
        rd_in_progress <= set_rd_in_progess;
  end

//XXX delay line
// mfinish_n + 30ns -> mfinishd_n
// mfinish_n + 140ns -> rdfinish_n

reg[10:0] mcycle_delay;

always @(posedge osc50mhz)
  begin
    mcycle_delay[0] <= mfinish_n;
    mcycle_delay[1] <= mcycle_delay[0];
    mcycle_delay[2] <= mcycle_delay[1];
    mcycle_delay[3] <= mcycle_delay[2];
    mcycle_delay[4] <= mcycle_delay[3];
    mcycle_delay[5] <= mcycle_delay[4];
    mcycle_delay[6] <= mcycle_delay[5];
    mcycle_delay[7] <= mcycle_delay[6];
  end

wire mfinishd_n, rdfinish_n;
wire wait_n;

assign mfinishd_n = ~mcycle_delay[2];
assign rdfinish_n = mcycle_delay[7];

assign wait_n =
	(~destmem_n & mbusy_sync) |
	(use_md & mbusy & memgrant_n) |		/* hang loses */
	(lcinc & needfetch & mbusy_sync);	/* ifetch */

assign hang_n = !(rd_in_progress & use_md & ~CLK3);

// page VCTRL2

wire mapwr0d, mapwr1d, vm0wp_n, vm1wp_n;
wire vmaenb_n, vmasel;
wire memdrive_n, mdsel, use_md;
wire wmap_n, memwr_n, memrd_n;

assign mapwr0d = !(wmapd_n | ~vma[26]);
assign mapwr1d = !(wmapd_n | ~vma[25]);

assign vm0wp_n = !(mapwr0d & wp1);
assign vm1wp_n = !(mapwr1d & wp1);

assign vmaenb_n = destvma_n & ifetch_n;
assign vmasel = ifetch_n & 1'b1;

// external?
wire lm_drive_enb;
assign lm_drive_enb = 0;

assign memdrive_n = !(wrcyc & lm_drive_enb);

assign mdsel = !(destmdr_n | CLK2);

assign use_md  = !(srcmd_n | nopa);

assign pfr_n = lvmo_n[23];

assign {wmap_n,memwr_n,memrd_n} =
  destmem_n ? 3'b000 :
	({ir[20],ir[19]} == 2'b01) ? 3'b001 :
	({ir[20],ir[19]} == 2'b10) ? 3'b010 :
	({ir[20],ir[19]} == 2'b11) ? 3'b100 :
	                             3'b000 ;

wire wmap;
assign wmap = ~wmap_n;

// page VMA

wire[31:0] vma_n;
reg[31:0] vma_latched;
wire vmadrive_n;

always @(posedge CLK1)
  begin
    vma_latched <= vmas;
  end

// need vma bus?
wire[31:0] vma;
assign vma =
	vmaenb_n == 0 ? vma_latched :
	32'b0;

assign vmadrive_n = !(~srcvma_n & tse);

initial
  vma_latched = 0;


// page VMAS

wire[31:0] vmas;

assign vmas = vmasel ? ob : { 8'b0,lc[25:2] };

wire[23:8] mapi;
wire[12:8] mapi_n;

assign mapi = memstart_n ? md_n[23:8] : vma[23:8];

// page VMEM0

wire[4:0] vmap_n;

part_2kx32ram  i_VMEM0 (
  .A(mapi[23:13]),
  .DO(vmap_n),
  .DI(vma_n),
  .WE_N(vm0wp_n),
  .CE_N(mapi23)
);

wire srcmap, use_map_n;
wire vmoparck, v0parok, vm0pari, vmoparodd;

assign srcmap = ~srcmap_n;
assign use_map_n = !(srcmap | memstart);
assign vmoparck = use_map_n | vmoparodd;
assign v0parok = use_map_n  | 1'b1;
assign vm0pari = 0;

wire vmopar;
assign vmopar = 0;

assign vmoparodd = vmopar ^ vmoparck;

// page VMEM1

assign mapi_n = ~mapi[12:8];

wire[23:0] vmo_n;
wire[23:0] vmo;

assign vmo = ~vmo_n;

part_1kx12ram  i_VMEM1 (
  .A( {vmap[4:0],mapi_n[12:8]} ),
  .DO(vmo_n[11:0]),
  .DI(vma_n[11:0]),
  .WE_N(vm1wp_n),
  .CE_N(1'b0)
);

wire vm1mpar, vm1lpar;

assign vm1mpar = 0;
assign vm1lpar = 0;

// page VMEM2

wire mapdrive_n;
wire vm0par, vm0parm, vm0parl, adrpar_n;

part_2kx22ram  i_VMEM2 (
  .A( {vmap[4:0],mapi_n[12:8]} ),
  .DO(vmo_n[23:12]),
  .DI(vma_n),
  .WE_N(vm1wp_n),
  .CE_N(mapi23)
);

assign vm0par = 0;
assign vm0parm = 0;
assign vm0parl = 0;

// page VMEMDR - map output drive

assign adrpar_n = 0;

reg[23:22] lvmo_n;
reg[21:8] pma;

always @(posedge memstart)
  begin
    { lvmo_n[23:22], pma[21:8] } <= vmo_n;
  end

initial
  begin
    lvmo_n = 0;
    pma = 0;
  end

assign mapdrive_n = !(tse & srcmap);

// page DEBUG

wire[48:0] i;

reg[15:0] latched_spy;

always @(posedge lddbirm_n)
  begin
     latched_spy <= spy;
  end

assign i[47:32] =
	idebug_n == 0 ? spy :
	16'b0;

initial
  latched_spy = 0;

// page ICTL - I RAM control

wire ramdisable, promdisabled_n;

assign promdisabled_n = ~promdisabled;

assign ramdisable = idebug | (promdisabled_n & iwrited_n);

//wire[3:0] ice;
//
//// banking for iram - only need 1!!
//assign ice =
//  ramdisable ? 3'b0000 :
//	({pc_n[13],pc_n[12]} == 2'b00) ? 4'b1000 :
//	({pc_n[13],pc_n[12]} == 2'b01) ? 4'b0100 :
//	({pc_n[13],pc_n[12]} == 2'b10) ? 4'b0010 :
//	                                 4'b0001 ;

// see clocks below
//assign iwe_n  = !(wp5& iwriteda);

//assign iwrp4 = 0;
//assign iwrp3 = 0;
//assign iwrp2 = 0;
//assign iwrp1 = 0;

// page OLORD1 

reg promdisable;
reg trapenb;
reg stathenb;
reg errstop;
reg speed1, speed0;

always @(posedge ldmode_n)
  begin
    promdisable <= spy[5];
    trapenb <= spy[4];
    stathenb <= spy[3];
    errstop <= spy[2];
    speed1 <= spy[1];
    speed0 <= spy[0];
  end

always @(reset_n)
  if (reset_n == 0)
    begin
      promdisable = 0;
      trapenb = 0;
      stathenb = 0;
      errstop = 0;
      speed1 = 0;
      speed0 = 0;
    end

initial
  begin
    promdisable = 0;
    trapenb = 0;
    stathenb = 0;
    errstop = 0;
    speed1 = 0;
    speed0 = 0;
  end


always @(posedge ldopc)
  begin
    opcinh <= spy[2];
    opcclk = spy[1];
    lpc_hold = spy[0];
  end

always @(reset_n)
  if (reset_n == 0)
    begin
      opcinh = 0;
      opcclk = 0;
      lpc_hold = 0;
    end

initial
  begin
    opcinh = 0;
    opcclk = 0;
    lpc_hold = 0;
  end

reg opcinh, opcclk, lpc_hold;
wire opcinh_n, opcclk_n, lpc_hold_n;

assign opcinh_n = ~opcinh;
assign opcclk_n = ~opcclk;
assign lpc_hold_n = ~lpc_hold;

always @(posedge ldclk)
  begin
    ldstat <= spy[4];
    idebug <= spy[3];
    nop11 <= spy[2];
    step <= spy[1];
  end

always @(reset_n)
  if (reset_n == 0)
    begin
      ldstat = 0;
      idebug = 0;
      nop11 = 0;
      step = 0;
    end

initial
  begin
    ldstat = 0;
    idebug = 0;
    nop11 = 0;
    step = 0;
  end

reg ldstat, idebug, nop11, step;
wire ldstat_n, idebug_n, nop11_n, step_n;

assign ldstat_n = ~ldstat;
assign idebug_n = ~idebug;
assign nop11_n = ~nop11;
assign step_n = ~step;

initial
  begin
    ldstat = 0;
	idebug = 0;
	nop11 = 0;
	step = 0;
  end

reg run;
wire run_n;
assign run_n = ~run;

always @(posedge ldclk_n or clock_reset_n or boot_n)
  if (boot_n == 0)
    run = 1;
  else
    if (clock_reset_n == 0)
      run = 0;
    else
      run <= spy[0];

reg srun, sstep, ssdone, promdisabled;

always @(posedge MCLK5)
  begin
    srun <= run;
    sstep <= step;
    ssdone <= sstep;
    promdisabled = promdisable;
  end

always @(clock_reset_n)
  if (clock_reset_n == 0)
    begin
      srun = 0;
      sstep = 0;
      ssdone = 0;
      promdisabled = 0;
    end

initial
  begin
    srun = 0;
    sstep = 0;
    ssdone = 0;
    promdisabled = 0;
  end

//xxx delay line
//assign speedclk = !(tpr60_n);

reg speed0a, speed1a;
reg sspeed0, sspeed1;

//always @(posedge speedclk)
//  begin
//    speed0a <= speed0;
//    speed1a <= speed1;
//    sspeed0 <= speed0a;
//    sspeed1 <= speed1a;
//  end
//
//always @(clock_reset_n)
//  if (clock_reset_n == 0)
//    begin
//      speed0a = 0;
//      speed1a = 0;
//      sspeed0 = 0;
//      sspeed1 = 0;
//    end

initial
    begin
      speed0a = 0;
      speed1a = 0;
      sspeed0 = 0;
      sspeed1 = 0;
    end

wire machrun, machrun_n, ssdone_n, stat_ovf, stathalt_n;

assign ssdone_n = ~ssdone;

assign machrun = (sstep & ssdone_n) | (srun & errhalt_n &
		wait_n & stathalt_n);

//assign stat_ovf = ~stc32;
//assign stat_ovf = 0'b0;
assign stathalt_n = !(statstop & stathenb);

assign machrun_n = machrun;

// page OLORD2

reg ape_n, mpe_n, pdlpe_n, dpe_n, ipe_n, spe_n, higherr_n, mempe_n;
reg v0pe_n, v1pe_n, statstop, halted_n;

wire spcoparok, vm0parok, pdlparok;
assign spcoparok = 1;
assign vm0parok = 1;
assign pdlparok = 1;

always @(posedge CLK5)
  begin
    ape_n <= aparok;
    mpe_n <= mmemparok;
    pdlpe_n <= pdlparok;
    dpe_n <= dparok;
    ipe_n <= iparok;
    spe_n <= spcparok;
    higherr_n <= highok;
    mempe_n <= memparok;

    v0pe_n <= v0parok;
    v1pe_n <= vm0parok;
    statstop <= stat_ovf;
    halted_n <= halt_n;
  end

wire lowerhighok_n, highok, ldmode;
wire prog_reset_n, reset, reset_n;
wire err, errhalt_n;
wire bus_reset_n, bus_power_reset_n;
wire power_reset;
wire clock_reset_n, prog_boot, boot1_n, boot2_n, boot_n;

assign lowerhighok_n = 0;
assign highok = 1;
assign ldmode = !ldmode_n;

assign prog_reset_n = !(ldmode & spy[6]);

assign reset = !(boot_n & clock_reset_n & prog_reset_n);
assign reset_n = ~reset;

assign err = ~ape_n | ~mpe_n | ~pdlpe_n | ~dpe_n |
	~ipe_n | ~spe_n | ~higherr_n | ~mempe_n |
	~v0pe_n | ~v1pe_n | ~halted_n;

assign errhalt_n = !(errstop & err);

// external
wire prog_bus_reset;
assign prog_bus_reset = 0;

assign bus_reset_n  = !(prog_bus_reset | power_reset);
assign bus_power_reset_n  = ~power_reset;

//external power_reset_n - low by rc, external input
reg power_reset_n;
assign power_reset  = ~power_reset_n;

// external
wire busint_lm_reset_n;

assign clock_reset_n = !(power_reset | !busint_lm_reset_n);

assign prog_boot = ldmode & spy[7];

assign boot1_n = 1;
assign boot2_n = 1;

assign boot_n  = !(!boot1_n | (!boot2_n | prog_boot));

always @(posedge CLK5 or clock_reset_n or boot_n)
  if (clock_reset_n == 0)
    boot_trap <= 0;
  else
    if (boot_n == 0)
      boot_trap <= 1;
    else
      if (srun == 1)
        boot_trap <= 0;


// page OPCS

reg[13:0] opc;
wire opcclka, opcinha;

assign opcclka = !(~CLK5 | opcclk);
assign opcinha = !opcinh_n;

always @(posedge opcinha or posedge opcclka)
  opc <= pc[13:0];

initial
  opc = 0;

// With the machine stopped, taking OPCCLK high then low will
// generate a clock to just the OPCS.
// Setting OPCINH high will prevent the OPCS from clocking when
// the machine runs.  Only change OPCINH when CLK is high 
// (e.g. machine stopped).


// page PCTL
wire promenable_n, promce0_n, promce1_n, bottom_1k;

assign bottom_1k = !(pc[13] | pc[12] | pc[11] | pc[10]);
assign promenable_n = !(bottom_1k & idebug_n & promdisabled_n & iwrited_n);

assign promce0_n = promenable_n | pc[9];
assign promce1_n = prompc_n[9] | promenable_n ;

// page PROM0

wire[11:0] prompc_n = ~pc[11:0];

part_1kx49prom  i_PROM0 (
  .A(prompc_n),
  .D(i),
  .CE_N(promce0_n)
);

// page IRAM

part_16kx49ram  i_VMEM2 (
  .A( pc[11:0] ),
  .DO(i),
  .DI(iwr),
  .WE_N(iwe_n),
  .CE_N(1'b0/*ice*/)
);

// page SPY0

wire[3:0] eadr;
wire spy_obh_n, spy_obl_n, spy_pc_n, spy_opc_n,
	spu_nc_n,spy_irh_n, spy_irm_n, spy_irl_n;

wire spy_sth_n, spy_stl_n, spy_ah_n, spy_al_n,
	spy_mh_n, spy_ml_n, spy_flag2_n, spy_flag1_n;

wire ldmode_n, ldopc_n, ldclk_n, lddbirh_n, lddbirm_n, lddbirl_n;

//external
wire dbread;
assign dbread = 0;

assign {spy_obh_n, spy_obl_n, spy_pc_n, spy_opc_n,
	spu_nc_n,spy_irh_n, spy_irm_n, spy_irl_n} =
  (~eadr[3] & ~dbread) ? 8'b00000000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b000) ? 8'b00000001 :
	({eadr[2],eadr[1],eadr[0]} == 3'b001) ? 8'b00000010 :
	({eadr[2],eadr[1],eadr[0]} == 3'b010) ? 8'b00000100 :
	({eadr[2],eadr[1],eadr[0]} == 3'b011) ? 8'b00001000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b100) ? 8'b00010000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b101) ? 8'b00100000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b110) ? 8'b01000000 :
	                                        8'b10000000;

assign {spy_sth_n,spy_stl_n,spy_ah_n,spy_al_n,
	spy_mh_n,spy_ml_n,spy_flag2_n,spy_flag1_n} =
  (eadr[3] & ~dbread) ? 8'b00000000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b000) ? 8'b00000001 :
	({eadr[2],eadr[1],eadr[0]} == 3'b001) ? 8'b00000010 :
	({eadr[2],eadr[1],eadr[0]} == 3'b010) ? 8'b00000100 :
	({eadr[2],eadr[1],eadr[0]} == 3'b011) ? 8'b00001000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b100) ? 8'b00010000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b101) ? 8'b00100000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b110) ? 8'b01000000 :
	                                        8'b10000000;

assign {ldmode_n,ldopc_n,ldclk_n,
	lddbirh_n,lddbirm_n,lddbirl_n} =
  (~dbread) ? 6'b000000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b000) ? 6'b000001 :
	({eadr[2],eadr[1],eadr[0]} == 3'b001) ? 6'b000010 :
	({eadr[2],eadr[1],eadr[0]} == 3'b010) ? 6'b000100 :
	({eadr[2],eadr[1],eadr[0]} == 3'b011) ? 6'b001000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b100) ? 6'b010000 :
	({eadr[2],eadr[1],eadr[0]} == 3'b101) ? 6'b100000 :
	                                        6'b000000;


// *******
// Clocks
// This circuitry is lifted from the LM-2, which replaced the delay
// lines with a clock chain.
// *******

//xxx need to clean these up
wire CLK1, CLK2, CLK3, CLK4, CLK5, MCLK1;
wire clk0_n, mclk0_n;

assign mclk0_n  = tpclk_n;
assign MCLK1 = !mclk0_n;

assign CLK1 = !clk0_n;
assign CLK2 = !clk0_n;
assign CLK3 = !clk0_n;
assign CLK4 = !clk0_n;
assign CLK5 = !clk0_n;
assign clk0_n = tpclk_n & machrun;

// LM-2 clocks

reg osc50mhz;
wire osc0, hifreq1, hifreq2, hf_n , hfdlyd, hftomm;
wire clk_n, mclk_n, tpclk, tpclk_n, lclk, lclk_n, wp, lwp_n;
wire tse, ltse, ltse_n;
wire tpr0_n, tpr0a, tpr0d, tpr0d_n;
wire tpr1a, tpr1d_n;
wire tpwp, sone_n, tprend_n;

reg tpr1, tpr1_n, ff1d;
reg tpr6_n, tpr5, tpr5_n, tpr4, tpr4_n, tpr3, tpr3_n, tpr2, tpr2_n;
reg tpw0, tpw0_n, tpw1, tpw1_n, tpw2, tpw2_n, tpw3, tpw3_n;

wire tpwpor1, tpwpiram;
wire tptse, tptsef, tptsef_n, maskc, ff1, ff1_n;
reg tendly_n, hangs_n, crbs_n;
wire hang_n;
wire machruna, iwe_n;
reg machruna_n;

reg sspeed1a, sspeed0a;

// -------

assign mclk_n = tpclk_n & 1'b1;
assign clk_n = tpclk_n & machruna;

assign lclk = ! clk_n ;
assign lclk_n = ! lclk ;
assign ltse_n = ! tptse ;
assign tse = ! ltse_n ;
assign lwp_n = ! tpwp ;
assign wp = ! lwp_n ;

assign tpr0a = ! tpr0_n ;
assign tpr0d_n = ! tpr0a;
assign tpr1a = ! tpr1_n ;
assign tpr1d_n = ! tpr1a ;
assign machruna = ! machruna ;

assign tpwp = tpw1 & crbs_n & machruna;
// ?? tpwpor1
assign tpwpiram = tpwpor1 & crbs_n & machruna;

assign tptsef = ! ( tpr1d_n & crbs_n & tptsef_n );
assign iwe_n = ! ( iwrited & tpwpiram );
assign tpclk_n = ! (tpw0_n & crbs_n & tpclk );

always @(posedge hifreq1)
  begin
    tpr6_n <= tpr5;
    tpw3 <= tpw2;
    tpw3_n <= !tpw2;
    tpw2 <= tpw1;
    tpw2_n <= !tpw1;
    tpw1 <= tpw0;
    tpw1_n <= !tpw0;

    tpr5 <= tpr4;
    tpr5_n <= !tpr4;

    tpr4 <= tpr3;
    tpr4_n <= !tpr3;

    tpr3 <= tpr2;
    tpr3_n <= !tpr2;

    tpr2_n <= sone_n ;
    tpr2 <= !sone_n ;
  end

assign maskc = ! ( tendly_n & tpr1_n );
assign ff1_n = ! ( tpr1_n & ff1 );
assign tpclk = ! ( tpclk_n & tpr0_n );
assign tptsef_n = ! ( tpr0d_n & tptsef );

assign tpwpor1 = !( tpw0_n & tpw1_n );
assign tptse = !(tptsef_n & machruna);

assign osc0 = !osc50mhz;
assign hifreq1 = !osc0;
assign hifreq2 = !osc0;
assign hf_n = !hifreq2;
assign hfdlyd = !hf_n;
assign hftomm = !hfdlyd;

always @(posedge hifreq1)
  begin
    ff1d <= ff1;
    tpr1_n <= tpr0_n ;
    tpr1 <= !tpr0_n ;
  end

assign ff1 = !(tpw2_n & crbs_n & ff1_n);
assign tpr0_n = !(ff1d & hangs_n & crbs_n);
assign sone_n = !(tpr1 & tpr3_n & tpr4_n);

assign tprend_n = ! (
  ( { sspeed1a, sspeed0a, ilong_n } == 3'b000 ) ? tpr6_n :
  ( { sspeed1a, sspeed0a, ilong_n } == 3'b001 ) ? tpr5_n :
  ( { sspeed1a, sspeed0a, ilong_n } == 3'b010 ) ? tpr5_n :
  ( { sspeed1a, sspeed0a, ilong_n } == 3'b011 ) ? tpr4_n :
  ( { sspeed1a, sspeed0a, ilong_n } == 3'b100 ) ? tpr4_n :
  ( { sspeed1a, sspeed0a, ilong_n } == 3'b101 ) ? tpr3_n :
  ( { sspeed1a, sspeed0a, ilong_n } == 3'b110 ) ? tpr4_n :
    tpr2_n );

always @(posedge tpr1)
  if (clock_reset_n)
    begin
      speed1a <= speed1;
      speed0a <= speed0;
      sspeed1a <= speed1a;
      sspeed0a <= speed0a;
    end

always @(clock_reset_n)
  if (clock_reset_n == 0)
  begin
    speed1a = 0;
    speed0a = 0;
    sspeed1a = 0;
    sspeed0a = 0;
  end

always @(posedge hfdlyd)
  tendly_n <= tprend_n;

always @(posedge hifreq2)
  begin
    tpw0_n <= maskc;
    tpw0 <= !maskc;

    hangs_n <= hang_n;
    crbs_n <= clock_reset_n ;
  end


initial
  begin
    ff1d = 0;
    crbs_n = 0;
    tpw2_n = 0;
  end


// *******
// Resets!
// *******

//assign tse = !tptse;

initial
  begin
  end

endmodule


module test;
  caddr cpu ();

  initial
    begin
      $dumpfile("caddr.vcd");
      $dumpvars(0, test.cpu);
    end

  initial
    begin
      cpu.osc50mhz = 0;
//      cpu.clock_reset_n = 1;
//      cpu.machruna = 0;
//      cpu.hang_n = 1;
//      #1 cpu.clock_reset_n = 0;
//      #250 cpu.clock_reset_n = 1;

      cpu.power_reset_n = 1;

      #1 cpu.power_reset_n = 0;
      #250 cpu.power_reset_n = 1;

      #500 $finish;
    end

  // 50mhz clock
  always
    begin
      #10 cpu.osc50mhz = 0;
      #10 cpu.osc50mhz = 1;
    end

endmodule