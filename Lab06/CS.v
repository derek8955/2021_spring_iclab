//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   2021 ICLAB Spring Course
//   Lab06			: CheckSum (CS)
//   Author         : Yao-Zhan Xu (xuyaozhan8905@gmail.com)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : CS.v
//   Module Name : CS
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
//synopsys translate_off
`include "CS_IP.v"
//synopsys translate_on

module CS
#(parameter WIDTH_DATA_1 = 384, parameter WIDTH_RESULT_1 = 8,
parameter WIDTH_DATA_2 = 128, parameter WIDTH_RESULT_2 = 8)
(
    data,
    in_valid,
    clk,
    rst_n,
    result,
    out_valid
);
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input [(WIDTH_DATA_1+WIDTH_DATA_2-1):0] data;
input in_valid, clk, rst_n;
output reg [(WIDTH_RESULT_1+WIDTH_RESULT_2-1):0] result;
output reg out_valid;
//================================================================
//  parameter / genvar / integer                          
//================================================================
// FSM
parameter STATE_IDLE   = 2'd0,
		  STATE_PROC   = 2'd1,
		  STATE_OUTPUT = 2'd2;
//================================================================
//   Wires & Registers 
//================================================================
wire [WIDTH_RESULT_1-1:0] result_384;
wire [WIDTH_RESULT_2-1:0] result_128;
reg [WIDTH_RESULT_1-1:0] result_384_r;
reg [WIDTH_RESULT_2-1:0] result_128_r;
wire out_valid_384, out_valid_128;
reg out_valid_384_r, out_valid_128_r;

reg [1:0] cur_state, nx_state;
	
wire ready;
wire[(WIDTH_RESULT_1+WIDTH_RESULT_2-1):0] pre_result;

//================================================================
//  CHECKSUM
//================================================================
CS_IP #( .WIDTH_DATA(384), .WIDTH_RESULT(8) )
	DATA1( .data( data[511:128] ), .in_valid( in_valid ), .clk( clk ), .rst_n( rst_n ), .result( result_384 ), .out_valid( out_valid_384 ) );

CS_IP #( .WIDTH_DATA(128), .WIDTH_RESULT(8) )
	DATA2( .data( data[127:0] ), .in_valid( in_valid ), .clk( clk ), .rst_n( rst_n ), .result( result_128 ), .out_valid( out_valid_128 ) );
	

//================================================================
//  PRE_OUTPUT
//================================================================
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) result_384_r <= 0;
	else result_384_r <= result_384;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) result_128_r <= 0;
	else result_128_r <= result_128;
end

assign pre_result = {result_384_r,result_128_r};

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) out_valid_384_r <= 0;
	else begin
		if( out_valid_384 ) out_valid_384_r <= 1;
		else if( nx_state == STATE_OUTPUT ) out_valid_384_r <= 0;
	end
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) out_valid_128_r <= 0;
	else begin
		if( out_valid_128 ) out_valid_128_r <= 1;
		else if( nx_state == STATE_OUTPUT ) out_valid_128_r <= 0;
	end
end

assign ready = out_valid_384_r & out_valid_128_r;	
//================================================================
//  OUTPUT
//================================================================
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) out_valid <= 0;
	else if( nx_state == STATE_OUTPUT ) out_valid <= 1;
	else out_valid <= 0;
end

always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) result <= 0;
	else if( nx_state == STATE_OUTPUT ) result <= pre_result;
end

//================================================================
//  FSM
//================================================================
always@( posedge clk or negedge rst_n ) begin
	if( !rst_n ) cur_state <= STATE_IDLE;
	else cur_state <= nx_state;
end

always@( * ) begin
	case( cur_state ) 
	STATE_IDLE: nx_state = ( in_valid )? STATE_PROC : STATE_IDLE;
	STATE_PROC: nx_state = ( ready )? STATE_OUTPUT : STATE_PROC;
	STATE_OUTPUT: nx_state = STATE_IDLE;
	default: nx_state = STATE_IDLE;
	endcase
end

endmodule