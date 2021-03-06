// Check that COFF section names are properly encoded.
//
// Encodings for different lengths:
//   [0, 8]:               raw name
//   (8, 999999]:          base 10 string table index (/9999999)
//
// RUN: llvm-mc -triple x86_64-pc-win32 -filetype=obj %s | llvm-readobj -s | FileCheck %s

// Raw encoding

// CHECK:   Section {
// CHECK:     Number: 1
// CHECK:     Name: s (73 00 00 00 00 00 00 00)
// CHECK:   }
// CHECK:   Section {
// CHECK:     Number: 2
// CHECK:     Name: s1234567 (73 31 32 33 34 35 36 37)
// CHECK:   }
.section s;        .long 1
.section s1234567; .long 1


// Base 10 encoding

// /4
// CHECK:   Section {
// CHECK:     Number: 3
// CHECK:     Name: s12345678 (2F 34 00 00 00 00 00 00)
// CHECK:   }
.section s12345678; .long 1


// Generate padding sections to increase the string table size to at least
// 1,000,000 bytes.
.macro pad_sections2 pad
  // 10x \pad
  .section p0\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad; .long 1
  .section p1\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad; .long 1
  .section p2\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad; .long 1
  .section p3\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad; .long 1
  .section p4\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad; .long 1
.endm

.macro pad_sections pad
  // 20x \pad
  pad_sections2 \pad\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad\pad
.endm

// 1000x 'a'
pad_sections aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa


// /1000029 == 4 + 10 + (5 * (2 + (20 * 10 * 1000) + 1))
//             v   |     |    v    ~~~~~~~~~~~~~~    v
//    table size   v     v   "p0"        pad         NUL separator
//     "s12345678\0"     # of pad sections
//
// CHECK:   Section {
// CHECK:     Number: 9
// CHECK:     Name: seven_digit (2F 31 30 30 30 30 32 39)
// CHECK:   }
.section seven_digit; .long 1
