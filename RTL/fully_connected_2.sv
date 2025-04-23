module fully_connected_2(
    input logic clk, 
    input logic rstN,
    input logic signed [15:0] input_vector [0:15],
    input logic signed [15:0] weights [0:255],   
    input logic signed [15:0] biases [0:15],     
    input logic valid_in,

    output logic signed [15:0] output_vector [0:15],
    output logic valid_out
);

    parameter NUM_NEURONS = 16;
    parameter INPUT_SIZE  = 16;

    // Internal signals
    logic signed [15:0] neuron_results [0:NUM_NEURONS-1];
    logic neuron_done [0:NUM_NEURONS-1];
    logic [15:0] neuron_done_vector;
    logic all_done;

    always_comb begin
        for (int k = 0; k < NUM_NEURONS; k++) begin
            neuron_done_vector[k] = neuron_done[k];
        end
    end

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_0 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[0:15]),
        .bias(biases[0]),
        .result(neuron_results[0]),
        .done(neuron_done[0])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_1 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[16:31]),
        .bias(biases[1]),
        .result(neuron_results[1]),
        .done(neuron_done[1])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_2 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[32:47]),
        .bias(biases[2]),
        .result(neuron_results[2]),
        .done(neuron_done[2])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_3 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[48:63]),
        .bias(biases[3]),
        .result(neuron_results[3]),
        .done(neuron_done[3])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_4 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[64:79]),
        .bias(biases[4]),
        .result(neuron_results[4]),
        .done(neuron_done[4])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_5 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[80:95]),
        .bias(biases[5]),
        .result(neuron_results[5]),
        .done(neuron_done[5])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_6 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[96:111]),
        .bias(biases[6]),
        .result(neuron_results[6]),
        .done(neuron_done[6])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_7 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[112:127]),
        .bias(biases[7]),
        .result(neuron_results[7]),
        .done(neuron_done[7])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_8 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[128:143]),
        .bias(biases[8]),
        .result(neuron_results[8]),
        .done(neuron_done[8])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_9 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[144:159]),
        .bias(biases[9]),
        .result(neuron_results[9]),
        .done(neuron_done[9])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_10 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[160:175]),
        .bias(biases[10]),
        .result(neuron_results[10]),
        .done(neuron_done[10])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_11 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[176:191]),
        .bias(biases[11]),
        .result(neuron_results[11]),
        .done(neuron_done[11])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_12 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[192:207]),
        .bias(biases[12]),
        .result(neuron_results[12]),
        .done(neuron_done[12])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_13 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[208:223]),
        .bias(biases[13]),
        .result(neuron_results[13]),
        .done(neuron_done[13])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_14 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[224:239]),
        .bias(biases[14]),
        .result(neuron_results[14]),
        .done(neuron_done[14])
    );

    neuron #(.INPUT_SIZE(INPUT_SIZE)) neuron_inst_15 (
        .clk(clk),
        .rstN(rstN),
        .start(valid_in),
        .inputs(input_vector),
        .weights(weights[240:255]),
        .bias(biases[15]),
        .result(neuron_results[15]),
        .done(neuron_done[15])
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