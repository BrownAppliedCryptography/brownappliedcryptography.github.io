---
title: Auth
name: auth
due: January 1 
---

Theme Song: [Who Am I?](https://www.youtube.com/watch?v=KPoCMd2DYJo)

In this assignment, you'll extend the secure communication protocol from last class to build a secure server-client authentication system. In particular, you'll explore the ways in which we can use digital signatures to expand our circle of trust and be sure that nobody is pretending to be someone they're not.

---

# Background Knowledge

In this assignment, you'll build a secure authentication platform. There are two programs involved; a server and a client. The server acts as a central verification authority that clients will interact with to obtain certificates. The server has its own globally-recognized public key, and signs the certificates of clients who properly log in. The clients will then use these certificates to communicate with each other, protected against impersonation attacks. In order to verify with the server, each client must provide a password and a valid 2fa response.

## Digital Signatures

You've interacted with digital signatures briefly in the first (warm-up) assignment, but we will go over the concept again here. Digital signatures are essentially the public-key equivalent to MACs. First, generate a keypair consisting of a public verification key $vk$ and a secret signing key $sk$, then use $sk$ to sign various messages $\sigma_i = Sign(m_i)$. When another party is given a message and signature, they can use $vk$ to verify that the message was signed correctly $Verify(\sigma_i, m_i) ?= true$. We want it to be the case that it is hard to forge signatures; that is, given $vk$ but not $sk$, finding valid signatures for any message, even when given valid signatures for other messages, is hard. 

Combining encryption with digital signatures, we achieve **authenticated encryption**, which is essentially the gold standard of communication. We know exactly who we are talking to and nobody else can read what we send.

## Password Authentication

You probably authenticate by password every day. Password authentication relies on both a server and a user knowing some shared secret $pw$, and the user proves that they know this secret by sending $pw$ (or some altered version of it) to the server. With the cryptographic primitives we've explored thus far in mind, there are a number of naive ways that one might implement password authentication. With encryption, one might encrypt the password and send it to the server, who will then decrypt it and store the password in a database for verification. While encryption makes this protocol safe from eavesdropping attacks, storing the password doesn't protect against cases where the server or database are compromised, leaking information to an attacker. Even if we stored a hash of the password, adversaries that have access to the database can mount an offline brute-force search attack or consult a [rainbow table](https://en.wikipedia.org/wiki/Rainbow_table) to crack the passwords We want to be careful to protect against a variety of attacks against all parts of our system.

We propose a heavily redunant but secure password authentication scheme so that you get a sense of the techniques you may see out in the wild. First, we assume we have access to a hash function $H$; to prevent offline brute-force attacks we could choose a slow (i.e. compute- or memory-intensive) hash function, but we'll any hash function for now. On registration, the server generates and sends a random **salt** to the user. A salt is a random string appended to a password before hashing it to prevent brute-force attacks. The user sends the hash of their password with the salt appended $h := H(pw || salt)$ to the server, which then computes a random short (say, 8-bit) **pepper** and hashes the user's message with the pepper appended yet again, $h' := H(h || pepper)$. Finally, the server stores the salt, but not the pepper. On verification, the server sends the stored salt to the user, who then sends the hash of their password. Then, the server tries all $2^8$ possible pepper values and verifies the user if any one of them succeeds. You will explore why this protocol was designed this way in the written portion of this assignment.

## Pseudorandom Functions and 2FA

Random numbers are convenient because they introduce a level of unpredictability to systems which can be very useful for keeping secret values secret (e.g. ElGamal encryption uses random values to ensure that even two ciphertexts of the same message are distinct). However, sometimes you want both you and your partner to experience the same randomness, or you may want to cheaply generate more randomness from some base *seed* of randomness. Pseudorandom functions (PRFs) are deterministic but unpredictable functions that take some value and output a pseudorandom value. We want that the distribution of PRF outputs are indistinguishable from that of a truly random function.

PRFs are useful in many ways. For one, they allow you to securely generate an infinite amount of seemingly random values deterministically for use in other cryptographic protocols. In this assignment, we'll use a PRF to implement two-factor authentication by using PRF outputs as a way of proving that we know the value of given a shared seed $s$. We can generate a short-lived login token by inputting this seed alongside the current time. The server can then validate that our values are correct by running the same function. 

## Putting it all together

The following diagram explains how the protocol works together.

![Architecture]()

In short, we proceed in the following steps: login or registration, then communication.

### Registration

- On setup, the server has access to a DSA keypair $vk_s, sk_s$.
- On registration, the user initiates a connection with the server and sends their DH public value $g^a$.
- The server will respond with both DH public values $(g^a, g^b)$ and a signature on both values, $\sigma_s = Sign(g^a, g^b, sk_s)$.
- Next, the user will send their $id_i$ to the server.
- The server will generate a random 128-bit $salt_i$ for this user and send it to the user.
- The user will use the salt to generate $h_i := H(password || salt_i)$ and send $h$ to the server.
- The server then generates a random 8-bit $pepper_i$ and generates $h_i' = H(h_i' || pepper_i)$.
- The server then generates a PRG seed $seed_i$ and sends it to the user for use in 2FA.
- The user generates a 2FA response $r := PRG(seed_i || now$, where $now$ is rounded down to the nearest minute.
- The server verifies that this response is valid by computing it again itself.
- The server now generates a DSA keypair $vk_i, sk_i$ and generates a certificate for this user $\sigma_i$ over the fields $(vk_i, id_i)$.
- The server sends $\sigma_i$ and $sk_i$ to the user.
- The server stores $(id_i, h_i', salt_i, seed_i)$ in the database.

### Login

- On setup, the server has access to a DSA keypair $vk_s, sk_s$.
- On login, the user initiates a connection with the server and sends their DH public value $g^a$.
- The server will respond with both DH public values $(g^a, g^b)$ and a signature on both values, $\sigma_s = Sign(g^a, g^b, sk_s)$.
- Next, the user will send their $id$ to the server.
- The server will retrieve $(id_i, h_i', salt_i, seed_i)$ from the database and sends $salt_i$ to the user.
- The user will use the salt to generate $h_i := H(password || salt_i)$ and send $h$ to the server.
- The server then tries all possible 8-bit $pepper_i$ and generates $\hat{h}_i' = H(h_i' || pepper_i)$ until one  matches $h'_i$.
- The server then sends $seed_i$ to the user for use in 2FA.
- The user generates a 2FA response $r := PRG(seed_i || now$, where $now$ is rounded down to the nearest minute.
- The server verifies that this response is valid by computing it again itself.
- The server now generates a DSA keypair $vk_i, sk_i$ and generates a certificate for this user $\sigma_i$ over the fields $(vk_i, id_i)$.
- The server sends $\sigma_i$ and $sk_i$ to the user.
- The server stores $(id_i, h_i', salt_i, seed_i)$ in the database.

### Communication

- On setup, both users should have registered and obtained a certficate.
- On startup, both users run Diffie-Hellman, signing every message with the certificate they received from the server.
- Upon receipt of a DH public value from the other party, each user verifies that the server's signature on the certificate is valid, and that the user's signature on the public vaue is valid.
- Following these steps, the users have come to a shared secret and use symmetric key encryption using these values.

---

# Assignment Specification

Please note: you may NOT change any of the function headers defined in the stencil. Doing so will break the autograder; if you don't understand a function header, please ask us what it means and we'll be happy to clarify.

## Functionality

You will primarily need to edit `src/drivers/crypto_driver.cxx`, `src/pkg/client.cxx`, and `src/pkg/server.cxx`. The following is an overview of relevant files:
- `src/cmd/user.cxx` is the main entrypoint for the `auth_user` binary. It calls the `User` class.
- `src/cmd/server.cxx` is the main entrypoint for the `auth_server` binary. It calls the `Server` class.
- `src/drivers/crypto_driver.cxx` contains all of the cryptographic protocols we use in this assignment.
- `src/pkg/user.cxx` Implements the `User` class.
- `src/pkg/server.cxx` Implements the `Server` class.

The following roadmap should help you organize concerns into a sequence:
- Familiarize yourself with the protocol and cryptographic primitives we're using.
- Implement DSA key generation, signing, and verification.
- Implement our modified DH key exchange protocol in registration and login.
- Implement register functionality to add new users to the system.
- Implement login functionality to verify old users.
- Implement 2FA using PRFs.
- Implement basic communication.
- Implement digital signatures in communication.

In particular, you should implement the following functions:
- `std::pair<DSA::PrivateKey, DSA::PublicKey> CryptoDriver::DSA_generate()`
- `std::string CryptoDriver::DSA_sign(std::vector<unsigned char> message, CryptoPP::DSA::PrivateKey signing_key)`
- `bool CryptoDriver::DSA_verify(std::vector<unsigned char> message, std::string signature, CryptoPP::DSA::PublicKey verification_key)`
- `void Server::HandleConnection(std::shared_ptr<NetworkDriver> network_driver, std::shared_ptr<CryptoDriver> crypto_driver)`
- `bool Server::HandleKeyExchange(std::shared_ptr<NetworkDriver> network_driver, std::shared_ptr<CryptoDriver> crypto_driver)`
- `void Server::HandleLogin(std::shared_ptr<NetworkDriver> network_driver, std::shared_ptr<CryptoDriver> crypto_driver, std::string id)`
- `void Server::HandleRegister(std::shared_ptr<NetworkDriver> network_driver, std::shared_ptr<CryptoDriver> crypto_driver, std::string id)`
- `bool UserClient::HandleServerKeyExchange()`
- `bool UserClient::HandleUserKeyExchange()`
- `void UserClient::HandleLoginOrRegister(std::string input)`

Some tips:
- You should be able to reuse a lot of code from Signal, especially in communicating between users.
- The `encrypt_and_tag` and `decrypt_and_verify` functions are convenient functions that should cut down on the amount of repetitive code in your implementation. Use them!
- You might notice that a lot of messages don't have `signature` fields; we use a generic wrapper `DSASignedWrapper` to handle signatures. Generate signatures over the serialization of the unsigned message.
- Use the `chvec2str` and `str2chvec` functions to convert to and from strings and bytevecs, and `byteblock_to_string` and `string_to_byteblock` to convert to and from strings and byteblocks.
- Remember to call `AES_generate_shared_key()` and `HMAC_generate_shared_key()` after running key exchange.
- Remember to call `network_driver->disconnect()` at the end of handler functions.
- You don't need to replicate our CLI functionality; however, using it as a debugging tool is helpful.
- Use our function `crypto_driver->nowish()` to get the time rounded down to the nearest minute.
- Use our function `crypto_driver->hash()` to hash values.
- Use our constants from `include-shared/constants.hpp` where applicable. In particular from now on, Diffie-Hellman parameters are now hard-coded here instead of exchanged.

## Support Code

The following is an overview of the functionality that each support code file provides.
- `src/drivers/storage_driver` implements a class to manage database connections and operations; use this instead of interacting with the database directly. We use `sqlite3` under the hood, so you can run `sqlite3 <dbpath>` to debug the database directory if necessary.
- `src/drivers/repl_driver` implements a convenience class to run different REPL commands.
- `src-shared/config.cxx` contains loaders for our configuration files.
- `src-shared/keyloaders.cxx` contains loader for our keys.
- Everything else from prior assignments is unchanged.

## Libraries: CryptoPP

You may find the following wiki pages useful during this assignment:
- [CryptoPP DSA](https://www.cryptopp.com/wiki/Digital_Signature_Algorithm)
- [CryptoPP Hash Functions](https://www.cryptopp.com/wiki/Hash_Functions)
- [CryptoPP SHA-256](https://www.cryptopp.com/wiki/SHA2)
- [CryptoPP Random Number Generators](https://www.cryptopp.com/wiki/RandomNumberGenerator)

---

# Getting Started

To get started, get your stencil repository [here](https://classroom.github.com/a/32hHmLcR) and clone it into the `devenv/home` folder. From here you can access the code from both your computer and from the Docker container.

## Running

To build the project, `cd`  into the `build` folder and run `cmake ..`. This will generate a set of Makefiles building the whole project. From here, you can run `make` to generate a binary you can run, and you can run `make check` to run any tests you write in the `test` folder.

To run the user binary, run `./auth_user <config file>`. We have provided user config files for you to use; you shouldn't need to change them unless you would like to experiment with more users. Afterwards, you can either choose to `login`, `register`, `connect`, or `listen`; the former two deal with other server binaries, the latter two deal with other user binaries. They call the corresponding `Handle` functions in code.

To run the server binary, run `./auth_server <port> <config file>`. We have provided server config files for you to use; you shouldn't need to change them. Afterwards, the server will start listening for connections and handle them in separate threads.

## Testing

You may write tests in any of the `test/**.cpp` files in the Doctest format. If you want to add any new tests, make sure to add the file in line 4 of `test/CMakeLists.txt` so that `cmake` can pick up on the new files. Examples have been included in the assignment stencil. To run the tests run `make test` in the `build` directory.

---

# FAQ

- None yet!

---
