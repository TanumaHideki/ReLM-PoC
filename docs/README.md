# ReLM: Proof of Concept
ReLM = Register-Less Multiprocessor

ReLM is the soft-core multiprocessor technology based on the unique memory architecture, enabling users to build a high-performance microcontroller on a relatively small FPGA board.

The most annoying task in developing on a FPGA board is logic synthesis, however, is not required for changing applications (software) with ReLM architecture.  
This advantage of ReLM supports users in easily designing circuits on a FPGA board. 

## For Further Reading...

* [ReLM Introduction (English)](relm_e.md) [(Japanese)](relm_j.md)
* ReLM Instruction Set (English) [(Japanese)](relm_isa_j.md)
* ReLM Development Environment (English) [(Japanese)](relm_sdk_j.md)
* ReLM Application Development (English) [(Japanese)](relm_app_j.md)
* ReLM Customizing (English) (Japanese)
* [Python API Reference (English)](relm_api.md)

Very Old Article...
* [relm.info - Register-less Multiprocessor Information (English)](http://relm.info/en/) [(Japanese)](http://relm.info/)

## Software Requirements

* Windows (OS for running the following software)
* Python (Newest version recommended, at least, 3.8 or later)
* Quartus Prime (Newest version recommended)
* Visual Studio Code (Recommended)

## Hardware Requirements

* Host PC (PC running the above software)
* FPGA: [Terasic DE0-CV Board](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=183&No=921)
  * This board has been discontinued, so we are currently preparing the next target board.
  * Next target candidate: [Terasic Cyclone V GX Starter Kit](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=830)
* VGA display
* PS/2 keyboard (option)

## Getting Started - Playable PoC "Bubble Estate"

1. __de0cv / relm_de0cv.py__
   * Execute "relm_de0cv.py".
   * Create code??.txt, data??.txt in "de0cv / loader" folder.
2. __de0cv / loader / relm_de0cv.qpf__
   * Open "relm_de0cv.qpf" to start up Quartus Prime for logic synthesis.
   * Create "de0cv / loader / output_files / relm_de0cv.svf".
3. __de0cv / loader / relm_test_led.py__ (Omittable)
   * Execute "relm_test_led.py".
   * Confirm the LED display of "HELLO_" on the FPGA board.
   * This process is omittable.
4. __de0cv / bubble / relm_bubble.py__
   * Execute "relm_bubble.py".
   * Confirm the LED display of "Play"  on the FPGA board.
   * Connect a VGA display to the board, then you can play the game. 
   * Attaching a PS/2 keyboard would make it much easier to play the game.

The game begins with two-page explanation, and advances to play by pressing Enter key.

A PS/2 keyboard would give better operability, but can be substituted by the buttons on the FPGA board.

The FPGA board has switches to change Human / CPU. ("SW0" corresponds to "You")

![Image of performing the game](bubble_fpga.jpg)
