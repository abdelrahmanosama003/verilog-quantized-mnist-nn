module neuron2 #(
    parameter INPUT_SIZE = 16
)(
    input  logic clk,
    input  logic rstN,
    input  logic start,
    input  logic signed [15:0] inputs   [INPUT_SIZE-1:0],
    input  logic signed [15:0] weights  [INPUT_SIZE-1:0],
    input  logic signed [15:0] bias,
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
                // Start MAC operation
                index        <= 0;
                accumulator  <= 0;
                done         <= 0;
                busy         <= 1;
            end else if (busy) begin
                if (index < INPUT_SIZE) begin
                    accumulator <= accumulator + (inputs[index] * weights[index]);
                    index <= index + logic'('b1);
                end else begin
                    // Done with accumulation
                    busy <= 0;
                    done <= 1;
                    temp_result <= (accumulator >>> 8) + bias;
                end
            end else if (done) begin
                // No ReLU: just saturate to 16-bit signed output
                if (temp_result > 32'sd32767)
                    result <= 16'sd32767;
                else if (temp_result < -32'sd32768)
                    result <= $signed(16'h8000);
                else
                    result <= temp_result[15:0]; // Keep sign
                done <= 0;
            end
        end
    end

endmodule
