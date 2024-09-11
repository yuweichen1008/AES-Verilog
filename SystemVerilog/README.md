# Advanced encryption standard (AES128, AES192, AES256) in SystemVerilog
<!-- ![aes from Kekayan, Medium](https://user-images.githubusercontent.com/29122581/169694136-ca48f098-d5f5-448f-8016-4cb9a9b0e300.png)
<div align="center">
  
  ![GitHub stars](https://img.shields.io/github/stars/michaelehab/AES-Verilog?style=plastic)
  ![GitHub forks](https://img.shields.io/github/forks/michaelehab/AES-Verilog?style=plastic)
  ![GitHub repo size](https://img.shields.io/github/repo-size/michaelehab/AES-Verilog?style=plastic)
  ![GitHub top language](https://img.shields.io/github/languages/top/michaelehab/AES-Verilog?style=plastic)
  
</div> -->
# Purpose

This directory migrating AES verilog code. Benefit for those who would like to integrate AES algorithm into UVM testbench or even higher level implementation on either ASIC design or design verification purpose

# Methodology

Since AES encryption and decryption are sharing some fundamental functions such as "Sbox" and "KeyExpension"
All of the basic feature should be found under `aes_base.sv` file for further operation toward AES process
Both `aes_encrypt.sv` and `aes_decrypt.sv` extends from `aes_base.sv`

Note: This is not a IEEE SVUVM class/component
Note: Default AES change from AES-128 to AES-256 for improvement

# File structure

AES files are wrapped with `aes_pkg.sv` package file, contains all files required in order.


# Contribution

Based on well established AES algorithm writing by @Michael Ehab and @Ibraam-Nashaat
Just a miner improvement on this repo whatsoever.

# Explanation:
The Advanced Encryption Standard (AES) specifies a FIPS-approved
cryptographic algorithm that can be used to protect electronic data. The AES algorithm is a
symmetric block cipher that can encrypt (encipher) and decrypt (decipher) information.
Encryption converts data to an unintelligible form called ciphertext; decrypting the ciphertext
converts the data back into its original form, called plaintext.
The AES algorithm is capable of using cryptographic keys of 128, 192, and 256 bits to encrypt
and decrypt data in blocks of 128 bits


# Usage

**🔐Encryption: (AES_Encrypt module)**
```SystemVerilog

```

**🔓Decryption: (AES_Decrypt module)**
```SystemVerilog
```

**Testing: (AES wrapper module)**
```SystemVerilog

```

# Verification Phase
