// =====================================================================================
// (C) COPYRIGHT 2016 YongaTek (Yonga Technology Microelectronics)
// All rights reserved.
// This file contains confidential and proprietary information of YongaTek and
// is protected under international copyright and other intellectual property laws.
// =====================================================================================
// Project           : GCU
// File ID           : %%
// Design Unit Name  : Modbus_UART_Controller.vhd
// Description       : Modbus UART Controller
// Comments          :
// Revision          : %%
// Last Changed Date : %%
// Last Changed By   : %%
// Designer
//          Name     : Burak Yakup Çakar
//          E-mail   : burak.cakar@yongatek.com
// =====================================================================================

module Modbus_UART_Controller #(
    parameter   clkdiv = 868 // Assumed 100 MHz clock frequency
    )
    (
    // Clock, reset and enable pins
    input       i_clk,
    input       i_rst,
    input       i_enable,
    // Interface with Modbus top module
    input       [7:0] i_tx_data,
    output reg  o_tx_ready,
    input       i_tx_wren,
    output      [7:0] o_rx_data,
    output reg  o_rx_ready,
    input       i_rx_rden,
    // UART interface
    input       i_rx,
    output      o_tx
    );

    // UART RX signals
    wire        uart_rx_dv;
    wire [7:0]  uart_rx_byte;

    // UART TX signals
    wire        uart_tx_dv;
    wire [7:0]  uart_tx_byte;
    wire        uart_tx_done;

    // UART RX instantiation
    uart_rx #(clkdiv) uart_rx_inst(
        .i_Clock(i_clk),
        .i_Rx_Serial(i_rx),
        .o_Rx_DV(uart_rx_dv),
        .o_Rx_Byte(uart_rx_byte)
        );

    // UART TX instantiation
    uart_tx #(clkdiv) uart_tx_inst(
        .i_Clock(i_clk),
        .i_Tx_DV(uart_tx_dv),
        .i_Tx_Byte(uart_tx_byte),
        .o_Tx_Active(),
        .o_Tx_Serial(o_tx),
        .o_Tx_Done(uart_tx_done)
        );

    assign uart_tx_byte     = i_tx_data;
    assign uart_tx_dv       = i_tx_wren;

    assign o_rx_data        = uart_rx_byte;

    // Control UART RX
    always @(posedge i_clk) begin
        if (i_rst) begin
            o_rx_ready  <= 1'b0;
        end
        else begin
            if (uart_rx_dv)     o_rx_ready  <= 1'b1;
            if (i_rx_rden)      o_rx_ready  <= 1'b0;
        end
    end

    // Control UART TX
    always @(posedge i_clk) begin
        if (i_rst) begin
            o_tx_ready  <= 1'b1;
        end
        else begin
            if (uart_tx_done)   o_tx_ready  <= 1'b1;
            if (i_tx_wren)      o_tx_ready  <= 1'b0;
        end
    end
endmodule
