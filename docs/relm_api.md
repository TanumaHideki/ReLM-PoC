# Python API Reference

## ReLMLoader

__with ReLMLoader( *release, dump=True, send=False, loader=False ):__

* __*release__
<BR>Folder path to create the memory image files (code??.txt, data??.txt).
<BR>Specify __\_\_file\_\___ to create it in the same folder as the Python code.
* __dump=Tree__
<BR>False to suppress dump output.
* __send=False__
<BR>True to send program code to the FPGA via JTAG.
* __loader=False__
<BR>True to include the program loader in the memory image.

## Block

* __definition block__
<BR>Define[ body ]
* __thread block__
<BR>Thread[ body ]
* __loader block__
<BR>Loader[ body ]

## Variable

* __signed integer definition__
<BR>var := Int()
<BR>var := Int( expr )
* __unsigned integer definition__
<BR>var := UInt()
<BR>var := UInt( expr )
* __assignment__
<BR>var( expr )

## Conditional

* __if-then__
<BR>If( cond )[ body ]
* __if-then-else__
<BR>If( cond )[ body ].Else[ body ]

## Loop

* __loop__
<BR>Do()[ body ]
* __do-while__
<BR>Do()[ body ].While( cond )
* __while__
<BR>While( cond )[ body ]
* __continue__
<BR>Continue()
* __break__
<BR>Break()

## Function

* __function returns value__
<BR>func := Function(p1 := Int(), p2 := Int(), ...)[ body ].Return( expr )
* __void function__
<BR>func := Function(p1 := Int(), p2 := Int(), ...)[ body ]
* __return value__
<BR>Return( expr )
* __return__
<BR>Return()
* __function call__
<BR>func(p1, p2, ...) -> expr

## Jump Table

* __definition__
<BR>table := Table( size )
* __register case__
<BR>table.Case( index, ... )
* __register default__
<BR>table.Default()
* __return from case__
<BR>table.Return()
* __switch to case__
<BR>table.Switch( expr, acc ) -> expr

## FIFO

* __allocation__
<BR>fifo := FIFO.Alloc( size=0 )
* __empty check__
<BR>fifo.IsEmpty() -> cond
* __pop__
<BR>fifo.Pop() -> expr
* __push__
<BR>fifo.Push( expr, ... )
* __lock (no empty check after this)__
<BR>fifo.Lock()

### Array
* __definition__
<BR>array := Array( *data, op="PUSH" )
* __read__
<BR>array[ expr ] -> expr
* __write__
<BR>array\[ expr ]( expr )

## SRAM

* __allocation__
<BR>sub := sram.Alloc( size )
* __read__
<BR>sram[ expr ] -> expr
* __write__
<BR>sram\[ expr ]( expr, ... )

## Array vs SRAM

Array
* Allocated on code memory
  * Consume code memory
* Thread safe
* Random access reading is slow
* Can be used for burst I/O transfer

SRAM
* I/O accessible memory device 
  * Not consume code memory
* Not thread safe
* Random access reading is fast
* Sequential writing is available
  * Can be used for initialization
  * But consume code memory

## Intrinsic (Register Access)

* __get accumulator__
<BR>Acc
<BR>AccU
* __set accumulator__
<BR>Acc( expr )
<BR>AccU( expr )
* __get register B__
<BR>RegB
<BR>RegBU
* __set register B__
<BR>RegB( expr, acc=0 )
<BR>RegBU( expr, acc=0 )
