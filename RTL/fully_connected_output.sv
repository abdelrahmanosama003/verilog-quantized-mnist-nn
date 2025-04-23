module fully_connected_output(
    input logic clk, 
    input logic rstN,
    input logic signed [15:0] input_vector [0:15],
    input logic signed [15:0] weights [0:159],    
    input logic signed [15:0] biases [0:9],       
    input logic valid_in,                        

    output logic signed [15:0] output_vector [0:9], 
    output logic valid_out                       
);

    parameter NUM_NEURONS = 10;
    parameter INPUT_SIZE  = 16;

    // Internal signals
    logic signed [15:0] neuron_results [0:NUM_NEURONS-1];
    logic neuron_done [0:NUM_NEURONS-1];
    logic [NUM_NEURONS-1:0] neuron_done_vector;
    logic all_done;

    always_comb begin
        for (int k = 0; k < NUM_NEURONS; k++) begin
            neuron_done_vector[k] = neuron_done[k];
        end
    end

    neuron2 #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_0 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[0:15]),
        .bias(biases[0]),
        .result(neuron_results[0]),
        .done(neuron_done[0])
    );

    neuron2 #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_1 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[16:31]),
        .bias(biases[1]),
        .result(neuron_results[1]),
        .done(neuron_done[1])
    );

    neuron2 #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_2 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[32:47]),
        .bias(biases[2]),
        .result(neuron_results[2]),
        .done(neuron_done[2])
    );

    neuron2 #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_3 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[48:63]),
        .bias(biases[3]),
        .result(neuron_results[3]),
        .done(neuron_done[3])
    );

    neuron2 #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_4 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[64:79]),
        .bias(biases[4]),
        .result(neuron_results[4]),
        .done(neuron_done[4])
    );

    neuron2 #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_5 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[80:95]),
        .bias(biases[5]),
        .result(neuron_results[5]),
        .done(neuron_done[5])
    );

    neuron2 #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_6 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[96:111]),
        .bias(biases[6]),
        .result(neuron_results[6]),
        .done(neuron_done[6])
    );

    neuron2 #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_7 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[112:127]),
        .bias(biases[7]),
        .result(neuron_results[7]),
        .done(neuron_done[7])
    );

    neuron2 #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_8 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[128:143]),
        .bias(biases[8]),
        .result(neuron_results[8]),
        .done(neuron_done[8])
    );

    neuron2 #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_9 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[144:159]),
        .bias(biases[9]),
        .result(neuron_results[9]),
        .done(neuron_done[9])
    );

    always_ff @(posedge clk or negedge rstN) begin
      if (!rstN) begin
        all_done <= 1'b0;
      end else if (&neuron_done_vector) begin
        all_done <= 1'b1;
      end else begin
        all_done <= 1'b0;
      end
    end

    // Output assignment when all neurons are done
    always_ff @(posedge clk or negedge rstN) begin
        if (!rstN) begin
            valid_out <= 0;
        end else begin
            if (all_done) begin
                for (int j = 0; j < NUM_NEURONS; j++) begin
                    output_vector[j] <= neuron_results[j];
                end
                valid_out <= 1;
            end else begin
                valid_out <= 0;
            end
        end
    end

endmodule