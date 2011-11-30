onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/Clk
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/HALT
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/PC
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/INSTR_OUT
add wave -noupdate -divider Icache
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/hit
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/icache_en
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/stop
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/stopDcache
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/stopIcache
add wave -noupdate -divider {CPU DATA}
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/PC
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/dCacheWait
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/Freeze
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/IF_PCSkip
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/ID_PcSrc
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/ramState
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/ramReadInt
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/ramWriteInt
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/ramAddr
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MCont/ramQ
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/CLK
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/hit
add wave -noupdate /tb_cpu/DUT/theCPU/dcacheBLK/Halt
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/state
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/MemWait
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/MemRead
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/MemWrite
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/wEN
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/addr
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/writeport
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/aMemRead
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/aMemWrite
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/aMemAddr
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/aMemRdData
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/aMemWrData
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/aMemWait
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/readport
add wave -noupdate -divider Halt
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/haltHit
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/haltDone
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/count16
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/nextCount16
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/readInt
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/haltAddr
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/destWay
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/mem2CacheData1
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/mem2CacheData2
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/state
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/wENInt
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/rtnState
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/nextRtnState
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/tagA
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/tagB
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/data1A
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/data2A
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/data1B
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/data2B
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/write2Data
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/validA
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/validB
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/dirtyA
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/dirtyB
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/dcacheBLK/dRamCLU/LRU
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/ID_Instr
add wave -noupdate /tb_cpu/DUT/theCPU/ID_FLUSH
add wave -noupdate -radix unsigned /tb_cpu/DUT/theCPU/Rs
add wave -noupdate -radix unsigned /tb_cpu/DUT/theCPU/Rt
add wave -noupdate -radix unsigned /tb_cpu/DUT/theCPU/ID_Rw
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/ID_ASel
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/ID_BSel
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/ID_FwdMuxA
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/ID_FwdMuxB
add wave -noupdate -divider EX
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/EX_Out
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/EX_BusB
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/EX_Rw
add wave -noupdate -divider MEM
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MEM_BusB
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MEM_MemWr
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MEM_Out
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MEM_REGWR
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MEM_Rw
add wave -noupdate /tb_cpu/DUT/theCPU/MEM_MEM2REG
add wave -noupdate -radix hexadecimal /tb_cpu/DUT/theCPU/MEM_Out
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -radix hexadecimal -childformat {{/tb_cpu/DUT/theCPU/icacheBlk/ram(15) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(14) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(13) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(12) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(11) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(10) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(9) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(8) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(7) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(6) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(5) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(4) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(3) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(2) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(1) -radix hexadecimal} {/tb_cpu/DUT/theCPU/icacheBlk/ram(0) -radix hexadecimal}} -subitemconfig {/tb_cpu/DUT/theCPU/icacheBlk/ram(15) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(14) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(13) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(12) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(11) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(10) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(9) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(8) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(7) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(6) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(5) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(4) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(3) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(2) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(1) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/icacheBlk/ram(0) {-height 16 -radix hexadecimal}} /tb_cpu/DUT/theCPU/icacheBlk/ram
add wave -noupdate -radix hexadecimal -childformat {{/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(0) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(1) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(2) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(3) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(4) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(5) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(6) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(7) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(8) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(9) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(10) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(11) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(12) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(13) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(14) -radix hexadecimal} {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(15) -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(0) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(1) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(2) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(3) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(4) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(5) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(6) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(7) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(8) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(9) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(10) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(11) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(12) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(13) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(14) {-height 16 -radix hexadecimal} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram(15) {-height 16 -radix hexadecimal}} /tb_cpu/DUT/theCPU/dcacheBLK/dRam/cram
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{R6 Updated} {19600 ns} 1} {{Cursor 3} {20700 ns} 1} {{Cursor 5} {22821 ns} 1} {{Cursor 5} {23029 ns} 0}
configure wave -namecolwidth 151
configure wave -valuecolwidth 360
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {10041896 ns} {10119086 ns}
