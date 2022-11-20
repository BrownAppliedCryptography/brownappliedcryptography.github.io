---
title: Auth
name: auth
due: January 1 
---

Theme Song: [Who Am I?](https://www.youtube.com/watch?v=KPoCMd2DYJo)

In this assignment, you'll extend the secure communication protocol from last class to build a secure server-client authentication system. In particular, you'll explore the ways in which we can use digital signatures to expand our circle of trust and be sure that nobody is pretending to be someone they're not.

---

# Background Knowledge

In this assignment, you'll build a secure authentication platform. There are three programs involved; a server, a client, and a 2fa applet. The server acts as a central verification authority that clients will interact with to obtain certificates. The server has its own globally-recognized public key, and signs the certificates of clients who properly log in. The clients will then use these certificates to communicate with each other, protected against impersonation attacks.

## Digital Signatures

You've interacted with digital signatures briefly in the first (warm-up) assignment, but we will go over the concept again here. Digital signatures are essentially the public-key equivalent to MACs. First, generate a keypair consisting of a public verification key $$vk$$ and a secret signing key $$sk$$, then use $$sk$$ to sign various messages $$\sigma_i = Sign(m_i)$$. When another party is given a message and signature, they can use $$vk$$ to verify that the message was signed correctly $$Verify(\sigma_i, m_i) ?= true$$. We want it to be the case that it is hard to forge signatures; that is, given $$vk$$ but not $$sk$$, finding valid signatures for any message, even when given valid signatures for other messages, is hard. 

Combining encryption with digital signatures, we achieve **authenticated encryption**, which is essentially the gold standard of communication. We know exactly who we are talking to and nobody else can read what we send.

## Password Authentication

You probably authenticate by password almost every day. To formalize this process, password authentication relies on both a server and a user knowing some shared secret $$pw$$, and the user proves that they know this secret by sending $$pw$$ (or some altered version of it) to the server. With the cryptographic primitives we've explored thus far in mind, there are a number of naive ways that one might implement password authentication. With encryption, one might encrypt the password and send it to the server, who will then decrypt it and store the password in a database for verification. While encryption makes this protocol safe from eavesdropping attacks, storing the password doesn't protect against cases where the server or database are compromised, leaking userdata. Even if we stored a hash of the password, adversaries that have access to the database can mount an offline brute-force search attack or consult a [rainbow table]() to crack the passwords We want to be careful to protect against a variety of attacks against all parts of our system.

We propose a heavily redunant but secure password authentication scheme so that you get a sense of the techniques you may see out in the wild. First, we assume we have access to a hash function $$H$$; to prevent offline brute-force attacks we could choose a slow (i.e. compute- or memory-intensive) hash function, but we'll any hash function for now. On registration, the server generates and sends a random **salt** to the user. A salt is a random string appended to a password before hashing it to prevent brute-force attacks. The user sends the hash of their password with the salt appended $$h := H(pw || salt)$$ to the server, which then computes a random short (say, 8-bit) **pepper** and hashes the user's message with the pepper appended yet again, $$h' := H(h || pepper)$$. Finally, the server stores the salt, but not the pepper. On verification, the server sends the stored salt to the user, who then sends the hash of their password. Then, the server tries all $$2^8$$ possible pepper values and verifies the user if any one of them succeeds. You will explore why this protocol was designed this way in the written portion of this assignment.

## Pseudorandom Functions and 2FA

Random numbers are convenient because they introduce a level of unpredictability to systems which can be very useful for keeping secret values secret (e.g. ElGamal encryption uses random values to ensure that even two ciphertexts of the same message are distinct). However, sometimes you want both you and your partner to experience the same randomness, or you may want to cheaply generate more randomness from some base *seed* of randomness. Pseudorandom functions (PRFs) are deterministic but unpredictable functions that take some value and output a pseudorandom value. We want that the distribution of PRF outputs are indistinguishable from that of a truly random function.

PRFs are useful in many ways. For one, they allow you to securely generate an infinite amount of seemingly random values deterministically for use in other cryptographic protocols. In this assignment, we'll use a PRF to implement two-factor authentication by using PRF outputs as a way of proving that we know the value of given a shared seed $$s$$. We can generate a short-lived login token by inputting this seed alongside the current time. The server can then validate that our values are correct by running the same function. 

## Putting it all together

The following diagram explains how the protocol works together.

![Architecture]()

In short, we proceed in the following steps:
- The user registers or logs in by sending their username and hashed+salted password, then generating a valid 2FA response.
- The server, upon receipt of a set of valid responses, issues a signed keypair for the user to use to sign their own messages.
- When users communicate with each other, they first verify that the certificate is valid (i.e. issued correctly by the server) then use it for authenticated encryption.

---

# Assignment Specification

Please note: you may NOT change any of the function headers defined in the stencil. Doing so will break the autograder; if you don't understand a function header, please ask us what it means and we'll be happy to clarify.

## Functionality

You will primarily need to edit `drivers/crypto_driver.cxx` and `pkg/client.cxx`. The following is an overview of relevant files:
- `cmd/user.cxx` is the main entrypoint for the `auth_user` binary. It calls the `User` class.
- `cmd/server.cxx` is the main entrypoint for the `auth_server` binary. It calls the `Server` class.
- `cmd/2fa.cxx` is the main entrypoint for the `auth_2fa` binary. It calls the `2FA` class.
- `drivers/cli_driver.cxx` implements a CLI that prints messages out to the screen.
- `drivers/crypto_driver.cxx` contains all of the cryptographic protocols we use in this assignment.
- `drivers/network_driver.cxx` contains a class that sends and receives streams of bytes using TCP. 
- `drivers/storage_driver.cxx` contains all of the cryptographic protocols we use in this assignment.
- `pkg/user.cxx` Implements the `User` class.
- `pkg/server.cxx` Implements the `Server` class.
- `pkg/2fa.cxx` Implements the `2FA` class.
- `pkg/messages.hpp` contains structs for each type of message you should expect to send and receive and `structures.cxx` contains the serialize and deserialize functions for these structs.

The following roadmap should help you organize concerns into a sequence:
- TODO:

In particular, you should implement the following functions:
- TODO:

Some tips:
- TODO:

## Support Code

The following is an overview of the functionality that each support code file provides.
- `drivers/storage_driver` implements two classes; one to manage a database connection and one to handle reading and writing data to a file.
- Everything else from prior assignments is unchanged.

## Libraries: CryptoPP

You may find the following wiki pages useful during this assignment:
- [CryptoPP DSA(https://www.cryptopp.com/wiki/Digital_Signature_Algorithm)
- [CryptoPP Hash Functions(https://www.cryptopp.com/wiki/Hash_Functions)
- [CryptoPP SHA-256(https://www.cryptopp.com/wiki/SHA2)
- [CryptoPP Random Number Generators(https://www.cryptopp.com/wiki/RandomNumberGenerator)

---

# Getting Started

To get started, get your stencil repository [here]() and clone it into the `devenv/home` folder. From here you can access the code from both your computer and from the Docker container.

## Running

To build the project, `cd`  into the `build` folder and run `cmake ..`. This will generate a set of Makefiles building the whole project. From here, you can run `make` to generate a binary you can run, `./auth_user` or `./auth_server` or `./auth_2fa`, and `make check` to run any tests you write in the `test` folder.

If you would like to add new files (e.g. to hold helper functions), make sure to include them in the `CMakeLists.txt` file s othat `cmake` can pick up on the new files.

## Testing

You may write tests in any of the `test/**.cpp` files in the Doctest format. If you want to add any new tests, make sure to add the file in line 4 of `test/CMakeLists.txt` so that `cmake` can pick up on the new files. Examples have been included in the assignment stencil. To run the tests run `make test` in the `build` directory.

---

# FAQ

- None yet!

---
