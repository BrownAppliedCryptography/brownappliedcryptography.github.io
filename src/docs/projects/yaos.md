---
title: Yao's
name: yaos
due: January 1 
---

Theme Song: [Nerdy Love](https://www.youtube.com/watch?v=6jzH6_KOsKk)

In this assignment, you'll implement oblivious transfer and garbled circuits to allow two parties to jointly compute a function without learning the other party's inputs.

---

# Background Knowledge

In this assignment, you'll implement a simple version of Yao's garbled circuits using a simple version of oblivious transfer. This assignment leaves a lot of room for optimizations, which we leave to the reader to explore.

We highly recommend reading TODO:

## Oblivious Transfer

## Garbled Circuits

### Bristol Format

## Putting it all together

The following diagram explains how the protocol works together.

![Architecture]()

In short, we proceed in the following steps: TODO:.

---

# Assignment Specification

Please note: you may NOT change any of the function headers defined in the stencil. Doing so will break the autograder; if you don't understand a function header, please ask us what it means and we'll be happy to clarify.

## Functionality

You will primarily need to edit `src/drivers/ot_driver.cxx`, `src/pkg/garbler.cxx`, and `src/pkg/runner.cxx`. The following is an overview of relevant files:
- `src/cmd/garbler.cxx` is the main entrypoint for the `yaos_garbler` binary. It calls the `Garbler` class.
- `src/cmd/runner.cxx` is the main entrypoint for the `yaos_runner` binary. It calls the `Runner` class.
- `src/drivers/ot_driver.cxx` contains a driver for oblivious transfer.
- `src/pkg/garbler.cxx` Implements the `Garbler` class.
- `src/pkg/runner.cxx` Implements the `Runner` class.

The following roadmap should help you organize concerns into a sequence:
- Implement oblivious transfer.
- Implement label generation and verification.
- Implement gate generation.
- Implement get evaluation
- Put it all together in the main functions.

In particular, you should implement the following functions:
- `void OTDriver::OT_send(std::string m0, std::string m1)`
- `std::string OTDriver::OT_recv(int choice_bit)`
- `void Garbler::run(std::vector<int> input)`
- `std::vector<GarbledGate> Garbler::generate_gates(Circuit circuit, GarbledLabels labels)`
- `GarbledLabels Garbler::generate_labels(Circuit circuit)`
- `CryptoPP::SecByteBlock Garbler::generate_encrypted_label(GarbledWire lhs, GarbledWire rhs, GarbledWire output)`
- `void Runner::run(std::vector<int> input)`
- `GarbledWire Runner::evaluate_gate(GarbledGate gate, GarbledWire lhs, GarbledWire rhs)`

Some tips:
- Use `byteblock_to_integer` and `integer_to_byteblock` to convert to and from integers and byteblocks.
- You may have to use `DH_generate_shared_key` and `AES_generate_shared_key` many times in oblivious transfer; that is expected.
- Remember to use the constants provided for `LABEL_LENGTH` and `LABEL_TAG_LENGTH`.
- Feel free to use `CryptoPP::OS_GenerateRandomBlock` and `CryptoPP::SecByteBlock::CleanGrow` to create labels.
- Look into `CryptoPP::xorbuf` to implement XOR

## Support Code

The following is an overview of the functionality that each support code file provides.
- `src-shared/circuit.cxx` contains type definitions and loaders for a boolean circuit written in Bristol format.
- Everything else from prior assignments is unchanged.

## Libraries: CryptoPP

You may find the following wiki pages useful during this assignment:
- [CryptoPP nbtheory](https://www.cryptopp.com/docs/ref/nbtheory_8h.html)

---

# Getting Started

To get started, get your stencil repository [here](https://classroom.github.com/a/RyYCEcnP) and clone it into the `devenv/home` folder. From here you can access the code from both your computer and from the Docker container.

## Running

To build the project, `cd`  into the `build` folder and run `cmake ..`. This will generate a set of Makefiles building the whole project. From here, you can run `make` to generate a binary you can run, and you can run `make check` to run any tests you write in the `test` folder.

## Testing

You may write tests in any of the `test/**.cpp` files in the Doctest format. If you want to add any new tests, make sure to add the file in line 4 of `test/CMakeLists.txt` so that `cmake` can pick up on the new files. Examples have been included in the assignment stencil. To run the tests run `make test` in the `build` directory.

---

# FAQ

- None yet!

---
