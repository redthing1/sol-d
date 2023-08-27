import core.stdc.stdio;
import core.stdc.string;
import core.stdc.stdlib;

import std.algorithm : map;
import std.conv : to;
import std.array : array;

import sol;

int main(string[] args) {
    int argc = cast(int) args.length;
    char** argv = args.map!(a => a.to!(char[]).ptr).array.ptr;

    if (argc != 3) {
        printf("Usage: %s <input> <key>\n", argv[0]);
        return 1;
    }
    // read input string from arg 0
    char* input = argv[1];

    enum size_t INPUT_MAX = 1024;
    if (strlen(input) > INPUT_MAX) {
        printf("input string too long!\n");
        return 1;
    }

    // read key from arg 1
    char* key_st = argv[2];
    // sha256 hash the key
    ubyte[sol_crypto_hash_BYTES] key;
    sol_crypto_hash(cast(ubyte*) key, cast(ubyte*) key_st, strlen(key_st));

    // generate a random nonce
    ubyte[sol_crypto_secretbox_NONCEBYTES] nonce;
    sol_randombytes(cast(void*) nonce, sol_crypto_secretbox_NONCEBYTES);

    // create a buffer for the plaintext
    ubyte[sol_crypto_secretbox_ZEROBYTES + INPUT_MAX] plaintext;
    // copy the input into the plaintext buffer
    memset(cast(void*) plaintext, 0, sol_crypto_secretbox_ZEROBYTES);
    memcpy(cast(void*) plaintext + sol_crypto_secretbox_ZEROBYTES, input, INPUT_MAX);

    // create a buffer for the ciphertext
    ubyte[sol_crypto_secretbox_ZEROBYTES + INPUT_MAX] ciphertext;
    // encrypt the plaintext
    sol_crypto_secretbox(cast(ubyte*) ciphertext, cast(ubyte*) plaintext, sol_crypto_secretbox_ZEROBYTES + INPUT_MAX, cast(
            ubyte*) nonce, cast(ubyte*) key);

    // print the parameters
    printf("key: ");
    for (size_t i = 0; i < sol_crypto_hash_sha256_BYTES; i++) {
        printf("%02x", key[i]);
    }
    printf("\n");
    printf("nonce: ");
    for (size_t i = 0; i < sol_crypto_secretbox_NONCEBYTES; i++) {
        printf("%02x", nonce[i]);
    }
    printf("\n");

    // print the original plaintext
    printf("plaintext: ");
    for (size_t i = sol_crypto_secretbox_ZEROBYTES; i < sol_crypto_secretbox_ZEROBYTES + strlen(
            input); i++) {
        printf("%02x", plaintext[i]);
    }
    printf("\n");

    printf("ciphertext: ");
    for (size_t i = sol_crypto_secretbox_ZEROBYTES; i < sol_crypto_secretbox_ZEROBYTES + strlen(
            input); i++) {
        printf("%02x", ciphertext[i]);
    }
    printf("\n");

    // now try to decrypt the ciphertext
    ubyte[sol_crypto_secretbox_ZEROBYTES + INPUT_MAX] decrypted;
    int secretbox_open_ret = sol_crypto_secretbox_open(
        cast(ubyte*) decrypted, cast(ubyte*) ciphertext, sol_crypto_secretbox_ZEROBYTES + INPUT_MAX, cast(
            ubyte*) nonce, cast(ubyte*) key);
    if (secretbox_open_ret != 0) {
        printf("decryption failed!\n");
        return 1;
    }

    // print the decrypted plaintext
    printf("plaintext: ");
    for (size_t i = sol_crypto_secretbox_ZEROBYTES; i < sol_crypto_secretbox_ZEROBYTES + strlen(
            input); i++) {
        printf("%02x", decrypted[i]);
    }
    printf("\n");

    // verify that the decrypted plaintext matches the original plaintext
    if (memcmp(cast(void*) plaintext, cast(void*) decrypted, sol_crypto_secretbox_ZEROBYTES + INPUT_MAX) != 0) {
        printf("decrypted plaintext does not match original plaintext!\n");
        return 1;
    }

    printf("decryption succeeded!\n");

    return 0;
}
