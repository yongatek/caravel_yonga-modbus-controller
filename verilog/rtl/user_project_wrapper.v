// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

    wire        sram_csb0; // active low chip select
    wire        sram_web0; // active low write control
    wire [3:0]  sram_wmask0; // write mask
    wire [7:0]  sram_addr0;
    wire [31:0] sram_din0;
    wire [31:0] sram_dout0;
    wire        sram_csb1; // active low chip select
    wire [7:0]  sram_addr1;
    wire [31:0] sram_dout1;

assign io_oeb = {`MPRJ_IO_PADS{wb_rst_i}};

Modbus_w_RegSpace_Controller Modbus_w_RegSpace_Controller_inst(
    // Power pins
    `ifdef USE_POWER_PINS
        .vccd1(vccd1), //VDD
        .vssd1(vssd1), //GND
    `endif
    // Clock, reset and enable pins
    .i_clk(wb_clk_i),
    .i_rst(wb_rst_i),
    // Wishbone interface
    .i_wbs_stb(wbs_stb_i),
    .i_wbs_cyc(wbs_cyc_i),
    .i_wbs_we(wbs_we_i),
    .i_wbs_sel(wbs_sel_i),
    .i_wbs_dat(wbs_dat_i),
    .i_wbs_adr(wbs_adr_i),
    .o_wbs_ack(wbs_ack_o),
    .o_wbs_dat(wbs_dat_o),
    // SRAM interface
    .sram_csb0(sram_csb0), // active low chip select
    .sram_web0(sram_web0), // active low write control
    .sram_addr0(sram_addr0),
    .sram_din0(sram_din0),
    .sram_dout0(sram_dout0),
    .sram_wmask0(sram_wmask0), // write mask
    .sram_csb1(sram_csb1), // active low chip select
    .sram_addr1(sram_addr1),
    .sram_dout1(sram_dout1),
    // UART interface
    .i_rx(io_in[9]),
    .o_tx(io_out[8])
    );

sky130_sram_1kbyte_1rw1r_32x256_8 sram_inst(
`ifdef USE_POWER_PINS
    .vccd1(vccd1),
    .vssd1(vssd1),
`endif
  .clk0(wb_clk_i), // clock
  .csb0(sram_csb0), // active low chip select
  .web0(sram_web0), // active low write control
  .wmask0(sram_wmask0), // write mask
  .addr0(sram_addr0),
  .din0(sram_din0),
  .dout0(sram_dout0),
  .clk1(wb_clk_i), // clock
  .csb1(sram_csb1), // active low chip select
  .addr1(sram_addr1),
  .dout1(sram_dout1)
);

endmodule	// user_project_wrapper

`default_nettype wire
