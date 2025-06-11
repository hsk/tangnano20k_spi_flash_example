# Tang Nano 20K Flash Dual SPI Fast モード サンプル

コマンド 0x3B を使い１バイト分高速なクロックでも動作するようにダミーを送ります。

Dual 高速モードではコマンド0x3B、アドレス24バイトの後にダミーバイトを送ってから2bitずつ読み取ります:

```python
    def read_bytes_dspi(self, address, length):
        self.spi.cs = 0
        self.send_byte(0x3B)  # Fast Read Dual Output
        self.send_byte((address >> 16) & 0xFF)
        self.send_byte((address >> 8) & 0xFF)
        self.send_byte(address & 0xFF)
        self.send_byte(0x00)  # Dummy byte
        data = [self.read_byte2() for _ in range(length)]
        self.spi.cs = 1
        self.on_clk_fall()
        return data

    def read_byte2(self):
        return self.send_byte2(0x00)

    def send_byte2(self, byte_out):
        byte_in = 0
        for i in range(4):
            self.spi.miso = (byte_out >> (7 - i*2)) & 1
            self.spi.mosi = (byte_out >> (6 - i*2)) & 1
            self.on_clk_fall()
            bit_in = (self.spi.miso << 1) | self.spi.mosi
            byte_in = (byte_in << 2) | bit_in
        return byte_in

```

verilog の実装では 0x3b を送り高速モードで動作させています。
コマンド1バイト、アドレス3バイト、ダミー1バイトを1bit単位で送り、データ読み取りは2bitずつ読み込むので1バイト読み出しに 8+8*3+8+4=8*5+4=**44クロック** かかります。
