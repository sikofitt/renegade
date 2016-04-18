#include <stdio.h>
#include <libscrypt.h>

#ifdef SCRYPT_SAFE_N
#undef SCRYPT_SAFE_N
#define SCRYPT_SAFE_N 16
#endif
#define SCRYPT_PASSWORD_LEN 60

int main() {

  char hash[SCRYPT_MCF_LEN], password[SCRYPT_PASSWORD_LEN];
  int returnCode;
  
  printf("\nEnter a password : ");
  scanf("%s", password);
  
  if( libscrypt_hash(hash, password, SCRYPT_N, SCRYPT_r, SCRYPT_p) > 0 ) {
    printf("%s", hash);
  } else {
    printf("We were not able to create the hash.");
  }

  return returnCode;
}
