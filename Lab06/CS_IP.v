//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   2021 ICLAB Spring Course
//   Lab06			: CheckSum Soft IP (CS_IP)
//   Author         : Yao-Zhan Xu (xuyaozhan8905@gmail.com)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : CS_IP.v
//   Module Name : CS_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


//############################################################################
//--------------------------------NOTE--------------------------------------//
//############################################################################
//The range of WIDTH_DATA: 64, 128, 256
//The range of WIDTH_RESULT: not larger than WIDTH_DATA, WIDTH_DATA is divisible by WIDTH_RESULT

module CS_IP
#(parameter WIDTH_DATA = 64, parameter WIDTH_RESULT = 8)
(
	// Input signals
    data,
    in_valid,
    clk,
    rst_n,
	// Output signals
    result,
    out_valid
);
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
input [(WIDTH_DATA-1):0] data;
input in_valid, clk, rst_n;
output reg [(WIDTH_RESULT-1):0] result;
output reg out_valid;

//================================================================
//  DESIGN                        
//================================================================

generate

// WIDTH_DATA == WIDTH_RESULT
// 64|64 , 128|128 , 256|256 , 384|384
if( WIDTH_DATA == WIDTH_RESULT ) begin
	reg [(WIDTH_DATA-1):0] input_data;
	reg out_flag;
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) input_data <= 0;
		else if( in_valid ) input_data <= data;
	end
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_flag <= 0;
		else if( in_valid ) out_flag <= 1;
		else out_flag <= 0;
	end
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_valid <= 0;
		else out_valid <= out_flag;
	end
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) result <= 0;
		else if( out_flag ) result <= ~input_data;
 	end	
end
// WIDTH_RESULT == 1 
// 64|1 , 128|1 , 256|1, 384|1
else if( WIDTH_RESULT == 1 ) begin
	reg [(WIDTH_DATA-1):0] input_data;
	reg out_flag;
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) input_data <= 0;
		else if( in_valid ) input_data <= data;
	end
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_flag <= 0;
		else if( in_valid ) out_flag <= 1;
		else out_flag <= 0;
	end
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_valid <= 0;
		else out_valid <= out_flag;
	end
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) result <= 0;
		else if( out_flag ) result <= ( input_data == 0 )? 1 : 0;
 	end	
end
// WIDTH_RESULT == 128 
// 256|128
else if( WIDTH_RESULT == 128 ) begin
	reg [255:0] input_data;
	reg out_flag;
	wire [127:0] sep_a, sep_b;
	wire [128:0] sep_c;
	wire [127:0] pre_result;
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) input_data <= 0;
		else if( in_valid ) input_data <= data;
	end
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_flag <= 0;
		else if( in_valid ) out_flag <= 1;
		else out_flag <= 0;
	end
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_valid <= 0;
		else out_valid <= out_flag;
	end
	
	assign sep_a = input_data[255:128];
	assign sep_b = input_data[127:0];
	assign sep_c = sep_a + sep_b;
	assign pre_result = sep_c[127:0] + sep_c[128];
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) result <= 0;
		else if( out_flag ) result <= ~pre_result;
 	end	
end
// WIDTH_RESULT == 2
// 64|2，128|2，256|2，384|2
else if( WIDTH_RESULT == 2 ) begin
	reg [WIDTH_DATA-1:0] input_data;
	reg state_bits[0:8]; 
	
	wire [13:0] sep_64;
	wire [13:0] sep_128;
	wire [13:0] sep_192;
	wire [13:0] sep_256;
	wire [13:0] sep_320;
	wire [13:0] sep_384;	
	reg [8:0] sep_r;
	
	wire [WIDTH_RESULT-1:0] pre_result;
	wire [8:0] pre_result2, pre_result3, pre_result4, pre_result5, pre_result6, pre_result7;

	integer i;
	genvar idx;
	localparam NUMS_GROUP = WIDTH_DATA/64;
	localparam OUT_DETEC = NUMS_GROUP+2;
	//================================================================
	//  INPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) input_data <= 0;
		else if( in_valid ) input_data <= data;
	end
	//================================================================
	//  STATE_BITS                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) begin
			for ( i=0 ; i<9 ; i=i+1 ) state_bits[i] <= 0;
		end 
		else begin
			state_bits[0] <= in_valid;
			for ( i=0 ; i<8 ; i=i+1 )
				state_bits[i+1] <= state_bits[i];
		end
		
	end
	//================================================================
	//  CHECKSUM                       
	//================================================================
	if( WIDTH_DATA == 64 ) begin
		assign sep_64 =  input_data[63:62] + input_data[61:60] + input_data[59:58] + input_data[57:56] +
						 input_data[55:54] + input_data[53:52] + input_data[51:50] + input_data[49:48] +
						 input_data[47:46] + input_data[45:44] + input_data[43:42] + input_data[41:40] +
						 input_data[39:38] + input_data[37:36] + input_data[35:34] + input_data[33:32] +
						 input_data[31:30] + input_data[29:28] + input_data[27:26] + input_data[25:24] +
						 input_data[23:22] + input_data[21:20] + input_data[19:18] + input_data[17:16] +
						 input_data[15:14] + input_data[13:12] + input_data[11:10] + input_data[9:8]   +
						 input_data[7:6]   + input_data[5:4]   + input_data[3:2]   + input_data[1:0]   ;
	end
	else if( WIDTH_DATA == 128 ) begin
		assign sep_64 =  input_data[63:62] + input_data[61:60] + input_data[59:58] + input_data[57:56] +
						 input_data[55:54] + input_data[53:52] + input_data[51:50] + input_data[49:48] +
						 input_data[47:46] + input_data[45:44] + input_data[43:42] + input_data[41:40] +
						 input_data[39:38] + input_data[37:36] + input_data[35:34] + input_data[33:32] +
						 input_data[31:30] + input_data[29:28] + input_data[27:26] + input_data[25:24] +
						 input_data[23:22] + input_data[21:20] + input_data[19:18] + input_data[17:16] +
						 input_data[15:14] + input_data[13:12] + input_data[11:10] + input_data[9:8]   +
						 input_data[7:6]   + input_data[5:4]   + input_data[3:2]   + input_data[1:0]   ;
		assign sep_128 = input_data[127:126] + input_data[125:124] + input_data[123:122] + input_data[121:120] +
						 input_data[119:118] + input_data[117:116] + input_data[115:114] + input_data[113:112] +
						 input_data[111:110] + input_data[109:108] + input_data[107:106] + input_data[105:104] +
						 input_data[103:102] + input_data[101:100] + input_data[99:98] + input_data[97:96] +
						 input_data[95:94] + input_data[93:92] + input_data[91:90] + input_data[89:88] +
						 input_data[87:86] + input_data[85:84] + input_data[83:82] + input_data[81:80] +
						 input_data[79:78] + input_data[77:76] + input_data[75:74] + input_data[73:72]   +
						 input_data[71:70]   + input_data[69:68]   + input_data[67:66]   + input_data[65:64]   ;
	end
	else if( WIDTH_DATA == 256 ) begin
		assign sep_64 =  input_data[63:62] + input_data[61:60] + input_data[59:58] + input_data[57:56] +
						 input_data[55:54] + input_data[53:52] + input_data[51:50] + input_data[49:48] +
						 input_data[47:46] + input_data[45:44] + input_data[43:42] + input_data[41:40] +
						 input_data[39:38] + input_data[37:36] + input_data[35:34] + input_data[33:32] +
						 input_data[31:30] + input_data[29:28] + input_data[27:26] + input_data[25:24] +
						 input_data[23:22] + input_data[21:20] + input_data[19:18] + input_data[17:16] +
						 input_data[15:14] + input_data[13:12] + input_data[11:10] + input_data[9:8]   +
						 input_data[7:6]   + input_data[5:4]   + input_data[3:2]   + input_data[1:0]   ;
		assign sep_128 = input_data[127:126] + input_data[125:124] + input_data[123:122] + input_data[121:120] +
						 input_data[119:118] + input_data[117:116] + input_data[115:114] + input_data[113:112] +
						 input_data[111:110] + input_data[109:108] + input_data[107:106] + input_data[105:104] +
						 input_data[103:102] + input_data[101:100] + input_data[99:98] + input_data[97:96] +
						 input_data[95:94] + input_data[93:92] + input_data[91:90] + input_data[89:88] +
						 input_data[87:86] + input_data[85:84] + input_data[83:82] + input_data[81:80] +
						 input_data[79:78] + input_data[77:76] + input_data[75:74] + input_data[73:72]   +
						 input_data[71:70]   + input_data[69:68]   + input_data[67:66]   + input_data[65:64]   ;
		assign sep_192 = input_data[191:190] + input_data[189:188] + input_data[187:186] + input_data[185:184] +
						 input_data[183:182] + input_data[181:180] + input_data[179:178] + input_data[177:176] +
						 input_data[175:174] + input_data[173:172] + input_data[171:170] + input_data[169:168] +
						 input_data[167:166] + input_data[165:164] + input_data[163:162] + input_data[161:160] +
						 input_data[159:158] + input_data[157:156] + input_data[155:154] + input_data[153:152] +
						 input_data[151:150] + input_data[149:148] + input_data[147:146] + input_data[145:144] +
						 input_data[143:142] + input_data[141:140] + input_data[139:138] + input_data[137:136]   +
						 input_data[135:134]   + input_data[133:132]   + input_data[131:130]   + input_data[129:128]   ;
		assign sep_256 = input_data[255:254] + input_data[253:252] + input_data[251:250] + input_data[249:248] +
						 input_data[247:246] + input_data[245:244] + input_data[243:242] + input_data[241:240] +
						 input_data[239:238] + input_data[237:236] + input_data[235:234] + input_data[233:232] +
						 input_data[231:230] + input_data[229:228] + input_data[227:226] + input_data[225:224] +
						 input_data[223:222] + input_data[221:220] + input_data[219:218] + input_data[217:216] +
						 input_data[215:214] + input_data[213:212] + input_data[211:210] + input_data[209:208] +
						 input_data[207:206] + input_data[205:204] + input_data[203:202] + input_data[201:200]   +
						 input_data[199:198]   + input_data[197:196]   + input_data[195:194]   + input_data[193:192]   ;				 
						 
	end
	else if( WIDTH_DATA == 384 ) begin
		assign sep_64 =  input_data[63:62] + input_data[61:60] + input_data[59:58] + input_data[57:56] +
						 input_data[55:54] + input_data[53:52] + input_data[51:50] + input_data[49:48] +
						 input_data[47:46] + input_data[45:44] + input_data[43:42] + input_data[41:40] +
						 input_data[39:38] + input_data[37:36] + input_data[35:34] + input_data[33:32] +
						 input_data[31:30] + input_data[29:28] + input_data[27:26] + input_data[25:24] +
						 input_data[23:22] + input_data[21:20] + input_data[19:18] + input_data[17:16] +
						 input_data[15:14] + input_data[13:12] + input_data[11:10] + input_data[9:8]   +
						 input_data[7:6]   + input_data[5:4]   + input_data[3:2]   + input_data[1:0]   ;
		assign sep_128 = input_data[127:126] + input_data[125:124] + input_data[123:122] + input_data[121:120] +
						 input_data[119:118] + input_data[117:116] + input_data[115:114] + input_data[113:112] +
						 input_data[111:110] + input_data[109:108] + input_data[107:106] + input_data[105:104] +
						 input_data[103:102] + input_data[101:100] + input_data[99:98] + input_data[97:96] +
						 input_data[95:94] + input_data[93:92] + input_data[91:90] + input_data[89:88] +
						 input_data[87:86] + input_data[85:84] + input_data[83:82] + input_data[81:80] +
						 input_data[79:78] + input_data[77:76] + input_data[75:74] + input_data[73:72]   +
						 input_data[71:70]   + input_data[69:68]   + input_data[67:66]   + input_data[65:64]   ;
		assign sep_192 = input_data[191:190] + input_data[189:188] + input_data[187:186] + input_data[185:184] +
						 input_data[183:182] + input_data[181:180] + input_data[179:178] + input_data[177:176] +
						 input_data[175:174] + input_data[173:172] + input_data[171:170] + input_data[169:168] +
						 input_data[167:166] + input_data[165:164] + input_data[163:162] + input_data[161:160] +
						 input_data[159:158] + input_data[157:156] + input_data[155:154] + input_data[153:152] +
						 input_data[151:150] + input_data[149:148] + input_data[147:146] + input_data[145:144] +
						 input_data[143:142] + input_data[141:140] + input_data[139:138] + input_data[137:136]   +
						 input_data[135:134]   + input_data[133:132]   + input_data[131:130]   + input_data[129:128]   ;
		assign sep_256 = input_data[255:254] + input_data[253:252] + input_data[251:250] + input_data[249:248] +
						 input_data[247:246] + input_data[245:244] + input_data[243:242] + input_data[241:240] +
						 input_data[239:238] + input_data[237:236] + input_data[235:234] + input_data[233:232] +
						 input_data[231:230] + input_data[229:228] + input_data[227:226] + input_data[225:224] +
						 input_data[223:222] + input_data[221:220] + input_data[219:218] + input_data[217:216] +
						 input_data[215:214] + input_data[213:212] + input_data[211:210] + input_data[209:208] +
						 input_data[207:206] + input_data[205:204] + input_data[203:202] + input_data[201:200]   +
						 input_data[199:198]   + input_data[197:196]   + input_data[195:194]   + input_data[193:192]   ;
		assign sep_320 = input_data[319:318] + input_data[317:316] + input_data[315:314] + input_data[313:312] +
						 input_data[311:310] + input_data[309:308] + input_data[307:306] + input_data[305:304] +
						 input_data[303:302] + input_data[301:300] + input_data[299:298] + input_data[297:296] +
						 input_data[295:294] + input_data[293:292] + input_data[291:290] + input_data[289:288] +
						 input_data[287:286] + input_data[285:284] + input_data[283:282] + input_data[281:280] +
						 input_data[279:278] + input_data[277:276] + input_data[275:274] + input_data[273:272] +
						 input_data[271:270] + input_data[269:268] + input_data[267:266] + input_data[265:264]   +
						 input_data[263:262]   + input_data[261:260]   + input_data[259:258]   + input_data[257:256]   ;
		assign sep_384 = input_data[383:382] + input_data[381:380] + input_data[379:378] + input_data[377:376] +
						 input_data[375:374] + input_data[373:372] + input_data[371:370] + input_data[369:368] +
						 input_data[367:366] + input_data[365:364] + input_data[363:362] + input_data[361:360] +
						 input_data[359:358] + input_data[357:356] + input_data[355:354] + input_data[353:352] +
						 input_data[351:350] + input_data[349:348] + input_data[347:346] + input_data[345:344] +
						 input_data[343:342] + input_data[341:340] + input_data[339:338] + input_data[337:336] +
						 input_data[335:334] + input_data[333:332] + input_data[331:330] + input_data[329:328]   +
						 input_data[327:326]   + input_data[325:324]   + input_data[323:322]   + input_data[321:320]   ;
	end
		
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) sep_r <= 0;
		else begin
			if( state_bits[2] ) sep_r <= sep_64;
			else if( state_bits[3] ) sep_r <= sep_r + sep_128;
			else if( state_bits[4] ) sep_r <= sep_r + sep_192;
			else if( state_bits[5] ) sep_r <= sep_r + sep_256;
			else if( state_bits[6] ) sep_r <= sep_r + sep_320;
			else if( state_bits[7] ) sep_r <= sep_r + sep_384;
		end
	end
	
	
	assign pre_result2 = sep_r[1:0] + sep_r[8:2];
	assign pre_result3 = pre_result2[1:0] + pre_result2[7:2];
	assign pre_result4 = pre_result3[1:0] + pre_result3[6:2];
	assign pre_result5 = pre_result4[1:0] + pre_result4[5:2];
	assign pre_result6 = pre_result5[1:0] + pre_result5[4:2];
	assign pre_result7 = pre_result6[1:0] + pre_result6[3:2];
	assign pre_result = pre_result7[7:0] + pre_result7[2];
	
	//================================================================
	//  OUTPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) result <= 0;
		else if( state_bits[ OUT_DETEC ] ) result <= ~pre_result;
 	end	
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_valid <= 0;
		else out_valid <= state_bits[ OUT_DETEC ];
	end
	
end
// WIDTH_RESULT == 4
// 64|4，128|4，256|4，384|4
else if( WIDTH_RESULT == 4 ) begin
	reg [WIDTH_DATA-1:0] input_data;
	reg state_bits [0:8]; 
	
	wire [13:0] sep_64;
	wire [13:0] sep_128;
	wire [13:0] sep_192;
	wire [13:0] sep_256;
	wire [13:0] sep_320;
	wire [13:0] sep_384;
	reg [10:0] sep_r;
	
	wire [WIDTH_RESULT-1:0] pre_result;
	wire [10:0] pre_result2, pre_result3, pre_result4, pre_result5;

	integer i;
	localparam NUMS_GROUP = WIDTH_DATA/64;
	localparam OUT_DETEC = NUMS_GROUP+2;
	
	//================================================================
	//  INPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) input_data <= 0;
		else if( in_valid ) input_data <= data;
	end
	//================================================================
	//  STATE_BITS                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) begin
			for ( i=0 ; i<9 ; i=i+1 ) state_bits[i] <= 0;
		end 
		else begin
			state_bits[0] <= in_valid;
			for ( i=0 ; i<8 ; i=i+1 )
				state_bits[i+1] <= state_bits[i];
		end
		
	end
	//================================================================
	//  CHECKSUM                       
	//================================================================
	
	if( WIDTH_DATA == 64 ) begin
		assign sep_64 = input_data[63:60] + input_data[59:56] + input_data[55:52] + input_data[51:48] +
						input_data[47:44] + input_data[43:40] + input_data[39:36] + input_data[35:32] +  
						input_data[31:28] + input_data[27:24] + input_data[23:20] + input_data[19:16] +
						input_data[15:12] + input_data[11:8] + input_data[7:4] + input_data[3:0]    ;
	end
	else if( WIDTH_DATA == 128 ) begin
		assign sep_64 = input_data[63:60] + input_data[59:56] + input_data[55:52] + input_data[51:48] +
						input_data[47:44] + input_data[43:40] + input_data[39:36] + input_data[35:32] +  
						input_data[31:28] + input_data[27:24] + input_data[23:20] + input_data[19:16] +
						input_data[15:12] + input_data[11:8] + input_data[7:4] + input_data[3:0]    ;
		assign sep_128 = input_data[127:124] + input_data[123:120] + input_data[119:116] + input_data[115:112] +
						  input_data[111:108] + input_data[107:104] + input_data[103:100] + input_data[99:96]   +  
						  input_data[95:92]   + input_data[91:88]   + input_data[87:84]   + input_data[83:80]   +
						  input_data[79:76]   + input_data[75:72]   + input_data[71:68]   + input_data[67:64]  ;
	end
	else if( WIDTH_DATA == 256 ) begin
		assign sep_64 = input_data[63:60] + input_data[59:56] + input_data[55:52] + input_data[51:48] +
						input_data[47:44] + input_data[43:40] + input_data[39:36] + input_data[35:32] +  
						input_data[31:28] + input_data[27:24] + input_data[23:20] + input_data[19:16] +
						input_data[15:12] + input_data[11:8] + input_data[7:4] + input_data[3:0]    ;
		assign sep_128 = input_data[127:124] + input_data[123:120] + input_data[119:116] + input_data[115:112] +
						  input_data[111:108] + input_data[107:104] + input_data[103:100] + input_data[99:96]   +  
						  input_data[95:92]   + input_data[91:88]   + input_data[87:84]   + input_data[83:80]   +
						  input_data[79:76]   + input_data[75:72]   + input_data[71:68]   + input_data[67:64]  ;
		assign sep_192 = input_data[191:188] + input_data[187:184] + input_data[183:180] + input_data[179:176] +
						  input_data[175:172] + input_data[171:168] + input_data[167:164] + input_data[163:160] +
						  input_data[159:156] + input_data[155:152] + input_data[151:148] + input_data[147:144] +
						  input_data[143:140] + input_data[139:136] + input_data[135:132] + input_data[131:128] ;				  
		assign sep_256 =  input_data[255:252] + input_data[251:248] + input_data[247:244] + input_data[243:240] +
						  input_data[239:236] + input_data[235:232] + input_data[231:228] + input_data[227:224] + 
						  input_data[223:220] + input_data[219:216] + input_data[215:212] + input_data[211:208] +
						  input_data[207:204] + input_data[203:200] + input_data[199:196] + input_data[195:192] ;				  
	end
	else if( WIDTH_DATA == 384 ) begin
		assign sep_64 = input_data[63:60] + input_data[59:56] + input_data[55:52] + input_data[51:48] +
						input_data[47:44] + input_data[43:40] + input_data[39:36] + input_data[35:32] +  
						input_data[31:28] + input_data[27:24] + input_data[23:20] + input_data[19:16] +
						input_data[15:12] + input_data[11:8] + input_data[7:4] + input_data[3:0]    ;
		assign sep_128 = input_data[127:124] + input_data[123:120] + input_data[119:116] + input_data[115:112] +
						  input_data[111:108] + input_data[107:104] + input_data[103:100] + input_data[99:96]   +  
						  input_data[95:92]   + input_data[91:88]   + input_data[87:84]   + input_data[83:80]   +
						  input_data[79:76]   + input_data[75:72]   + input_data[71:68]   + input_data[67:64]  ;
		assign sep_192 = input_data[191:188] + input_data[187:184] + input_data[183:180] + input_data[179:176] +
						  input_data[175:172] + input_data[171:168] + input_data[167:164] + input_data[163:160] +
						  input_data[159:156] + input_data[155:152] + input_data[151:148] + input_data[147:144] +
						  input_data[143:140] + input_data[139:136] + input_data[135:132] + input_data[131:128] ;				  
		assign sep_256 =  input_data[255:252] + input_data[251:248] + input_data[247:244] + input_data[243:240] +
						  input_data[239:236] + input_data[235:232] + input_data[231:228] + input_data[227:224] + 
						  input_data[223:220] + input_data[219:216] + input_data[215:212] + input_data[211:208] +
						  input_data[207:204] + input_data[203:200] + input_data[199:196] + input_data[195:192] ;	
		assign sep_320 =  input_data[319:316] + input_data[315:312] + input_data[311:308] + input_data[307:304] +
						  input_data[303:300] + input_data[299:296] + input_data[295:292] + input_data[291:288] + 
						  input_data[287:284] + input_data[283:280] + input_data[279:276] + input_data[275:272] +
						  input_data[271:268] + input_data[267:264] + input_data[263:260] + input_data[259:256] ;
		assign sep_384 =  input_data[383:380] + input_data[379:376] + input_data[375:372] + input_data[371:368] +
						  input_data[367:364] + input_data[363:360] + input_data[359:356] + input_data[355:352] + 
						  input_data[351:348] + input_data[347:344] + input_data[343:340] + input_data[339:336] +
						  input_data[335:332] + input_data[331:328] + input_data[327:324] + input_data[323:320];
	end
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) sep_r <= 0;
		else begin
			if( state_bits[2] ) sep_r <= sep_64;
			else if( state_bits[3] ) sep_r <= sep_r + sep_128;
			else if( state_bits[4] ) sep_r <= sep_r + sep_192;
			else if( state_bits[5] ) sep_r <= sep_r + sep_256;
			else if( state_bits[6] ) sep_r <= sep_r + sep_320;
			else if( state_bits[7] ) sep_r <= sep_r + sep_384;
		end
	end
	
	
	assign pre_result2 = sep_r[3:0] + sep_r[10:4];
	assign pre_result3 = pre_result2[3:0] + pre_result2[9:4];
	assign pre_result4 = pre_result3[3:0] + pre_result3[8:4];
	assign pre_result5 = pre_result4[3:0] + pre_result4[7:4];
	assign pre_result = pre_result5[3:0] + pre_result5[4];
	
	//================================================================
	//  OUTPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) result <= 0;
		else if( state_bits[ OUT_DETEC ] ) result <= ~pre_result;
 	end	
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_valid <= 0;
		else out_valid <= state_bits[ OUT_DETEC ];
	end
end
// WIDTH_RESULT == 8
// 64|8，128|8，256|8，384|8
else if( WIDTH_RESULT == 8 ) begin
	reg [WIDTH_DATA-1:0] input_data;
	reg state_bits [0:8]; 
	
	wire [13:0] sep_64;
	wire [13:0] sep_128;
	wire [13:0] sep_192;
	wire [13:0] sep_256;
	wire [13:0] sep_320;
	wire [13:0] sep_384;
	reg [13:0] sep_r;
	
	wire [WIDTH_RESULT-1:0] pre_result;
	wire [13:0] pre_result2;

	integer i;
	genvar idx;
	localparam NUMS_GROUP = WIDTH_DATA/64;
	localparam OUT_DETEC = NUMS_GROUP+2;
	
	//================================================================
	//  INPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) input_data <= 0;
		else if( in_valid ) input_data <= data;
	end
	//================================================================
	//  STATE_BITS                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) begin
			for ( i=0 ; i<9 ; i=i+1 ) state_bits[i] <= 0;
		end 
		else begin
			state_bits[0] <= in_valid;
			for ( i=0 ; i<8 ; i=i+1 )
				state_bits[i+1] <= state_bits[i];
		end
		
	end
	//================================================================
	//  CHECKSUM                       
	//================================================================
	if( WIDTH_DATA == 64 ) begin
		assign sep_64 = input_data[63:56] + input_data[55:48] + input_data[47:40] + input_data[39:32] +
			input_data[31:24] + input_data[23:16] + input_data[15:8] + input_data[7:0]    ;
	end	  
	else if( WIDTH_DATA == 128 ) begin
		assign sep_64 = input_data[63:56] + input_data[55:48] + input_data[47:40] + input_data[39:32] +
			input_data[31:24] + input_data[23:16] + input_data[15:8] + input_data[7:0]    ;
		assign sep_128 = input_data[127:120] + input_data[119:112] + input_data[111:104] + input_data[103:96] +
			     input_data[95:88]   + input_data[87:80]   + input_data[79:72]   + input_data[71:64]  ;	  
	end
	else if( WIDTH_DATA == 256 ) begin
		assign sep_64 = input_data[63:56] + input_data[55:48] + input_data[47:40] + input_data[39:32] +
			input_data[31:24] + input_data[23:16] + input_data[15:8] + input_data[7:0]    ;
		assign sep_128 = input_data[127:120] + input_data[119:112] + input_data[111:104] + input_data[103:96] +
			     input_data[95:88]   + input_data[87:80]   + input_data[79:72]   + input_data[71:64]  ;	  
		assign sep_192 = input_data[191:184] + input_data[183:176] + input_data[175:168] + input_data[167:160] +
				  input_data[159:152] + input_data[151:144] + input_data[143:136] + input_data[135:128] ;
		assign sep_256 = input_data[255:248] + input_data[247:240] + input_data[239:232] + input_data[231:224] +
					input_data[223:216] + input_data[215:208] + input_data[207:200] + input_data[199:192] ;
	end
	else if( WIDTH_DATA == 384 ) begin
		assign sep_64 = input_data[63:56] + input_data[55:48] + input_data[47:40] + input_data[39:32] +
			input_data[31:24] + input_data[23:16] + input_data[15:8] + input_data[7:0]    ;
		assign sep_128 = input_data[127:120] + input_data[119:112] + input_data[111:104] + input_data[103:96] +
			     input_data[95:88]   + input_data[87:80]   + input_data[79:72]   + input_data[71:64]  ;	  
		assign sep_192 = input_data[191:184] + input_data[183:176] + input_data[175:168] + input_data[167:160] +
				  input_data[159:152] + input_data[151:144] + input_data[143:136] + input_data[135:128] ;
		assign sep_256 = input_data[255:248] + input_data[247:240] + input_data[239:232] + input_data[231:224] +
					input_data[223:216] + input_data[215:208] + input_data[207:200] + input_data[199:192] ;
		assign sep_320 = input_data[319:312] + input_data[311:304] + input_data[303:296] + input_data[295:288] +
				  input_data[287:280] + input_data[279:272] + input_data[271:264] + input_data[263:256] ;
		assign sep_384 = input_data[383:376] + input_data[375:368] + input_data[367:360] + input_data[359:352] +
				  input_data[351:344] + input_data[343:336] + input_data[335:328] + input_data[327:320] ;
	end

	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) sep_r <= 0;
		else begin
			if( state_bits[2] ) sep_r <= sep_64;
			else if( state_bits[3] ) sep_r <= sep_r + sep_128;
			else if( state_bits[4] ) sep_r <= sep_r + sep_192;
			else if( state_bits[5] ) sep_r <= sep_r + sep_256;
			else if( state_bits[6] ) sep_r <= sep_r + sep_320;
			else if( state_bits[7] ) sep_r <= sep_r + sep_384;
		end
	end
	
	assign pre_result2 = sep_r[7:0] + sep_r[13:8];
	assign pre_result = pre_result2[7:0] + pre_result2[8];
	
	//================================================================
	//  OUTPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) result <= 0;
		else if( state_bits[ OUT_DETEC ] ) result <= ~pre_result;
 	end	
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_valid <= 0;
		else out_valid <= state_bits[ OUT_DETEC ];
	end
end
// WIDTH_RESULT == 16
// 64|16，128|16，256|16，384|16
else if( WIDTH_RESULT == 16 ) begin
	reg [WIDTH_DATA-1:0] input_data;
	reg state_bits [0:8]; 
	
	reg [20:0] sep_r;
	
	wire [WIDTH_RESULT-1:0] pre_result;
	wire [20:0] pre_result2;

	integer i;
	localparam NUMS_GROUP = WIDTH_DATA/64;
	localparam OUT_DETEC = NUMS_GROUP+2;
	
	//================================================================
	//  INPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) input_data <= 0;
		else if( in_valid ) input_data <= data;
	end
	//================================================================
	//  STATE_BITS                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) begin
			for ( i=0 ; i<9 ; i=i+1 ) state_bits[i] <= 0;
		end 
		else begin
			state_bits[0] <= in_valid;
			for ( i=0 ; i<8 ; i=i+1 )
				state_bits[i+1] <= state_bits[i];
		end
		
	end
	//================================================================
	//  CHECKSUM                       
	//================================================================

	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) sep_r <= 0;
		else begin
			if( state_bits[2] ) sep_r <= input_data[63:48] + input_data[47:32] + input_data[31:16] + input_data[15:0];
			else if( state_bits[3] ) sep_r <= sep_r + input_data[127:112] + input_data[111:96] + input_data[95:80] + input_data[79:64];
			else if( state_bits[4] ) sep_r <= sep_r + input_data[191:176] + input_data[175:160] + input_data[159:144] + input_data[143:128];
			else if( state_bits[5] ) sep_r <= sep_r + input_data[255:240] + input_data[239:224] + input_data[223:208] + input_data[207:192];
			else if( state_bits[6] ) sep_r <= sep_r + input_data[319:304] + input_data[303:288] + input_data[287:272] + input_data[271:256];
			else if( state_bits[7] ) sep_r <= sep_r + input_data[383:368] + input_data[367:352] + input_data[351:336] + input_data[335:320];
		end
	end
	assign pre_result2 = sep_r[15:0] + sep_r[20:16];
	assign pre_result = pre_result2[15:0] + pre_result2[16];
	
	//================================================================
	//  OUTPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) result <= 0;
		else if( state_bits[ OUT_DETEC ] ) result <= ~pre_result;
 	end	
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_valid <= 0;
		else out_valid <= state_bits[ OUT_DETEC ];
	end
end
// WIDTH_RESULT == 32
// 64|32，128|32，256|32，384|32
else if( WIDTH_RESULT == 32 ) begin
	reg [WIDTH_DATA-1:0] input_data;
	reg state_bits [0:8]; 
	
	reg [35:0] sep_r;
	
	wire [WIDTH_RESULT-1:0] pre_result;
	wire [35:0] pre_result2;

	integer i;
	localparam NUMS_GROUP = WIDTH_DATA/64;
	localparam OUT_DETEC = NUMS_GROUP+2;
	
	//================================================================
	//  INPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) input_data <= 0;
		else if( in_valid ) input_data <= data;
	end
	//================================================================
	//  STATE_BITS                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) begin
			for ( i=0 ; i<9 ; i=i+1 ) state_bits[i] <= 0;
		end 
		else begin
			state_bits[0] <= in_valid;
			for ( i=0 ; i<8 ; i=i+1 )
				state_bits[i+1] <= state_bits[i];
		end
		
	end
	//================================================================
	//  CHECKSUM                       
	//================================================================
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) sep_r <= 0;
		else begin 
			if( state_bits[2] ) sep_r <= input_data[63:32] + input_data[31:0];
			else if( state_bits[3] ) sep_r <= sep_r + input_data[127:96] + input_data[95:64];
			else if( state_bits[4] ) sep_r <= sep_r + input_data[191:160] + input_data[159:128];
			else if( state_bits[5] ) sep_r <= sep_r + input_data[255:224] + input_data[223:192];
			else if( state_bits[6] ) sep_r <= sep_r + input_data[319:288] + input_data[287:256];
			else if( state_bits[7] ) sep_r <= sep_r + input_data[383:352] + input_data[351:320];
		end
	end
	
	assign pre_result2 = sep_r[31:0] + sep_r[35:32];
	assign pre_result = pre_result2[31:0] + pre_result2[32];
	
	//================================================================
	//  OUTPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) result <= 0;
		else if( state_bits[ OUT_DETEC ] ) result <= ~pre_result;
 	end	
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_valid <= 0;
		else out_valid <= state_bits[ OUT_DETEC ];
	end
end
// WIDTH_RESULT == 64
// 128|64，256|64，384|64 
else begin // WIDTH_RESULT ==64
	reg [WIDTH_DATA-1:0] input_data;
	reg state_bits [0:5]; 
	
	reg [66:0] sep_r;
	
	wire [WIDTH_RESULT-1:0] pre_result;
	wire [66:0] pre_result2;

	integer i;
	localparam NUMS_GROUP = WIDTH_DATA/128;
	localparam OUT_DETEC = NUMS_GROUP+2;
	
	//================================================================
	//  INPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) input_data <= 0;
		else if( in_valid ) input_data <= data;
	end
	//================================================================
	//  STATE_BITS                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) begin
			for ( i=0 ; i<9 ; i=i+1 ) state_bits[i] <= 0;
		end 
		else begin
			state_bits[0] <= in_valid;
			for ( i=0 ; i<8 ; i=i+1 )
				state_bits[i+1] <= state_bits[i];
		end
		
	end
	//================================================================
	//  CHECKSUM                       
	//================================================================
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) sep_r <= 0;
		else begin
			if( state_bits[2] ) sep_r <= input_data[63:0] + input_data[127:64];
			else if( state_bits[3] ) sep_r <= sep_r + input_data[191:128] + input_data[255:192];
			else if( state_bits[4] ) sep_r <= sep_r + input_data[383:320] + input_data[319:256];
		end
	end
	
	assign pre_result2 = sep_r[63:0] + sep_r[66:64];
	assign pre_result = pre_result2[63:0] + pre_result2[64];
	
	//================================================================
	//  OUTPUT                       
	//================================================================
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) result <= 0;
		else if( state_bits[ OUT_DETEC ] ) result <= ~pre_result;
 	end	
	
	always@( posedge clk or negedge rst_n ) begin
		if( !rst_n ) out_valid <= 0;
		else out_valid <= state_bits[ OUT_DETEC ];
	end
end

endgenerate

endmodule