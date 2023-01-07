---
title: Vote
name: vote
due: January 1 
---

Theme Song: [Ruler of Everything](https://www.youtube.com/watch?v=I8sUC-dsW8A)

In this assignment, you'll implement a cryptographic voting protocol based on the widely used Helios protocol. In particular, you'll explore how we can use zero knowledge proofs and homomorphic encryption in practice.

---

# Background Knowledge

In this assignment, you'll build a voting platform. There are four programs involves; arbiters that generate the election parameters and decrypt the final result, a registrar server that handles checking that all voters are registered to vote only once, a tallyer server that handles checking that all votes are valid, and the voter itself. All of these parties will interact to conduct an election; but, before we can describe how the protocol works, we describe some of the primitives we'll be using.

## Additively Homomorphic Encryption

## Zero Knowledge Proofs

## Sigma Protocols

## Disjunctive Chaum-Pedersen

## Some Resources

The following papers are incredibly useful for gaining a full understanding of protocols like ours:
- [Cryptographic Voting — A Gentle Introduction](https://eprint.iacr.org/2016/765.pdf)
- [Helios](https://www.usenix.org/legacy/events/sec08/tech/full_papers/adida/adida.pdf)


## Putting it all together

The following diagram explains how the protocol works together.

![Architecture]()

In short, we proceed in the following steps: TODO:.

---

# Assignment Specification

Please note: you may NOT change any of the function headers defined in the stencil. Doing so will break the autograder; if you don't understand a function header, please ask us what it means and we'll be happy to clarify.

## Functionality

You will primarily need to edit `src/drivers/crypto_driver.cxx`, `src/pkg/arbiter.cxx`, `src/pkg/election.cxx`, `src/pkg/registrar.cxx`, `src/pkg/tallyer.cxx`, and `src/pkg/voter.cxx`. The following is an overview of relevant files:
- `src/cmd/arbiter.cxx` is the main entrypoint for the `auth_arbiter` binary. It calls the `Arbiter` class.
- `src/cmd/registrar.cxx` is the main entrypoint for the `auth_registrar` binary. It calls the `Registrar` class.
- `src/cmd/tallyer.cxx` is the main entrypoint for the `auth_tallyer` binary. It calls the `Tallyer` class.
- `src/cmd/voter.cxx` is the main entrypoint for the `auth_voter` binary. It calls the `Voter` class.
- `src/drivers/crypto_driver.cxx` contains all of the cryptographic protocols we use in this assignment.
- `src/pkg/arbiter.cxx` Implements the `Arbiter` class.
- `src/pkg/registrar.cxx` Implements the `Registrar` class.
- `src/pkg/tallyer.cxx` Implements the `Tallyer` class.
- `src/pkg/voter.cxx` Implements the `Voter` class.
- `src/pkg/election.cxx` Implements the `Election` class, which holds most of the interesting cryptographic operations.

The following roadmap should help you organize concerns into a sequence:
- Implement ElGamal key generation, as it will be used in the rest of the assignment.
- Implement the `Election` functions.
- Implement the handler functions in each party.

In particular, you should implement the following functions:
- `std::pair<CryptoPP::Integer, CryptoPP::Integer> CryptoDriver::EG_generate()`
- `void Arbiter::HandleAdjudicate(std::string _)`
- `void Registrar::HandleRegister(std::shared_ptr<NetworkDriver> network_driver, std::shared_ptr<CryptoDriver> crypto_driver)`
- `void Tallyer::HandleTally(std::shared_ptr<NetworkDriver> network_driver, std::shared_ptr<CryptoDriver> crypto_driver)`
- `void Voter::HandleRegister(std::string input)`
- `void Voter::HandleVote(std::string input)`
- `void Voter::HandleVerify(std::string input)`
- `std::pair<Vote_Struct, VoteZKP_Struct> Election::GenerateVote(CryptoPP::Integer vote, CryptoPP::Integer pk)`
- `bool Election::VerifyVoteZKP(std::pair<Vote_Struct, VoteZKP_Struct> vote, CryptoPP::Integer pk)`
- `std::pair<PartialDecryption_Struct, DecryptionZKP_Struct> Election::PartialDecrypt(Vote_Struct combined_vote, CryptoPP::Integer pk, CryptoPP::Integer sk)`
- `bool Election::VerifyPartialDecryptZKP(ArbiterToWorld_PartialDecryption_Message a2w_dec_s, CryptoPP::Integer pki)`
- `Vote_Struct Election::CombineVotes(std::vector<VoteRow> all_votes)`
- `CryptoPP::Integer Election::CombineResults(Vote_Struct combined_vote, std::vector<PartialDecryptionRow> all_partial_decryptions)`

Some tips:
- Familiarize yourself *deeply* with the protocols and proofs of this assignment; you should fully understand how the ZKPs work before diving into implementation.
- This assignment doesn't rely as much on CryptoPP libraries; as such, there is more room for error. Be careful!

## Support Code

The following is an overview of the functionality that each support code file provides.
- Everything from prior assignments is unchanged. Hooray!

## Libraries: CryptoPP

You may find the following functions useful:
- `CryptoPP::EuclideanMultiplicativeInverse`
- `CryptoPP::ModularExponentiation`
- `CryptoPP::Integer::Zero`
- `CryptoPP::Integer::One`

You may find the following wiki pages useful during this assignment:
- [CryptoPP nbtheory](https://www.cryptopp.com/docs/ref/nbtheory_8h.html)

---

# Getting Started

To get started, get your stencil repository [here](https://classroom.github.com/a/DX9ztxip) and clone it into the `devenv/home` folder. From here you can access the code from both your computer and from the Docker container.

## Running

To build the project, `cd`  into the `build` folder and run `cmake ..`. This will generate a set of Makefiles building the whole project. From here, you can run `make` to generate a binary you can run, and you can run `make check` to run any tests you write in the `test` folder.

## Testing

You may write tests in any of the `test/**.cpp` files in the Doctest format. If you want to add any new tests, make sure to add the file in line 4 of `test/CMakeLists.txt` so that `cmake` can pick up on the new files. Examples have been included in the assignment stencil. To run the tests run `make test` in the `build` directory.

---

# FAQ

- None yet!

---
