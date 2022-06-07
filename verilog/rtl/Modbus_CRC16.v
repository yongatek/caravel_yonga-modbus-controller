// =====================================================================================
// (C) COPYRIGHT 2016 YongaTek (Yonga Technology Microelectronics)
// All rights reserved.
// This file contains confidential and proprietary information of YongaTek and
// is protected under international copyright and other intellectual property laws.
// =====================================================================================
// Project           : GCU
// File ID           : %%
// Design Unit Name  : Modbus_CRC16.vhd
// Description       : 16 bit CRC for Modbus
// Comments          :
// Revision          : %%
// Last Changed Date : %%
// Last Changed By   : %%
// Designer
//          Name     : Burak Yakup Çakar
//          E-mail   : burak.cakar@yongatek.com
// =====================================================================================

module Modbus_CRC16(
    // Clock, reset and enable pins
    input               i_clk,
    input               i_rst,
    input               i_enable,
    // Interface with top module
    input       [7:0]   i_data,
    input               i_start,
    output reg  [15:0]  o_crc16,
    output reg          o_done
    );

    // State declaration
    localparam IDLE         = 2'b00;
    localparam START_CRC    = 2'b01;
    localparam ITERATE      = 2'b10;

    // CRC16 polinom
    localparam polinom      = 16'hA001;

    reg  [3:0]  iters;

    reg  [7:0]  data;

    reg  [1:0]  state;

    always @(posedge i_clk) begin
        if (i_rst) begin
            o_crc16 <= 16'hffff;
            o_done  <= 1'b0;
            
            iters 	<= 4'h0;

            state   <= IDLE;
        end
        else begin
            if (i_enable) begin
                o_done          <= 1'b0;

                case (state)
                    IDLE : begin
                        if (i_start) begin
                            data        <= i_data;
                            state       <= START_CRC;
                        end
                        else state      <= IDLE;
                    end
                    START_CRC : begin
                        o_crc16[7:0]    <= o_crc16[7:0] ^ data;

                        state           <= ITERATE;
                    end
                    ITERATE : begin
                        if (iters < 8) begin
                            if (o_crc16[0] == 1'b1) o_crc16 <= {1'b0, o_crc16[15:1]} ^ polinom;
                            else o_crc16 <= {1'b0, o_crc16[15:1]};

                            iters       <= iters + 1;
                        end
                        else begin
                            iters       <= 4'h0;

                            o_done      <= 1'b1;

                            state       <= IDLE;
                        end
                    end
                    default : state <= IDLE;
                endcase
            end
        end
    end
endmodule
