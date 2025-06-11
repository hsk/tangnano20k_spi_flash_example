# Tang Nano 20K SPI/QSPI/QPI フラッシュメモリ読み込み例

実機でタイミングがズレると動かないなどの問題があったので比較のため**27MHz**と**72MHz**の２つのバージョンを用意しました。

- [2.27m_uart_flash_spi](2.27m_uart_flash_spi)
    SPI 高速読み取りモード(0x0B)を**27MHz**で動す例
- [2.72m_uart_flash_spi](2.72m_uart_flash_spi)
    SPI 高速読み取りモード(0x0B)を**72MHz**で動す例
- [3.27m_uart_flash_dspi](3.27m_uart_flash_dspi)
    Dual SPI 高速読み取りモード(0x3B)を**27MHz**で動す例
- [3.72m_uart_flash_dspi](3.72m_uart_flash_dspi)
    Dual SPI 高速読み取りモード(0x3B)を**72MHz**で動す例
- [3.72m_uart_flash_dspi2](3.72m_uart_flash_dspi2)
    Dual SPI 高速読み取りモード(0x3B)を**72MHz**で動す例
- [4.27m_uart_flash_qspi](4.27m_uart_flash_qspi)
    Quad SPI 高速読み取りモード(0x6B)を**27MHz**で動す例
- [4.72m_uart_flash_qspi](4.72m_uart_flash_qspi)
    Quad SPI 高速読み取りモード(0x6B)を**72MHz**で動す例
- [5.27m_uart_flash_dspi_io](5.27m_uart_flash_dspi_io)
    Dual SPI 高速I/Oモード(0x3B)を**27MHz**で動す例
- [5.72m_uart_flash_dspi_io](5.72m_uart_flash_dspi_io)
    Dual SPI 高速I/Oモード(0x3B)を**72MHz**で動す例
- [6.27m_uart_flash_qspi_io](6.27m_uart_flash_qspi_io)
    Quad SPI 高速I/Oモード(0xEB)を**27MHz**で動す例
- [6.72m_uart_flash_qspi_io](6.72m_uart_flash_qspi_io)
    Quad SPI 高速I/Oモード(0xEB)を**72MHz**で動す例
- [7.27m_uart_flash_dspi_io_cont](7.27m_uart_flash_dspi_io_cont)
    Dual SPI 高速I/Oモード(0x3B)の継続読み出しを**27MHz**で動す例
- [7.72m_uart_flash_dspi_io_cont](7.72m_uart_flash_dspi_io_cont)
    Dual SPI 高速I/Oモード(0x3B)の継続読み出しを**72MHz**で動す例
- [8.27m_uart_flash_qspi_io_cont](8.27m_uart_flash_qspi_io_cont)
    Quad SPI 高速I/Oモード(0xEB)の継続読み出しを**27MHz**で動す例
- [8.72m_uart_flash_qspi_io_cont](8.72m_uart_flash_qspi_io_cont)
    Quad SPI 高速I/Oモード(0xEB)の継続読み出しを**72MHz**で動す例
- [9.27m_uart_flash_qpi](9.27m_uart_flash_qpi)
    QPIモード(0x38, 0xEB)を**27MHz**で動かす例
- [9.72m_uart_flash_qpi](9.72m_uart_flash_qpi)
    QPIモード(0x38, 0xEB)を**72MHz**で動かす例
- [10.27m_uart_flash_qpi_cont](10.27m_uart_flash_qpi_cont)
    QPIモード(0x38, 0xEB)の継続読み出しを**27MHz**で動かす例
- [10.72m_uart_flash_qpi_cont](10.72m_uart_flash_qpi_cont)
    QPIモード(0x38, 0xEB)の継続読み出しを**72MHz**で動かす例
