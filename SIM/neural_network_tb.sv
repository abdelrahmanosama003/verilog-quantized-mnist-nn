`timescale 1ns / 1ps

module neural_network_tb();
    // Test bench signals
    logic clk;
    logic rstN;
    logic start;
    logic signed [15:0] input_image [0:783];
    logic signed [15:0] output_result [0:9];
    logic valid_out;
    
    // Memories for weights and biases
    logic signed [15:0] fc1_weights [0:12543];
    logic signed [15:0] fc2_weights [0:255];
    logic signed [15:0] fc3_weights [0:159];
    logic signed [15:0] fc1_biases [0:15];
    logic signed [15:0] fc2_biases [0:15];
    logic signed [15:0] fc3_biases [0:9];
    
    // Instantiate the neural network
    neural_network_top dut(
        .clk(clk),
        .rstN(rstN),
        .start(start),
        .input_image(input_image),
        .fc1_weights(fc1_weights),
        .fc2_weights(fc2_weights),
        .fc3_weights(fc3_weights),
        .fc1_biases(fc1_biases),
        .fc2_biases(fc2_biases),
        .fc3_biases(fc3_biases),
        .output_result(output_result),
        .valid_out(valid_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end
    
    // Test sequence
    initial begin
        // Initialize signals
        rstN = 0;
        start = 0;
        
        // Reset the system
        #20 rstN = 1;
        
        $readmemh("fc1_weights.mem", fc1_weights);
        $readmemh("fc2_weights.mem", fc2_weights);
        $readmemh("fc3_weights.mem", fc3_weights);
        $readmemh("fc1_biases.mem", fc1_biases);
        $readmemh("fc2_biases.mem", fc2_biases);
        $readmemh("fc3_biases.mem", fc3_biases);
        $readmemh("data_in.mem", input_image);

        #10;
        start = 1;
        #10 start = 0;
        
        // Wait for valid output
        wait(valid_out)
            
        for (int i = 0; i < 10; i++) begin
            $display("Neuron %0d: %d", i, output_result[i]);
        end

        // Finish simulation
        #20 $stop;
    end

endmodule