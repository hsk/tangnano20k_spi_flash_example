all:

clean:
	cd 02.27m_flash_spi && make clean
	cd 02.72m_flash_spi && make clean
	cd 03.27m_flash_dspi && make clean
	cd 03.72m_flash_dspi && make clean
	cd 03.72m_flash_dspi2 && make clean
	cd 04.27m_flash_qspi && make clean
	cd 04.72m_flash_qspi && make clean
	cd 05.27m_flash_dspi_io && make clean
	cd 05.72m_flash_dspi_io && make clean
	cd 06.27m_flash_qspi_io && make clean
	cd 06.72m_flash_qspi_io && make clean
	cd 07.27m_flash_dspi_io_cont && make clean
	cd 07.72m_flash_dspi_io_cont && make clean
	cd 08.27m_flash_qspi_io_cont && make clean
	cd 08.72m_flash_qspi_io_cont && make clean
	cd 09.27m_flash_qpi && make clean
	cd 09.72m_flash_qpi && make clean
	cd 10.27m_flash_qpi_cont && make clean
	cd 10.72m_flash_qpi_cont && make clean
	cd 20.27m_rv32_uart && make clean
	cd 20.72m_rv32_uart && make clean
	cd 21.72m_rv32_uart_sram2 && make clean
	cd 22.72m_rv32_uart_sram2_flash_spi && make clean
	cd 32.72m_rv32_uart_flash_spi_sram && make clean
	cd 33.72m_rv32_uart_flash_dspi_sram && make clean
	cd 34.72m_rv32_uart_flash_qspi_sram && make clean
	cd 35.72m_rv32_uart_flash_dspi_io_sram && make clean
	cd 37.72m_rv32_uart_flash_dspi_io_cont_sram && make clean
	cd x26.72m_rv32_uart_sram2_flash_qspi_io && make clean
	cd x36.72m_rv32_uart_flash_qspi_io_sram && make clean
	cd x38.72m_rv32_uart_flash_qspi_io_sram && make clean
