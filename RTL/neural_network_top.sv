module neural_network_top(
    input logic clk,
    input logic rstN,
    input logic start,  // Signal to start processing new input
    input logic signed [15:0] input_image [0:783],  // 28x28 input image
    input logic signed [15:0] fc1_weights [0:12543],
    input logic signed [15:0] fc2_weights [0:255],
    input logic signed [15:0] fc3_weights [0:159],
    input logic signed [15:0] fc1_biases [0:15],
    input logic signed [15:0] fc2_biases [0:15],
    input logic signed [15:0] fc3_biases [0:9],

    output logic signed [15:0] output_result [0:9], // 10 classification outputs
    output logic valid_out  // Indicates when output is valid
);
    // Internal signals for layer connections
    logic signed [15:0] layer1_output [0:15];
    logic signed [15:0] layer2_output [0:15];
    logic layer1_valid, layer2_valid;
    
    // Instantiate the three layers
    fully_connected_1 layer1(
        .clk(clk),
        .rstN(rstN),
        .input_vector(input_image),
        .weights(fc1_weights),
        .biases(fc1_biases),
        .output_vector(layer1_output),
        .valid_in(start),         // Start signal triggers first layer
        .valid_out(layer1_valid)  // First layer's output valid signal
    );
    
    fully_connected_2 layer2(
        .clk(clk),
        .rstN(rstN),
        .input_vector(layer1_output),
        .weights(fc2_weights),
        .biases(fc2_biases),
        .output_vector(layer2_output),
        .valid_in(layer1_valid),  // Triggered by first layer's completion
        .valid_out(layer2_valid)  // Second layer's output valid signal
    );
    
    fully_connected_output output_layer(
        .clk(clk),
        .rstN(rstN),
        .input_vector(layer2_output),
        .weights(fc3_weights),
        .biases(fc3_biases),
        .output_vector(output_result),
        .valid_in(layer2_valid),  // Triggered by second layer's completion
        .valid_out(valid_out)  // Final output valid signal
    );
endmodule