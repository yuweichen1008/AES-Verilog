`ifndef AES_DECRYPT_SV
`define AES_DECRYPT_SV
class AES_Decrypt #(parameter N=256,parameter Nr=14,parameter Nk=8) extends aes_base;

  string                 name;
  bit [(128*(Nr+1))-1:0] fullkeys;
  bit [127:0]            states [Nr+1:0] ;
  bit [127:0]            afterSubBytes;
  bit [127:0]            afterShiftRows;

  function new(string name="aes_decrypt");
    this.name = name;
    this.nk   = Nk;
    this.nr   = Nr;
  endfunction

  extern function void decrypt(bit[N-1 : 0] key, bit[127 : 0] in, bit[127 : 0] out);
  extern function decryptRound(bit[127:0] in, bit[127:0] key, ref bit[127:0] out);

endclass

function void AES_Decrypt::decrypt(bit[N-1 : 0] key, bit[127 : 0] in, bit[127 : 0] out);
  fullkeys = keyExpansion(key);

  for(int ii=1; ii<Nr ;ii=ii+1)begin
    decryptRound(states[ii-1],fullkeys[ii*128+:128],states[ii]);
  end
  inverseShiftRows(states[Nr-1],afterShiftRows);
  inverseSubBytes(afterShiftRows,afterSubBytes);
  addRoundKey(afterSubBytes,fullkeys[((128*(Nr+1))-1)-:128],states[Nr]);
endfunction

function AES_Decrypt::decryptRound(bit[127:0] in, bit[127:0] key, ref bit[127:0] out);
  bit [127:0] afterSubBytes;
  bit [127:0] afterShiftRows;
  bit [127:0] afterMixColumns;
  bit [127:0] afterAddroundKey;

  inverseShiftRows(in,afterShiftRows);
  inverseSubBytes(afterShiftRows,afterSubBytes);
  addRoundKey(afterSubBytes,key,afterAddroundKey);
  inverseMixColumns(afterAddroundKey,out);

endfunction
`endif // AES_DECRYPT_SV