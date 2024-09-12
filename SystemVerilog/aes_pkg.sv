`ifndef AES_PKG_SV
`define AES_PKG_SV
package aes_pkg;
    `include "aes_define.sv"

    `include "aes_base.sv"
    `include "aes_encrypt.sv"
    `include "aes_decrypt.sv"

    `include "aes.sv"
endpackage
`endif // AES_PKG_SV