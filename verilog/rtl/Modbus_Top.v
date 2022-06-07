// =====================================================================================
// (C) COPYRIGHT 2016 YongaTek (Yonga Technology Microelectronics)
// All rights reserved.
// This file contains confidential and proprietary information of YongaTek and
// is protected under international copyright and other intellectual property laws.
// =====================================================================================
// Project           : GCU
// File ID           : %%
// Design Unit Name  : Modbus_Top.vhd
// Description       : Modbus Top
// Comments          :
// Revision          : %%
// Last Changed Date : %%
// Last Changed By   : %%
// Designer
//          Name     : Burak Yakup Çakar
//          E-mail   : burak.cakar@yongatek.com
// =====================================================================================

module Modbus_Top #(
        parameter device_id = 8'h01, // Device address is 0x01
        parameter clk_freq = 40000000, // 40 MHz clock frequency
        parameter baud_rate = 115200 // 115200 Baud Rate
    )
    (
        // Clock, reset and enable pins
	    input               i_clk,
        input               i_rst,
        // Interface with register space
        output reg  [7:0]   o_mem_addr,
        output reg          o_mem_wren,
        output reg          o_mem_rden,
        input       [15:0]  i_mem_dout,
        output      [15:0]  o_mem_din,
        input               i_mem_wrready,
        // UART interface
        input               i_rx,
        output              o_tx
    );

    // State declaration
    localparam IDLE             = 3'b000;
    localparam RECEIVE_REQUEST  = 3'b001;
    localparam CHECK_ERRORS     = 3'b010;
    localparam MEM_WRITE        = 3'b011;
    localparam MEM_READ         = 3'b100;
    localparam SEND_RESPONSE    = 3'b101;

    localparam clkdiv           = clk_freq / baud_rate; // Clocks per bit for specified Baud Rate

    localparam timeout_count    = clkdiv * 4 * (8 + 1 + 1); // Wait for 4 bytes interval since the last data received. Baud: 115200. Clock: 100 MHz

    wire        i_enable    = 1'b1; // Enable all submodules and this module

    // UART controller signals
    reg  [7:0]  uart_tx_data;
    wire        uart_tx_ready;
    reg         uart_tx_wren;
    wire [7:0]  uart_rx_data;
    wire        uart_rx_ready;
    reg         uart_rx_rden;

    // 16 bit CRC signals
    reg         crc_soft_rst;
    reg  [7:0]  crc_data;
    reg         crc_start;
    wire [15:0] crc_crc16;
    wire        crc_done;

    // FIFO signals
    reg         fifo_soft_rst;
    wire [15:0] fifo_din;
    wire [15:0] fifo_dout;
    reg         fifo_re;
    reg         fifo_we;

    // Modbus frame fields
    reg  [7:0]  id;
    reg  [7:0]  func;
    reg  [15:0] start_addr;
    reg  [15:0] quantity;
    reg  [7:0]  byte_count;
    reg  [15:0] crc16;
    reg  [7:0]  errcode;

    // Receive state flags
    reg         receive_func;
    reg         receive_start_addr;
    reg         receive_quantity;
    reg         receive_byte_count;
    reg         receive_data;
    reg         receive_crc;

    // Send state flags
    reg         send_id;
    reg         send_func;
    reg         send_start_addr;
    reg         send_quantity;
    reg         send_byte_count;
    reg         send_data;
    reg         send_crc;
    reg         send_errcode;

    // UART RX data queue
    reg  [7:0]  uart_rx_data_q0;
    reg  [7:0]  uart_rx_data_q1;

    reg  [15:0] fifo_din_reg;
    reg         fifo_data_ready;

    // Enables CRC computation
    reg         crc_enable;

    // Data byte counter
    reg  [7:0]  byte_counter;

    reg  [15:0] timeout_counter;

    reg  [2:0]  state;

    // Modbus UART controller instantiation
    Modbus_UART_Controller #(clkdiv) Modbus_UART_Controller_inst (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_enable(i_enable),
        .i_tx_data(uart_tx_data),
        .o_tx_ready(uart_tx_ready),
        .i_tx_wren(uart_tx_wren),
        .o_rx_data(uart_rx_data),
        .o_rx_ready(uart_rx_ready),
        .i_rx_rden(uart_rx_rden),
        .i_rx(i_rx),
        .o_tx(o_tx)
        );

    // CRC16 instantiation
    Modbus_CRC16 Modbus_CRC16_inst(
        .i_clk(i_clk),
        .i_rst(i_rst | crc_soft_rst),
        .i_enable(i_enable),
        .i_data(crc_data),
        .i_start(crc_start),
        .o_crc16(crc_crc16),
        .o_done(crc_done)
        );

    // CoreFIFO instantiation
    fifo #(.ADDR_W(7), .DATA_W(16), .BUFF_L(128))
    fifo_inst(
        .clk(i_clk),
        .n_reset(~(i_rst | fifo_soft_rst)),
        .wr_en(fifo_we),
        .data_in(fifo_din),
        .rd_en(fifo_re),
        .data_out(fifo_dout),
        .data_count(),
        .empty(),
        .full(),
        .almst_empty(),
        .almst_full(),
        .err()
        );

    // FIFO data output is directly wired to memory
    assign o_mem_din    = fifo_dout;
    // FIFO data input is connected to a register when receiving write requests,
    // it is directly wired to memory othervise
    assign fifo_din     = (state == RECEIVE_REQUEST) ? fifo_din_reg : i_mem_dout;

    always @(posedge i_clk) begin
        if (i_rst) begin
            o_mem_addr          <= 8'h00;
            o_mem_wren          <= 1'b0;
            o_mem_rden          <= 1'b0;

            uart_tx_data        <= 8'h00;
            uart_tx_wren        <= 1'b0;
            uart_rx_rden        <= 1'b0;

            crc_soft_rst        <= 1'b0;
            crc_data            <= 8'h00;
            crc_start           <= 1'b0;

            fifo_soft_rst       <= 1'b0;
            fifo_din_reg        <= 16'h0000;
            fifo_re             <= 1'b0;
            fifo_we             <= 1'b0;

            id                  <= 8'h00;
            func                <= 8'h00;
            start_addr          <= 16'h0000;
            quantity            <= 16'h0000;
            crc16               <= 16'h0000;
            errcode             <= 8'h00;

            receive_func        <= 1'b0;
            receive_start_addr  <= 1'b0;
            receive_quantity    <= 1'b0;
            receive_byte_count  <= 1'b0;
            receive_data        <= 1'b0;
            receive_crc         <= 1'b0;
            send_id             <= 1'b0;
            send_func           <= 1'b0;
            send_start_addr     <= 1'b0;
            send_quantity       <= 1'b0;
            send_byte_count     <= 1'b0;
            send_data           <= 1'b0;
            send_crc            <= 1'b0;
            send_errcode        <= 1'b0;

            uart_rx_data_q0     <= 8'h00;
            uart_rx_data_q1     <= 8'h00;

            crc_enable          <= 1'b0;

            byte_counter        <= 8'h00;

            fifo_data_ready     <= 1'b0;

            timeout_counter     <= 16'h0000;

            state               <= IDLE;
        end
        else begin
            if (i_enable) begin
                // These signals will be reset when not overrode
                fifo_soft_rst   <= 1'b0;
                fifo_re         <= 1'b0;
                fifo_we         <= 1'b0;

                crc_soft_rst    <= 1'b0;
                crc_start       <= 1'b0;

                uart_rx_rden    <= 1'b0;
                uart_tx_wren    <= 1'b0;

                case (state)
                    IDLE : begin
                        if (uart_rx_ready && ~uart_rx_rden) begin // Read and store RX data
                            uart_rx_rden    <= 1'b1;

                            uart_rx_data_q0 <= uart_rx_data;
                            uart_rx_data_q1 <= uart_rx_data_q0;
                            crc_data        <= uart_rx_data_q1;

                            id              <= uart_rx_data;
                        end
                        else if (uart_rx_ready && uart_rx_rden) begin // Change state with id check
                            errcode         <= (id != device_id) ? 8'hff : 8'h00;

                            receive_func    <= 1'b1;

                            state           <= RECEIVE_REQUEST;
                        end
                        else state <= IDLE;
                    end
                    RECEIVE_REQUEST : begin
                        if (uart_rx_ready && ~uart_rx_rden) begin // Read and store RX data
                            uart_rx_rden    <= 1'b1;

                            uart_rx_data_q0 <= uart_rx_data;
                            uart_rx_data_q1 <= uart_rx_data_q0;
                            crc_data        <= uart_rx_data_q1;

                            crc_start       <= (crc_enable) ? 1'b1 : 1'b0;

                            timeout_counter <= 16'h0000;

                            // Receive state flags determine where RX data will be written
                            if (receive_func) begin
                                func                    <= uart_rx_data;
                                crc_enable              <= 1'b1;
                            end
                            else if (receive_start_addr && byte_counter == 8'h00) begin
                                start_addr[15:8]        <= uart_rx_data;
                            end
                            else if (receive_start_addr && byte_counter == 8'h01) begin
                                start_addr[7:0]         <= uart_rx_data;
                            end
                            else if (receive_quantity && byte_counter == 8'h00) begin
                                quantity[15:8]          <= uart_rx_data;
                            end
                            else if (receive_quantity && byte_counter == 8'h01) begin
                                quantity[7:0]           <= uart_rx_data;
                            end
                            else if (receive_byte_count) begin
                                byte_count              <= uart_rx_data;
                            end
                            else if (receive_data && byte_counter[0] == 1'b0) begin
                                fifo_din_reg[15:8]      <= uart_rx_data;
                            end
                            else if (receive_data && byte_counter[0] == 1'b1) begin
                                fifo_din_reg[7:0]       <= uart_rx_data;
                            end
                            else if (receive_crc && byte_counter == 8'h00) begin
                                crc16[7:0]              <= uart_rx_data;
                            end
                            else if (receive_crc && byte_counter == 8'h01) begin
                                crc16[15:8]             <= uart_rx_data;
                            end
                        end
                        else if (uart_rx_ready && uart_rx_rden) begin // Change state depending on request frame
                            if (receive_func) begin
                                receive_func    <= 1'b0;

                                if (errcode == 8'h00) begin
                                    if (func == 8'h03 || func == 8'h10) begin // If function code is not valid, set error code 0x01
                                        receive_start_addr  <= 1'b1;
                                    end
                                    else begin
                                        errcode             <= 8'h01;
                                    end
                                end
                            end
                            else if (receive_start_addr && byte_counter == 8'h00) begin
                                byte_counter            <= 8'h01;
                            end
                            else if (receive_start_addr && byte_counter == 8'h01) begin
                                byte_counter            <= 8'h00;
                                receive_start_addr      <= 1'b0;
                                receive_quantity        <= 1'b1;
                            end
                            else if (receive_quantity && byte_counter == 8'h00) begin
                                byte_counter            <= 8'h01;
                            end
                            else if (receive_quantity && byte_counter == 8'h01) begin
                                byte_counter            <= 8'h00;
                                receive_quantity        <= 1'b0;

                                if (errcode == 8'h00) begin
                                    if (quantity == 16'h0000 || quantity > 16'h007d || (func == 8'h10 && quantity > 16'h007b)) begin // If quantity is invalid, set error code 0x03
                                        errcode         <= 8'h03;
                                    end
                                    else if (start_addr[15:8] != 8'h00 || (func == 8'h03 && start_addr + quantity > 16'h0100) || (func == 8'h10 && start_addr + quantity > 16'h0080)) begin // If address is invalid, set error code 0x02
                                        errcode         <= 8'h02;
                                    end
                                    else if (func == 8'h03) begin // If function is read holding registers, receive crc
                                        receive_crc     <= 1'b1;
                                    end
                                    else if (func == 8'h10) begin // If function is write multiple registers, receive byte count
                                        receive_byte_count  <= 1'b1;
                                    end
                                end
                            end
                            else if (receive_byte_count) begin
                                receive_byte_count      <= 1'b0;
                                receive_data            <= 1'b1;

                                errcode                 <= (byte_count[7:1] != quantity[6:0] && errcode == 8'h00) ? 8'h04 : errcode;
                            end
                            else if (receive_data && byte_counter[0] == 1'b0) begin
                                byte_counter            <= byte_counter + 1;
                            end
                            else if (receive_data && byte_counter[0] == 1'b1) begin
                                byte_counter            <= byte_counter + 1;

                                fifo_we                 <= 1'b1;
                                if (byte_counter == byte_count - 1) begin
                                    byte_counter        <= 8'h00;

                                    receive_data        <= 1'b0;
                                    receive_crc         <= 1'b1;
                                end
                            end
                            else if (receive_crc && byte_counter == 8'h00) begin
                                byte_counter            <= 8'h01;
                            end
                            else if (receive_crc && byte_counter == 8'h01) begin
                                byte_counter            <= 8'h00;
                                receive_crc             <= 1'b0;
                            end
                        end
                        else begin
                            if(timeout_counter < timeout_count) begin // Wait for 4 bytes to finish receiving request
                                timeout_counter     <= timeout_counter + 1;
                            end
                            else begin
                                receive_func        <= 1'b0;
                                receive_start_addr  <= 1'b0;
                                receive_quantity    <= 1'b0;
                                receive_data        <= 1'b0;
                                receive_crc         <= 1'b0;

                                byte_counter        <= 8'h00;

                                timeout_counter     <= 16'h0000;

                                state               <= CHECK_ERRORS;
                            end
                        end
                    end
                    CHECK_ERRORS : begin
                        crc_soft_rst                <= 1'b1;
                        crc_data                    <= 8'h00;
                        crc_enable                  <= 1'b1;

                        byte_counter                <= 8'h00;

                        uart_rx_data_q0             <= 8'h00;
                        uart_rx_data_q1             <= 8'h00;

                        timeout_counter             <= 16'h0000;

                        if ((errcode == 8'h00 && crc_crc16 != crc16) || (errcode != 8'h00 && crc_crc16 != {uart_rx_data_q0, uart_rx_data_q1}) || errcode == 8'hff) begin
                            fifo_soft_rst           <= 1'b1;
                            fifo_din_reg            <= 16'h0000;

                            crc_enable              <= 1'b0;

                            id                      <= 8'h00;
                            func                    <= 8'h00;
                            start_addr              <= 16'h0000;
                            quantity                <= 16'h0000;
                            crc16                   <= 16'h0000;
                            errcode                 <= 8'h00;

                            uart_rx_data_q0         <= 8'h00;
                            uart_rx_data_q1         <= 8'h00;

                            state                   <= IDLE;
                        end
                        else if (errcode != 8'h00) begin // If there is an error, just send error response
                            send_id                 <= 1'b1;

                            state                   <= SEND_RESPONSE;
                        end
                        else if (func == 8'h03) begin // If the function is read holding registers, read memory
                            o_mem_addr              <= start_addr[7:0];
                            o_mem_rden              <= 1'b1;

                            state                   <= MEM_READ;
                        end
                        else if (func == 8'h10) begin // If the function is write multiple registers, write  memory
                            fifo_re                 <= 1'b1;

                            o_mem_addr              <= start_addr[7:0];

                            byte_counter            <= byte_counter + 2;

                            state                   <= MEM_WRITE;
                        end
                        else begin
                            o_mem_addr              <= 8'h00;
                            o_mem_wren              <= 1'b0;
                            o_mem_rden              <= 1'b0;

                            uart_tx_data            <= 8'h00;

                            fifo_soft_rst           <= 1'b1;
                            fifo_din_reg            <= 16'h0000;
                            fifo_re                 <= 1'b0;
                            fifo_we                 <= 1'b0;

                            id                      <= 8'h00;
                            func                    <= 8'h00;
                            start_addr              <= 16'h0000;
                            quantity                <= 16'h0000;
                            crc16                   <= 16'h0000;
                            errcode                 <= 8'h00;

                            receive_func            <= 1'b0;
                            receive_start_addr      <= 1'b0;
                            receive_quantity        <= 1'b0;
                            receive_data            <= 1'b0;
                            receive_crc             <= 1'b0;
                            send_id                 <= 1'b0;
                            send_func               <= 1'b0;
                            send_start_addr         <= 1'b0;
                            send_quantity           <= 1'b0;
                            send_byte_count         <= 1'b0;
                            send_data               <= 1'b0;
                            send_crc                <= 1'b0;
                            send_errcode            <= 1'b0;

                            state                   <= IDLE;
                        end
                    end
                    MEM_WRITE : begin
                        if (i_mem_wrready) begin
                            if (byte_counter[7:1] == quantity[6:0]) begin
                                if (fifo_re) begin
                                    o_mem_addr          <= (o_mem_wren) ? o_mem_addr + 1 : o_mem_addr;
                                    o_mem_wren          <= 1'b1;
                                end
                                else begin
                                    o_mem_addr          <= 8'h00;
                                    o_mem_wren          <= 1'b0;

                                    byte_counter        <= 8'h00;

                                    send_id             <= 1'b1;

                                    state               <= SEND_RESPONSE;
                                end
                            end
                            else begin
                                fifo_re             <= 1'b1;

                                o_mem_wren          <= 1'b1;
                                o_mem_addr          <= (o_mem_wren) ? o_mem_addr + 1 : o_mem_addr; // Increase address after the first read

                                byte_counter        <= byte_counter + 2;
                            end
                        end
                    end
                    MEM_READ : begin
                        if (byte_counter[7:1] == quantity[6:0]) begin
                            o_mem_addr          <= 8'h00;
                            o_mem_rden          <= 1'b0;

                            byte_counter        <= 8'h00;

                            send_id             <= 1'b1;

                            state               <= SEND_RESPONSE;
                        end
                        else begin
                            fifo_we             <= 1'b1;

                            o_mem_addr          <= o_mem_addr + 1;
                            o_mem_rden          <= 1'b1;

                            byte_counter        <= byte_counter + 2;
                        end
                    end
                    SEND_RESPONSE : begin
                        if (uart_tx_ready && ~uart_tx_wren) begin // Send data. The data will be determined by send state flags
                            if (send_id) begin
                                uart_tx_wren    <= 1'b1;
                                uart_tx_data    <= device_id;

                                send_id         <= 1'b0;
                                send_func       <= 1'b1;
                            end
                            else if (send_func) begin
                                uart_tx_wren    <= 1'b1;

                                if (errcode != 8'h00) begin
                                    uart_tx_data    <= func | 8'h80; // 80 + func will be sent if there is an error
                                    send_errcode    <= 1'b1;
                                end
                                else if (func == 8'h03) begin
                                    uart_tx_data    <= func;
                                    send_byte_count <= 1'b1;
                                end
                                else if (func == 8'h10) begin
                                    uart_tx_data    <= func;
                                    send_start_addr <= 1'b1;
                                end
                                send_func       <= 1'b0;
                            end
                            else if (send_start_addr && byte_counter == 8'h00) begin
                                uart_tx_wren    <= 1'b1;
                                uart_tx_data    <= start_addr[15:8];

                                byte_counter    <= 8'h01;
                            end
                            else if (send_start_addr && byte_counter == 8'h01) begin
                                uart_tx_wren    <= 1'b1;
                                uart_tx_data    <= start_addr[7:0];

                                byte_counter    <= 8'h00;

                                send_start_addr <= 1'b0;
                                send_quantity   <= 1'b1;
                            end
                            else if (send_quantity && byte_counter == 8'h00) begin
                                uart_tx_wren    <= 1'b1;
                                uart_tx_data    <= quantity[15:8];

                                byte_counter    <= 8'h01;
                            end
                            else if (send_quantity && byte_counter == 8'h01) begin
                                uart_tx_wren    <= 1'b1;
                                uart_tx_data    <= quantity[7:0];

                                byte_counter    <= 8'h00;

                                send_quantity   <= 1'b0;
                                send_crc        <= 1'b1;
                            end
                            else if (send_byte_count) begin
                                uart_tx_wren    <= 1'b1;
                                uart_tx_data    <= {quantity[6:0], 1'b0};

                                send_byte_count <= 1'b0;
                                send_data       <= 1'b1;
                            end
                            else if (send_data && byte_counter[0] == 1'b0) begin
                                if (~fifo_re && ~fifo_data_ready) begin
                                    fifo_re         <= 1'b1;
                                end
                                else if (fifo_re && ~fifo_data_ready) begin
                                    fifo_data_ready <= 1'b1;
                                end
                                else begin
                                    fifo_data_ready <= 1'b0;

                                    uart_tx_wren    <= 1'b1;
                                    uart_tx_data    <= fifo_dout[15:8];

                                    byte_counter    <= byte_counter + 1;
                                end
                            end
                            else if (send_data && byte_counter[0] == 1'b1) begin
                                uart_tx_wren        <= 1'b1;
                                uart_tx_data        <= fifo_dout[7:0];

                                if (byte_counter + 1 == {quantity[6:0], 1'b0}) begin
                                    byte_counter    <= 8'h00;

                                    send_data       <= 1'b0;
                                    send_crc        <= 1'b1;
                                end
                                else begin
                                    byte_counter    <= byte_counter + 1;
                                end
                            end
                            else if (send_errcode) begin
                                uart_tx_wren    <= 1'b1;
                                uart_tx_data    <= errcode;

                                send_errcode    <= 1'b0;
                                send_crc        <= 1'b1;
                            end
                            else if (send_crc && byte_counter == 8'h00) begin
                                uart_tx_wren    <= 1'b1;
                                uart_tx_data    <= crc_crc16[7:0];

                                byte_counter    <= 8'h01;
                            end
                            else if (send_crc && byte_counter == 8'h01) begin
                                uart_tx_wren    <= 1'b1;
                                uart_tx_data    <= crc_crc16[15:8];

                                byte_counter    <= 8'h00;

                                send_crc        <= 1'b0;
                            end
                        end
                        else if (uart_tx_ready && uart_tx_wren) begin
                            if (~send_id && ~send_func && ~send_start_addr && ~send_quantity &&
                                ~send_byte_count && ~send_data && ~send_errcode && ~send_crc) begin // If no flags are set, finish sending response
                                uart_tx_data    <= 8'h00;

                                crc_soft_rst    <= 1'b1;
                                crc_data        <= 8'h00;

                                fifo_soft_rst   <= 1'b1;
                                fifo_data_ready <= 1'b0;

                                id              <= 8'h00;
                                func            <= 8'h00;
                                start_addr      <= 16'h0000;
                                quantity        <= 16'h0000;
                                crc16           <= 16'h0000;
                                errcode         <= 8'h00;

                                state           <= IDLE;
                            end
                            else begin// Compute CRC16
                                if (send_crc) begin
                                    crc_enable  <= 1'b0;
                                end
                                crc_start       <= (crc_enable) ? 1'b1 : 1'b0;
                                crc_data        <= uart_tx_data;
                            end
                        end
                    end
                    default : state <= IDLE;
                endcase
            end
        end
    end
endmodule
