---
title: Auth
name: auth
due: January 1 
---

Theme Song: [Who Am I?](https://www.youtube.com/watch?v=KPoCMd2DYJo)

In this assignment, you'll 

---

# Background Knowledge

## Digital Signatures

## Pseudorandom Generators

## Hash Functions

## Secure Password Storage

## Putting it all together

The following diagram explains how the protocol works together.

![Architecture](/static/img/handout/signal/architecture.png)

In short, we proceed in 

---

# Assignment Specification

Please note: you may NOT change any of the function headers defined in the stencil. Doing so will break the autograder; if you don't understand a function header, please ask us what it means and we'll be happy to clarify.

## Functionality

You will primarily need to edit `drivers/crypto_driver.cxx` and `pkg/client.cxx`. The following is an overview of relevant files:
- `cmd/user.cxx` TODO:
- `cmd/server.cxx` TODO:
- `cmd/2fa.cxx` TODO:
- `drivers/cli_driver.cxx` implements a CLI that prints messages out to the screen.
- `drivers/crypto_driver.cxx` contains all of the cryptographic protocols we use in this assignment.
- `drivers/network_driver.cxx` contains a class that sends and receives streams of bytes using TCP. 
- `drivers/storage_driver.cxx` contains all of the cryptographic protocols we use in this assignment.
- `pkg/user.cxx` TODO:
- `pkg/server.cxx` TODO:
- `pkg/2fa.cxx` TODO:
- `pkg/messages.hpp` contains structs for each type of message you should expect to send and receive and `structures.cxx` contains the serialize and deserialize functions for these structs.

The following roadmap should help you organize concerns into a sequence:
- TODO:

In particular, you should implement the following functions:
- TODO:

Some tips:
- TODO:

## Support Code

The following is an overview of the functionality that each support code file provides.
- TODO:

## Libraries: CryptoPP

You may find the following wiki pages useful during this assignment:
- TODO:

## Written Response

Please respond to the following questions in your `README`.
- Why are we double-hashing password to store? TODO: Question
- What would be the implications of allowing users to further sign new certificates for other users?
- Explain an attack that could arise if the server did not send back the user's public value alongside their (the server's) public value.
- TODO:

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
