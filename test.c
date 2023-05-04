

#ifdef _MSC_VER
# pragma warning(push, 3)
# include <openssl/applink.c>
# pragma warning(pop)
#endif
#include <openssl/engine.h> 
#include <openssl/evp.h>
#include <openssl/rand.h>
#include <openssl/err.h>
#include <openssl/asn1.h>
#include <string.h>

#if defined _MSC_VER
# include <malloc.h>
# define alloca _alloca
#elif defined __linux__
# include <alloca.h>
#endif
#include <stdlib.h>

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <openssl/evp.h>
#include <openssl/aes.h>

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif


void ENGINE_load_gost(void);
static ENGINE *engine_gost(void);

static const unsigned char Em_cbc[] = {
    /* 28147-89 CBC test vector generated from canonical implementation */
    0x96,0xd1,0xb0,0x5e,0xea,0x68,0x39,0x19,0xf3,0x96,0xb7,0x8c,0x1d,0x47,0xbb,0x61,
    0x61,0x83,0xe2,0xcc,0xa9,0x76,0xa4,0xba,0xbe,0x9c,0xe8,0x7d,0x6f,0xa7,0x3c,0xf2,
};


#define T(e) \
    if (!(e)) { \
	ERR_print_errors_fp(stderr); \
	OpenSSLDie(__FILE__, __LINE__, #e); \
    }

int engine_is_available(const char *name)
{
    ENGINE *e = ENGINE_get_first();
    int result = 0;
    while (e != NULL) {
        printf("-> load engine %s \n", ENGINE_get_id(e));
        if (strcmp(ENGINE_get_id(e), name) == 0){
            printf("load %s success\n", name); 
            result =  1;
        } 
        e = ENGINE_get_next(e);
    }
     printf("-> load engine exit \n");
    ENGINE_free(e);
    return result;
}


/**
 * Encrypt or decrypt, depending on flag 'should_encrypt'
 */
void en_de_crypt(int should_encrypt, FILE *ifp, FILE *ofp, unsigned char *ckey, unsigned char *ivec) {

    const unsigned BUFSIZE=4096;
    unsigned char *read_buf = malloc(BUFSIZE);
    unsigned char *cipher_buf;
    unsigned blocksize;
    int out_len;
    EVP_CIPHER_CTX ctx;

    const EVP_CIPHER* cipher = EVP_get_cipherbyname("gost89");

    EVP_CipherInit(&ctx, cipher, ckey, ivec, should_encrypt);
    blocksize = EVP_CIPHER_CTX_block_size(&ctx);
    cipher_buf = malloc(BUFSIZE + blocksize);

    while (1) {

        // Read in data in blocks until EOF. Update the ciphering with each read.

        int numRead = fread(read_buf, sizeof(unsigned char), BUFSIZE, ifp);
        EVP_CipherUpdate(&ctx, cipher_buf, &out_len, read_buf, numRead);
        fwrite(cipher_buf, sizeof(unsigned char), out_len, ofp);
        if (numRead < BUFSIZE) { // EOF
            break;
        }
    }

    // Now cipher the final block and write it out.

    EVP_CipherFinal(&ctx, cipher_buf, &out_len);
    fwrite(cipher_buf, sizeof(unsigned char), out_len, ofp);

    // Free memory

    free(cipher_buf);
    free(read_buf);
}
int test_gost() {
     ENGINE *eng;
    eng = ENGINE_by_id("gost");
    ENGINE_init(eng);

    ENGINE_CIPHERS_PTR fn_c; 
    fn_c = ENGINE_get_ciphers(eng);

    EVP_CIPHER * ciph2 = (EVP_CIPHER *)EVP_get_cipherbyname("gost89");

     const int *nids;
        int n, k;
        n = fn_c(eng, NULL, &nids, 0);
        for (k = 0; k < n; ++k)
        {
            EVP_CIPHER *ciph = ENGINE_get_cipher(eng, nids[k]);

             printf( "Cipher: %s \"\n", EVP_CIPHER_name(ciph));

        }
    printf( "Cipher22: %s \"\n", EVP_CIPHER_name(ciph2));

    const EVP_CIPHER* cipher = EVP_get_cipherbyname("gost89");

    if (cipher == NULL) {
         printf( "Cipher22: cipher gost error \n");
        return 0;
    }
    printf( "Cipher22: cipher gost success \n");
    return 0;
}

int main(int argc, char *argv[]) {
    ENGINE_load_gost();
/*
  if (!test_gost()) {
        return 0;
    }
*/

  
    unsigned char ckey[] = "thiskeyisverybad";
    unsigned char ivec[] = "dontusethisinput";
    FILE *fIN, *fOUT;
 

    // First encrypt the file

    fIN = fopen("plaint", "rb"); //File to be encrypted; plain text
    fOUT = fopen("cyphertext.txt", "wb"); //File to be written; cipher text

    en_de_crypt(TRUE, fIN, fOUT, ckey, ivec);

    fclose(fIN);
    fclose(fOUT);

    //Decrypt file now

    fIN = fopen("cyphertext.txt", "rb"); //File to be read; cipher text
    fOUT = fopen("decrypted.txt", "wb"); //File to be written; cipher text

    en_de_crypt(FALSE, fIN, fOUT, ckey, ivec);

    fclose(fIN);
    fclose(fOUT);

    return 0;
}
/*
int main() {
  ENGINE_load_gost();
 if (engine_is_available("gost")) {
  printf("contain gost 22\n");
 } else {
   printf("faield gost 22 \n");
 }

 EVP_aes_256_cbc();
  return 1;
}
*/