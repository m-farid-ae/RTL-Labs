// ============================================================
// Lab 4-9 (RTL Project) : UART controller interface to a memory
// Objective: Design an interface to a memory block that executes
// memory read/write commands coming from a UART device.
//   * UART serial-to-parallel interface  (uart_rx)
//   * UART parallel-to-serial interface  (uart_tx)
//   * FIFOs buffering UART commands/data in both directions
//   * Parallel interface to the memory block (read/write ops)
//   * 2-port memory model (one read port, one write port)
//
// Command protocol (bytes received over UART):
//   byte0 : 8'h01 = WRITE command, 8'h00 = READ command
//   byte1 : address (8-bit)
//   byte2 : data    (only for WRITE)
// Response: for a READ, one data byte is sent back over UART.
// ============================================================
`timescale 1ns/1ps

// ------------------------------------------------------------
// UART receiver : serial -> parallel (8N1, 16x oversampling)
// ------------------------------------------------------------
module uart_rx(rx_out, rx_valid, rx_serial, clk, reset);
    parameter CLKS_PER_BIT = 16;
    output reg [7:0] rx_out;
    output reg       rx_valid;
    input            rx_serial, clk, reset;

    localparam IDLE  = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
    reg [1:0] state;
    reg [7:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] rx_data;

    // two-flop synchronizer
    reg r1, r2;
    wire rx_sync = r2;
    always @(posedge clk or posedge reset)
        if (reset) begin r1 <= 1'b1; r2 <= 1'b1; end
        else       begin r1 <= rx_serial; r2 <= r1; end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            clk_count <= 8'd0;
            bit_index <= 3'd0;
            rx_data   <= 8'd0;
            rx_out    <= 8'd0;
            rx_valid  <= 1'b0;
        end else begin
            rx_valid <= 1'b0;
            case (state)
                IDLE:
                    if (rx_sync == 1'b0) begin
                        state     <= START;
                        clk_count <= 8'd0;
                    end
                START:   // verify start bit at its middle
                    if (clk_count == (CLKS_PER_BIT/2)-1) begin
                        if (rx_sync == 1'b0) begin
                            state     <= DATA;
                            clk_count <= 8'd0;
                            bit_index <= 3'd0;
                        end else
                            state <= IDLE;
                    end else
                        clk_count <= clk_count + 8'd1;
                DATA:    // sample each bit in its middle
                  if (clk_count == (CLKS_PER_BIT)-1) begin
                        clk_count          <= 8'd0;
                        rx_data[bit_index] <= rx_sync;
                        if (bit_index == 3'd7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 3'd1;
                    end else
                        clk_count <= clk_count + 8'd1;
              STOP: if (clk_count == (CLKS_PER_BIT)-1) begin
    						clk_count <= 8'd0;
    						if (rx_sync == 1'b1) begin
       							 rx_out   <= rx_data;
        						rx_valid <= 1'b1;
    						end
    					state <= IDLE;          // always return to IDLE
					end else
    					clk_count <= clk_count + 8'd1;
                default: state <= IDLE;
            endcase
        end
    end
endmodule

// ------------------------------------------------------------
// UART transmitter : parallel -> serial (8N1)
// ------------------------------------------------------------
module uart_tx(tx_serial, tx_busy, tx_in, tx_start, clk, reset);
    parameter CLKS_PER_BIT = 16;
    output reg       tx_serial;
    output reg       tx_busy;
    input      [7:0] tx_in;
    input            tx_start, clk, reset;

    localparam IDLE  = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
    reg [1:0] state;
    reg [7:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] data;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            clk_count <= 8'd0;
            bit_index <= 3'd0;
            data      <= 8'd0;
            tx_serial <= 1'b1;
            tx_busy   <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_serial <= 1'b1;
                    clk_count <= 8'd0;
                    bit_index <= 3'd0;
                    if (tx_start) begin
                        tx_busy <= 1'b1;
                        data    <= tx_in;
                        state   <= START;
                    end else
                        tx_busy <= 1'b0;
                end
                START: begin
                    tx_busy   <= 1'b1;
                    tx_serial <= 1'b0;               // start bit
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 8'd0;
                        state     <= DATA;
                    end else
                        clk_count <= clk_count + 8'd1;
                end
                DATA: begin
                    tx_busy   <= 1'b1;
                    tx_serial <= data[bit_index];    // LSB first
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 8'd0;
                        if (bit_index == 3'd7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 3'd1;
                    end else
                        clk_count <= clk_count + 8'd1;
                end
                STOP: begin
                    tx_busy   <= 1'b1;
                    tx_serial <= 1'b1;               // stop bit
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 8'd0;
                        state     <= IDLE;
                    end else
                        clk_count <= clk_count + 8'd1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

// ------------------------------------------------------------
// FIFO : 128 entries x 8 bits (from Lab 4-8)
// ------------------------------------------------------------
module fifo(d_in, d_in_valid, d_out, d_out_req, clk, reset, full, empty);
    input  [7:0] d_in;
    input        d_in_valid, d_out_req, clk, reset;
    output reg [7:0] d_out;
    output       full, empty;

    reg [7:0] mem [0:127];
    reg [6:0] wr_ptr, rd_ptr;
    reg [7:0] count;

    integer i;
    assign full  = (count == 8'd128);
    assign empty = (count == 8'd0);

    wire do_push = d_in_valid & ~full;
    wire do_pop  = d_out_req  & ~empty;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            wr_ptr <= 7'd0; 
            rd_ptr <= 7'd0; 
            count <= 8'd0; 
            d_out <= 8'd0;
          for (int i = 0; i < 128; i = i + 1)
                mem[i] <= 8'b0;
        end
        else begin
        if (do_push) begin
            mem[wr_ptr] <= d_in;
            wr_ptr      <= wr_ptr + 7'd1;
        end
        if (do_pop) begin
            d_out  <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 7'd1;
        end
        case ({do_push, do_pop})
            2'b10:   count <= count + 8'd1;
            2'b01:   count <= count - 8'd1;
            default: count <= count;
        endcase
        end
    end
endmodule

// ------------------------------------------------------------
// 2-port memory : one write port + one read port (asynchronous read)
// ------------------------------------------------------------
module ram_2port(d_out, d_in, wr_addr, rd_addr, we, clk, reset);
    output [7:0] d_out;
    input  [7:0] d_in;
    input  [7:0] wr_addr, rd_addr;
    input        we, clk, reset;

    reg [7:0] mem [0:255];

    assign d_out = mem[rd_addr];          // read port

    always @(posedge clk or posedge reset)                 // write port
    begin
        if(reset)
            for (int i = 0; i < 256; i = i + 1)
                mem[i] <= 8'b0;
        else if (we)
            mem[wr_addr] <= d_in;
    end
endmodule

// ------------------------------------------------------------
// Top level : UART -> command FIFO -> controller -> RAM / TX FIFO -> UART
// ------------------------------------------------------------
module uart_mem_top(tx_serial, rx_serial, clk, reset);
    parameter CLKS_PER_BIT = 16;
    input  rx_serial, clk, reset;
    output tx_serial;

    // UART RX -> command byte stream
    wire tx_busy;
    wire [7:0] rx_byte;
    wire       rx_valid;
    uart_rx #(CLKS_PER_BIT) u_rx (
        .rx_out(rx_byte), .rx_valid(rx_valid),
        .rx_serial(rx_serial), .clk(clk), .reset(reset));

    // command	 FIFO (buffers UART commands)
    wire [7:0] cmd_dout;
    wire       cmd_full, cmd_empty;
    wire       cmd_pop;
    fifo u_cmd_fifo (
        .d_in(rx_byte), .d_in_valid(rx_valid), .d_out(cmd_dout),
        .d_out_req(cmd_pop), .clk(clk), .reset(reset), .full(cmd_full), .empty(cmd_empty));

    // controller FSM
    localparam IDLE    = 3'd0,
               CMD     = 3'd1,
               WR_ADDR = 3'd2,
               WR_DATA = 3'd3,
               RD_ADDR = 3'd4,
               RD_EXEC = 3'd5;
    reg [2:0] state;
    reg [7:0] addr_reg;

    //assign cmd_pop = !cmd_empty &&
                     //((state == IDLE) || (state == CMD) || (state == WR_ADDR));
  //assign cmd_pop = !cmd_empty && (state == WR_DATA);
  assign cmd_pop = !cmd_empty && ((state == CMD)     ||   // pop command byte
                                (state == WR_ADDR)  ||   // pop address
                                  (state == IDLE));     

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else begin
            case (state)
                IDLE:    if (!cmd_empty) state <= CMD;
              	CMD:     if (!cmd_empty) state <= (cmd_dout == 8'h01) ? WR_ADDR : RD_ADDR;
              	WR_ADDR: if (!cmd_empty) begin addr_reg <= cmd_dout; state <= WR_DATA; end
                WR_DATA: state <= IDLE;      // memory write happens this cycle
                RD_ADDR: begin addr_reg <= cmd_dout; state <= RD_EXEC; end
                RD_EXEC: state <= IDLE;      // read data pushed to TX FIFO
                default: state <= IDLE;
            endcase
        end
    end

    // memory (write port driven by controller, read port combinational)
    wire [7:0] mem_dout;
    wire       mem_we = (state == WR_DATA);
    ram_2port u_ram (
        .d_out(mem_dout), .d_in(cmd_dout),
        .wr_addr(addr_reg), .rd_addr(addr_reg),
        .we(mem_we), .clk(clk), .reset(reset));

    // TX FIFO (buffers responses back to the UART)
    wire [7:0] tx_dout;
    wire       tx_full, tx_empty;
    reg        tx_pop, tx_start;
    fifo u_tx_fifo (
        .d_in(mem_dout), .d_in_valid(state == RD_EXEC), .d_out(tx_dout),
        .d_out_req(tx_pop), .clk(clk), .reset(reset), .full(tx_full), .empty(tx_empty));

    // start a TX transmission whenever the UART is idle and data is waiting
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_pop   <= 1'b0;
            tx_start <= 1'b0;
        end else begin
            tx_pop   <= 1'b0;                    // default: pulse for 1 cycle
            tx_start <= tx_pop & ~tx_busy;       // d_out valid by now
            if (!tx_busy && !tx_empty && !tx_pop && !tx_start)
                tx_pop <= 1'b1;                  // load d_out with the head byte
        end
    end

    
    uart_tx #(CLKS_PER_BIT) u_tx (
        .tx_serial(tx_serial), .tx_busy(tx_busy), .tx_in(tx_dout),
        .tx_start(tx_start), .clk(clk), .reset(reset));
endmodule
