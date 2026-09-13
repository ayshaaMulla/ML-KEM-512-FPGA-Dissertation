`timescale 1ns / 1ps

module Kyber512_check_tb();

reg clk, rst, start;
reg [2:0] k;
wire ready_pk, ready_c;
wire req_pk, req_c;
wire valid_server, valid_client;
wire [31:0] dout_server;
wire [31:0] dout_client;

integer fp_out_ser, fp_out_cli;
integer i;
integer fail;
integer server_count, client_count;

reg [31:0] expected_key [0:7];
reg [31:0] server_last [0:7];
reg [31:0] client_last [0:7];

initial begin
	expected_key[0] = 32'h6725690a;
	expected_key[1] = 32'h2cb2246f;
	expected_key[2] = 32'h814c6f28;
	expected_key[3] = 32'hec4c22a4;
	expected_key[4] = 32'h259b6c50;
	expected_key[5] = 32'h020e487d;
	expected_key[6] = 32'h449fb4e3;
	expected_key[7] = 32'h7f23a3ca;

	for(i = 0; i < 8; i = i + 1) begin
		server_last[i] = 32'h0;
		client_last[i] = 32'h0;
	end

	server_count = 0;
	client_count = 0;
	fail = 0;
	fp_out_ser = $fopen("output_ser_512_check.txt","w");
	fp_out_cli = $fopen("output_cli_512_check.txt","w");
end

always @(posedge clk) begin
	if(valid_server) begin
		$fdisplay(fp_out_ser,"%h",dout_server);
		$display("SERVER %0t: %h",$time,dout_server);
		for(i = 0; i < 7; i = i + 1)
			server_last[i] <= server_last[i+1];
		server_last[7] <= dout_server;
		server_count <= server_count + 1;
	end

	if(valid_client) begin
		$fdisplay(fp_out_cli,"%h",dout_client);
		$display("CLIENT %0t: %h",$time,dout_client);
		for(i = 0; i < 7; i = i + 1)
			client_last[i] <= client_last[i+1];
		client_last[7] <= dout_client;
		client_count <= client_count + 1;
	end
end

always #5 clk = ~clk;

initial begin
	clk = 1'h0;
	rst = 1'h0;
	start = 1'h0;
	k = 3'h2;

	#10 rst = 1'h1;
	#20 rst = 1'h0;
	start = 1'h1;
	#10 start = 1'h0;

	#200000;
	$display("");
	$display("==== Kyber512 self-check ====");

	if(server_count < 8) begin
		$display("FAIL: server produced fewer than 8 output words: %0d", server_count);
		fail = 1;
	end

	if(client_count < 8) begin
		$display("FAIL: client produced fewer than 8 output words: %0d", client_count);
		fail = 1;
	end

	for(i = 0; i < 8; i = i + 1) begin
		if(server_last[i] !== expected_key[i]) begin
			$display("FAIL: server key word %0d expected %h got %h", i, expected_key[i], server_last[i]);
			fail = 1;
		end

		if(client_last[i] !== expected_key[i]) begin
			$display("FAIL: client key word %0d expected %h got %h", i, expected_key[i], client_last[i]);
			fail = 1;
		end
	end

	if(fail == 0)
		$display("PASS: Kyber512 server and client shared keys match the round3 C reference.");
	else
		$display("FAIL: Kyber512 hardware output does not match the round3 C reference.");

	$fclose(fp_out_ser);
	$fclose(fp_out_cli);
	$finish;
end

Kyber_Server S(
	.clk(clk),
	.rst(rst),
	.start(start),
	.wen(valid_client),
	.k(k),
	.din(dout_client),
	.ready_pk(ready_pk),
	.ready_c(ready_c),
	.req_pk(req_pk),
	.req_c(req_c),
	.valid(valid_server),
	.dout(dout_server)
);

Kyber_Client C(
	.clk(clk),
	.rst(rst),
	.start(start),
	.wen(valid_server),
	.k(k),
	.din(dout_server),
	.ready_pk(ready_pk),
	.ready_c(ready_c),
	.req_pk(req_pk),
	.req_c(req_c),
	.valid(valid_client),
	.dout(dout_client)
);

endmodule
