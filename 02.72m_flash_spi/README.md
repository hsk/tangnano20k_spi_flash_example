# Tang Nano 20K Flash SPI Fast モード サンプル

コマンド 0x0B を使い１バイト分高速なクロックでも動作するようにダミーを送ります。

pythonでcsを0にしてコマンド0x03を送り、アドレス24ビットを送った後、データを読み取るのが通常モードです:

```python
    def read_bytes_spi(self, address, length):
        self.spi.cs = 0  # 通信開始
        # コマンド送信: 0x03 (read)
        self.send_byte(0x03)
        # アドレス送信（上位 → 下位）
        self.send_byte((address >> 16) & 0xFF)
        self.send_byte((address >> 8) & 0xFF)
        self.send_byte(address & 0xFF)
        # データ読み取り
        data = [self.read_byte() for _ in range(length)]
        self.spi.cs = 1  # 通信終了
        self.on_clk_fall()
        return data
```

一方高速モードではコマンド0x0B、アドレス24バイトの後にダミーバイトを送ってから読み取ります:

```python
    def read_bytes_spi_fast(self, address, length):
        self.spi.cs = 0
        self.send_byte(0x0B)  # 高速読み出しコマンド
        self.send_byte((address >> 16) & 0xFF)
        self.send_byte((address >> 8) & 0xFF)
        self.send_byte(address & 0xFF)
        self.send_byte(0x00)  # ダミーバイト
        data = [self.read_byte() for _ in range(length)]
        self.spi.cs = 1
        self.on_clk_fall()
        return data
```

verilog の実装では 0x0b を送り高速モードで動作させています。

72MHz で動かす場合は読み込み前に 1クロックウェイトを入れるとうまく動いたのでウェイトが入れてあります。

