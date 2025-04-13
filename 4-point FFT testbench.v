// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module tb_fft4_streaming;

    reg clk;
    reg rst;
    reg valid_in;
    reg signed [7:0] real_in;
    reg signed [7:0] imag_in;
    wire valid_out;
    wire signed [15:0] real_out;
    wire signed [15:0] imag_out;

    fft4_streaming uut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .real_in(real_in),
        .imag_in(imag_in),
        .valid_out(valid_out),
        .real_out(real_out),
        .imag_out(imag_out)
    );

    // Clock
    always #5 clk = ~clk;

    // Input samples
    reg signed [7:0] real_samples[0:3];
    reg signed [7:0] imag_samples[0:3];

    integer i;

    initial begin
        // VCD setup for EDA Playground
        $dumpfile("fft4_streaming.vcd");
        $dumpvars(1, uut); // Limit scope to DUT only

        // Init
        clk = 0;
        rst = 1;
        valid_in = 0;
        real_in = 0;
        imag_in = 0;

        // Sample input
        real_samples[0] = 8'd10; imag_samples[0] = 8'd0;
        real_samples[1] = 8'd20; imag_samples[1] = 8'd0;
        real_samples[2] = 8'd30; imag_samples[2] = 8'd0;
        real_samples[3] = 8'd40; imag_samples[3] = 8'd0;

        #20;
        rst = 0;

        // Feed inputs
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge clk);
            valid_in <= 1;
            real_in <= real_samples[i];
            imag_in <= imag_samples[i];
        end

        @(posedge clk);
        valid_in <= 0;

        // Wait for output
        wait (valid_out);
        for (i = 0; i < 4; i = i + 1) begin
            @(posedge clk);
            if (valid_out)
                $display("FFT[%0d] = %d + j%d", i, real_out, imag_out);
        end

        #20;
        $finish;
    end

endmodule
