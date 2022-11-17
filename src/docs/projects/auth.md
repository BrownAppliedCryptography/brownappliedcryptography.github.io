---
title: Auth
name: auth
due: January 1 
---

Theme Song: [Who Am I?](https://www.youtube.com/watch?v=KPoCMd2DYJo)

In this assignment, you'll extend the secure communication protocol from last class to build a secure server-client authentication system. In particular, you'll explore the ways in which we can use digital signatures to expand our circle of trust and be sure that nobody is pretending to be someone they're not.

---

# Background Knowledge

In this assignment, you'll build a secure authentication platform. There are three programs involved; a server, a client, and a 2fa applet. The server 

## Digital Signatures

## Pseudorandom Generators

## Hash Functions

## Secure Password Storage

## Putting it all together

The following diagram explains how the protocol works together.

![Architecture]()

In short, we proceed in 

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
