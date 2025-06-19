# link.ld: RISC-V用リンカスクリプト
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
    ROM  : ORIGIN = 0x00000000, LENGTH = 16K  # 0x00000000 - 0x00003FFF
    RAM  : ORIGIN = 0x10000000, LENGTH = 16K  # 0x10000000 - 0x10003FFF
}

SECTIONS {
    # プログラムコード（ROM）
    .text : {
        *(.text.start)  # スタートアップコード
        *(.text*)       # 他のコード
        *(.rodata*)     # 読み取り専用データ
    } > ROM

    # 初期化済みデータ（RAMにコピー、初期値はROM）
    .data : {
        _sdata = .;     # データセクションの開始
        *(.data*)
        _edata = .;     # データセクションの終了
    } > RAM AT > ROM

    # 未初期化データ（RAM）
    .bss : {
        _sbss = .;      # BSSセクションの開始
        *(.bss*)
        _ebss = .;      # BSSセクションの終了
    } > RAM

    # リンカ変数
    _sidata = LOADADDR(.data); # データのROM内アドレス
}
