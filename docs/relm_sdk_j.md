# ReLM開発環境

## 開発言語

* Python
  * アプリケーションをPython上のDSLで記述して、ReLMアーキテクチャ用のバイナリコードを生成します。
  * 開発中は回路を固定してソフトウェアのみを更新しますので、煩わしい論理合成が不要になります。
    * Intel(ALTERA)環境では、USB BlasterをDLL呼び出しで使用します。
  * なるべく新しいバージョンが望ましいですが、[:= 演算子](https://docs.python.org/3/whatsnew/3.8.html)を使用しますのでPython 3.8以降になります。
* Verilog HDL
  * FPGA用の論理合成に使用します。
  * デバイス接続用のカスタムロジックや、カスタム拡張命令の記述にも使用します。

## 開発ツール

* Quartus Prime
  * Intel(ALTERA) FPGA用の論理合成に必要です。
  * Pythonからの通信のため、付属のUSB Blasterのドライバーもインストールする必要があります。
  * FPGAの規模によりますが、基本的にLite Editionで問題ありません。
* Visual Studio Code（推奨）
  * プラグインでPythonとVerilog HDLどちらも対応可能です。
  * Pythonコードの起動が比較的簡単です。
  * [GitHub Copilot](https://github.com/features/copilot)が利用可能です。
    * ReLM関連のコード例が増えれば予測精度が向上するかもしれません。

## ターゲットFPGAボード

* [Terasic DE0-CV Board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=183&No=921)
  * FPGA: Cyclone V 5CEBA4F23C7N
  * 8コア構成
    * 16コア構成も可能だが余裕が無い
  * PS/2 port
  * VGA output
  * ___残念ながら生産中止なので、次期ターゲットに切り替え予定___

* [Terasic Cyclone V GX Starter Kit](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=830)
  * FPGA: Cyclone V GX 5CGXFC5C6F27C7N
  * 16コア構成（予定）
  * HDMI output
  * Audio input & output
  * Arduino header
    * USB Host Shield経由でUSBデバイス対応予定
  * Micro SD Card
    * AIアプリケーションに使用予定
  * ___次期メインターゲット予定___

## ファイル構成

* relm.v  
_ReLMアーキテクチャ基本回路実装_
* relm_custom_none.v  
_カスタム命令無し_
* relm_custom_div.v  
_カスタム命令（整数除算）_
* relm.py  
_Python DSL基本ライブラリ_
* relm_jtag.py  
_USB Blaster通信関連_
* __de0cv (folder)__  
_DE0-CVターゲット関連_
  * __relm_de0cv.py__  
  _DE0-CVデバイス対応（ローダー生成）_
  * relm_font.py  
  _コンソール出力関連_
  * relm_de0cv.v  
  _DE0-CVトップモジュール_
  * relm_de0cv.sdc  
  _クロック周波数指定_
  * __loader (folder)__  
  _開発時ローダー関連_
    * __relm_de0cv.qpf__  
    _Quartus Primeプロジェクト（ローダー構成）_
    * relm_de0cv.qsf  
    _Quartus Primeプロジェクト設定_
    * __relm_test_led.py__  
    _LEDテスト（ローダー実行）_
    * __relm_test_ps2.py__  
    _PS/2通信テスト（ローダー実行）_
    * __relm_test_vga.py__  
    _VGA表示テスト（ローダー実行）_
  * __bubble (folder)__  
  _Playable PoC ゲームアプリ関連_
    * __relm_bubble.py__  
    _Playable PoC サンプルゲームアプリ 『Bubble Estate』_
    * __relm_bubble_release.py__  
    _スタンドアロン構成リリース用メモリイメージ生成_
    * __relm_de0cv.qpf__  
    _Quartus Primeプロジェクト（スタンドアロン構成）_
    * relm_de0cv.qsf  
    _Quartus Primeプロジェクト設定_

## ローダー構成準備

DE0-CVターゲットを例に開発作業手順を説明していきます。

de0cvフォルダ内の __relm_de0cv.py__ を実行すると、de0cv/loaderフォルダ内にコードデータ出力code??.txtとdata??.txtが作成されます。

コードデータ出力と同じフォルダにあるQuartus Primeのプロジェクトファイル __relm_de0cv.qpf__ を開いて論理合成すると、プログラムローダーを実装したReLM環境が生成されます。（必要な設定は既にrelm_de0cv.qsf内に保存）

生成されたReLM環境はloader/output_files環境に以下のFPGAコンフィグレーション用ファイルとして保存されます。
* __relm_de0cv.sof__  
_Quartus PrimeでFPGAをコンフィグレーションするためのSOFファイル_
* __relm_de0cv.pof__  
_Quartus Primeでボード上のROMに回路を書き込んで電源投入時にコンフィグレーションするためのPOFファイル_
* __relm_de0cv.svf__  
_ReLM環境で直接コンフィグレーションするためのSVFファイル_

SOFファイルは最も標準的なコンフィグレーション用ファイルですが、毎回Quartus Primeを使用する必要がありますのでReLM環境上での開発作業では若干不便です。

ReLM環境で最も使いやすいのはSVFファイルによるコンフィグレーションで、ボード上のROMに全く別の回路が入っていたとしても、自動的にリセットを掛けてReLMローダー環境を読み込んでの実行が可能なので、とても便利です。（ボード上のROMの内容は変更しない）

SVFファイルによる起動ではコンフィグレーションに数秒ほど待たされるので、作業が佳境に入ってくると若干効率を上げたくなるかもしれません。

そういった場合、POFファイルを使ってボード上のROMを書き換えると、電源投入ですぐにローダー環境が立ち上がるので起動時の待ち時間が短縮されます。（POFファイルによるROMの書き換えに関しては、FPGAボードの説明書を参照）

POFファイルはローダー環境以外にも、ReLM環境で開発したアプリケーションをホストPC無しでも起動できるようにする、スタンドアロン構成のリリース（ROMへの書き込み）にも利用されます。

## ReLMの起動シーケンス

コードデータ出力時のデバッグ用ダンプ出力を利用して、電源投入時の起動シーケンスについて説明します。

DE0-CVターゲットは８コア構成なので、最初の８ワードは全８スレッドのエントリーポイントになります。

~~~
0000:   JUMP    0000:           218:        with ReLMLoader(__file__, "..", "loader", release_loader=True):
0001:   JUMP    0001:           218:        with ReLMLoader(__file__, "..", "loader", release_loader=True):
0002:   JUMP    0002:           218:        with ReLMLoader(__file__, "..", "loader", release_loader=True):
0003:   JUMP    0003:           218:        with ReLMLoader(__file__, "..", "loader", release_loader=True):
0004:   JUMP    0004:           218:        with ReLMLoader(__file__, "..", "loader", release_loader=True):
0005:   JUMP    0005:           218:        with ReLMLoader(__file__, "..", "loader", release_loader=True):
0006:   JUMP    0006:           218:        with ReLMLoader(__file__, "..", "loader", release_loader=True):
0007:   JUMP    0008:           142:    Loader[
~~~

０番地から６番地までは同じ番地へのジャンプ命令となりますので、最初の７スレッドは休止状態となります。

７番地は８番地へのジャンプとなり、８番地からはプログラムローダーのコードが続きますので、スレッドの１つを使用してプログラムローダーを実行していることがわかります。

~~~
0008:   IN      JTAG            144:            Out("PUTOP", In("JTAG")),
0009:   BLOAD   PUTOP           144:            Out("PUTOP", In("JTAG")),
000A:   OPB     OUT             144:            Out("PUTOP", In("JTAG")),
000B:   OPB     LOAD            145:            If(RegB & 0xC00000 != 0)[
000C:   AND     00C00000        145:            If(RegB & 0xC00000 != 0)[
000D:   JEQ     0013:           145:            If(RegB & 0xC00000 != 0)[
000E:   AND     00800000        146:                (Acc & 0x800000).opb("JEQ"),
000F:   OPB     JEQ             146:                (Acc & 0x800000).opb("JEQ"),
0010:   LOAD    00000000        147:                (+operand).opb("PUT"),
0011:   OPB     PUT             147:                (+operand).opb("PUT"),
0012:   JUMP    0008:           148:                Continue(),
0013:   LOAD    00000000        150:            operand(operand << 16 | RegB),
0014:   MUL     00010000        150:            operand(operand << 16 | RegB),
0015:   OPB     OR              150:            operand(operand << 16 | RegB),
0016:   PUT     0010:           141:    operand = Int()
0017:   PUT     0013:           141:    operand = Int()
0018:   JUMP    0008:
~~~

左側のアセンブリコードに対し、右側はソースコードのどの行に対応するかを示しています。

プログラムローダー部分のソースコード（relm_de0cv.py）は以下になりますが、まず"JTAG"からデータを入力して"PUTOP"に出力していることがわかります。

~~~ py
operand = Int()
Loader[
    Do()[
        Out("PUTOP", In("JTAG")),
        If(RegB & 0xC00000 != 0)[
            (Acc & 0x800000).opb("JEQ"),
            (+operand).opb("PUT"),
            Continue(),
        ],
        operand(operand << 16 | RegB),
    ],
]
del operand
~~~

この"PUTOP"というのはプログラムローダーが使用する命令コード（OpCode）書き換え用デバイスのポート番号で、開発終了後のリリース時には削除される機能です。

アセンブリコードの可読性を上げるため、I/Oポート番号や命令コードは文字列で指定して、メモリに書き込む際に実際の数値のコードに変換されます。

RegBやAccはReLMアーキテクチャのレジスタに直接アクセスするための[intrinsic](https://en.wikipedia.org/wiki/Intrinsic_function)ですが、これはプログラムローダーのコードを極力コンパクトにするための最適化で、通常のアプリケーションレベルでは必ずしも使う必要はありません。

先程作成したコードデータ出力は、このプログラムローダーだけが起動している状態のメモリーイメージになります。

FPGA上のReLM環境でプログラムローダーが起動していると、任意の番地の命令コード（OpCode）とオペランド（Operand）を書き換えられますので、ホストPCから[JTAG](https://ja.wikipedia.org/wiki/JTAG)経由でローダー直後の番地（0x19）からプログラムコードを書き込み、最後にスレッドエントリー（０番地～７番地）のオペランドを書き換えるとスレッドを起動することができます。

このプログラムローダー環境を利用することで、煩わしい論理合成をせずにアプリケーションソフトウェアの開発作業を進めることが可能になります。

loaderフォルダ内に動作確認用のサンプルコードがありますので、これらのコードを使ってPythonコードによるアプリケーション記述について説明します。

## 動作確認: LED点灯およびボタン入力（relm_test_led.py）

FPGAボードを接続した状態で、まずrelm_test_led.pyを実行してみてください。

<details><summary>出力を表示</summary>

~~~
0000:   JUMP    0019:           9:          Thread[
0001:   JUMP    0001:           8:      with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
0002:   JUMP    0002:           8:      with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
0003:   JUMP    0003:           8:      with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
0004:   JUMP    0004:           8:      with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
0005:   JUMP    0005:           8:      with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
0006:   JUMP    0006:           8:      with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
0007:   JUMP    0008:           6:      from relm_de0cv import *
0008:   IN      JTAG            6:      from relm_de0cv import *
0009:   BLOAD   PUTOP           6:      from relm_de0cv import *
000A:   OPB     OUT             6:      from relm_de0cv import *
000B:   OPB     LOAD            6:      from relm_de0cv import *
000C:   AND     00C00000        6:      from relm_de0cv import *
000D:   JEQ     0013:           6:      from relm_de0cv import *
000E:   AND     00800000        6:      from relm_de0cv import *
000F:   OPB     JEQ             6:      from relm_de0cv import *
0010:   LOAD    00000000        6:      from relm_de0cv import *
0011:   OPB     PUT             6:      from relm_de0cv import *
0012:   JUMP    0008:           6:      from relm_de0cv import *
0013:   LOAD    00000000        6:      from relm_de0cv import *
0014:   MUL     00010000        6:      from relm_de0cv import *
0015:   OPB     OR              6:      from relm_de0cv import *
0016:   PUT     0010:           6:      from relm_de0cv import *
0017:   PUT     0013:           6:      from relm_de0cv import *
0018:   JUMP    0008:
0019:   LOAD    LED1            10:             LED(
001A:   OUT     7DDB4B4B        10:             LED(
001B:   LOAD    LED0            10:             LED(
001C:   OUT     EF030000        10:             LED(
001D:   IN      KEY             19:                 key := Int(In("KEY")),
001E:   PUT     0020:           19:                 key := Int(In("KEY")),
001F:   PUT     0022:           19:                 key := Int(In("KEY")),
0020:   LOAD    00000000        20:                 Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
0021:   AND     0000001F        20:                 Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
0022:   BLOAD   00000000        20:                 Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
0023:   SAR     00000020        20:                 Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
0024:   OPB     XOR             20:                 Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
0025:   MUL     00000002        20:                 Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
0026:   ADD     00000001        20:                 Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
0027:   BLOAD   LED0            20:                 Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
0028:   OPB     OUT             20:                 Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
0029:   JUMP    001D:
SVF configuration: loader/output_files/relm_de0cv.svf
IDCODE: 2B050DD
..................................................
.
Loading instructions...
IDCODE: 2B050DD
42 / 65536 instructions (0.1 % used)
~~~
</details><br>

起動に成功するとPCのコンソールに上のダンプ出力が表示され、FPGAボードではLEDに HELLO_ と表示されてボタンを押したりスイッチを変更したりすると、LEDが連動して変化するようになります。

残念ながらローダー部分のソースコードはダンプ出力に表示されなくなりますが、0x19番地からユーザーコードが読み込まれ、０番地から起動されていることが読み取れます。

Pythonのソースコードは以下になります。

~~~ py
with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
    Thread[
        LED(
            hex5=0b0111110,  # H
            hex4=0b1101101,  # E
            hex3=0b0100101,  # L
            hex2=0b0100101,  # L
            hex1=0b1110111,  # O
            hex0=0b0000001,  # _
        ),
        Do()[
            key := Int(In("KEY")),
            Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
        ],
    ]
~~~

ReLMLoaderのloaderオプションで実行構成を選択できますが、ここではSVFファイルの相対パスを指定しています。

loaderにSVFファイルを指定すると、ボードのリセットとによるローダー環境のコンフィグレーションを実行した上で、さらにこのローダー環境を利用したプログラムのロードと起動を行います。

なお、SVFファイル指定の相対パスはrelm_de0cv.pyがあるフォルダde0cvが基準となります。（アプリケーションコードのフォルダではない）

loader=Trueと指定するかSVFファイルを削除（警告メッセージが出る）すると、FPGAボード上のROMにローダー環境が既に保存されている場合、SVFファイルによるローダー環境のコンフィギュレーションをせずにROM上のローダー環境を利用してプログラムをロードするようになります。

load=Falseとすると、プログラムのロードを行わずダンプ出力のみを表示します。

このオプションではFPGAボードを使用しないので、プログラムがまだ未完成でダンプ出力によるチェックのみをしたい場合等、ボード未接続でも問題なく利用可能です。

ReLMのアプリケーションコードは、基本的にReLMLoaderのwithブロック内に記述します。

FPGAに送信されるコードは __Thread[ ]__ または __Define[ ]__ ブロックに記述しますが、__Thread[ ]__ ブロック毎にスレッドが１つ起動します。

後から参照される配列データや関数オブジェクトの定義は __Define[ ]__ ブロック内に記述します。

通常のPython文法内で[ドメイン固有言語](https://ja.wikipedia.org/wiki/%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3%E5%9B%BA%E6%9C%89%E8%A8%80%E8%AA%9E)を構築する都合上、コードブロックは配列の要素の様にカンマ区切りの式の列として記述されます。

かなり見慣れない表記になりますので、コード整形ツールの導入をお勧めいたします。（私はVisual Studio Code環境で[Black Formatter](https://black.readthedocs.io/en/stable/)を使用）

この表記の都合上、全ての実行文は式としても評価できる必要があります。

Pythonの通常の代入文 __[変数名 = 式]__ は式としては評価できないので、変数定義の場合は[:= 演算子](https://docs.python.org/3/whatsnew/3.8.html)で __[変数名 := 式]__ 定義をしない既存変数への代入は __[変数名(式)]__ の様に括弧つき表記になります。

上の例では以下のPythonコードが key という符号付き整数型（Int）変数の定義と初期化の処理になります。
~~~ py
            key := Int(In("KEY")),
~~~

このアセンブリコード出力は以下の様に、I/Oポートからのボタン状態の取得と、PUT命令２つに展開されます。
~~~
001D:   IN      KEY             19:                 key := Int(In("KEY")),
001E:   PUT     0020:           19:                 key := Int(In("KEY")),
001F:   PUT     0022:           19:                 key := Int(In("KEY")),
~~~

ここでPUT命令が２つあるのは key の参照が２箇所あるためで、Int型変数の実体は、実は全ての参照箇所のオペランドとなります。
~~~ py
            Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
~~~

プログラムローダーのコードにも出てきましたが、__Do()[__ ブロック __]__ は無限ループになります。

__Do()[__ ブロック __].While(__ 条件式 __)__ で脱出条件を付けると通常の[do-while文](https://ja.wikipedia.org/wiki/Do-while%E6%96%87)になります。

## 動作確認: PS/2キーボード入力（relm_test_ps2.py）

念のため、FPGAボードの電源を切った状態でPS/2ポートにキーボードを接続してください。

FPGAボードの電源を入れて、relm_test_ps2.pyを実行してください。

起動に成功するとLEDに PS2PS2 と表示され、キーボード上のLEDが点灯し、キーボードを押すとキーコードに応じてLEDが点滅するようになります。

Pythonコードは以下の様になります。

<details><summary>コードを表示</summary>

~~~ py
with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
    Define[
        # sendPS2 := SendPS2(),
        sendPS2 := Function(data := Int())[
            IO("PS2", 0x80000001),
            Acc(1 - (-100 * 1000) // (20 * ReLM.ncpu)),  # 100us
            Do()[...].While(Acc - 1 != 0),
            IO("PS2", 0x40000000),
            data & 0xFF,
            IO("PS2", 0x0, load="BLOAD"),
            IO("PS2", RegB | 0x40000000),
            IO("PS2", RegB),
            IO("PS2", (RegB >> 1) | 0x40000000),
            IO("PS2", RegB >> 1),
            IO("PS2", (RegB >> 2) | 0x40000000),
            IO("PS2", RegB >> 2),
            IO("PS2", (RegB >> 3) | 0x40000000),
            IO("PS2", RegB >> 3),
            IO("PS2", (RegB >> 4) | 0x40000000),
            IO("PS2", RegB >> 4),
            IO("PS2", (RegB >> 5) | 0x40000000),
            IO("PS2", RegB >> 5),
            IO("PS2", (RegB >> 6) | 0x40000000),
            IO("PS2", RegB >> 6),
            IO("PS2", (RegB >> 7) | 0x40000000),
            IO("PS2", RegB >> 7),
            RegB((RegB >> 1) ^ RegB),
            RegB((RegB >> 2) ^ RegB),
            RegB((RegB >> 4) ^ RegB),
            IO("PS2", RegB ^ 0x40000001),
            IO("PS2", RegB ^ 0x1),
            IO("PS2", 0x40000001),
            IO("PS2", 0x1),
            IO("PS2", 0x40000001),
        ],
        # recvPS2 := RecvPS2(),
        recvPS2 := Function()[
            Do()[IO("PS2", 0x40000001),].While(IO("PS2", 0x1) != 0),
            IO("PS2", 0x40000001),
            IO("PS2", 0x1),
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 1) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 2) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 3) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 4) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 5) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 6) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 7) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            IO("PS2", 0x1),
            IO("PS2", 0x40000001),
            IO("PS2", 0x1),
            IO("PS2", 0x40000001),
        ].Return(RegB),
    ]
    Thread[
        LED(
            hex5=0b1111100,  # P
            hex4=0b1101011,  # S
            hex3=0b1011101,  # 2
            hex2=0b1111100,  # P
            hex1=0b1101011,  # S
            hex0=0b1011101,  # 2
        ),
        sendPS2(0xED),  # Keyboard LED command
        sendPS2(0x7),  # Keyboard LED command
        # sendPS2(0xF4),  # Mouse Enable
        Do()[Out("LED0", recvPS2() * 2 + 1),],
    ]
~~~
</details><br>

__Thread[ ]__ ブロックの前に __Define[ ]__ ブロックで関数オブジェクト(Function)を２つ定義しています。

このように、スレッドを起動せずに後で参照される関数や配列といったオブジェクトを定義する場合、__Define[ ]__ ブロックを使用します。

PS/2ポートにデータを創出するsendPS2関数定義の冒頭は以下になります。

~~~ py
        sendPS2 := Function(data := Int())[
            IO("PS2", 0x80000001),
            Acc(1 - (-100 * 1000) // (20 * ReLM.ncpu)),  # 100us
            Do()[...].While(Acc - 1 != 0),
~~~

関数定義では、パラメータにInt型変数の定義を入れて、続く関数本体でパラメータを参照するコードを記述します。

ここではPS/2の送信開始時にクロック信号をLに落として100マイクロ秒待機する処理ですが、待ち時間用のループ数計算は通常のPython式で計算して、結果をアキュムレータ（Acc）に代入しています。

続くDo-Whileループの本体にEllipsis（...）が入っていますが、これはPythonの文法上ブロック内を空にできないので、ダミーのオブジェクトで見た目の違和感が少ないものを置いています。

実はブロック内でStatement型（relm.pyで定義）以外のオブジェクトを置いてもコード生成の際は無視されますので、Noneや０といった数値を置いても同じ効果になります。（数値だけを置いても何も起こらないので、アキュムレータに代入したい場合 Acc(数値) とする）

以下は関数呼び出し側のコードですが、
~~~ py
        sendPS2(0xED),  # Keyboard LED command
~~~
この部分のアセンブリコード出力は以下の様になり、パラメータ変数への代入と、戻り先番地（以下では0xB4）をアキュムレータに入れて関数のエントリーポイントにジャンプするコードに展開されます。
~~~
00BC:   LOAD    000000ED        78:             sendPS2(0xED),  # Keyboard LED command
00BD:   PUT     0021:           11:             sendPS2 := Function(data := Int())[
00BE:   LOAD    000000B4        78:             sendPS2(0xED),  # Keyboard LED command
00BF:   JUMP    0019:           78:             sendPS2(0xED),  # Keyboard LED command
~~~

関数の戻り先番地は回転待ちのペナルティを抑えるために最適化されますので、必ずしも連続したコード配置にはなりません。

recvPS2関数は本体の末尾で結果を返していますので、
~~~ py
        recvPS2 := Function()[
        ...
        ].Return(RegB),
~~~
式の中で呼び出して結果を参照することができます。
~~~ py
        Do()[Out("LED0", recvPS2() * 2 + 1),],
~~~

## 動作確認: VGAディスプレイ出力（relm_test_vga.py）

relm_test_vga.pyはVGAで画面に文字を出力する比較的複雑なサンプルです。

最初のスレッドはVRAMの実装です。
~~~ py
    Thread[
        Acc("VGA"),
        Do()[vram := Array(*([0xFEDCBA98] * 80 * 480))],
    ]
~~~

VRAMとして配列（Array）オブジェクトを定義していますが、その実体は連続したPUSH命令です。

アキュムレータにVGA出力用FIFOのポート番号を入れてPUSH命令のループを回し続けることで、映像信号を生成することができるようになります。

DE0-CVターゲットのコードメモリは65536ワードなので、VRAMがこれに収まるようにピクセル当たり4ビット（16色）の[インデックスカラー](https://ja.wikipedia.org/wiki/%E3%82%A4%E3%83%B3%E3%83%87%E3%83%83%E3%82%AF%E3%82%B9%E3%82%AB%E3%83%A9%E3%83%BC)を採用しています。

それでもVGAで 640 x 480 ピクセルの場合、80 x 480 = 38400 ワードが必要になりますので、コードメモリの半分以上をVRAMが占めることになります。

Arrayオブジェクトはこのように巨大になる可能性がありますので、デバッグ用ダンプ出力は先頭10要素までで抑止されます。

次にコンソールオブジェクトとサービススレッドの起動です。

~~~ py
    console = Console(vram, 80, FIFO.Alloc(), FIFO.Alloc())
    Thread[console.Service()]
~~~

FIFO.Alloc() はFIFOの割り当てで、フォントデータの通信用とメインスレッドとの通信用の２本割り当てます。

サービススレッドの実装部分はrelm_font.pyにあります。

~~~ py
    def Service(self) -> Block:
        return Block[
            pos := Int(),
            color_fg := Int(),
            color_bg := Int(),
            self.fifo_font.Lock(),
            self.fifo_print.Lock(),
            Do()[
                If(RegB(self.fifo_print.Pop(), 0x80000000).opb("AND") == 0)[
                    text := Int(RegB),
                    While(text != 0)[
                        self.PutChar(pos, text & 0x7F, color_fg, color_bg),
                        pos(pos + 1),
                        text(text >> 8),
                    ],
                    Continue(),
                ],
                If(RegB & 0x40000000 == 0)[pos(RegB & 0x3FFFFFFF), Continue()],
                bg := Int(RegB & 0xF),
                color_bg(Acc * 0x11111111),
                color_fg(((RegB & 0xF0) >> 4) - bg),
            ],
        ]
~~~

必要に応じてコードを展開したい場合、このようにBlockオブジェクトやFunctionオブジェクトを返すPython関数を用意して、ThreadブロックやDefineブロックの中で呼び出します。

以下はメインスレッドでのカラーパレット設定と文字列出力処理の一部になります。

~~~ py
        Out("VGAPAL", *[i * 0x1111 for i in range(16)]),
        console.Print(" !\"#$%&'()*+,-./0123456789:;<=>?", pos=0, color=0xF0),
~~~

文字列出力時のVRAMへのフォント書き込みと、FIFO出力のためのVRAM読み出しは、それぞれ別々のスレッドで実行されますが、意図的に排他処理をしなくても並列処理が可能です。
