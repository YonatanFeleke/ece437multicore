onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_cpu/nReset
add wave -noupdate -radix hexadecimal /tb_cpu/cpuClk
add wave -noupdate -radix hexadecimal /tb_cpu/halt
add wave -noupdate -divider {Input to CPU}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {CPU Out}
add wave -noupdate -radix hexadecimal /tb_cpu/halt
add wave -noupdate -radix hexadecimal /tb_cpu/initClkCtl
add wave -noupdate -radix hexadecimal /tb_cpu/address
add wave -noupdate -divider {Input to CPU}
add wave -noupdate -radix hexadecimal /tb_cpu/memQ
add wave -noupdate -divider {CPU Out}
add wave -noupdate -radix hexadecimal /tb_cpu/viewMemWen
add wave -noupdate -radix hexadecimal /tb_cpu/viewMemAddr
add wave -noupdate -radix hexadecimal /tb_cpu/address
add wave -noupdate -divider HaltHit
add wave -noupdate -divider {DirtyA and Dirty B}
add wave -noupdate -divider DestWay
add wave -noupdate -divider rtnState
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|rtnState.idle\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|rtnState.dirtyRW\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|rtnState.haltDump\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|rtnState.update\/regout}
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate {/tb_cpu/DUT/\theCPU|MCont|stopDcache\/combout}
add wave -noupdate -divider haltAddr
add wave -noupdate -divider WriteAddr1
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider Count16
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|count16[3]\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|count16[2]\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|count16[1]\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|count16[0]\/regout}
add wave -noupdate -divider {State info}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.idle\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.chkHit\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.hitUpdate\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.cleanRW\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.dirtyRW\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.read1\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.read2\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.update\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.write1\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.waitSingle1\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.write2\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.waitSingle2\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.haltDump\/regout}
add wave -noupdate {/tb_cpu/DUT/\theCPU|dcacheBLK|dRamCLU|state.halted\/regout}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19794 ns} 1} {{Fisrt Halt Hit} {19498 ns} 1} {{Cursor 3} {41244 ns} 0}
configure wave -namecolwidth 501
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {34076 ns} {51806 ns}
