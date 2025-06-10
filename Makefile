all:

clean:
	cd 2.27m_uart_flash_spi && make clean
	cd 2.72m_uart_flash_spi && make clean
	cd 3.27m_uart_flash_dspi && make clean
	cd 3.72m_uart_flash_dspi && make clean
	cd 3.72m_uart_flash_dspi2 && make clean
	cd 4.27m_uart_flash_qspi && make clean
	cd 4.72m_uart_flash_qspi && make clean
	cd 5.27m_uart_flash_dspi_io && make clean
	cd 5.72m_uart_flash_dspi_io && make clean
	cd 6.27m_uart_flash_qspi_io && make clean
	cd 6.72m_uart_flash_qspi_io && make clean
	cd 7.27m_uart_flash_dspi_io_cont && make clean
	cd 7.72m_uart_flash_dspi_io_cont && make clean
	cd 8.27m_uart_flash_qspi_io_cont && make clean
	cd 8.72m_uart_flash_qspi_io_cont && make clean
