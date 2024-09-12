`ifndef AES_SV
`define AES_SV
class aes;

  string      name;
  aes_base    ab;
  AES_Encrypt ae;
  AES_Decrypt ad;
  int         aes_mode; // 3 : AES-256, 2 : AES-196, 1 : AES-128

  function new(string name = "aes");
    this.name = name;
  endfunction

  extern function void init_aes(int mode);
endclass

function void aes::init_aes(int mode);
  aes_mode = mode;
  ab       = new("aes_base");
  ae       = new("aes_encrypt");
  ad       = new("aes_decrypt");
  ae.init_aes(mode);  // Encryption
  ad.init_aes(mode);  // Decryption
endfunction
`endif // AES_SV