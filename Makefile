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
