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

We highly recommend reading the first few pages of [The Simplest Protocol for Oblivious Transfer](https://eprint.iacr.org/2015/267.pdf) and [Faster Secure Two-Party Computation Using Garbled Circuits](https://www.usenix.org/legacy/event/sec11/tech/full_papers/Huang.pdf). It will help immensely in understanding the mathematics of this assignment.

## Oblivious Transfer

A foundational algorithm in multiparty computation is oblivious transfer (OT), which allows a receiver to select a message from a sender without the sender learning which message they selected, nor the receiver learning more than the message they selected. At first glance, OT seems impossible to achieve, but as we will see, we can use basic primitives that we've seen already to build an inefficient but simple implementation of 1-of-2 OT.

We present an implementation of OT based on Diffie-Hellman key exchange. Let $H$ be a hash function. The protocol proceeds as follows:
- The sender prepares two messages, $m_0, m_1$ to send to the receiver.
- The sender generates a Diffie-Hellman keypair, $(a, g^a)$, and sends $A = g^a$ to the receiver.
- The receiver generates a Diffie-Hellman keypair, $(b, g^b)$.
	- If the receiver wishes to receive $m_0$, they send back $B = g^b$.
	- If they wish to receive $m_1$, they send back $B = A g^b$.
- The receiver generates shared key $k_c = H(A^b)$.
- The sender generates $k_0 = H(B^a)$ and $k_1 = H((B/A)^a)$ and encrypts $e_0 = E(k_0, m_0)$ and $e_1 = E(k_1, m_1)$, sending both to the receiver.
	- Notice that depending on the sender's choice bit, the key for the message they selected will be equal to $k_c$.
- The receive decrypts the ciphertext they selected.

## Garbled Circuits

Garbled circuits allow two parties to jointly compute over a boolean circuit without learning any intermediate values or the other party's inputs. This is an immensely useful primitive as it allows two parties to jointly compute any function securely. We'll describe a garbled circuit protocol, without optimizations, that uses our OT implementation above, along with some other primitives we've been interacting with.

All of our circuits are specified using [Bristol Format](https://homes.esat.kuleuven.be/~nsmart/MPC/old-circuits.html), and we provide parsers to ease development. We highly recommend reading up on the format, should you need to debug a particular circuit or wish to write your own.

We present a simple implementation of garbled circuits. Let $H$ be a hash function. The protocol proceeds as follows:
- The garbler parses circuit $C$ and obtains a set of gates and wires to process.
- For each wire, the garbler produces a 0-label and a 1-label, which should be a random $k$-bit string. Labels should be tagged with $\lambda$ trailing 0's so we can identify when decryption was successful.
- For each gate, the garbler will produce a garbled gate consisting of 4 ciphertexts, where each ciphertext is the encryption of the corresponding output label when the two input labels are combined. Concretely, let's say we're garbling an "AND" gate with input wires $w_x, w_y$ and output wire $w_z$. Then, the ciphertexts will be as follows:
	- $c_{00} = E(w_x^0 || w_y^0, w_z^0)$
	- $c_{01} = E(w_x^0 || w_y^1, w_z^0)$
	- $c_{10} = E(w_x^1 || w_y^0, w_z^0)$
	- $c_{11} = E(w_x^1 || w_y^1, w_z^1)$
- The garbler permutes each garbled gate and sends all of them to the runner.
- The garbler also sends labels corresponding to the garbler's input.
- The evaluator uses OT to retrieve the labels corresponding to its input.
- The evaluator evaluates each gate and retrieves the corresponding output label by decrypting all output wires using the input wires it has until it reaches a valid decryption.
- The evaluator sends the labels correponding to the output to the garbler, which then reveals the final output.

## Some Resources

The following papers are incredibly useful for gaining a full understanding of protocols like ours:
- [The Simplest Protocol for Oblivious Transfer](https://eprint.iacr.org/2015/267.pdf)
- [Faster Secure Two-Party Computation Using Garbled Circuits](https://www.usenix.org/legacy/event/sec11/tech/full_papers/Huang.pdf)

## Putting it all together

The following diagram explains how the protocol works together.

![Architecture]()

We don't give a detailed protocol description as it doesn't differ meaningfully from the base protocol described above.

---

# Assignment Specification

Please note: you may NOT change any of the function headers defined in the stencil. Doing so will break the autograder; if you don't understand a function header, please ask us what it means and we'll be happy to clarify.

## Functionality

You will primarily need to edit `src/drivers/ot_driver.cxx`, `src/pkg/garbler.cxx`, and `src/pkg/runner.cxx`. The following is an overview of relevant files:
- `src/cmd/garbler.cxx` is the main entrypoint for the `yaos_garbler` binary. It calls the `Garbler` class.
- `src/cmd/runner.cxx` is the main entrypoint for the `yaos_runner` binary. It calls the `Runner` class.
- `src/drivers/ot_driver.cxx` contains a driver for OT.
- `src/pkg/garbler.cxx` Implements the `Garbler` class.
- `src/pkg/runner.cxx` Implements the `Runner` class.

The following roadmap should help you organize concerns into a sequence:
- Implement OT.
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
- You may have to use `DH_generate_shared_key` and `AES_generate_shared_key` many times in OT; that is expected.
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
