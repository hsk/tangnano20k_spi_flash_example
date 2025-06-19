# startup.s: RISC-Vスタートアップコード
.section .text.start
.global _start
_start:
    # スタックポインタの初期化
    la sp, 0x10004000       # sp = 0x10004000

    # .dataセクションの初期化（ROMからRAMへコピー）
    la t0, _sidata          # ROMのデータ開始アドレス
    la t1, _sdata           # RAMのデータ開始アドレス
    la t2, _edata           # RAMのデータ終了アドレス
    beq t1, t2, data_done   # データが空ならスキップ
data_loop:
    lw t3, (t0)             # ROMから読み出し
    sw t3, (t1)             # RAMに書き込み
    addi t0, t0, 4          # 次のワード
    addi t1, t1, 4
    blt t1, t2, data_loop   # t1 < t2 ならループ
data_done:

    # .bssセクションのゼロクリア
    la t0, _sbss            # BSS開始アドレス
    la t1, _ebss            # BSS終了アドレス
    beq t0, t1, bss_done    # BSSが空ならスキップ
bss_loop:
    sw zero, (t0)           # 0を書き込み
    addi t0, t0, 4          # 次のワード
    blt t0, t1, bss_loop    # t0 < t1 ならループ
bss_done:

    # main関数を呼び出し
    jal ra, main

    # mainから戻ったら無限ループ
loop:
    j loop
