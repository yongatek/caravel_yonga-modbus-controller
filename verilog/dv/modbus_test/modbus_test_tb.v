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

`timescale 1 ns / 1 ps

module modbus_test_tb;
	reg clock;
	reg RSTB;
	reg CSB;
	reg power1, power2;
	reg power3, power4;

	wire gpio;
	wire [37:0] mprj_io;

	wire caravel_rx;
	wire caravel_tx;
	wire caravel_chip_ready;

	// Task variables

	reg modbus_check_err;

	reg  [7:0]	rx_byte;

	integer i;

	assign caravel_tx 			= mprj_io[8];
	assign mprj_io[9] 			= caravel_rx;
	assign caravel_chip_ready 	= mprj_io[10];

	reg	 reset;

	assign mprj_io[3] = 1'b1;

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	initial begin
		for (i = 0; i < 255; i = i + 1) uut.mprj.sram_inst.mem[i] = 0;
	end

	initial begin
		$dumpfile("modbus_test.vcd");
		$dumpvars(0, modbus_test_tb);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (250) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		`ifdef GL
			$display ("Monitor: Timeout, Modbus Test (GL) Failed");
		`else
			$display ("Monitor: Timeout, Modbus Test (RTL) Failed");
		`endif
		$display("%c[0m",27);
		$finish;
	end

	initial begin
		reset = 1'b1;

	   	wait(caravel_chip_ready);
	   	$display("Monitor: Modbus Test Started");

	   	reset = 1'b0;

	   	send_modbus_frame({8'h01, 8'h10, 8'h00, 8'h00, 8'h00, 8'h01, 8'h02, 8'h00, 8'h01, 8'h67, 8'h90}, 11);

	   	check_modbus_frame({8'h01, 8'h10, 8'h00, 8'h00, 8'h00, 8'h01, 8'h01, 8'hc9}, 8, 1);

	   	if (modbus_check_err) begin
	   	`ifdef GL
			$display ("Monitor: Frame Mismatch, Modbus Test (GL) Failed");
		`else
			$display ("Monitor: Frame Mismatch, Modbus Test (RTL) Failed");
		`endif
			$finish;
	   	end 

		
	   	send_modbus_frame({8'h01, 8'h03, 8'h00, 8'h80, 8'h00, 8'h04, 8'h45, 8'he1}, 8);

	   	check_modbus_frame({8'h01, 8'h03, 8'h08, 8'h59, 8'h6f, 8'h6e, 8'h67, 8'h61, 8'h74, 8'h65, 8'h6b, 8'hc7, 8'h98}, 13, 1);

	   	if (modbus_check_err) begin
	   	`ifdef GL
			$display ("Monitor: Frame Mismatch, Modbus Test (GL) Failed");
		`else
			$display ("Monitor: Frame Mismatch, Modbus Test (RTL) Failed");
		`endif
		  $finish;
	   	end 
	   	
		`ifdef GL
	    	$display("Monitor: Modbus Test (GL) Passed");
		`else
		    $display("Monitor: Modbus Test (RTL) Passed");
		`endif
	    $finish;
	end

	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#2000;
		RSTB <= 1'b1;	    	// Release reset
		#100000;
		CSB = 1'b0;		// CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		#200;
		power1 <= 1'b1;
		#200;
		power2 <= 1'b1;
	end

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	reg  [7:0] 	master_tx_data;
    wire 		master_tx_ready;
    reg       	master_tx_wren;
    wire [7:0]	master_rx_data;
    wire		master_rx_ready;
    reg       	master_rx_rden;

	caravel uut (
		.vddio	  (VDD3V3),
		.vddio_2  (VDD3V3),
		.vssio	  (VSS),
		.vssio_2  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda1_2  (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa1_2  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock    (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("modbus_test.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

	Modbus_UART_Controller #( 434 ) modbus_master
    (
    // Clock, reset and enable pins
    .i_clk(clock),
    .i_rst(reset),
    .i_enable(1'b1),
    // Interface with Modbus top module
    .i_tx_data(master_tx_data),
    .o_tx_ready(master_tx_ready),
    .i_tx_wren(master_tx_wren),
    .o_rx_data(master_rx_data),
    .o_rx_ready(master_rx_ready),
    .i_rx_rden(master_rx_rden),
    // UART interface
    .i_rx(caravel_tx),
    .o_tx(caravel_rx)
    );

    task send_modbus_frame(input [255:0] frame, input [4:0] length);
    	begin
    		frame = frame << (32 - length) * 8;

    		for (i = 0; i < length; i = i + 1) begin
    			// Wait until tx is available
    			wait (master_tx_ready);
    			wait (~clock);
    			wait (clock);
    			
    			// Send tx byte
    			master_tx_data 	= frame[255:248];
    			master_tx_wren 	= 1'b1;

    			wait (~clock);
    			wait (clock);

    			// master_tx_data	= 0;
    			master_tx_wren	= 1'b0;

    			wait (~clock);
    			wait (clock);

    			frame = frame << 8;
    		end 
    	end
    endtask

    task check_modbus_frame(input [255:0] ref_frame, input [4:0] length, input compare);
    	begin
    		modbus_check_err = 0;

    		ref_frame = ref_frame << (32 - length) * 8;

    		for (i = 0; i < length; i = i + 1) begin
    			// Wait until rx data is available
    			wait (master_rx_ready);
    			wait (~clock);
    			wait (clock);

    			// Receive rx byte
    			rx_byte 		= master_rx_data;
    			master_rx_rden 	= 1'b1;

    			wait (~clock);
    			wait (clock);

    			master_rx_rden	= 1'b0;

    			if (compare) modbus_check_err = (rx_byte != ref_frame[255:248]) ? 1'b1 : modbus_check_err;

    			wait (~clock);
    			wait (clock);

    			ref_frame = ref_frame << 8;
    		end 
    	end
    endtask

endmodule
`default_nettype wire
