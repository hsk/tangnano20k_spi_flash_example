# Tang Nano 20K SPI/QSPI/QPI フラッシュメモリ読み込み例

実機でタイミングがズレると動かないなどの問題があったので比較のため**27MHz**と**72MHz**の２つのバージョンを用意しました。
全体的に各ディレクトリでmacos環境でmakeを実行するとgw_shとopenFPGALoaderがインストールされていれば、screenコマンドでUARTで接続されます。
そのままでは何も起きませんが a を押すと文字列が１文字0x400000から読み出され、それ以外のキーを押すと16進数で表示されます。

- [02.27m_flash_spi](02.27m_flash_spi)
    SPI 高速読み取りモード(0x0B)を**27MHz**で動す例
- [02.72m_flash_spi](02.72m_flash_spi)
    SPI 高速読み取りモード(0x0B)を**72MHz**で動す例
- [03.27m_flash_dspi](03.27m_flash_dspi)
    Dual SPI 高速読み取りモード(0x3B)を**27MHz**で動す例
- [03.72m_flash_dspi](03.72m_flash_dspi)
    Dual SPI 高速読み取りモード(0x3B)を**72MHz**で動す例
- [03.72m_flash_dspi2](03.72m_flash_dspi2)
    Dual SPI 高速読み取りモード(0x3B)を**72MHz**で動す例
- [04.27m_flash_qspi](04.27m_flash_qspi)
    Quad SPI 高速読み取りモード(0x6B)を**27MHz**で動す例
- [04.72m_flash_qspi](04.72m_flash_qspi)
    Quad SPI 高速読み取りモード(0x6B)を**72MHz**で動す例
- [05.27m_flash_dspi_io](05.27m_flash_dspi_io)
    Dual SPI 高速I/Oモード(0x3B)を**27MHz**で動す例
- [05.72m_flash_dspi_io](05.72m_flash_dspi_io)
    Dual SPI 高速I/Oモード(0x3B)を**72MHz**で動す例
- [06.27m_flash_qspi_io](06.27m_flash_qspi_io)
    Quad SPI 高速I/Oモード(0xEB)を**27MHz**で動す例
- [06.72m_flash_qspi_io](06.72m_flash_qspi_io)
    Quad SPI 高速I/Oモード(0xEB)を**72MHz**で動す例
- [07.27m_flash_dspi_io_cont](07.27m_flash_dspi_io_cont)
    Dual SPI 高速I/Oモード(0x3B)の継続読み出しを**27MHz**で動す例
- [07.72m_flash_dspi_io_cont](07.72m_flash_dspi_io_cont)
    Dual SPI 高速I/Oモード(0x3B)の継続読み出しを**72MHz**で動す例
- [08.27m_flash_qspi_io_cont](08.27m_flash_qspi_io_cont)
    Quad SPI 高速I/Oモード(0xEB)の継続読み出しを**27MHz**で動す例
- [08.72m_flash_qspi_io_cont](08.72m_flash_qspi_io_cont)
    Quad SPI 高速I/Oモード(0xEB)の継続読み出しを**72MHz**で動す例
- [09.27m_flash_qpi](09.27m_flash_qpi)
    QPIモード(0x38, 0xEB)を**27MHz**で動かす例
- [09.72m_flash_qpi](09.72m_flash_qpi)
    QPIモード(0x38, 0xEB)を**72MHz**で動かす例
- [10.27m_flash_qpi_cont](10.27m_flash_qpi_cont)
    QPIモード(0x38, 0xEB)の継続読み出しを**27MHz**で動かす例
- [10.72m_flash_qpi_cont](10.72m_flash_qpi_cont)
    QPIモード(0x38, 0xEB)の継続読み出しを**72MHz**で動かす例

QPI モードに入ると QPIモードから抜けずに終了するので次に書き込めなくなります。
その時は電源を入れ直ししたり、ボタンを押しながらロードするとロードできます。


