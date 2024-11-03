// Copyright 2021 The OpenROAD Project
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module prim_secded_72_64_enc (
	in,
	out
);
	input [63:0] in;
	output wire [71:0] out;
	assign out[0] = in[0];
	assign out[1] = in[1];
	assign out[2] = in[2];
	assign out[3] = in[3];
	assign out[4] = in[4];
	assign out[5] = in[5];
	assign out[6] = in[6];
	assign out[7] = in[7];
	assign out[8] = in[8];
	assign out[9] = in[9];
	assign out[10] = in[10];
	assign out[11] = in[11];
	assign out[12] = in[12];
	assign out[13] = in[13];
	assign out[14] = in[14];
	assign out[15] = in[15];
	assign out[16] = in[16];
	assign out[17] = in[17];
	assign out[18] = in[18];
	assign out[19] = in[19];
	assign out[20] = in[20];
	assign out[21] = in[21];
	assign out[22] = in[22];
	assign out[23] = in[23];
	assign out[24] = in[24];
	assign out[25] = in[25];
	assign out[26] = in[26];
	assign out[27] = in[27];
	assign out[28] = in[28];
	assign out[29] = in[29];
	assign out[30] = in[30];
	assign out[31] = in[31];
	assign out[32] = in[32];
	assign out[33] = in[33];
	assign out[34] = in[34];
	assign out[35] = in[35];
	assign out[36] = in[36];
	assign out[37] = in[37];
	assign out[38] = in[38];
	assign out[39] = in[39];
	assign out[40] = in[40];
	assign out[41] = in[41];
	assign out[42] = in[42];
	assign out[43] = in[43];
	assign out[44] = in[44];
	assign out[45] = in[45];
	assign out[46] = in[46];
	assign out[47] = in[47];
	assign out[48] = in[48];
	assign out[49] = in[49];
	assign out[50] = in[50];
	assign out[51] = in[51];
	assign out[52] = in[52];
	assign out[53] = in[53];
	assign out[54] = in[54];
	assign out[55] = in[55];
	assign out[56] = in[56];
	assign out[57] = in[57];
	assign out[58] = in[58];
	assign out[59] = in[59];
	assign out[60] = in[60];
	assign out[61] = in[61];
	assign out[62] = in[62];
	assign out[63] = in[63];
	assign out[64] = ((((((((((((((((((((((((in[0] ^ in[1]) ^ in[2]) ^ in[3]) ^ in[4]) ^ in[5]) ^ in[6]) ^ in[7]) ^ in[8]) ^ in[9]) ^ in[10]) ^ in[11]) ^ in[12]) ^ in[13]) ^ in[14]) ^ in[15]) ^ in[16]) ^ in[17]) ^ in[18]) ^ in[19]) ^ in[20]) ^ in[57]) ^ in[58]) ^ in[61]) ^ in[62]) ^ in[63];
	assign out[65] = ((((((((((((((((((((((((in[0] ^ in[1]) ^ in[2]) ^ in[3]) ^ in[4]) ^ in[5]) ^ in[21]) ^ in[22]) ^ in[23]) ^ in[24]) ^ in[25]) ^ in[26]) ^ in[27]) ^ in[28]) ^ in[29]) ^ in[30]) ^ in[31]) ^ in[32]) ^ in[33]) ^ in[34]) ^ in[35]) ^ in[58]) ^ in[59]) ^ in[60]) ^ in[62]) ^ in[63];
	assign out[66] = ((((((((((((((((((((((((in[0] ^ in[6]) ^ in[7]) ^ in[8]) ^ in[9]) ^ in[10]) ^ in[21]) ^ in[22]) ^ in[23]) ^ in[24]) ^ in[25]) ^ in[36]) ^ in[37]) ^ in[38]) ^ in[39]) ^ in[40]) ^ in[41]) ^ in[42]) ^ in[43]) ^ in[44]) ^ in[45]) ^ in[56]) ^ in[57]) ^ in[59]) ^ in[60]) ^ in[63];
	assign out[67] = ((((((((((((((((((((((((in[1] ^ in[6]) ^ in[11]) ^ in[12]) ^ in[13]) ^ in[14]) ^ in[21]) ^ in[26]) ^ in[27]) ^ in[28]) ^ in[29]) ^ in[36]) ^ in[37]) ^ in[38]) ^ in[39]) ^ in[46]) ^ in[47]) ^ in[48]) ^ in[49]) ^ in[50]) ^ in[51]) ^ in[56]) ^ in[57]) ^ in[58]) ^ in[61]) ^ in[63];
	assign out[68] = ((((((((((((((((((((((((in[2] ^ in[7]) ^ in[11]) ^ in[15]) ^ in[16]) ^ in[17]) ^ in[22]) ^ in[26]) ^ in[30]) ^ in[31]) ^ in[32]) ^ in[36]) ^ in[40]) ^ in[41]) ^ in[42]) ^ in[46]) ^ in[47]) ^ in[48]) ^ in[52]) ^ in[53]) ^ in[54]) ^ in[56]) ^ in[58]) ^ in[59]) ^ in[61]) ^ in[62];
	assign out[69] = ((((((((((((((((((((((((in[3] ^ in[8]) ^ in[12]) ^ in[15]) ^ in[18]) ^ in[19]) ^ in[23]) ^ in[27]) ^ in[30]) ^ in[33]) ^ in[34]) ^ in[37]) ^ in[40]) ^ in[43]) ^ in[44]) ^ in[46]) ^ in[49]) ^ in[50]) ^ in[52]) ^ in[53]) ^ in[55]) ^ in[56]) ^ in[57]) ^ in[59]) ^ in[60]) ^ in[61];
	assign out[70] = ((((((((((((((((((((((((in[4] ^ in[9]) ^ in[13]) ^ in[16]) ^ in[18]) ^ in[20]) ^ in[24]) ^ in[28]) ^ in[31]) ^ in[33]) ^ in[35]) ^ in[38]) ^ in[41]) ^ in[43]) ^ in[45]) ^ in[47]) ^ in[49]) ^ in[51]) ^ in[52]) ^ in[54]) ^ in[55]) ^ in[56]) ^ in[59]) ^ in[60]) ^ in[61]) ^ in[62];
	assign out[71] = ((((((((((((((((((((((((in[5] ^ in[10]) ^ in[14]) ^ in[17]) ^ in[19]) ^ in[20]) ^ in[25]) ^ in[29]) ^ in[32]) ^ in[34]) ^ in[35]) ^ in[39]) ^ in[42]) ^ in[44]) ^ in[45]) ^ in[48]) ^ in[50]) ^ in[51]) ^ in[53]) ^ in[54]) ^ in[55]) ^ in[57]) ^ in[58]) ^ in[60]) ^ in[62]) ^ in[63];
endmodule
