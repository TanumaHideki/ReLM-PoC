# ReLMのカスタマイズ

ReLMアーキテクチャは、ハードウェア構成や利用目的に応じて以下の手段でカスタマイズが可能になっています。

* I/Oポートへの拡張デバイス接続
* カスタム拡張命令セット

これらのソフトウェア（アプリケーション）への影響を比較すると、前者は比較的小規模なデバイスドライバの開発に留まるのに対し、後者は比較的大規模で、例えば浮動小数点への対応では複雑な命令アーキテクチャ体系の拡張が必要となります。

ハードウェア面では、I/Oポート上のデバイスは全プロセッサで共有されるのに対し、カスタム拡張命令セットの回路は全てのプロセッサで個別に付加されますので、それだけ回路規模や動作周波数に対する条件は厳しくなります。

## カスタム拡張命令用モジュール

ReLMアーキテクチャの論理合成の際、何らかのカスタム拡張命令用回路モジュールをリンクする必要があります。

現在用意済みの拡張命令モジュールは以下になります。

* カスタム拡張命令無し（relm_custom_none.v）
* 整数除算拡張（relm_custom_div.v）
* 浮動小数点演算および整数除算拡張（relm_custom_div_fp.v）

以下はカスタム拡張命令無し（relm_custom_none.v）のモジュールで、回路規模を抑えたい場合や自前で拡張命令を開発する際の雛型として使用します。

[relm_custom_none.v](../relm_custom_none.v)

~~~ v
module relm_custom(clk, op_in, a_in, cb_in, x_in, xb_in, opb_in, mul_ax_in, mul_a_out, mul_x_out, a_out, cb_out, retry_out);
	parameter WD = 32;
	parameter WOP = 5;
	parameter WC = 0;
	input clk;
	input [WOP-1:0] op_in;
	input [WD-1:0] a_in;
	input [WC+WD-1:0] cb_in;
	input [WD-1:0] x_in;
	input [WD-1:0] xb_in;
	input opb_in;
	input [WD*2-1:0] mul_ax_in;
	output [WD-1:0] mul_a_out;
	assign mul_a_out = {WD{1'bx}};
	output [WD-1:0] mul_x_out;
	assign mul_x_out = {WD{1'bx}};
	output [WD-1:0] a_out;
	assign a_out = {WD{1'bx}};
	output [WC+WD-1:0] cb_out;
	assign cb_out = {WC+WD{1'bx}};
	output retry_out;
	assign retry_out = 0;
endmodule
~~~

以下がパラメータおよび入出力信号になります。

* parameter WD = 32;  
  ワードビット長。
* parameter WOP = 5;  
  命令コードビット長。
* parameter WC = 0;  
  カスタムレジスタ（C）ビット長。使用しない場合は０を指定。
* input clk;  
  クロック信号。基本的に命令実行は１クロック内で完了する組み合わせ回路となるため、通常は使用しない。
* input [WOP-1:0] op_in;  
  命令コード。
* input [WD-1:0] a_in;  
  アキュムレータ（Acc）入力。
* input [WC+WD-1:0] cb_in;  
  カスタムレジスタ（C）とレジスタ（B）の入力。
* input [WD-1:0] x_in;  
  コードメモリ上のオペランド値。OPB命令の場合は命令コード。
* input [WD-1:0] xb_in;  
  演算用オペランド値。OPB命令の場合はレジスタ（B）の値。
* input opb_in;  
  OPB命令フラグ。
* input [WD*2-1:0] mul_ax_in;  
  基本命令用乗算器出力。
* output [WD-1:0] mul_a_out;  
  基本命令用乗算器入力。
* output [WD-1:0] mul_x_out;  
  基本命令用乗算器入力。
* output [WD-1:0] a_out;  
  アキュムレータ（Acc）出力。
* output [WC+WD-1:0] cb_out;  
  カスタムレジスタ（C）とレジスタ（B）の出力。
* output retry_out;
  リトライ出力。１を出力した場合、PUT命令の衝突時と同様に命令を再実行する。

カスタム拡張命令用モジュールは、基本的に演算前のレジスタ値と命令コードを入力して、演算結果のレジスタ値を出力するという構成になっています。

演算処理が複雑になれば演算結果出力に遅延が発生し、動作可能なクロック周波数が低下します。

そのため、整数除算や浮動小数点演算のような複雑な演算処理の場合、１クロック内で実行可能な処理に分割して実行する必要があります。

後述の整数除算や浮動小数点演算に関しては、比較的低性能の旧ターゲットボードDE0-CVで８コア50MHzでの動作が可能となるような命令の粒度で構成されています。

## 整数除算命令拡張

以下は整数除算命令拡張用のモジュール（relm_custom_div.v）になります。

[relm_custom_div.v](../relm_custom_div.v)

このモジュールではcustom5の系列に(OPB) DIVおよび、OPB専用の拡張命令としてDIVINIT, DIVLOOP, DIVMODを付加しています。

| OpCode | +0 | +1 | +2 | +3 | +4 | +5 | +6 | +7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0x00 | LOAD | SWAP/SHIFT | BLOAD | BSLOAD | ADD | AND | XOR | OR |
| 0x08 | PUSH/OUT | POP/IO | PUT | PUTS | RSUB | JEQ | JNE | JUMP |
| 0x10 | UGT | ULT | IGT | ILT | SUB | MUL | SHR | SAR |
| 0x18 | custom0 | custom1 | custom2 | custom3 | custom4 | **DIV** | custom6 | OPB/HALT |
| 0x20 | | | BLOADX | BSLOADX | | | | |
| 0x38 | | | | | | **DIVINIT** | | |
| 0x58 | | | | | | **DIVLOOP** | | |

整数除算アルゴリズムは内部的に２ワード分のカスタムレジスタを使用しますので、これらをC, Dレジスタとして除算アルゴリズム実行時のデータの流れを以下に示します。

| OpCode | D | C | B | A | X (operand) or #Remarks |
| --- | --- | --- | --- | --- | --- |
| DIV | | | | **N (numerator)** | **D (denominator)** |
| OPB SHR | D | N | d (MSB of D) | n (MSB of N) | SHR (opcode) |
| OPB DIVINIT | D | N | d | q := n / d | DIVINIT (opcode) |
| OPB MUL | q | N | q | D | MUL (opcode) |
| BLOAD | q | N | q | Dq := D * q | 0 |
| OPB BLOAD | q | N | Dq | 0 | BLOAD (opcode) |
| OPB DIVLOOP | q | N' | Q' := 0 | Dq | DIVLOOP (opcode) |
| OPB DIVLOOP | q >>= 3 | N'' | Q'' | Dq >>= 3 | DIVLOOP (opcode) |
| OPB DIVLOOP | q >>= 3 | N''' | Q''' | Dq >>= 3 | DIVLOOP (opcode) |
| OPB DIVLOOP | | | . . . | | DIVLOOP (opcode) |
| JNE | | | Q (quotient) | finished when Acc == 0 | # Repeat DIVLOOP |
| | | | | | # Get the quotient result |
| OPB LOAD | | | Q (quotient) | | LOAD (opcode) |
| | | | | **Q (quotient)** | |
| | | | | | # Get the remainder result |
| LOAD | | | Q (quotient) | | D (denominator) |
| OPB MUL | | | Q | D | MUL (opcode) |
| RSUB | | | | Q * D | N (numerator) |
| | | | | **R := N - Q * D (remainder)** | |

最初のDIV命令からDIVLOOP命令までの処理は除数と被除数をパラメータとして受け取った後、後段のDIVLOOPによる処理のために内部状態の初期化を行います。

DIVLOOPでは古典的な除算アルゴリズムと同様に上位ビットから商を決定していきますが、relm_compareモジュールで引き算よりも先に大小比較結果を先読みする方法で商の３ビット分を一度に処理する構成になっています。

DIVLOOPを11回またはアキュムレータ（Acc）が０になるまで繰り返し実行すると、レジスタ（B）に商が格納されます。

一度に３ビットずつ計算する構成上、中間結果から剰余を求めようとすると回路が複雑化してしまいますので、まず商だけを求めて剰余は改めて計算する構成になっています。

## 整数除算命令拡張の利用

基本命令のコンパイラ（relm.py）で切り捨て除算（//）および剰余（%）を式中で使用した場合、ハードウェア実装の有無に関わらず拡張命令（DIV, DIVINIT, DIVLOOP, DIVMOD）を使用したコードを出力します。

ただし、現状の整数除算は除数、被除数ともに符号なし32ビット整数として扱う処理となっていますので、負数をそのまま入力すると異常な結果となります。

もし負数を扱いたい場合は、まず正数に直してから除算を行い、後で符号を反映する処理を追加してください。

Playable PoCのバブルエステートは資産状況を表す棒グラフ表示のスケーリングに除算を使用していますので、そのまま除算命令のテストコードにもなっています。

![relm_bubble_3.jpg](relm_bubble_3.jpg)

この他に、[relm_test_int_div.py](../de0cv/loader/relm_test_int_div.py) も除算および剰余のテストコードになっています。

$10^{47}-1$ が素因数 $35121409$ を持つことから、 $100^{47}\equiv 1\mod 35121409$ であることを剰余演算で確かめています。

![relm_test_int_div.jpg](relm_test_int_div.jpg)

## 浮動小数点演算命令拡張

浮動小数点演算は、[IEEE 754](https://ja.wikipedia.org/wiki/IEEE_754)の[単精度浮動小数点形式（binary32）](https://ja.wikipedia.org/wiki/%E5%8D%98%E7%B2%BE%E5%BA%A6%E6%B5%AE%E5%8B%95%E5%B0%8F%E6%95%B0%E7%82%B9%E6%95%B0)がちょうど１ワード長となるため、通常の整数と同様にレジスタ内に格納し、レジスタ操作を兼用します。

これにより、符号等に関する単純なビット操作を直接行うことが可能になりますが、レジスタの値が整数と浮動小数点のどちらかを区別できないため、ソフトウェア側で適切な管理が必要となります。

浮動小数点演算に関しては、以下の表に示す通り、比較的多くの命令を拡張しています。

| OpCode | +0 | +1 | +2 | +3 | +4 | +5 | +6 | +7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0x00 | LOAD | SWAP/SHIFT | BLOAD | BSLOAD | ADD | AND | XOR | OR |
| 0x08 | PUSH/OUT | POP/IO | PUT | PUTS/**PUTM** | RSUB | JEQ | JNE | JUMP |
| 0x10 | UGT | ULT | IGT | ILT | SUB | MUL | SHR | SAR |
| 0x18 | **FADD** | **FMUL** | **ROUND/TRUNC** | **FCOMP** | **ITOF** | DIV | **FDIV** | OPB/HALT |
| 0x20 | | | BLOADX | BSLOADX | | | | |
| 0x38 | **FRSUB** | **FMULM** | **FTOI** | **ISIGN** | **ITOFB** | DIVINIT | **FDIVINIT** | |
| 0x58 | **FSUB** | | | | **ITOFG** | DIVLOOP | **FDIVLOOP** | |
| 0x78 | **FADDM** | | | | **ITOFGB** | | | |
| 0x98 | | | | | **ITOFS** | | | |
| 0xA8 | | | | | **ITOFSB** | | | |
| 0xC8 | | | | | **ITOFSG** | | | |
| 0xE8 | | | | | **ITOFSGB** | | | |

命令の構成を以下に示しますが、処理の効率上、[非正規化数](https://ja.wikipedia.org/wiki/%E9%9D%9E%E6%AD%A3%E8%A6%8F%E5%8C%96%E6%95%B0)は０として扱います。

* FADD, FRSUB, FSUB, FADDM  
  後処理も含めて **FADD, ITOF** の２命令で浮動小数点の加算を実行します。  
  FADD命令から後処理のITOF命令へのデータ受け渡しにレジスタ（B）を使用します。  
  FRSUB, FSUB, FADDMは左辺や右辺の符号を変えた加算ですが、OPB形式でのみ使用可能です。
* PUTM  
  非OPB形式の加算命令はFADDしか使えないため、引き算の場合は右辺か左辺のどちらかを符号反転した上で加算を実行することになります。  
  浮動小数点の符号反転は **XOR 0x80000000** の１命令で可能ですが、なるべく命令数を減らすため、PUTと同時に符号反転を実施する命令 **PUTM** が用意されています。  
  回路規模への影響が小さいため、基本命令セットの回路には既にPUTMの機能が組み込まれています。
* FMUL, FMULM  
  FADDと同様にITOFを後処理として利用して、**FMUL, ITOF** の２命令で浮動小数点の乗算を実行します。  
  後処理のITOF命令へのデータ受け渡しにレジスタ（B）を使用します。  
  FMULMは乗算結果の符号を反転させるもので、OPB形式でのみ使用可能です。
* ROUND/TRUNC  
  加算と合わせて様々なモードの整数への丸め（round, floor, ceil, trunc）を実現します。  
  例えば **ROUND 1.0, OPB TRUNC, OPB FADD, OPB ITOF** の４命令で小数点以下切り上げ（ceil）となります。  
  同様に小数点以下切り捨て（floor）は **ROUND 1.0, OPB TRUNC, OPB FADD, OPB ITOF**、最近整数への丸め（round）は **ROUND 0.5, OPB FADD, OPB ITOF, OPB TRUNC** となります。  
  単に **OPB TRUNC** とすると、０方向への丸め（trunc）となります。  
  [relm_test_fp_round.py](../de0cv/loader/relm_test_fp_round.py) は丸め機能のテストコードで、以下の様な画面を表示します。

![relm_test_fp_round.jpg](relm_test_fp_round.jpg)

* FCOMP  
  浮動小数点の大小を比較します。  
  Acc > XB の場合 **1**、Acc == XB の場合 **0**、Acc < XB の場合 **-1** をアキュムレータ（Acc）に格納します。  
  非数（NaN）は正の無限大 $(+\infty)$ より大きいか負の無限大 $(-\infty)$ より小さくなります。  
  正負のゼロ $(\pm 0)$ および非正規化数は互いに等しいと見なされます。
* ITOF, ITOFB, ITOFG, ITOFS, ISIGN  
  整数を浮動小数点に変換します。  
  アキュムレータ（Acc）で仮数部、オペランド（XB）で符号および指数部を指定して、浮動小数点数に合成します。  
  加算命令FADDや乗算命令FMULはITOF命令の入力に合わせた指数部をレジスタ（B）に出力して、丸めやオーバーフロー判定といった後処理に引き継ぎます。  
  整数値の変換の場合、適切な指数部を入力する必要があるため、非OPB形式で即値パラメータを指定することになります。  
  ISIGNは符号付き整数を浮動小数点に変換する場合の前処理で、入力値の符号に応じて整数値変換用の指数部をレジスタ（B）に設定します。  
  ITOF命令のもう一つの機能として、カスタムレジスタ（C, D）利用のための転送があります。  
  FADD命令やFMUL命令実行後レジスタ（B）の一時データは不要となるので、ITOF命令は毎回カスタムレジスタ（C）の値でレジスタ（B）を上書きします。  
  ITOFB命令を実行すると合成後の出力値をカスタムレジスタ（C）に上書きしますので、後でOPB形式のオペランドとして利用できるようになります。  
  ITOFS命令は出力値をカスタムレジスタ（D）に上書きして、ITOFG命令はカスタムレジスタ（D）の値をレジスタ（B）に転送します。  
  これらの操作によりPUT命令の削減が可能になりますが、浮動小数点除算はこれを利用して効率化を図っています。
* FTOI  
  浮動小数点を整数に変換します。  
  後処理で仮数部の右シフトが必要になりますので、**OPB FTOI, OPB SAR** の２命令を組み合わせます。  
  入力範囲は $(1-2^{24})\sim (2^{24}-1)$ にのみ対応しています。  
  浮動小数点のテストコードで十進表示の際にもFTOI命令が使用されます。
* FDIV, FDIVINIT, FDIVLOOP  
  浮動小数点除算は整数除算と同様、複雑な処理の組合せとなります。  
  浮動小数点除算では前処理として、除数の指数部と仮数部を分離します。  
  被除数を除数の指数部のみで除算した結果と除数の仮数部をレジスタに置いて、後段の逆数計算に引き渡します。  
  後段では仮数部の逆数を計算して、指数部のみによる除算結果と掛け合わせて全体の除算結果とします。  
  仮数部の逆数計算では、整数除算用の **DIVLOOP** 命令を利用しています。

演算回路の実装コードは以下になりますが、除算関連、桁合わせが必要なFADD命令、正規化やオーバーフロー等の判定を行うITOF命令以外に関しては、比較的単純な構造になります。

[relm_custom_div_fp.v](../relm_custom_div_fp.v)

## 浮動小数点除算

FDIV命令は、オペランド（XB）の被除数をアキュムレータ（Acc）の除数で除算を実行するための前処理を行います。

除数を指数部と仮数部に分解して、仮数部をカスタムレジスタ（C）に置き、指数部のみによる除算結果はアキュムレータ（Acc）に一旦置かれて次のPUT命令で最後の乗算命令のオペランドに転送されます。

仮数部は $1.0\sim 2.0$ に正規化され、この逆数を計算して先程の指数部の除算結果と掛けると最終的な除算結果が求められます。

この仮数部の逆数計算は[Newton-Raphson除算](https://ja.wikipedia.org/wiki/%E9%99%A4%E7%AE%97_(%E3%83%87%E3%82%B8%E3%82%BF%E3%83%AB)#%E3%83%8B%E3%83%A5%E3%83%BC%E3%83%88%E3%83%B3-%E3%83%A9%E3%83%97%E3%82%BD%E3%83%B3%E9%99%A4%E7%AE%97)による手法で、３次の[チェビシェフ多項式](https://ja.wikipedia.org/wiki/%E3%83%81%E3%82%A7%E3%83%93%E3%82%B7%E3%82%A7%E3%83%95%E5%A4%9A%E9%A0%85%E5%BC%8F)で近似値を求めてから反復式を使って精度を上げていきます。

[リンク先](https://en.wikipedia.org/wiki/Division_algorithm#Variant_Newton%E2%80%93Raphson_division)と同様に３次収束の反復式を用いた場合、必要な反復回数の見積もりが $\log_3\left(\frac{24+1}{\log_2 99}\right)=1.208222482$ となることから反復回数が２回必要となりますが、２次収束の反復式でも $\log_2\left(\frac{24+1}{\log_2 99}\right)=1.914987326$ で同じく２回で十分なことがわかりますので、ここではより単純な２次収束の式を使うことにします。

この方法をもとに仮数部 $1\le D<2$ の逆数 $D^{-1}$ を求める式を書き下すと、以下のようになります。

$$
\begin{align*}
x_1 & =\frac{32}{99}\left(\left(D-\frac{9}{4}\right)^2+\frac{3}{2}\right) \\
x_2 & =(2-x_1D)x_1 \\
D^{-1} & \approx(1-x_2D)x_2+x_2 \\
\end{align*}
$$

実際の計算精度をテストプログラム [relm_test_fp_div.py](../de0cv/loader/relm_test_fp_div.py) で確認した結果が、以下の画面出力になります。

![relm_test_fp_div.jpg](relm_test_fp_div.jpg)

$x$ は12次[チェビシェフ多項式の極値点](https://ja.wikipedia.org/wiki/%E3%83%81%E3%82%A7%E3%83%93%E3%82%B7%E3%82%A7%E3%83%95%E5%A4%9A%E9%A0%85%E5%BC%8F#%E9%9B%B6%E7%82%B9%E3%81%A8%E6%A5%B5%E5%80%A4)を $1.0\sim 2.0$ にスケーリングして $-1\sim +2$ の整数値で振ったもので、理論的に誤差が最大となる３次チェビシェフ多項式の極値点を含みます。

$y$ は $x$ の逆数の計算結果、 $xy$ は逆数の検算で理想的にはちょうど $1.0$ となります。

誤差を評価するため $xy-1$ を $ulp=2^{-23}=0.000000119209$ 単位で表示したものが右端になりますが、一部の点で $-0.5ulp\sim +1.0ulp$ の誤差がある以外はほぼ $0$ となっています。（負方向の誤差は指数が変わるので $0.5ulp$ 単位）

２回目の反復計算の式を $D^{-1}\approx(2-x_2D)x_2$ としても数学的には等価で計算量が減らせますが、以下の様に数値計算誤差は明らかに増加します。（１回目はあまり影響しない）

![relm_test_fp_div_err.jpg](relm_test_fp_div_err.jpg)

浮動小数点除算で実際に仮数部の逆数計算を実行するコードは [relm_float.py](../relm_float.py) の以下の部分になります。（インデントは[Black Formatter](https://black.readthedocs.io/en/stable/)による整形結果）

~~~py
    @staticmethod
    def fdiv(minus: bool = False) -> FloatExprB:
        D = RegDF
        return AccF[
            y := Float(AccFM if minus else AccF),
            (
                (
                    1.0
                    - RegBF(
                        (
                            2.0
                            - RegBF(
                                ((AccF(-2.25) + RegBF) ** 2 + 1.5) * (32.0 / 99.0),
                                x1 := [],
                            )
                            * D
                        )
                        * x1,
                        x2 := [],
                    )
                    * D
                )
                * x2
                + x2
            )
            * y,
        ]
~~~

このコンパイル結果のダンプ出力は以下の様になり、FDIV命令も含めると27命令（50MHzクロックで540ns）で浮動小数点除算が完結します。

これはちょうど、古典的な[トランスピュータ](https://ja.wikipedia.org/wiki/%E3%83%88%E3%83%A9%E3%83%B3%E3%82%B9%E3%83%94%E3%83%A5%E3%83%BC%E3%82%BF) [IMS T800-30 の単精度除算（567ns）](https://www.transputer.net/tn/06/tn06.html#x1-150005)とほぼ同程度の性能となります。

ただし、単精度の加減乗算に関してはReLMが２命令分で 40ns に対し、IMS T800-30 は 233ns, 367ns とかなり大きな差があります。

~~~
9BA3:   FDIV    +1.000000E+00           55:     y := Float(1.0 / x),
9BA4:   PUT     9BBC:                   55:     ->      y := Float(1.0 / x),
9BA5:   LOAD    C0100000                55:     y := Float(1.0 / x),
9BA6:   OPB     FADD                    55:     y := Float(1.0 / x),
9BA7:   OPB     ITOF                    55:     y := Float(1.0 / x),
9BA8:   OPB     FSQU                    55:     y := Float(1.0 / x),
9BA9:   OPB     ITOF                    55:     y := Float(1.0 / x),
9BAA:   FADD    +1.500000E+00           55:     y := Float(1.0 / x),
9BAB:   OPB     ITOF                    55:     y := Float(1.0 / x),
9BAC:   FMUL    +3.232323E-01           55:     y := Float(1.0 / x),
9BAD:   OPB     ITOFGB                  55:     y := Float(1.0 / x),
9BAE:   OPB     FMUL                    55:     y := Float(1.0 / x),
9BAF:   OPB     ITOF                    55:     y := Float(1.0 / x),
9BB0:   FADD    -2.000000E+00           55:     y := Float(1.0 / x),
9BB1:   OPB     ITOF                    55:     y := Float(1.0 / x),
9BB2:   OPB     FMULM                   55:     y := Float(1.0 / x),
9BB3:   OPB     ITOFGB                  55:     y := Float(1.0 / x),
9BB4:   OPB     FMUL                    55:     y := Float(1.0 / x),
9BB5:   OPB     ITOF                    55:     y := Float(1.0 / x),
9BB6:   FADD    -1.000000E+00           55:     y := Float(1.0 / x),
9BB7:   OPB     ITOF                    55:     y := Float(1.0 / x),
9BB8:   OPB     FMULM                   55:     y := Float(1.0 / x),
9BB9:   OPB     ITOF                    55:     y := Float(1.0 / x),
9BBA:   OPB     FADD                    55:     y := Float(1.0 / x),
9BBB:   OPB     ITOF                    55:     y := Float(1.0 / x),
9BBC:   FMUL    +0.000000E+00           55:     y := Float(1.0 / x),
9BBD:   OPB     ITOF                    55:     y := Float(1.0 / x),
~~~

## マンデルブロ集合デモ

浮動小数点演算のテストコードを兼ねて、[マンデルブロ集合](https://ja.wikipedia.org/wiki/%E3%83%9E%E3%83%B3%E3%83%87%E3%83%AB%E3%83%96%E3%83%AD%E9%9B%86%E5%90%88)の描画を行うデモプログラム [relm_mandelbrot.py](../de0cv/loader/relm_mandelbrot.py) の画面出力です。

![relm_mandelbrot_1.jpg](relm_mandelbrot_1.jpg)

このプログラムでは７スレッドで並列計算を行い、スケールを変化させながら描画を繰り返し、疑似的な拡大アニメーションを表示します。

反復計算で座標が閾値半径の外に発散するまでの回数で彩色が決定されますが、集合内部の点では最大の反復回数まで計算を繰り返すため描画に時間が掛かってしまいます。

集合内部の点の大部分では反復計算時に座標が周期的な軌道に入りますので、60以下の周期についてはこれを検出して反復計算を打ち切るようにしています。

[周期１および２の点（メインカージオイド）](https://en.wikipedia.org/wiki/Plotting_algorithms_for_the_Mandelbrot_set#Cardioid_/_bulb_checking)
については簡単に判定できますので、反復計算の前に検出します。

集合内部の点で最大回数まで反復を行った点は緑色となり、周期が検出された点は黄色、周期１および２の点は暗めの黄色となります。

![relm_mandelbrot_2.jpg](relm_mandelbrot_2.jpg)

集合外部の点は発散までの反復回数を一旦[グレイコード](https://ja.wikipedia.org/wiki/%E3%82%B0%E3%83%AC%E3%82%A4%E3%82%B3%E3%83%BC%E3%83%89)に変換し、[ビットカウント](https://en.wikipedia.org/wiki/Hamming_weight)に応じて彩色を行います。

反復回数が１変化するとそのグレイコードはいずれかの１ビットのみが変化するので、ビットカウント数に圧縮した場合でも１だけずつ変化することになります。

![relm_mandelbrot_3.jpg](relm_mandelbrot_3.jpg)
