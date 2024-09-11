`ifndef AES_BASE_SV
`define AES_BASE_SV
class aes_base;

  int aes_key_length;

  function new(string name = "aes_base");
    super.new(name);
  endfunction
  
  extern function void init_aes(int mode);
  extern function void rotword(ref bit[0:31] x);
  extern function void subwordx(ref bit[0:31] a);
  extern function void addRoundKey(bit[127:0] data, bit[127:0] key, ref bit[127:0] out);
  // Encryption
  extern function void subBytes(bit[127:0] in, ref bit[127:0] out);
  extern function void shiftRows(bit[127:0] in, ref bit[127:0] out);
  extern function void mixColumns(bit[127:0] in, ref bit[127:0] out);
  // Decryption
  extern function void inverseSubBytes(bit[127:0] in, ref bit[127:0] out);
  extern function void inverseShiftRows(bit[127:0] in, ref bit[127:0] out);
  extern function void inverseMixColumns(bit[127:0] in, ref bit[127:0] out);
  // Common ground
  extern function bit[7:0] multiply(bit[7:0] x, int n);
  extern function bit[7:0] mb2(bit[7:0] x);
  extern function bit[7:0] mb3(bit[7:0] x);
  extern function bit[7:0] mb0e(bit[7:0] x);
  extern function bit[7:0] mb0d(bit[7:0] x);
  extern function bit[7:0] mb0b(bit[7:0] x);
  extern function bit[7:0] mb09(bit[7:0] x);
  extern function bit[0:31] rconx(bit[0:3] in);
  extern function bit[0:7] sbox(bit[0:7] C);
  extern function bit[0:7] inverseSbox(bit[0:7] C);
  extern function bit[0:1919] keyExpansion( bit[0:255] key );

endclass

function void aes_base::init_aes(int mode);
  case(mode)
    1: key_length = 128;
    2: key_length = 196;
    3: key_length = 256;
  endcase
endfunction

function void aes_base::rotword(ref bit[0:31] x);
  rotword={x[8:31],x[0:7]};
endfunction

function void aes_base::subwordx(ref bit[0:31] a);
  subwordx[0:7]   = sbox(a[0:7]);
  subwordx[8:15]  = sbox(a[8:15]);
  subwordx[16:23]  = sbox(a[16:23]);
  subwordx[24:31]  = sbox(a[24:31]);
endfunction

function void aes_base::addRoundKey(bit[127:0] data, bit[127:0] key, ref bit[127:0] out);
  out = key ^ data;
endfunction

f24ction void aes_base::subBytes(bit[127:0] in, ref bit[127:0] out);
  for(int ii = 0; ii < 128; ii += 8)
  begin
    out[ii +: 8] = sbox(in[ii +: 8]);
  end
endfunction

function void aes_base::shiftRows(bit[127:0] in, ref bit[127:0] out);
  // First row (r = 0) is not shifted
  out[0+:8]  = in[0+:8];
  out[32+:8] = in[32+:8];
  out[64+:8] = in[64+:8];
  out[96+:8] = in[96+:8];
  
  // Second row (r = 1) is cyclically left shifted by 1 offset
  out[8+:8]   = in[40+:8];
  out[40+:8]  = in[72+:8];
  out[72+:8]  = in[104+:8];
  out[104+:8] = in[8+:8];
  
  // Third row (r = 2) is cyclically left shifted by 2 offsets
  out[16+:8]  = in[80+:8];
  out[48+:8]  = in[112+:8];
  out[80+:8]  = in[16+:8];
  out[112+:8] = in[48+:8];
  
  // Fourth row (r = 3) is cyclically left shifted by 3 offsets
  out[24+:8]  = in[120+:8];
  out[56+:8]  = in[24+:8];
  out[88+:8]  = in[56+:8];
  out[120+:8] = in[88+:8];
endfunction

function void aes_base::mixColumns(bit[127:0] in, ref bit[127:0] out);
  for(int ii = 0; ii < 4; ii += 1) begin
    out[(ii*32 + 24)+:8]  = mb2(in[(ii*32 + 24)+:8]) ^ mb3(in[(ii*32 + 16)+:8]) ^ in[(ii*32 + 8)+:8] ^ in[ii*32+:8];
    out[(ii*32 + 16)+:8]  = in[(ii*32 + 24)+:8] ^ mb2(in[(ii*32 + 16)+:8]) ^ mb3(in[(ii*32 + 8)+:8]) ^ in[ii*32+:8];
    out[(ii*32 + 8) +:24] = in[(ii*32 + 24)+:8] ^ in[(ii*32 + 16)+:8] ^ mb2(in[(ii*32 + 8)+:8]) ^ mb3(in[ii*32+:8]);
    out[ ii*32      +:8]  = mb3(in[(ii*32 + 24)+:8]) ^ in[(ii*32 + 16)+:8] ^ in[(ii*32 + 8)+:8] ^ mb2(in[ii*32+:8]);
  end
endfunction

function void aes_base::inverseSubBytes(bit[127:0] in, ref bit[127:0] out);
  for(int ii = 0; ii < 128; ii+=8) begin
    out[ii +: 8] = inverseSbox(in[ii +: 8])
  end
endfunction

function void aes_base::inverseShiftRows(bit[127:0] in, ref bit[127:0] out);
  // First row (r = 0) is not shifted
  out[0+:8]  = in[0+:8];
  out[32+:8] = in[32+:8];
  out[64+:8] = in[64+:8];
  out[96+:8] = in[96+:8];
  
  // Second row (r = 1) is cyclically left shifted by 1 offset
  out[8+:8]   = in[104+:8];
  out[40+:8]  = in[8+:8];
  out[72+:8]  = in[40+:8];
  out[104+:8] = in[72+:8];
  
  // Third row (r = 2) is cyclically left shifted by 2 offsets
  out[16+:8]  = in[80+:8];
  out[48+:8]  = in[112+:8];
  out[80+:8]  = in[16+:8];
  out[112+:8] = in[48+:8];
  
  // Fourth row (r = 3) is cyclically left shifted by 3 offsets
  out[24+:8]  = in[56+:8];
  out[56+:8]  = in[88+:8];
  out[88+:8]  = in[120+:8];
  out[120+:8] = in[24+:8];
endfunction

function void aes_base::inverseMixColumns(bit[127:0] in, ref bit[127:0] out);
  for(int ii = 0; ii < 4; ii += 1) begin
    out[(ii*32 + 24)+:8] = mb0e(in[(ii*32 + 24)+:8]) ^ mb0b(in[(ii*32 + 16)+:8]) ^ mb0d(in[(ii*32 + 8)+:8]) ^ mb09(in[ii*32+:8]);
    out[(ii*32 + 16)+:8] = mb09(in[(ii*32 + 24)+:8]) ^ mb0e(in[(ii*32 + 16)+:8]) ^ mb0b(in[(ii*32 + 8)+:8]) ^ mb0d(in[ii*32+:8]);
    out[(ii*32 + 8) +:8] = mb0d(in[(ii*32 + 24)+:8]) ^ mb09(in[(ii*32 + 16)+:8]) ^ mb0e(in[(ii*32 + 8)+:8]) ^ mb0b(in[ii*32+:8]);
    out[ ii*32      +:8] = mb0b(in[(ii*32 + 24)+:8]) ^ mb0d(in[(ii*32 + 16)+:8]) ^ mb09(in[(ii*32 + 8)+:8]) ^ mb0e(in[ii*32+:8]);
  end
endfunction

function bit[7:0] aes_base::multiply(bit[7:0] x, int n);
  for(int ii = 0; ii < n; ii += 1) begin
    if(x[7]) x = ((x << 1) ^ 8'h1b);
    else x = x << 1;
  end
  multiply = x;
endfunction

function bit[7:0] aes_base::mb2(bit[7:0] x);
  if(x[7]) mb2 = ((x << 1) ^ 8'h1b);
  else mb2 = x << 1;
endfunction

function bit[7:0] aes_base::mb3(bit[7:0] x);
   mb3 = mb2(x) ^ x;
endfunction

function bit[7:0] aes_base::mb0e(bit[7:0] x); mb0e = multiply(x,3) ^ multiply(x,2) ^ multiply(x,1); endfunction
function bit[7:0] aes_base::mb0d(bit[7:0] x); mb0d = multiply(x,3) ^ multiply(x,2) ^ x;             endfunction
function bit[7:0] aes_base::mb0b(bit[7:0] x); mb0b = multiply(x,3) ^ multiply(x,1) ^ x;             endfunction
function bit[7:0] aes_base::mb09(bit[7:0] x); mb09 = multiply(x,3) ^ x;                             endfunction

function bit[0:31] aes_base::rconx(bit[0:3] in);
  case(in)
    4'h1:     rconx=32'h01000000;
    4'h2:     rconx=32'h02000000;
    4'h3:     rconx=32'h04000000;
    4'h4:     rconx=32'h08000000;
    4'h5:     rconx=32'h10000000;
    4'h6:     rconx=32'h20000000;
    4'h7:     rconx=32'h40000000;
    4'h8:     rconx=32'h80000000;
    4'h9:     rconx=32'h1b000000;
    4'ha:     rconx=32'h36000000;
    default:  rconx=32'h00000000;
  endcase
endfunction

function bit[0:7] aes_base::sbox(bit[0:7] C);
  case (C)
    8'h00: sbox=8'h63;
    8'h01: sbox=8'h7c;
    8'h02: sbox=8'h77;
    8'h03: sbox=8'h7b;
    8'h04: sbox=8'hf2;
    8'h05: sbox=8'h6b;
    8'h06: sbox=8'h6f;
    8'h07: sbox=8'hc5;
    8'h08: sbox=8'h30;
    8'h09: sbox=8'h01;
    8'h0a: sbox=8'h67;
    8'h0b: sbox=8'h2b;
    8'h0c: sbox=8'hfe;
    8'h0d: sbox=8'hd7;
    8'h0e: sbox=8'hab;
    8'h0f: sbox=8'h76;
    8'h10: sbox=8'hca;
    8'h11: sbox=8'h82;
    8'h12: sbox=8'hc9;
    8'h13: sbox=8'h7d;
    8'h14: sbox=8'hfa;
    8'h15: sbox=8'h59;
    8'h16: sbox=8'h47;
    8'h17: sbox=8'hf0;
    8'h18: sbox=8'had;
    8'h19: sbox=8'hd4;
    8'h1a: sbox=8'ha2;
    8'h1b: sbox=8'haf;
    8'h1c: sbox=8'h9c;
    8'h1d: sbox=8'ha4;
    8'h1e: sbox=8'h72;
    8'h1f: sbox=8'hc0;
    8'h20: sbox=8'hb7;
    8'h21: sbox=8'hfd;
    8'h22: sbox=8'h93;
    8'h23: sbox=8'h26;
    8'h24: sbox=8'h36;
    8'h25: sbox=8'h3f;
    8'h26: sbox=8'hf7;
    8'h27: sbox=8'hcc;
    8'h28: sbox=8'h34;
    8'h29: sbox=8'ha5;
    8'h2a: sbox=8'he5;
    8'h2b: sbox=8'hf1;
    8'h2c: sbox=8'h71;
    8'h2d: sbox=8'hd8;
    8'h2e: sbox=8'h31;
    8'h2f: sbox=8'h15;
    8'h30: sbox=8'h04;
    8'h31: sbox=8'hc7;
    8'h32: sbox=8'h23;
    8'h33: sbox=8'hc3;
    8'h34: sbox=8'h18;
    8'h35: sbox=8'h96;
    8'h36: sbox=8'h05;
    8'h37: sbox=8'h9a;
    8'h38: sbox=8'h07;
    8'h39: sbox=8'h12;
    8'h3a: sbox=8'h80;
    8'h3b: sbox=8'he2;
    8'h3c: sbox=8'heb;
    8'h3d: sbox=8'h27;
    8'h3e: sbox=8'hb2;
    8'h3f: sbox=8'h75;
    8'h40: sbox=8'h09;
    8'h41: sbox=8'h83;
    8'h42: sbox=8'h2c;
    8'h43: sbox=8'h1a;
    8'h44: sbox=8'h1b;
    8'h45: sbox=8'h6e;
    8'h46: sbox=8'h5a;
    8'h47: sbox=8'ha0;
    8'h48: sbox=8'h52;
    8'h49: sbox=8'h3b;
    8'h4a: sbox=8'hd6;
    8'h4b: sbox=8'hb3;
    8'h4c: sbox=8'h29;
    8'h4d: sbox=8'he3;
    8'h4e: sbox=8'h2f;
    8'h4f: sbox=8'h84;
    8'h50: sbox=8'h53;
    8'h51: sbox=8'hd1;
    8'h52: sbox=8'h00;
    8'h53: sbox=8'hed;
    8'h54: sbox=8'h20;
    8'h55: sbox=8'hfc;
    8'h56: sbox=8'hb1;
    8'h57: sbox=8'h5b;
    8'h58: sbox=8'h6a;
    8'h59: sbox=8'hcb;
    8'h5a: sbox=8'hbe;
    8'h5b: sbox=8'h39;
    8'h5c: sbox=8'h4a;
    8'h5d: sbox=8'h4c;
    8'h5e: sbox=8'h58;
    8'h5f: sbox=8'hcf;
    8'h60: sbox=8'hd0;
    8'h61: sbox=8'hef;
    8'h62: sbox=8'haa;
    8'h63: sbox=8'hfb;
    8'h64: sbox=8'h43;
    8'h65: sbox=8'h4d;
    8'h66: sbox=8'h33;
    8'h67: sbox=8'h85;
    8'h68: sbox=8'h45;
    8'h69: sbox=8'hf9;
    8'h6a: sbox=8'h02;
    8'h6b: sbox=8'h7f;
    8'h6c: sbox=8'h50;
    8'h6d: sbox=8'h3c;
    8'h6e: sbox=8'h9f;
    8'h6f: sbox=8'ha8;
    8'h70: sbox=8'h51;
    8'h71: sbox=8'ha3;
    8'h72: sbox=8'h40;
    8'h73: sbox=8'h8f;
    8'h74: sbox=8'h92;
    8'h75: sbox=8'h9d;
    8'h76: sbox=8'h38;
    8'h77: sbox=8'hf5;
    8'h78: sbox=8'hbc;
    8'h79: sbox=8'hb6;
    8'h7a: sbox=8'hda;
    8'h7b: sbox=8'h21;
    8'h7c: sbox=8'h10;
    8'h7d: sbox=8'hff;
    8'h7e: sbox=8'hf3;
    8'h7f: sbox=8'hd2;
    8'h80: sbox=8'hcd;
    8'h81: sbox=8'h0c;
    8'h82: sbox=8'h13;
    8'h83: sbox=8'hec;
    8'h84: sbox=8'h5f;
    8'h85: sbox=8'h97;
    8'h86: sbox=8'h44;
    8'h87: sbox=8'h17;
    8'h88: sbox=8'hc4;
    8'h89: sbox=8'ha7;
    8'h8a: sbox=8'h7e;
    8'h8b: sbox=8'h3d;
    8'h8c: sbox=8'h64;
    8'h8d: sbox=8'h5d;
    8'h8e: sbox=8'h19;
    8'h8f: sbox=8'h73;
    8'h90: sbox=8'h60;
    8'h91: sbox=8'h81;
    8'h92: sbox=8'h4f;
    8'h93: sbox=8'hdc;
    8'h94: sbox=8'h22;
    8'h95: sbox=8'h2a;
    8'h96: sbox=8'h90;
    8'h97: sbox=8'h88;
    8'h98: sbox=8'h46;
    8'h99: sbox=8'hee;
    8'h9a: sbox=8'hb8;
    8'h9b: sbox=8'h14;
    8'h9c: sbox=8'hde;
    8'h9d: sbox=8'h5e;
    8'h9e: sbox=8'h0b;
    8'h9f: sbox=8'hdb;
    8'ha0: sbox=8'he0;
    8'ha1: sbox=8'h32;
    8'ha2: sbox=8'h3a;
    8'ha3: sbox=8'h0a;
    8'ha4: sbox=8'h49;
    8'ha5: sbox=8'h06;
    8'ha6: sbox=8'h24;
    8'ha7: sbox=8'h5c;
    8'ha8: sbox=8'hc2;
    8'ha9: sbox=8'hd3;
    8'haa: sbox=8'hac;
    8'hab: sbox=8'h62;
    8'hac: sbox=8'h91;
    8'had: sbox=8'h95;
    8'hae: sbox=8'he4;
    8'haf: sbox=8'h79;
    8'hb0: sbox=8'he7;
    8'hb1: sbox=8'hc8;
    8'hb2: sbox=8'h37;
    8'hb3: sbox=8'h6d;
    8'hb4: sbox=8'h8d;
    8'hb5: sbox=8'hd5;
    8'hb6: sbox=8'h4e;
    8'hb7: sbox=8'ha9;
    8'hb8: sbox=8'h6c;
    8'hb9: sbox=8'h56;
    8'hba: sbox=8'hf4;
    8'hbb: sbox=8'hea;
    8'hbc: sbox=8'h65;
    8'hbd: sbox=8'h7a;
    8'hbe: sbox=8'hae;
    8'hbf: sbox=8'h08;
    8'hc0: sbox=8'hba;
    8'hc1: sbox=8'h78;
    8'hc2: sbox=8'h25;
    8'hc3: sbox=8'h2e;
    8'hc4: sbox=8'h1c;
    8'hc5: sbox=8'ha6;
    8'hc6: sbox=8'hb4;
    8'hc7: sbox=8'hc6;
    8'hc8: sbox=8'he8;
    8'hc9: sbox=8'hdd;
    8'hca: sbox=8'h74;
    8'hcb: sbox=8'h1f;
    8'hcc: sbox=8'h4b;
    8'hcd: sbox=8'hbd;
    8'hce: sbox=8'h8b;
    8'hcf: sbox=8'h8a;
    8'hd0: sbox=8'h70;
    8'hd1: sbox=8'h3e;
    8'hd2: sbox=8'hb5;
    8'hd3: sbox=8'h66;
    8'hd4: sbox=8'h48;
    8'hd5: sbox=8'h03;
    8'hd6: sbox=8'hf6;
    8'hd7: sbox=8'h0e;
    8'hd8: sbox=8'h61;
    8'hd9: sbox=8'h35;
    8'hda: sbox=8'h57;
    8'hdb: sbox=8'hb9;
    8'hdc: sbox=8'h86;
    8'hdd: sbox=8'hc1;
    8'hde: sbox=8'h1d;
    8'hdf: sbox=8'h9e;
    8'he0: sbox=8'he1;
    8'he1: sbox=8'hf8;
    8'he2: sbox=8'h98;
    8'he3: sbox=8'h11;
    8'he4: sbox=8'h69;
    8'he5: sbox=8'hd9;
    8'he6: sbox=8'h8e;
    8'he7: sbox=8'h94;
    8'he8: sbox=8'h9b;
    8'he9: sbox=8'h1e;
    8'hea: sbox=8'h87;
    8'heb: sbox=8'he9;
    8'hec: sbox=8'hce;
    8'hed: sbox=8'h55;
    8'hee: sbox=8'h28;
    8'hef: sbox=8'hdf;
    8'hf0: sbox=8'h8c;
    8'hf1: sbox=8'ha1;
    8'hf2: sbox=8'h89;
    8'hf3: sbox=8'h0d;
    8'hf4: sbox=8'hbf;
    8'hf5: sbox=8'he6;
    8'hf6: sbox=8'h42;
    8'hf7: sbox=8'h68;
    8'hf8: sbox=8'h41;
    8'hf9: sbox=8'h99;
    8'hfa: sbox=8'h2d;
    8'hfb: sbox=8'h0f;
    8'hfc: sbox=8'hb0;
    8'hfd: sbox=8'h54;
    8'hfe: sbox=8'hbb;
    8'hff: sbox=8'h16;
  endcase
endfunction

function bit[0:7] aes_base::inverseSbox(bit[0:7] C);
  case(C)
    8'h00: inverseSbox = 8'h52;
    8'h01: inverseSbox = 8'h09;
    8'h02: inverseSbox = 8'h6a;
    8'h03: inverseSbox = 8'hd5;
    8'h04: inverseSbox = 8'h30;
    8'h05: inverseSbox = 8'h36;
    8'h06: inverseSbox = 8'ha5;
    8'h07: inverseSbox = 8'h38;
    8'h08: inverseSbox = 8'hbf;
    8'h09: inverseSbox = 8'h40;
    8'h0a: inverseSbox = 8'ha3;
    8'h0b: inverseSbox = 8'h9e;
    8'h0c: inverseSbox = 8'h81;
    8'h0d: inverseSbox = 8'hf3;
    8'h0e: inverseSbox = 8'hd7;
    8'h0f: inverseSbox = 8'hfb;
    8'h10: inverseSbox = 8'h7c;
    8'h11: inverseSbox = 8'he3;
    8'h12: inverseSbox = 8'h39;
    8'h13: inverseSbox = 8'h82;
    8'h14: inverseSbox = 8'h9b;
    8'h15: inverseSbox = 8'h2f;
    8'h16: inverseSbox = 8'hff;
    8'h17: inverseSbox = 8'h87;
    8'h18: inverseSbox = 8'h34;
    8'h19: inverseSbox = 8'h8e;
    8'h1a: inverseSbox = 8'h43;
    8'h1b: inverseSbox = 8'h44;
    8'h1c: inverseSbox = 8'hc4;
    8'h1d: inverseSbox = 8'hde;
    8'h1e: inverseSbox = 8'he9;
    8'h1f: inverseSbox = 8'hcb;
    8'h20: inverseSbox = 8'h54;
    8'h21: inverseSbox = 8'h7b;
    8'h22: inverseSbox = 8'h94;
    8'h23: inverseSbox = 8'h32;
    8'h24: inverseSbox = 8'ha6;
    8'h25: inverseSbox = 8'hc2;
    8'h26: inverseSbox = 8'h23;
    8'h27: inverseSbox = 8'h3d;
    8'h28: inverseSbox = 8'hee;
    8'h29: inverseSbox = 8'h4c;
    8'h2a: inverseSbox = 8'h95;
    8'h2b: inverseSbox = 8'h0b;
    8'h2c: inverseSbox = 8'h42;
    8'h2d: inverseSbox = 8'hfa;
    8'h2e: inverseSbox = 8'hc3;
    8'h2f: inverseSbox = 8'h4e;
    8'h30: inverseSbox = 8'h08;
    8'h31: inverseSbox = 8'h2e;
    8'h32: inverseSbox = 8'ha1;
    8'h33: inverseSbox = 8'h66;
    8'h34: inverseSbox = 8'h28;
    8'h35: inverseSbox = 8'hd9;
    8'h36: inverseSbox = 8'h24;
    8'h37: inverseSbox = 8'hb2;
    8'h38: inverseSbox = 8'h76;
    8'h39: inverseSbox = 8'h5b;
    8'h3a: inverseSbox = 8'ha2;
    8'h3b: inverseSbox = 8'h49;
    8'h3c: inverseSbox = 8'h6d;
    8'h3d: inverseSbox = 8'h8b;
    8'h3e: inverseSbox = 8'hd1;
    8'h3f: inverseSbox = 8'h25;
    8'h40: inverseSbox = 8'h72;
    8'h41: inverseSbox = 8'hf8;
    8'h42: inverseSbox = 8'hf6;
    8'h43: inverseSbox = 8'h64;
    8'h44: inverseSbox = 8'h86;
    8'h45: inverseSbox = 8'h68;
    8'h46: inverseSbox = 8'h98;
    8'h47: inverseSbox = 8'h16;
    8'h48: inverseSbox = 8'hd4;
    8'h49: inverseSbox = 8'ha4;
    8'h4a: inverseSbox = 8'h5c;
    8'h4b: inverseSbox = 8'hcc;
    8'h4c: inverseSbox = 8'h5d;
    8'h4d: inverseSbox = 8'h65;
    8'h4e: inverseSbox = 8'hb6;
    8'h4f: inverseSbox = 8'h92;
    8'h50: inverseSbox = 8'h6c;
    8'h51: inverseSbox = 8'h70;
    8'h52: inverseSbox = 8'h48;
    8'h53: inverseSbox = 8'h50;
    8'h54: inverseSbox = 8'hfd;
    8'h55: inverseSbox = 8'hed;
    8'h56: inverseSbox = 8'hb9;
    8'h57: inverseSbox = 8'hda;
    8'h58: inverseSbox = 8'h5e;
    8'h59: inverseSbox = 8'h15;
    8'h5a: inverseSbox = 8'h46;
    8'h5b: inverseSbox = 8'h57;
    8'h5c: inverseSbox = 8'ha7;
    8'h5d: inverseSbox = 8'h8d;
    8'h5e: inverseSbox = 8'h9d;
    8'h5f: inverseSbox = 8'h84;
    8'h60: inverseSbox = 8'h90;
    8'h61: inverseSbox = 8'hd8;
    8'h62: inverseSbox = 8'hab;
    8'h63: inverseSbox = 8'h00;
    8'h64: inverseSbox = 8'h8c;
    8'h65: inverseSbox = 8'hbc;
    8'h66: inverseSbox = 8'hd3;
    8'h67: inverseSbox = 8'h0a;
    8'h68: inverseSbox = 8'hf7;
    8'h69: inverseSbox = 8'he4;
    8'h6a: inverseSbox = 8'h58;
    8'h6b: inverseSbox = 8'h05;
    8'h6c: inverseSbox = 8'hb8;
    8'h6d: inverseSbox = 8'hb3;
    8'h6e: inverseSbox = 8'h45;
    8'h6f: inverseSbox = 8'h06;
    8'h70: inverseSbox = 8'hd0;
    8'h71: inverseSbox = 8'h2c;
    8'h72: inverseSbox = 8'h1e;
    8'h73: inverseSbox = 8'h8f;
    8'h74: inverseSbox = 8'hca;
    8'h75: inverseSbox = 8'h3f;
    8'h76: inverseSbox = 8'h0f;
    8'h77: inverseSbox = 8'h02;
    8'h78: inverseSbox = 8'hc1;
    8'h79: inverseSbox = 8'haf;
    8'h7a: inverseSbox = 8'hbd;
    8'h7b: inverseSbox = 8'h03;
    8'h7c: inverseSbox = 8'h01;
    8'h7d: inverseSbox = 8'h13;
    8'h7e: inverseSbox = 8'h8a;
    8'h7f: inverseSbox = 8'h6b;
    8'h80: inverseSbox = 8'h3a;
    8'h81: inverseSbox = 8'h91;
    8'h82: inverseSbox = 8'h11;
    8'h83: inverseSbox = 8'h41;
    8'h84: inverseSbox = 8'h4f;
    8'h85: inverseSbox = 8'h67;
    8'h86: inverseSbox = 8'hdc;
    8'h87: inverseSbox = 8'hea;
    8'h88: inverseSbox = 8'h97;
    8'h89: inverseSbox = 8'hf2;
    8'h8a: inverseSbox = 8'hcf;
    8'h8b: inverseSbox = 8'hce;
    8'h8c: inverseSbox = 8'hf0;
    8'h8d: inverseSbox = 8'hb4;
    8'h8e: inverseSbox = 8'he6;
    8'h8f: inverseSbox = 8'h73;
    8'h90: inverseSbox = 8'h96;
    8'h91: inverseSbox = 8'hac;
    8'h92: inverseSbox = 8'h74;
    8'h93: inverseSbox = 8'h22;
    8'h94: inverseSbox = 8'he7;
    8'h95: inverseSbox = 8'had;
    8'h96: inverseSbox = 8'h35;
    8'h97: inverseSbox = 8'h85;
    8'h98: inverseSbox = 8'he2;
    8'h99: inverseSbox = 8'hf9;
    8'h9a: inverseSbox = 8'h37;
    8'h9b: inverseSbox = 8'he8;
    8'h9c: inverseSbox = 8'h1c;
    8'h9d: inverseSbox = 8'h75;
    8'h9e: inverseSbox = 8'hdf;
    8'h9f: inverseSbox = 8'h6e;
    8'ha0: inverseSbox = 8'h47;
    8'ha1: inverseSbox = 8'hf1;
    8'ha2: inverseSbox = 8'h1a;
    8'ha3: inverseSbox = 8'h71;
    8'ha4: inverseSbox = 8'h1d;
    8'ha5: inverseSbox = 8'h29;
    8'ha6: inverseSbox = 8'hc5;
    8'ha7: inverseSbox = 8'h89;
    8'ha8: inverseSbox = 8'h6f;
    8'ha9: inverseSbox = 8'hb7;
    8'haa: inverseSbox = 8'h62;
    8'hab: inverseSbox = 8'h0e;
    8'hac: inverseSbox = 8'haa;
    8'had: inverseSbox = 8'h18;
    8'hae: inverseSbox = 8'hbe;
    8'haf: inverseSbox = 8'h1b;
    8'hb0: inverseSbox = 8'hfc;
    8'hb1: inverseSbox = 8'h56;
    8'hb2: inverseSbox = 8'h3e;
    8'hb3: inverseSbox = 8'h4b;
    8'hb4: inverseSbox = 8'hc6;
    8'hb5: inverseSbox = 8'hd2;
    8'hb6: inverseSbox = 8'h79;
    8'hb7: inverseSbox = 8'h20;
    8'hb8: inverseSbox = 8'h9a;
    8'hb9: inverseSbox = 8'hdb;
    8'hba: inverseSbox = 8'hc0;
    8'hbb: inverseSbox = 8'hfe;
    8'hbc: inverseSbox = 8'h78;
    8'hbd: inverseSbox = 8'hcd;
    8'hbe: inverseSbox = 8'h5a;
    8'hbf: inverseSbox = 8'hf4;
    8'hc0: inverseSbox = 8'h1f;
    8'hc1: inverseSbox = 8'hdd;
    8'hc2: inverseSbox = 8'ha8;
    8'hc3: inverseSbox = 8'h33;
    8'hc4: inverseSbox = 8'h88;
    8'hc5: inverseSbox = 8'h07;
    8'hc6: inverseSbox = 8'hc7;
    8'hc7: inverseSbox = 8'h31;
    8'hc8: inverseSbox = 8'hb1;
    8'hc9: inverseSbox = 8'h12;
    8'hca: inverseSbox = 8'h10;
    8'hcb: inverseSbox = 8'h59;
    8'hcc: inverseSbox = 8'h27;
    8'hcd: inverseSbox = 8'h80;
    8'hce: inverseSbox = 8'hec;
    8'hcf: inverseSbox = 8'h5f;
    8'hd0: inverseSbox = 8'h60;
    8'hd1: inverseSbox = 8'h51;
    8'hd2: inverseSbox = 8'h7f;
    8'hd3: inverseSbox = 8'ha9;
    8'hd4: inverseSbox = 8'h19;
    8'hd5: inverseSbox = 8'hb5;
    8'hd6: inverseSbox = 8'h4a;
    8'hd7: inverseSbox = 8'h0d;
    8'hd8: inverseSbox = 8'h2d;
    8'hd9: inverseSbox = 8'he5;
    8'hda: inverseSbox = 8'h7a;
    8'hdb: inverseSbox = 8'h9f;
    8'hdc: inverseSbox = 8'h93;
    8'hdd: inverseSbox = 8'hc9;
    8'hde: inverseSbox = 8'h9c;
    8'hdf: inverseSbox = 8'hef;
    8'he0: inverseSbox = 8'ha0;
    8'he1: inverseSbox = 8'he0;
    8'he2: inverseSbox = 8'h3b;
    8'he3: inverseSbox = 8'h4d;
    8'he4: inverseSbox = 8'hae;
    8'he5: inverseSbox = 8'h2a;
    8'he6: inverseSbox = 8'hf5;
    8'he7: inverseSbox = 8'hb0;
    8'he8: inverseSbox = 8'hc8;
    8'he9: inverseSbox = 8'heb;
    8'hea: inverseSbox = 8'hbb;
    8'heb: inverseSbox = 8'h3c;
    8'hec: inverseSbox = 8'h83;
    8'hed: inverseSbox = 8'h53;
    8'hee: inverseSbox = 8'h99;
    8'hef: inverseSbox = 8'h61;
    8'hf0: inverseSbox = 8'h17;
    8'hf1: inverseSbox = 8'h2b;
    8'hf2: inverseSbox = 8'h04;
    8'hf3: inverseSbox = 8'h7e;
    8'hf4: inverseSbox = 8'hba;
    8'hf5: inverseSbox = 8'h77;
    8'hf6: inverseSbox = 8'hd6;
    8'hf7: inverseSbox = 8'h26;
    8'hf8: inverseSbox = 8'he1;
    8'hf9: inverseSbox = 8'h69;
    8'hfa: inverseSbox = 8'h14;
    8'hfb: inverseSbox = 8'h63;
    8'hfc: inverseSbox = 8'h55;
    8'hfd: inverseSbox = 8'h21;
    8'hfe: inverseSbox = 8'h0c;
    8'hff: inverseSbox = 8'h7d;
  endcase
endfunction

function bit[0:1919] aes_base::keyExpansion( bit[0:255] key );
  // w represents the array that will store all the generated keys of all rounds.
  /* [(128 * (nr + 1)) - 1] this formula is meant to calculate the length of W ; so that it can store all the
  generated keys of all rounds.*/ 
  bit[0:1919] w; // Word array for the key schedule
  bit[0:  31] temp;
  bit[0:  31] r;
  bit[0:  31] rot; // It stores the returned value from the function rotword().
  bit[0:  31] x;  //It stores the returned value from the function subwordx().
  bit[0:  31] rconv; //It stores the returned value from the function rconx().
  bit[0:  31] new;

  //The first [(nk*32)-1 ]-bit key is stored in W.
  w = key;    

  for(int i = nk; i < 4*(nr + 1); i = i + 1) begin
    temp = w[(128 * (nr + 1) - 32) +: 32];
    if(i % nk == 0) begin
      rot = rotword(temp); // A call to the function rotword() is done and the returned value is stored in rot.
      x = subwordx (rot);  //A call to the function subwordx() is done and the returned value is stored in x.
      rconv = rconx (i/nk); //A call to the function rconx() is done and the returned value is stored in rconv.
      temp = x ^ rconv;   
    end
    else if(nk >6 && i % nk == 4) begin
      temp = subwordx(temp);
    end
    new = (w[(128*(nr+1)-(nk*32))+:32] ^ temp);
    // We would shift W by 32 bit to the left to add the new generated key word (new) at its end.
    w = w << 32;
    w = {w[0 : (128 * (nr + 1) - 32) - 1], new};
  end
  keyExpansion = w;
endfunction

`endif // AES_BASE_SV