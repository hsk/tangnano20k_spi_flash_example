module top(input sys_clk, rst, uart_rx, output uart_tx);
    localparam DIV = 72_000_000/115200;
    wire clk, pll_lock, clkoutp_dummy;
    clk72m_rpll pll_inst (
        .clkout(clk),
        .lock(pll_lock),
        .clkoutp(clkoutp_dummy),
        .clkin(sys_clk)
    );
    // ===== パラメータ定義 =====
    `include "inc/sys_parameters.v"
    parameter BARREL_SHIFTER = 0;
    parameter ENABLE_MUL = 0;
    parameter ENABLE_DIV = 0;
    parameter ENABLE_FAST_MUL = 0;
    parameter ENABLE_COMPRESSED = 0;
    parameter ENABLE_IRQ_QREGS = 0;
    parameter        MEMBYTES = 4*(1 << SRAM_ADDR_WIDTH); 
    parameter [31:0] STACKADDR = (MEMBYTES);         // スタックアドレス（下方向に成長）
    parameter [31:0] PROGADDR_RESET = 32'h0000_0000; // リセット時プログラムアドレス
    parameter [31:0] PROGADDR_IRQ = 32'h0000_0000;   // 割り込み時プログラムアドレス
    // ===== リセット制御 =====
    // reset_control: ボタン入力からリセット信号生成
    wire                       resetn; 
    reset_control reset_controller(clk, !rst, resetn);
    // ===== picorv32 CPUコア =====
    // RISC-V 32bit CPU
    wire                       mem_valid, mem_ready, mem_instr;
    wire [31:0]                mem_addr, mem_wdata, mem_rdata;
    wire [3:0]                 mem_wstrb;
    picorv32#(
        .STACKADDR(STACKADDR),
        .PROGADDR_RESET(PROGADDR_RESET),
        .PROGADDR_IRQ(PROGADDR_IRQ),
        .BARREL_SHIFTER(BARREL_SHIFTER),
        .COMPRESSED_ISA(ENABLE_COMPRESSED),
        .ENABLE_MUL(ENABLE_MUL),
        .ENABLE_DIV(ENABLE_DIV),
        .ENABLE_FAST_MUL(ENABLE_FAST_MUL),
        .ENABLE_IRQ(1),
        .ENABLE_IRQ_QREGS(ENABLE_IRQ_QREGS)
    ) cpu (
        .clk         (clk),
        .resetn      (resetn),
        .mem_valid   (mem_valid),
        .mem_instr   (mem_instr),
        .mem_ready   (mem_ready),
        .mem_addr    (mem_addr),
        .mem_wdata   (mem_wdata),
        .mem_wstrb   (mem_wstrb),
        .mem_rdata   (mem_rdata),
        .irq         ('b0)
    );
    // ===== SRAM（オンチップメモリ） =====
    wire sram_sel, sram_ready;
    wire [31:0] sram_rdata;
    sram #(.WIDTH(SRAM_ADDR_WIDTH)) memory (
        .clk(clk),
        .resetn(resetn),
        .addr(mem_addr[SRAM_ADDR_WIDTH + 1:0]),
        .wstrb(mem_wstrb),
        .wdata(mem_wdata),
        .sram_sel(sram_sel),
        .sram_ready(sram_ready),
        .sram_rdata(sram_rdata)
    );
    // ===== UARTモジュール =====
    // UARTラッパ: コアと外部UARTの橋渡し
    wire uart_sel, uart_ready;
    wire [31:0] uart_rdata;
    uart_wrap #(DIV) uart(
        .clk(clk),
        .resetn(resetn),
        .addr(mem_addr[3:0]),
        .wstrb(mem_wstrb),
        .wdata(mem_wdata),
        .uart_sel(uart_sel),
        .uart_ready(uart_ready),
        .uart_rdata(uart_rdata),
        .uart_tx(uart_tx),
        .uart_rx(uart_rx)
    );
    // ===== メモリマップ定義 =====
    //   SRAM 0x00000000 - 0x0001ffff
    //   UART 0x80000008 - 0x8000000f
    assign sram_sel = mem_valid && (mem_addr < MEMBYTES);
    assign uart_sel = mem_valid && ((mem_addr & 32'hfffffff8) == 32'h80000008);
    // ===== スレーブからのデータ選択 =====
    assign mem_rdata = sram_sel ? sram_rdata :
                       uart_sel ? uart_rdata : 32'h0;
    // ===== スレーブの応答: mem_ready生成 =====
    // どのスレーブがターゲットでもreadyならOK
    assign mem_ready = mem_valid & (sram_ready | uart_ready);
endmodule

module reset_control(input clk, reset_button_n, output resetn);
    reg [5:0] reset_count = 0;
    assign resetn = &reset_count;
    always @(posedge clk)
        if (reset_button_n) reset_count <= reset_count + !resetn;
        else                reset_count <= 'b0;
endmodule

module sram #(WIDTH=11) (
    input clk, resetn, sram_sel, [3:0] wstrb, [WIDTH + 1:0] addr,
    input [31:0] wdata, output reg sram_ready, [31:0] sram_rdata);
    initial sram_ready = 1'b0;
    always @(posedge clk) sram_ready <= sram_sel;
    sram8 #(.WIDTH(WIDTH), .MEM_INIT_FILE("inc/mem_init3.ini"))
    gmem3(clk, resetn, sram_sel, wstrb[3], addr[WIDTH + 1:2], wdata[31:24], sram_rdata[31:24]);
    sram8 #(.WIDTH(WIDTH), .MEM_INIT_FILE("inc/mem_init2.ini"))
    gmem2(clk, resetn, sram_sel, wstrb[2], addr[WIDTH + 1:2], wdata[23:16], sram_rdata[23:16]);
    sram8 #(.WIDTH(WIDTH), .MEM_INIT_FILE("inc/mem_init1.ini"))
    gmem1(clk, resetn, sram_sel, wstrb[1], addr[WIDTH + 1:2], wdata[15:8], sram_rdata[15:8]);
    sram8 #(.WIDTH(WIDTH), .MEM_INIT_FILE("inc/mem_init0.ini"))
    gmem0(clk, resetn, sram_sel, wstrb[0], addr[WIDTH + 1:2], wdata[7:0], sram_rdata[7:0]);
endmodule

module sram8 #(WIDTH = 11, MEM_INIT_FILE = "")(
    input clk, resetn, sel, wstrb, [WIDTH - 1:0] addr, [7:0] wdata, output reg [7:0] rdata);
    reg [7:0] mem[(1 << WIDTH) - 1:0];
    initial if (MEM_INIT_FILE != "") $readmemh(MEM_INIT_FILE, mem);
    always @(posedge clk or negedge resetn)
        rdata <= ~resetn ? 0 : sel & !wstrb ? mem[addr] : rdata;
    always @(posedge clk) if (sel & wstrb) mem[addr] <= wdata;
endmodule

module uart_wrap #(parameter integer DEFAULT_DIV = 234) (
    input clk, resetn,
    input [3:0] addr, [3:0] wstrb, [31:0] wdata,
    input uart_sel, output uart_ready, output [31:0] uart_rdata,
    input uart_rx, output uart_tx
);
    wire cfg_sel;
    wire [3:0] cfg_wstrb;
    assign cfg_wstrb = cfg_sel ? wstrb : 4'b0000;
    reg [31:0] cfg_div;
    always @(posedge clk)
        if (!resetn)
            cfg_div <= DEFAULT_DIV;
        else begin
            if (cfg_wstrb[0]) cfg_div[ 7: 0] <= wdata[ 7: 0];
            if (cfg_wstrb[1]) cfg_div[15: 8] <= wdata[15: 8];
            if (cfg_wstrb[2]) cfg_div[23:16] <= wdata[23:16];
            if (cfg_wstrb[3]) cfg_div[31:24] <= wdata[31:24];
        end

    wire rx_sel;
    wire [31:0] rx_rdata;
    uart_rx rx(
        .clk(clk),
        .rstn(resetn),
        .uart_rx(uart_rx),
        .cfg_div(cfg_div),
        .read(rx_sel && !wstrb),
        .data(rx_rdata)
    );

    wire tx_ready, tx_sel;
    uart_tx tx(
        .clk(clk),
        .rstn(resetn),
        .cfg_div(cfg_div),
        .start(cfg_wstrb),
        .uart_tx(uart_tx),
        .data(wdata),
        .tx_write(tx_sel),
        .ready(tx_ready)
    );

    assign rx_sel = uart_sel && (addr == 4'hc);
    assign cfg_sel = uart_sel && (addr == 4'h8);
    assign tx_sel = rx_sel && wstrb[0];
    assign uart_rdata = cfg_sel ? cfg_div :
                        rx_sel ? rx_rdata : 32'h0;
    assign uart_ready = cfg_sel | (rx_sel && tx_ready);
endmodule

module uart_rx (
    input clk, rstn, uart_rx, [31:0] cfg_div,
    input read,
    output [7:0] data,
    // 受信データの有効フラグ
    output reg rx_valid
);
    // クロック分周設定レジスタ
    reg [31:0] divcnt;
    // 受信状態を示すFSMステート
    reg [3:0] state;
    // 受信パターン格納用レジスタ
    reg [7:0] pattern, buf_data;
    // 受信バッファが有効なら受信データを返し、無効なら全ビット1を返す
    assign data = rx_valid ? buf_data : ~0;

    // UART受信FSM
    always @(posedge clk)
        if (!rstn) begin
            state <= 0;
            divcnt <= 0;
            pattern <= 0;
            buf_data <= 0;
            rx_valid <= 0;
        end else begin
            divcnt <= divcnt + 1;
            // データ読み出し時に受信バッファ無効化
            if (read)
                rx_valid <= 0;
            case (state)
                0: begin
                    // ステート0: 待機状態、スタートビット検出待ち
                    if (!uart_rx)
                        state <= 1;
                    divcnt <= 0;
                end
                1: if (2*divcnt > cfg_div) begin
                    // ステート1: スタートビットの中間でサンプリング準備
                    state <= 2;
                    divcnt <= 0;
                end
                default: if (divcnt > cfg_div) begin
                    // ステート2～9: データビット受信中、LSBから受信
                    pattern <= {uart_rx, pattern[7:1]};
                    state <= state + 1;
                    divcnt <= 0;
                end
                10: if (divcnt > cfg_div) begin
                    // ステート10: ストップビット受信完了、データ確定
                    buf_data <= pattern;
                    rx_valid <= 1;
                    state <= 0;
                end
            endcase
        end
endmodule

module uart_tx (
    input clk, rstn, output uart_tx,
    input start, input [31:0] cfg_div,
    input tx_write, [31:0] data,
    output ready
);
    reg [9:0] pat;
    reg [3:0] bit;
    reg [31:0] cnt;
    reg state;
    assign ready = !(tx_write && (bit || state));
    assign uart_tx = pat[0];
    always @(posedge clk) begin
        if (start)
            state <= 1;
        cnt <= cnt + 1;
        if (!rstn) begin
            pat <= ~0;
            bit <= 0;
            cnt <= 0;
            state <= 1;
        end else if (state && !bit) begin
            pat <= ~0;
            bit <= 15;
            cnt <= 0;
            state <= 0;
        end else if (tx_write && !bit) begin
            pat <= {1'b1, data[7:0], 1'b0};
            bit <= 10;
            cnt <= 0;
        end else if (cnt > cfg_div && bit) begin
            pat <= {1'b1, pat[9:1]};
            bit <= bit - 1;
            cnt <= 0;
        end
    end
endmodule
