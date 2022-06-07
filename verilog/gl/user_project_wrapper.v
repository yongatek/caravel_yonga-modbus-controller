module user_project_wrapper (user_clock2,
    vccd1,
    vccd2,
    vdda1,
    vdda2,
    vssa1,
    vssa2,
    vssd1,
    vssd2,
    wb_clk_i,
    wb_rst_i,
    wbs_ack_o,
    wbs_cyc_i,
    wbs_stb_i,
    wbs_we_i,
    analog_io,
    io_in,
    io_oeb,
    io_out,
    la_data_in,
    la_data_out,
    la_oenb,
    user_irq,
    wbs_adr_i,
    wbs_dat_i,
    wbs_dat_o,
    wbs_sel_i);
 input user_clock2;
 input vccd1;
 input vccd2;
 input vdda1;
 input vdda2;
 input vssa1;
 input vssa2;
 input vssd1;
 input vssd2;
 input wb_clk_i;
 input wb_rst_i;
 output wbs_ack_o;
 input wbs_cyc_i;
 input wbs_stb_i;
 input wbs_we_i;
 inout [28:0] analog_io;
 input [37:0] io_in;
 output [37:0] io_oeb;
 output [37:0] io_out;
 input [127:0] la_data_in;
 output [127:0] la_data_out;
 input [127:0] la_oenb;
 output [2:0] user_irq;
 input [31:0] wbs_adr_i;
 input [31:0] wbs_dat_i;
 output [31:0] wbs_dat_o;
 input [3:0] wbs_sel_i;

 wire \sram_addr0[0] ;
 wire \sram_addr0[1] ;
 wire \sram_addr0[2] ;
 wire \sram_addr0[3] ;
 wire \sram_addr0[4] ;
 wire \sram_addr0[5] ;
 wire \sram_addr0[6] ;
 wire \sram_addr0[7] ;
 wire \sram_addr1[0] ;
 wire \sram_addr1[1] ;
 wire \sram_addr1[2] ;
 wire \sram_addr1[3] ;
 wire \sram_addr1[4] ;
 wire \sram_addr1[5] ;
 wire \sram_addr1[6] ;
 wire \sram_addr1[7] ;
 wire sram_csb0;
 wire sram_csb1;
 wire \sram_din0[0] ;
 wire \sram_din0[10] ;
 wire \sram_din0[11] ;
 wire \sram_din0[12] ;
 wire \sram_din0[13] ;
 wire \sram_din0[14] ;
 wire \sram_din0[15] ;
 wire \sram_din0[16] ;
 wire \sram_din0[17] ;
 wire \sram_din0[18] ;
 wire \sram_din0[19] ;
 wire \sram_din0[1] ;
 wire \sram_din0[20] ;
 wire \sram_din0[21] ;
 wire \sram_din0[22] ;
 wire \sram_din0[23] ;
 wire \sram_din0[24] ;
 wire \sram_din0[25] ;
 wire \sram_din0[26] ;
 wire \sram_din0[27] ;
 wire \sram_din0[28] ;
 wire \sram_din0[29] ;
 wire \sram_din0[2] ;
 wire \sram_din0[30] ;
 wire \sram_din0[31] ;
 wire \sram_din0[3] ;
 wire \sram_din0[4] ;
 wire \sram_din0[5] ;
 wire \sram_din0[6] ;
 wire \sram_din0[7] ;
 wire \sram_din0[8] ;
 wire \sram_din0[9] ;
 wire \sram_dout0[0] ;
 wire \sram_dout0[10] ;
 wire \sram_dout0[11] ;
 wire \sram_dout0[12] ;
 wire \sram_dout0[13] ;
 wire \sram_dout0[14] ;
 wire \sram_dout0[15] ;
 wire \sram_dout0[16] ;
 wire \sram_dout0[17] ;
 wire \sram_dout0[18] ;
 wire \sram_dout0[19] ;
 wire \sram_dout0[1] ;
 wire \sram_dout0[20] ;
 wire \sram_dout0[21] ;
 wire \sram_dout0[22] ;
 wire \sram_dout0[23] ;
 wire \sram_dout0[24] ;
 wire \sram_dout0[25] ;
 wire \sram_dout0[26] ;
 wire \sram_dout0[27] ;
 wire \sram_dout0[28] ;
 wire \sram_dout0[29] ;
 wire \sram_dout0[2] ;
 wire \sram_dout0[30] ;
 wire \sram_dout0[31] ;
 wire \sram_dout0[3] ;
 wire \sram_dout0[4] ;
 wire \sram_dout0[5] ;
 wire \sram_dout0[6] ;
 wire \sram_dout0[7] ;
 wire \sram_dout0[8] ;
 wire \sram_dout0[9] ;
 wire \sram_dout1[0] ;
 wire \sram_dout1[10] ;
 wire \sram_dout1[11] ;
 wire \sram_dout1[12] ;
 wire \sram_dout1[13] ;
 wire \sram_dout1[14] ;
 wire \sram_dout1[15] ;
 wire \sram_dout1[16] ;
 wire \sram_dout1[17] ;
 wire \sram_dout1[18] ;
 wire \sram_dout1[19] ;
 wire \sram_dout1[1] ;
 wire \sram_dout1[20] ;
 wire \sram_dout1[21] ;
 wire \sram_dout1[22] ;
 wire \sram_dout1[23] ;
 wire \sram_dout1[24] ;
 wire \sram_dout1[25] ;
 wire \sram_dout1[26] ;
 wire \sram_dout1[27] ;
 wire \sram_dout1[28] ;
 wire \sram_dout1[29] ;
 wire \sram_dout1[2] ;
 wire \sram_dout1[30] ;
 wire \sram_dout1[31] ;
 wire \sram_dout1[3] ;
 wire \sram_dout1[4] ;
 wire \sram_dout1[5] ;
 wire \sram_dout1[6] ;
 wire \sram_dout1[7] ;
 wire \sram_dout1[8] ;
 wire \sram_dout1[9] ;
 wire sram_web0;
 wire \sram_wmask0[0] ;
 wire \sram_wmask0[1] ;
 wire \sram_wmask0[2] ;
 wire \sram_wmask0[3] ;

 Modbus_w_RegSpace_Controller Modbus_w_RegSpace_Controller_inst (.i_clk(wb_clk_i),
    .i_rst(wb_rst_i),
    .i_rx(io_in[9]),
    .i_wbs_cyc(wbs_cyc_i),
    .i_wbs_stb(wbs_stb_i),
    .i_wbs_we(wbs_we_i),
    .o_tx(io_out[8]),
    .o_wbs_ack(wbs_ack_o),
    .sram_csb0(sram_csb0),
    .sram_csb1(sram_csb1),
    .sram_web0(sram_web0),
    .vccd1(vccd1),
    .vssd1(vssd1),
    .i_wbs_adr({wbs_adr_i[31],
    wbs_adr_i[30],
    wbs_adr_i[29],
    wbs_adr_i[28],
    wbs_adr_i[27],
    wbs_adr_i[26],
    wbs_adr_i[25],
    wbs_adr_i[24],
    wbs_adr_i[23],
    wbs_adr_i[22],
    wbs_adr_i[21],
    wbs_adr_i[20],
    wbs_adr_i[19],
    wbs_adr_i[18],
    wbs_adr_i[17],
    wbs_adr_i[16],
    wbs_adr_i[15],
    wbs_adr_i[14],
    wbs_adr_i[13],
    wbs_adr_i[12],
    wbs_adr_i[11],
    wbs_adr_i[10],
    wbs_adr_i[9],
    wbs_adr_i[8],
    wbs_adr_i[7],
    wbs_adr_i[6],
    wbs_adr_i[5],
    wbs_adr_i[4],
    wbs_adr_i[3],
    wbs_adr_i[2],
    wbs_adr_i[1],
    wbs_adr_i[0]}),
    .i_wbs_dat({wbs_dat_i[31],
    wbs_dat_i[30],
    wbs_dat_i[29],
    wbs_dat_i[28],
    wbs_dat_i[27],
    wbs_dat_i[26],
    wbs_dat_i[25],
    wbs_dat_i[24],
    wbs_dat_i[23],
    wbs_dat_i[22],
    wbs_dat_i[21],
    wbs_dat_i[20],
    wbs_dat_i[19],
    wbs_dat_i[18],
    wbs_dat_i[17],
    wbs_dat_i[16],
    wbs_dat_i[15],
    wbs_dat_i[14],
    wbs_dat_i[13],
    wbs_dat_i[12],
    wbs_dat_i[11],
    wbs_dat_i[10],
    wbs_dat_i[9],
    wbs_dat_i[8],
    wbs_dat_i[7],
    wbs_dat_i[6],
    wbs_dat_i[5],
    wbs_dat_i[4],
    wbs_dat_i[3],
    wbs_dat_i[2],
    wbs_dat_i[1],
    wbs_dat_i[0]}),
    .i_wbs_sel({wbs_sel_i[3],
    wbs_sel_i[2],
    wbs_sel_i[1],
    wbs_sel_i[0]}),
    .o_wbs_dat({wbs_dat_o[31],
    wbs_dat_o[30],
    wbs_dat_o[29],
    wbs_dat_o[28],
    wbs_dat_o[27],
    wbs_dat_o[26],
    wbs_dat_o[25],
    wbs_dat_o[24],
    wbs_dat_o[23],
    wbs_dat_o[22],
    wbs_dat_o[21],
    wbs_dat_o[20],
    wbs_dat_o[19],
    wbs_dat_o[18],
    wbs_dat_o[17],
    wbs_dat_o[16],
    wbs_dat_o[15],
    wbs_dat_o[14],
    wbs_dat_o[13],
    wbs_dat_o[12],
    wbs_dat_o[11],
    wbs_dat_o[10],
    wbs_dat_o[9],
    wbs_dat_o[8],
    wbs_dat_o[7],
    wbs_dat_o[6],
    wbs_dat_o[5],
    wbs_dat_o[4],
    wbs_dat_o[3],
    wbs_dat_o[2],
    wbs_dat_o[1],
    wbs_dat_o[0]}),
    .sram_addr0({\sram_addr0[7] ,
    \sram_addr0[6] ,
    \sram_addr0[5] ,
    \sram_addr0[4] ,
    \sram_addr0[3] ,
    \sram_addr0[2] ,
    \sram_addr0[1] ,
    \sram_addr0[0] }),
    .sram_addr1({\sram_addr1[7] ,
    \sram_addr1[6] ,
    \sram_addr1[5] ,
    \sram_addr1[4] ,
    \sram_addr1[3] ,
    \sram_addr1[2] ,
    \sram_addr1[1] ,
    \sram_addr1[0] }),
    .sram_din0({\sram_din0[31] ,
    \sram_din0[30] ,
    \sram_din0[29] ,
    \sram_din0[28] ,
    \sram_din0[27] ,
    \sram_din0[26] ,
    \sram_din0[25] ,
    \sram_din0[24] ,
    \sram_din0[23] ,
    \sram_din0[22] ,
    \sram_din0[21] ,
    \sram_din0[20] ,
    \sram_din0[19] ,
    \sram_din0[18] ,
    \sram_din0[17] ,
    \sram_din0[16] ,
    \sram_din0[15] ,
    \sram_din0[14] ,
    \sram_din0[13] ,
    \sram_din0[12] ,
    \sram_din0[11] ,
    \sram_din0[10] ,
    \sram_din0[9] ,
    \sram_din0[8] ,
    \sram_din0[7] ,
    \sram_din0[6] ,
    \sram_din0[5] ,
    \sram_din0[4] ,
    \sram_din0[3] ,
    \sram_din0[2] ,
    \sram_din0[1] ,
    \sram_din0[0] }),
    .sram_dout0({\sram_dout0[31] ,
    \sram_dout0[30] ,
    \sram_dout0[29] ,
    \sram_dout0[28] ,
    \sram_dout0[27] ,
    \sram_dout0[26] ,
    \sram_dout0[25] ,
    \sram_dout0[24] ,
    \sram_dout0[23] ,
    \sram_dout0[22] ,
    \sram_dout0[21] ,
    \sram_dout0[20] ,
    \sram_dout0[19] ,
    \sram_dout0[18] ,
    \sram_dout0[17] ,
    \sram_dout0[16] ,
    \sram_dout0[15] ,
    \sram_dout0[14] ,
    \sram_dout0[13] ,
    \sram_dout0[12] ,
    \sram_dout0[11] ,
    \sram_dout0[10] ,
    \sram_dout0[9] ,
    \sram_dout0[8] ,
    \sram_dout0[7] ,
    \sram_dout0[6] ,
    \sram_dout0[5] ,
    \sram_dout0[4] ,
    \sram_dout0[3] ,
    \sram_dout0[2] ,
    \sram_dout0[1] ,
    \sram_dout0[0] }),
    .sram_dout1({\sram_dout1[31] ,
    \sram_dout1[30] ,
    \sram_dout1[29] ,
    \sram_dout1[28] ,
    \sram_dout1[27] ,
    \sram_dout1[26] ,
    \sram_dout1[25] ,
    \sram_dout1[24] ,
    \sram_dout1[23] ,
    \sram_dout1[22] ,
    \sram_dout1[21] ,
    \sram_dout1[20] ,
    \sram_dout1[19] ,
    \sram_dout1[18] ,
    \sram_dout1[17] ,
    \sram_dout1[16] ,
    \sram_dout1[15] ,
    \sram_dout1[14] ,
    \sram_dout1[13] ,
    \sram_dout1[12] ,
    \sram_dout1[11] ,
    \sram_dout1[10] ,
    \sram_dout1[9] ,
    \sram_dout1[8] ,
    \sram_dout1[7] ,
    \sram_dout1[6] ,
    \sram_dout1[5] ,
    \sram_dout1[4] ,
    \sram_dout1[3] ,
    \sram_dout1[2] ,
    \sram_dout1[1] ,
    \sram_dout1[0] }),
    .sram_wmask0({\sram_wmask0[3] ,
    \sram_wmask0[2] ,
    \sram_wmask0[1] ,
    \sram_wmask0[0] }));
 sky130_sram_1kbyte_1rw1r_32x256_8 sram_inst (.csb0(sram_csb0),
    .csb1(sram_csb1),
    .web0(sram_web0),
    .clk0(wb_clk_i),
    .clk1(wb_clk_i),
    .vccd1(vccd1),
    .vssd1(vssd1),
    .addr0({\sram_addr0[7] ,
    \sram_addr0[6] ,
    \sram_addr0[5] ,
    \sram_addr0[4] ,
    \sram_addr0[3] ,
    \sram_addr0[2] ,
    \sram_addr0[1] ,
    \sram_addr0[0] }),
    .addr1({\sram_addr1[7] ,
    \sram_addr1[6] ,
    \sram_addr1[5] ,
    \sram_addr1[4] ,
    \sram_addr1[3] ,
    \sram_addr1[2] ,
    \sram_addr1[1] ,
    \sram_addr1[0] }),
    .din0({\sram_din0[31] ,
    \sram_din0[30] ,
    \sram_din0[29] ,
    \sram_din0[28] ,
    \sram_din0[27] ,
    \sram_din0[26] ,
    \sram_din0[25] ,
    \sram_din0[24] ,
    \sram_din0[23] ,
    \sram_din0[22] ,
    \sram_din0[21] ,
    \sram_din0[20] ,
    \sram_din0[19] ,
    \sram_din0[18] ,
    \sram_din0[17] ,
    \sram_din0[16] ,
    \sram_din0[15] ,
    \sram_din0[14] ,
    \sram_din0[13] ,
    \sram_din0[12] ,
    \sram_din0[11] ,
    \sram_din0[10] ,
    \sram_din0[9] ,
    \sram_din0[8] ,
    \sram_din0[7] ,
    \sram_din0[6] ,
    \sram_din0[5] ,
    \sram_din0[4] ,
    \sram_din0[3] ,
    \sram_din0[2] ,
    \sram_din0[1] ,
    \sram_din0[0] }),
    .dout0({\sram_dout0[31] ,
    \sram_dout0[30] ,
    \sram_dout0[29] ,
    \sram_dout0[28] ,
    \sram_dout0[27] ,
    \sram_dout0[26] ,
    \sram_dout0[25] ,
    \sram_dout0[24] ,
    \sram_dout0[23] ,
    \sram_dout0[22] ,
    \sram_dout0[21] ,
    \sram_dout0[20] ,
    \sram_dout0[19] ,
    \sram_dout0[18] ,
    \sram_dout0[17] ,
    \sram_dout0[16] ,
    \sram_dout0[15] ,
    \sram_dout0[14] ,
    \sram_dout0[13] ,
    \sram_dout0[12] ,
    \sram_dout0[11] ,
    \sram_dout0[10] ,
    \sram_dout0[9] ,
    \sram_dout0[8] ,
    \sram_dout0[7] ,
    \sram_dout0[6] ,
    \sram_dout0[5] ,
    \sram_dout0[4] ,
    \sram_dout0[3] ,
    \sram_dout0[2] ,
    \sram_dout0[1] ,
    \sram_dout0[0] }),
    .dout1({\sram_dout1[31] ,
    \sram_dout1[30] ,
    \sram_dout1[29] ,
    \sram_dout1[28] ,
    \sram_dout1[27] ,
    \sram_dout1[26] ,
    \sram_dout1[25] ,
    \sram_dout1[24] ,
    \sram_dout1[23] ,
    \sram_dout1[22] ,
    \sram_dout1[21] ,
    \sram_dout1[20] ,
    \sram_dout1[19] ,
    \sram_dout1[18] ,
    \sram_dout1[17] ,
    \sram_dout1[16] ,
    \sram_dout1[15] ,
    \sram_dout1[14] ,
    \sram_dout1[13] ,
    \sram_dout1[12] ,
    \sram_dout1[11] ,
    \sram_dout1[10] ,
    \sram_dout1[9] ,
    \sram_dout1[8] ,
    \sram_dout1[7] ,
    \sram_dout1[6] ,
    \sram_dout1[5] ,
    \sram_dout1[4] ,
    \sram_dout1[3] ,
    \sram_dout1[2] ,
    \sram_dout1[1] ,
    \sram_dout1[0] }),
    .wmask0({\sram_wmask0[3] ,
    \sram_wmask0[2] ,
    \sram_wmask0[1] ,
    \sram_wmask0[0] }));
 assign io_oeb[0] = wb_rst_i;
 assign io_oeb[10] = wb_rst_i;
 assign io_oeb[11] = wb_rst_i;
 assign io_oeb[12] = wb_rst_i;
 assign io_oeb[13] = wb_rst_i;
 assign io_oeb[14] = wb_rst_i;
 assign io_oeb[15] = wb_rst_i;
 assign io_oeb[16] = wb_rst_i;
 assign io_oeb[17] = wb_rst_i;
 assign io_oeb[18] = wb_rst_i;
 assign io_oeb[19] = wb_rst_i;
 assign io_oeb[1] = wb_rst_i;
 assign io_oeb[20] = wb_rst_i;
 assign io_oeb[21] = wb_rst_i;
 assign io_oeb[22] = wb_rst_i;
 assign io_oeb[23] = wb_rst_i;
 assign io_oeb[24] = wb_rst_i;
 assign io_oeb[25] = wb_rst_i;
 assign io_oeb[26] = wb_rst_i;
 assign io_oeb[27] = wb_rst_i;
 assign io_oeb[28] = wb_rst_i;
 assign io_oeb[29] = wb_rst_i;
 assign io_oeb[2] = wb_rst_i;
 assign io_oeb[30] = wb_rst_i;
 assign io_oeb[31] = wb_rst_i;
 assign io_oeb[32] = wb_rst_i;
 assign io_oeb[33] = wb_rst_i;
 assign io_oeb[34] = wb_rst_i;
 assign io_oeb[35] = wb_rst_i;
 assign io_oeb[36] = wb_rst_i;
 assign io_oeb[37] = wb_rst_i;
 assign io_oeb[3] = wb_rst_i;
 assign io_oeb[4] = wb_rst_i;
 assign io_oeb[5] = wb_rst_i;
 assign io_oeb[6] = wb_rst_i;
 assign io_oeb[7] = wb_rst_i;
 assign io_oeb[8] = wb_rst_i;
 assign io_oeb[9] = wb_rst_i;
endmodule
