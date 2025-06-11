module top (
    input sys_clk, rst, uart_rx,
    output uart_tx,
    output mspi_clk, mspi_cs, 
    inout  mspi_di,
    inout  mspi_do,
    inout  mspi_wp,
    inout  mspi_hold
);
    localparam DIV = 27_000_000/115200;
    wire clk = sys_clk;
    // 受信モジュール
    wire rx_valid;
    wire [7:0] rx_data;
    uart_rx #(.DEFAULT_DIV(DIV)) uart_rx_inst (
        .clk(clk),
        .rstn(~rst),
        .uart_rx(uart_rx),
        .read(!rst & rx_valid),
        .data(rx_data),
        .rx_valid(rx_valid)
    );

    // SPIフラッシュリーダー
    wire spi_ready;
    wire [7:0] spi_data;
    reg spi_read = 0;
    reg [23:0] addr = 24'h400000; // 初期アドレス0x400000

    qpi_flash_reader qspi_flash_inst (
        .clk(clk),
        .read(spi_read),
        .addr(addr),
        .ready(spi_ready),
        .data(spi_data),
        .cs(mspi_cs),
        .di(mspi_di),
        .do(mspi_do),
        .wp(mspi_wp),
        .hold(mspi_hold)
    );
    assign mspi_clk = clk;

    reg tx_mode;
    // 送信モジュール
    wire tx_ready, hex_ready;
    reg tx_write = 0;
    reg [7:0] tx_data = 8'h00;
    wire [7:0] tx_data1;
    wire tx_write1;
    uart_tx #(.DEFAULT_DIV(DIV)) uart_tx_inst (
        .clk(clk),
        .rstn(~rst),
        .tx_write(tx_mode==0?tx_write:tx_write1),
        .data(tx_mode==0?tx_data:tx_data1),
        .uart_tx(uart_tx),
        .ready(tx_ready)
    );
    uart_tx_hex uart_hex (
        .clk(clk),
        .hex_write(tx_mode==0?0:tx_write),
        .hex_data(tx_data),
        .hex_ready(hex_ready),
        .tx_data(tx_data1),
        .tx_write(tx_write1),
        .tx_ready(tx_ready)
    );

    // 制御ロジック
    reg [1:0] state = 0;
    localparam IDLE = 0, SPI = 2, TX = 3;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            spi_read <= 0;
            tx_write <= 0;
            addr <= 24'h400000;
        end else begin
            case (state)
                IDLE: begin
                    if (rx_valid) begin
                        tx_mode <= rx_data == 8'h61 ? 0 : 1;  // 'a'が受信された
                        spi_read <= 1;
                        state <= SPI;
                    end
                end
                SPI: begin
                    spi_read <= 0;
                    if (spi_ready) begin
                        tx_data <= spi_data; // SPIから読み込んだデータを送信データに設定
                        tx_write <= 1;
                        state <= TX;
                    end
                end
                TX: begin
                    tx_write <= 0;
                    if (tx_mode==0?tx_ready:hex_ready) begin
                        addr <= addr + 1; // アドレスをインクリメント
                        if (addr >= 24'h400000+24'd25) addr <= 24'h400000;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule

module qpi_flash_reader (
    input wire clk,
    input wire read,
    input [23:0] addr,
    output reg ready = 0,
    output reg [7:0] data = 8'h00,
    output reg cs = 1,
    inout di,
    inout do,
    inout wp,
    inout hold
);
    reg di_out, do_out, wp_out, hold_out;
    assign di   = (init < 2 || cnt <= 9) ? di_out : 1'bz;
    assign do   = (init < 2 || cnt <= 9) ? do_out : 1'bz;
    assign wp   = (init < 2 || cnt <= 9) ? wp_out : 1'bz;
    assign hold = (init < 2 || cnt <= 9) ? hold_out : 1'bz;
    reg [5:0] cnt = 0;
    reg [31:0] stack;
    reg [1:0] state = IDLE;
    localparam IDLE = 0, CMD = 1, SEND = 2, RECV = 3;
    reg [1:0] init = 0;
    reg cont = 0;
    always @(posedge clk) if (init == 0) begin
        cnt <= cnt + 1;
        if (state == IDLE) begin
            ready <= 0;
            cnt <= 0;
            state <= CMD;
            stack[7:0] <= 8'h38;// qpi enable
            cs <= 0;
        end else if (state == CMD) begin
            {di_out, stack[7:0]} <= {stack[7:0], 1'b1};
            if (cnt == 7) begin
                init <= 2;
                cs <= 1;
                state <= IDLE;
            end
        end
    /*
    end else if (init == 1) begin
        cnt <= cnt + 1;
        if (state == IDLE) begin
            cnt <= 0;
            state <= CMD;
            stack[15:0] <= {8'hc0,8'b0000_0000};// set read param
            cs <= 0;
        end else if (state == CMD) begin
            {hold_out, wp_out, do_out, di_out, stack[15:0]} <= {stack[15:0], 4'b1111};
            if (cnt == 3) begin
                init <= 2;
                cs <= 1;
                state <= IDLE;
            end
        end
    */
    end else begin
        cnt <= cnt + 1;
        if (state == IDLE) begin
            ready <= 0;
            cnt <= 0;
            if (read) begin
                if (cont) begin
                    cnt <= 2;
                    stack <= {addr, 8'b1110_1111};
                    state <= SEND;
                end else begin
                    stack[7:0] <= 8'heb;// qspi i/o
                    state <= CMD;
                end
                cs <= 0;
                data <= 0;
            end
        end else if (state == CMD) begin
            {hold_out, wp_out, do_out, di_out, stack[7:0]} <= {stack[7:0], 4'b1111};
            if (cnt == 1) begin
                cont <= 1;
                stack <= {addr, 8'b1110_1111};
                state <= SEND;
            end
        end else if (state == SEND) begin
            {hold_out, wp_out, do_out, di_out, stack} <= {stack, 4'b1111};
            if (cnt == 9)
                state <= RECV;
        end else if (state == RECV) begin
            data <= {data[3:0], hold, wp, do, di};
            if (cnt == 11) begin
                cs <= 1;
                ready <= 1;
                state <= IDLE;
            end
        end
    end
endmodule

module uart_rx #(
    parameter DEFAULT_DIV = 27_000_000/115200
) (
    input clk, rstn, uart_rx,
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
                1: if (2*divcnt > DEFAULT_DIV) begin
                    // ステート1: スタートビットの中間でサンプリング準備
                    state <= 2;
                    divcnt <= 0;
                end
                default: if (divcnt > DEFAULT_DIV) begin
                    // ステート2～9: データビット受信中、LSBから受信
                    pattern <= {uart_rx, pattern[7:1]};
                    state <= state + 1;
                    divcnt <= 0;
                end
                10: if (divcnt > DEFAULT_DIV) begin
                    // ステート10: ストップビット受信完了、データ確定
                    buf_data <= pattern;
                    rx_valid <= 1;
                    state <= 0;
                end
            endcase
        end
endmodule

module uart_tx #(
    parameter DEFAULT_DIV = 27_000_000/115200
) (
    input clk, rstn,
    input tx_write,
    input [7:0] data,
    output uart_tx,
    output ready
);
    // 送信パターンとビットカウンタ、分周カウンタ、ダミーフラグ
    reg [9:0] pattern;
    reg [3:0] bitcnt;
    reg [31:0] divcnt;
    reg send_dummy;

    // 送信信号は送信パターンのLSB
    assign uart_tx = pattern[0];
    // 書き込み時に送信中なら待ち状態を示す
    wire busy;
    assign busy = tx_write || (bitcnt || send_dummy);
    assign ready = !busy;
    // UART送信ロジック
    always @(posedge clk) begin
        if (!rstn) begin
            // リセット時は送信パターンを全1(アイドル状態)にし、ダミーフレーム送信中に設定
            pattern <= ~0;
            bitcnt <= 0;
            divcnt <= 0;
            send_dummy <= 1;
        end else begin
            divcnt <= divcnt + 1;
            if (send_dummy && !bitcnt) begin
                // ダミーフレーム送信中、ビット数が0になったら再びアイドル状態に戻す
                pattern <= ~0;
                bitcnt <= 15; // ダミーフレームの長さ設定（15ビット）
                divcnt <= 0;
                send_dummy <= 0;
            end else if (tx_write && !bitcnt) begin
                // データ書き込み要求があり、送信中でなければ送信開始
                pattern <= {1'b1, data, 1'b0}; // ストップビット, データ, スタートビット
                bitcnt <= 10; // 送信ビット数：1スタート + 8データ + 1ストップ
                divcnt <= 0;
            end else if (divcnt > DEFAULT_DIV && bitcnt) begin
                // 分周カウンタが設定値を超え、送信ビットが残っていれば1ビット送信
                pattern <= {1'b1, pattern[9:1]};
                bitcnt <= bitcnt - 1;
                divcnt <= 0;
            end
        end
    end
endmodule

module uart_tx_hex (
    input wire clk,          // クロック入力
    input wire hex_write,        // 送信開始信号（例：spi_ready）
    input wire [7:0] hex_data,   // 送信する8ビットデータ
    output reg [7:0] tx_data, // UARTに送るデータ（ASCIIコード）
    output reg tx_write,     // UART送信開始信号
    input wire tx_ready,          // UARTモジュールからのビジー信号
    output reg hex_ready = 0
);
    reg [1:0] state = 0;     // ステートマシン（0:待機, 1:上位ニブル送信, 2:下位ニブル送信）
    reg [3:0] next_data = 0; // 現在の送信データを保持

    // 4ビットのニブルをASCIIコードに変換する関数
    function [7:0] nibble_to_ascii;
        input [3:0] n;
        begin
            nibble_to_ascii = (n < 10) ? ("0" + n) : ("A" + (n - 10)); // 0-9は"0"～"9"、10-15は"A"～"F"
        end
    endfunction

    // クロックの立ち上がりエッジで動作
    always @(posedge clk) begin
        tx_write <= 0; // デフォルトで送信開始信号をクリア

        case (state)
            0: begin // 待機状態（IDLE）
                if (hex_write && tx_ready) begin // write信号がアクティブかつUARTがビジーでない
                    next_data <= hex_data[3:0]; // 入力データを保持
                    tx_data <= nibble_to_ascii(hex_data[7:4]); // 上位ニブルをASCIIに変換
                    tx_write <= 1; // UART送信開始
                    state <= 1;    // 上位ニブル送信状態へ
                    hex_ready <= 0;
                end
            end
            1: begin // 上位ニブル送信状態
                if (tx_ready && !tx_write) begin
                    tx_data <= nibble_to_ascii(next_data); // 下位ニブルをASCIIに変換
                    tx_write <= 1; // UART送信開始
                    state <= 2;    // 下位ニブル送信状態へ
                end
            end
            2: begin // 下位ニブル送信状態
                if (tx_ready && !tx_write) begin
                    state <= 0;    // 待機状態へ戻る
                    hex_ready <= 1;
                end
            end
            default: begin
                state <= 0;
            end
        endcase
    end
endmodule
