cd {D:/Uni/Thesis/Neural Network v2/SIM}

vlib work
transcript file ../transcript.log

vlog -sv "../RTL/*.sv"
vlog -sv neural_network_tb.sv
vsim -voptargs=+acc work.neural_network_tb

run -all

quit