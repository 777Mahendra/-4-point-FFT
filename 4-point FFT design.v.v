// Code your design here
module fft4_streaming (
    input clk,
    input rst,
    input valid_in,
    input signed [7:0] real_in,
    input signed [7:0] imag_in,
    output reg valid_out,
    output reg signed [15:0] real_out,
    output reg signed [15:0] imag_out
);

    reg signed [7:0] real_buffer[0:3];
    reg signed [7:0] imag_buffer[0:3];
    reg [1:0] sample_count;
    reg [1:0] output_index;
    reg [2:0] state;

    reg signed [15:0] real_tmp[0:3];
    reg signed [15:0] imag_tmp[0:3];

    reg signed [15:0] a0r, a0i, a1r, a1i, a2r, a2i, a3r, a3i;
    reg signed [15:0] b0r, b0i, b1r, b1i, b2r, b2i, b3r, b3i;

    localparam IDLE = 3'd0,
               COLLECT = 3'd1,
               COMPUTE = 3'd2,
               OUTPUT = 3'd3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sample_count <= 0;
            output_index <= 0;
            state <= IDLE;
            valid_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (valid_in) begin
                        real_buffer[0] <= real_in;
                        imag_buffer[0] <= imag_in;
                        sample_count <= 1;
                        state <= COLLECT;
                    end
                    valid_out <= 0;
                end

                COLLECT: begin
                    if (valid_in) begin
                        real_buffer[sample_count] <= real_in;
                        imag_buffer[sample_count] <= imag_in;
                        sample_count <= sample_count + 1;
                        if (sample_count == 2'd3)
                            state <= COMPUTE;
                    end
                    valid_out <= 0;
                end

                COMPUTE: begin
                    a0r = real_buffer[0]; a0i = imag_buffer[0];
                    a1r = real_buffer[1]; a1i = imag_buffer[1];
                    a2r = real_buffer[2]; a2i = imag_buffer[2];
                    a3r = real_buffer[3]; a3i = imag_buffer[3];

                    b0r = a0r + a2r; b0i = a0i + a2i;
                    b1r = a1r + a3r; b1i = a1i + a3i;
                    b2r = a0r - a2r; b2i = a0i - a2i;
                    b3r = a1i - a3i; b3i = a3r - a1r;

                    real_tmp[0] <= b0r + b1r;
                    imag_tmp[0] <= b0i + b1i;

                    real_tmp[1] <= b2r + b3r;
                    imag_tmp[1] <= b2i + b3i;

                    real_tmp[2] <= b0r - b1r;
                    imag_tmp[2] <= b0i - b1i;

                    real_tmp[3] <= b2r - b3r;
                    imag_tmp[3] <= b2i - b3i;

                    output_index <= 0;
                    state <= OUTPUT;
                    valid_out <= 0;
                end

                OUTPUT: begin
                    valid_out <= 1;
                    real_out <= real_tmp[output_index];
                    imag_out <= imag_tmp[output_index];
                    output_index <= output_index + 1;
                    if (output_index == 2'd3)
                        state <= IDLE;
                end
            endcase
        end
    end
endmodule
