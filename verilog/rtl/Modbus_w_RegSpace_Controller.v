// =====================================================================================
// (C) COPYRIGHT 2016 YongaTek (Yonga Technology Microelectronics)
// All rights reserved.
// This file contains confidential and proprietary information of YongaTek and
// is protected under international copyright and other intellectual property laws.
// =====================================================================================
// Project           : GCU
// File ID           : %%
// Design Unit Name  : Modbus_RegSpace_Top.vhd
// Description       : Modbus Register Space Top Module
// Comments          :
// Revision          : %%
// Last Changed Date : %%
// Last Changed By   : %%
// Designer
//          Name     : Burak Yakup Çakar
//          E-mail   : burak.cakar@yongatek.com
// =====================================================================================

module Modbus_w_RegSpace_Controller (
    // Power pins
    `ifdef USE_POWER_PINS
        inout vccd1, //VDD
        inout vssd1, //GND
    `endif
    // Clock, reset and enable pins
    input               i_clk,
    input               i_rst,
    // Wishbone interface
    input               i_wbs_stb,
    input               i_wbs_cyc,
    input               i_wbs_we,
    input       [3:0]   i_wbs_sel,
    input       [31:0]  i_wbs_dat,
    input       [31:0]  i_wbs_adr,
    output reg          o_wbs_ack,
    output      [31:0]  o_wbs_dat,
    // SRAM interface
    output              sram_csb0, // active low chip select
    output              sram_web0, // active low write control
    output      [7:0]   sram_addr0,
    output      [31:0]  sram_din0,
    input       [31:0]  sram_dout0,
    output      [3:0]   sram_wmask0, // write mask
    output              sram_csb1, // active low chip select
    output      [7:0]   sram_addr1,
    input       [31:0]  sram_dout1,
    // UART interface
    input               i_rx,
    output              o_tx
    );

    // Modbus controller interface
    wire [7:0]  controller_addr;
    wire        controller_wren;
    wire        controller_rden;
    wire [15:0] controller_dout;
    wire [15:0] controller_din;
    wire        controller_wrready;

    wire        wb_valid;

    assign wb_valid = i_wbs_cyc && i_wbs_stb;

    assign sram_addr0   = (wb_valid && i_wbs_we) ? i_wbs_adr[9:2] : controller_addr; // Processor only uses RW port when writing
    assign sram_web0    = (wb_valid && i_wbs_we) ? ~i_wbs_we : ~controller_wren; 
    assign sram_csb0    = i_rst;
    assign sram_din0    = { 16'h0000, (wb_valid) ? i_wbs_dat[15:0] : controller_din };


    assign controller_wrready = 1'b1;
    assign controller_dout    = (wb_valid) ? 0 : sram_dout0[15:0];
    assign o_wbs_dat          = (wb_valid) ? sram_dout1 : 0;

    assign sram_wmask0  = 4'hf;

    assign sram_csb1    = i_rst;
    assign sram_addr1   = i_wbs_adr[9:2];

    always @(posedge i_clk) begin
        if(i_rst) o_wbs_ack <= 1'b0;
        else begin
            if (wb_valid && !o_wbs_ack) o_wbs_ack <= 1'b1;
            else o_wbs_ack <= 1'b0;
        end
    end 

    Modbus_Top #(
        .device_id(8'h01), // Device address is 0x01
        .clk_freq(50000000), // 40 MHz clock frequency
        .baud_rate(115200) // 115200 Baud Rate
    ) Modbus_Top_inst
    (
        // Clock, reset and enable pins
        .i_clk(i_clk),
        .i_rst(i_rst),
        // Interface with register space
        .o_mem_addr(controller_addr),
        .o_mem_wren(controller_wren),
        .o_mem_rden(controller_rden),
        .i_mem_dout(controller_dout),
        .o_mem_din(controller_din),
        .i_mem_wrready(controller_wrready),
        // UART interface
        .i_rx(i_rx),
        .o_tx(o_tx)
    );

endmodule
