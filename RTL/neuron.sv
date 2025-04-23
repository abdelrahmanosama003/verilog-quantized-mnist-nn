module neuron #(
    parameter INPUT_SIZE = 784
)(
    input logic clk,
    input logic rstN,
    input logic start,
    input logic signed [15:0] inputs   [INPUT_SIZE-1:0],
    input logic signed [15:0] weights  [INPUT_SIZE-1:0],
    input logic signed [15:0] bias,
    output logic signed [15:0] result,
    output logic done
);

    // Internal signals
    logic [$clog2(INPUT_SIZE):0] index;
    logic signed [31:0] accumulator;
    logic busy;
    logic signed [31:0] temp_result;

    always_ff @(posedge clk or negedge rstN) begin
        if (!rstN) begin
            index        <= 0;
            accumulator  <= 0;
            result       <= 0;
            done         <= 0;
            busy         <= 0;
            temp_result  <= 0;
        end else begin
            if (start && !busy) begin
                // Start the MAC operation
                index        <= 0;
                accumulator  <= 0;
                done         <= 0;
                busy         <= 1;
            end else if (busy) begin
                if (index < INPUT_SIZE) begin
                    accumulator <= accumulator + (inputs[index] * weights[index]);
                    index <= index + 'd1;
                end else begin
                    // Done with accumulation
                    busy <= 0;
                    done <= 1;
                    temp_result <= (accumulator >>> 8) + bias;
                end
            end else if (done) begin
                // Apply ReLU and saturate to 16-bit signed
                if (temp_result > 0) begin
                    if (temp_result > 32'sd32767)
                        result <= 16'sd32767;
                    else if (temp_result < -32'sd32768)
                        result <= -16'sd32768;  // Shouldn’t happen due to ReLU, but safe
                    else
                        result <= temp_result[15:0]; // Safe since it’s within range
                end else begin
                    result <= 16'sd0;
                end
                done <= 0; // One-cycle done pulse
            end
        end
    end

endmodule
