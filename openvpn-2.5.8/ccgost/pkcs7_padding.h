//
//  pkcs7_padding.h
//  
//
//  Created by Admin on 24/05/2023.
//

#ifndef pkcs7_padding_h
#define pkcs7_padding_h
typedef unsigned char u8;
typedef unsigned int word32;

#include <stdio.h>
 
int pkcs7_padding_pad_buffer( u8 *buffer,  size_t data_length, size_t buffer_size, u8 modulus );
int pkcs7_padding_valid( u8 *buffer, size_t data_length, size_t buffer_size, u8 modulus );
size_t pkcs7_padding_data_length( u8 * buffer, size_t buffer_size, u8 modulus );
 
#endif
