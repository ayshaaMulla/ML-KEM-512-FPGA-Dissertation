`timescale 1ns / 1ps

module mult512_check_tb();

reg clk;
reg [11:0] a;
reg [11:0] b;
wire [23:0] prod;
wire [11:0] reduced;
wire [10:0] quo;

integer tests;
integer errors;
integer seed;
integer i;

mult_gen_0 dut_mult(
    .CLK(clk),
    .A(a),
    .B(b),
    .P(prod)
);

reduc dut_reduc(
    .clk(clk),
    .c(prod),
    .d(reduced),
    .q(quo)
);

always #5 clk = ~clk;

function [11:0] kyber_modq;
    input [23:0] value;
    begin
        kyber_modq = value % 12'd3329;
    end
endfunction

task check_mul;
    input [11:0] in_a;
    input [11:0] in_b;
    reg [23:0] expected_prod;
    reg [11:0] expected_red;
    begin
        expected_prod = in_a * in_b;
        expected_red = kyber_modq(expected_prod);

        @(negedge clk);
        a = in_a;
        b = in_b;

        repeat (8) @(posedge clk);
        tests = tests + 1;

        if (reduced !== expected_red) begin
            errors = errors + 1;
            $display("FAIL test %0d: a=%0d b=%0d product=%0d expected_mod=%0d got=%0d q=%0d",
                     tests, in_a, in_b, expected_prod, expected_red, reduced, quo);
        end else begin
            $display("PASS test %0d: a=%0d b=%0d product=%0d mod3329=%0d",
                     tests, in_a, in_b, expected_prod, reduced);
        end
    end
endtask

initial begin
    clk = 1'b0;
    a = 12'd0;
    b = 12'd0;
    tests = 0;
    errors = 0;
    seed = 32'h5120_3329;

    repeat (4) @(posedge clk);

    check_mul(12'd0,    12'd0);
    check_mul(12'd1,    12'd1);
    check_mul(12'd2,    12'd1665);
    check_mul(12'd17,   12'd19);
    check_mul(12'd128,  12'd256);
    check_mul(12'd3328, 12'd1);
    check_mul(12'd3328, 12'd3328);
    check_mul(12'd2285, 12'd2571);
    check_mul(12'd1441, 12'd1729);
    check_mul(12'd3328, 12'd1665);

    for (i = 0; i < 40; i = i + 1) begin
        check_mul($random(seed) % 12'd3329, $random(seed) % 12'd3329);
    end

    $display("==== Kyber512 multiplier/reduction self-check ====");
    $display("Tests run: %0d", tests);

    if (errors == 0) begin
        $display("PASS: mult_gen_0 + reduc match software (a*b) mod 3329.");
    end else begin
        $display("FAIL: %0d multiplier/reduction mismatches found.", errors);
    end

    $finish;
end

endmodule
