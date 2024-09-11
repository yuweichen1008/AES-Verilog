`ifndef AES_ENCRYPT_SV
`define AES_ENCRYPT_SV
class AES_Encrypt #(parameter N=256,parameter Nr=14,parameter Nk=8) extends aes_base;

  string       name;
  bit [0:1919] fullkeys;
  bit [127:0]  states [Nr+1:0] ;
  bit [127:0]  afterSubBytes;
  bit [127:0]  afterShiftRows;

  function new(string name="aes_encrypt");
    this.name = name;
  endfunction

  extern function void encrypt(bit[N-1 : 0] key, bit[DWIDTH-1 : 0] in, bit[DWIDTH-1 : 0] out);
  extern function encryptRound(bit[127:0] in, bit[127:0] key, ref bit[127:0] out);

endclass

function void AES_Encrypt::encrypt(bit[N-1 : 0] key, bit[DWIDTH-1 : 0] in, bit[DWIDTH-1 : 0] out);
  fullkeys = keyExpansion(key);
  addRoundKey(in,fullkeys[((N*(Nr+1))-1)-:N],states[0]); // bit[127:0] data, bit[127:0] key, ref bit[127:0] out
  for(int i=1; i<Nr ;i=i+1) begin
    encryptRound(states[i-1],fullkeys[(((N*(Nr+1))-1)-N*i)-:N],states[i]);
  end
  subBytes(states[Nr-1],afterSubBytes);
  shiftRows(afterSubBytes,afterShiftRows);
  addRoundKey(afterShiftRows,fullkeys[N-1:0],states[Nr]);
endfunction

function AES_Encrypt::encryptRound(bit[127:0] in, bit[127:0] key, ref bit[127:0] out);
  bit[127:0] afterSubBytes;
  bit[127:0] afterShiftRows;
  bit[127:0] afterMixColumns;
  bit[127:0] afterAddroundKey;

  subBytes(in,afterSubBytes);
  shiftRows(afterSubBytes,afterShiftRows);
  mixColumns(afterShiftRows,afterMixColumns);
  addRoundKey(afterMixColumns,key,out);
		
endfunction

`endif // AES_ENCRYPT_SV