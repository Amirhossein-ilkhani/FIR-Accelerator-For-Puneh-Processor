onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_fir/clk
add wave -noupdate /test_fir/r
add wave -noupdate -radix hexadecimal /test_fir/test/addressBUS
add wave -noupdate -radix hexadecimal /test_fir/test/dataBUS
add wave -noupdate /test_fir/test/cpu_req
add wave -noupdate /test_fir/test/cpu_grant
add wave -noupdate /test_fir/test/dma_req
add wave -noupdate /test_fir/test/dma_grant
add wave -noupdate /test_fir/test/orreadmem
add wave -noupdate /test_fir/test/orwritemem
add wave -noupdate /test_fir/test/infully
add wave -noupdate /test_fir/test/outfully
add wave -noupdate /test_fir/test/outcomplete
add wave -noupdate -radix hexadecimal /test_fir/test/DMA_inst/DP/num_reg
add wave -noupdate -radix hexadecimal /test_fir/test/DMA_inst/DP/flag_reg
add wave -noupdate -radix hexadecimal /test_fir/test/DMA_inst/DP/add_reg
add wave -noupdate /test_fir/test/fir_inst/start
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {598169 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {802549 ps} {873551 ps}
