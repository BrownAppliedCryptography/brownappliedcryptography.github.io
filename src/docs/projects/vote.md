---
title: Vote
name: vote
due: January 1 
---

Theme Song: [Ruler of Everything](https://www.youtube.com/watch?v=I8sUC-dsW8A)

In this assignment, you'll implement a cryptographic voting protocol based on the widely used Helios protocol. In particular, you'll explore how we can use zero knowledge proofs and homomorphic encryption in practice.

---

# Background Knowledge

In this assignment, you'll build a voting platform. There are four programs involves; arbiters that generate the election parameters and decrypt the final result, a registrar server that handles checking that all voters are registered to vote only once, a tallyer server that handles checking that all votes are valid, and the voter itself. All of these parties will interact to conduct an election.

We highly recommend reading [Cryptographic Voting - A Gentle Introduction](https://eprint.iacr.org/2016/765.pdf) in full. It will help immensely in understanding the mathematics of this assignment.

## Additively Homomorphic Encryption

A particularly annoying part about standard encryption is that usually, once data has been encrypted, it must be decrypted before it can be altered. Indeed, being able to alter a ciphertext that produces a proportional or meaningful change in the corresponding plaintext is called **malleability**, and is usually very undesirable. However, in some instances being able to compute over encrypted data is very useful, as it allows multiple parties to compute over shared data securely without corresponding first. Encryption schemes that allow for computation over their ciphertexts are called **homomorphic encryption schemes**. Of those, some may only allow addition or multiplication (**additively** and **multiplicatively** homomorphic), but those that allow any operation are called **fully** homomorphic. We explore the additively homomorphic scheme.

Formally, an additively homomorphic encryption scheme is a pair of functions $(Enc, Dec)$ such that for any two messages $m_0, m_1$, we have that $Dec(Enc(m_0) + Enc(m_1)) = Dec(Enc(m_0 + m_1))$.  In other words, we can construct a ciphertext for $m_0 + m_1$ using ciphertexts for $m_0$ and $m_1$ individually. Note that addition may mean something different for the plaintexts and ciphertexts.

We have actually already seen a simple multiplicatively homomorphic encryption scheme: ElGamal encryption. To see why, consider two ciphertexts $c_1 = (g^{r_1}, h^{r_1} m_1)$ and $c_2 = (g^{r_2}, h^{r_2} m_2)$. See that we can construct a ciphertext for $m_1 m_2$ by multiplying component-wise to obtain $c = g^{r_1 + r_2}, h^{r_1 + r_2} m_1 m_2$. We can apply the same idea to convert this encryption scheme into an additively homomorphic encryption scheme by instead encoding our messages as $g^m$ instead of $m$; then, the above combination becomes combining $c_1 = (g^{r_1}, h^{r_1} g^{m_1})$ and $c_2 = (g^{r_2}, h^{r_2} g^{m_2})$ to get $c = g^{r_1 + r_2}, h^{r_1 + r_2} g^{m_1 + m_2}$.

One glaring issue with this adaptation is that in order to recover $m_1 m_2$ we need to solve the discrete logarithm problem. However, for our purposes, we will only be encrypting small values and combining them a small number of times, so a brute-force, linear-time approach is perfectly fine. Note that this doesn't compromise the security of encryption as the secret key $s$ and the random keys $r$ are still expected to be very large, so a brute-force approach can't break those discrete logs.

## Threshold Encryption

Let's say we will be using homomorphic encryption that allows anyone to add their vote to a publicly tracked value. As of now, one party solely holds the decryption key and can check the value at any time they please. This isn't necessarily desirable; it would be nice if decryption keys could be split amongst multiple parties and only once a particular threshold of them have combined their keys can ciphertexts be decrypted. This is known as **threshold encryption** and is actually also very easy to achieve with ElGamal encryption.

In typically ElGamal encryption, one party would generate a keypair $sk, pk$ and publish $pk$ to the world. In threshold ElGamal encryption, $n$ parties will get together and each generate a keypair $sk_i, pk_i$. They will then multiply their public values together and publish $pk = \prod_i pk_i = g^{\sum_i sk_i}$. Encryption should use this composite public key.

In order to decrypt any ciphertext encrypted using this public key, the parties have two options. They can combine their secret keys and decrypt regularly, which forces the parties to regenerate a new public key should they wish to maintain secrecy of any future ciphertexts. Alternatively, each party can partially decrypt the ciphertext, and then the parties can combine their partial decryptions to get a full decryption. To compute a partial decryption of a ciphertext $c = (g^r, pk^r m)$, each party computes $g^{r sk_i}$. Then, multiplying all partial decryptions together retrieves $g^{r \sum sk_i} = pk^r$, which can then be used to decrypt the right-hand-side of the ciphertext.

## Zero Knowledge Proofs

Let's say that our protocol allows voters to encrypt a 0 or a 1 and post it to the public message board as a vote for or against a particular policy. How will we know that the voters haven't cheated and posted a 10 or 100, without decrypting every ciphertext and checking that it is, in fact, a 0 or a 1? **Zero knowledge proofs** allow us to prove this fact, among many others, without revealing anything else. They are a powerful cryptographic primitive that allow us to build trust without revealing too much information.

We'll explore three zero knowledge proof protocols to get the hand of things. The first we'll explore is a protocol to prove that we know the ElGamal secret key $sk$ corresponding to a particular ElGamal public key $pk$. The protocol is as follows. First, generate a new keypair $sk', pk'$ and reveal $pk'$. Let the party you're proving choose a random value $c$ in the range $(0, q-1)$.  Finally, reveal $sk'' := sk' + c \cdot sk \text{(mod q)}$. To check that this proof is valid, the challenger checks that $g^{sk''} ?= pk' \cdot pk^c$.

It's clear why a correctly generated proof will verify as correct. What isn't clear is why it proves that the prover knows $sk$. Consider the case where the prover doesn't know $sk$, but can observe every other message being sent around. The prover then has to compute $sk'' = sk' + c \cdot sk \text{(mod q)$, which it cannot do without $sk$, lest the verification fail. Thus, this proof is sound. We eschew a rigorous proof for another reading.

### Sigma Protocols

Protocols of the above format are called **Sigma protocols**, and can be altered to prove a variety of statements. Formally, a sigma protocol is a protocol using the following template to prove knowledge of a preimage $x : y := f(x)$ of a value $y$ under $f$:
1. The prover samples a random value $a$ and reveals $f(a)$.
2. The other party picks a challenge $c$ from the range $[0, n-1]$ and sends it to the prover.
3. The prover computes $d := a + cx$ and reveals d.
4. The other party checks that $f(d) ?= b + c \cdot y$.

### Non-interactivity

One annoying point of this protocol is that we would have to repeat it for each and every person we wish to prove this fact to. This isn't very scalable! We recognize that the only reason we need to repeat it is to obtain a value $c$ that we are sure that the prover didn't select themselves; the reason we can't reuse a proof that was used for someone else is that we can't be sure that the prover didn't collude with anybody. We instead generate a value $c$ as the hash of all of the constants in the ZKP. In the above example, we generate $c = H(pk, pk')$. Since nobody has control over what the output of a hash function is, nor can they intelligently select inputs to get a particular output, this is perfectly good as a $c$ value. This makes the ZKP non-interactive, allowing it to scale. This works for all of the sigma protocols we will encounter.

### Partial Decryption ZKP

We explore another ZKP that proves that a partial decryption $c := (a, b)$ is correct. This proof comes in two parts; first, we need to prove that we correct compute $d := a^{sk}$ and we need to prove that $g^{sk} = pk$. To do so, we first pick a random $r$ and compute $(u, v) := (a^r, g^r)$. Next, we receive a challenge value $c$ as usual, and compute $s := r + c \cdot sk$. We then reveal $((u, v), s)$ as our proof. To check the proof, we check that $a^s ?= u \cdot d^c$ and that $g^s ?= v \cdot pk^c$. We leave verifying correctness to the reader.

### Disjunctive Chaum-Pedersen

We explore one last ZKP that proves that a ciphertext is either an encryption of 0 or 1. So far it has been pretty easy to prove "AND" statements; simply add more proofs and be done. However, proving "OR" statements is significantly more difficult since one of the statements could be false. We'll approach this ZKP in steps and build up to a protocol that works.

First, notice that we can reduce proving that a ciphertext is an encryption of $m$ to the first ZKP quite easily by dividing the RHS of the ciphertext by $g^m$. Next, notice that we can actually cheat in our ZKP as long as we can select our value of $c$ before commiting to our randomness. In particular, we can compute "random" values to use in the proof $a' = g^r / a^c$ and $b' = pk^r / (b / g^m)^c$, which will then end up verifying correctly. We can use these two facts to generate a ZKP for an "OR" statement.

The protocol is as follows. Run the sigma protocols to prove that $(a, b)$ is an encryption of either 0 or 1 simultaneously. Receive a challenge $c$ and for each protocol, produce a new challenge $c_i$ and proof such that $c = c_1 + c_2$. Since we can cheat if we choose $c_i$ beforehand, we cheat in exactly one of the protocols, then recover the challenge we use for the other by subtracting $c_i$ from $c$. Note that we can't cheat in both protocols unless the challenge $c$ we receive happens to be the sum of our chosen $c_i$. Then, to verify, we check each individual ZKP and that $c = c_1 + c_2$. This protocol is known as **Disjunctive Chaum-Pedersen** (DCP), or the **Sigma-OR** protocol. A more detailed explanation can be found in the readings.

## Some Resources

The following papers are incredibly useful for gaining a full understanding of protocols like ours:
- [Cryptographic Voting — A Gentle Introduction](https://eprint.iacr.org/2016/765.pdf)
- [Helios](https://www.usenix.org/legacy/events/sec08/tech/full_papers/adida/adida.pdf)


## Putting it all together

The following diagram explains how the protocol works together.

![Architecture]()

In short, we proceed in the following steps: registration, voting, verification. We won't describe the ZKPs or encryptions in use in detail.

### Registration

- On setup, the registrar has access to a DSA keypair $vk_r, sk_r$.
- First, the voter generates a DSA keypair $(sk_i, vk_i)$ and sends $(vk_i, id_i)$ to the registrar.
- The registrar ensures that the voter hasn't voted before and signs their verification key using $sk_r$, then sends the signature to the voter.

### Voting

- On setup, the arbiters have generated a ElGamal public key $pk$.
- On setup, the tallyer has access to a DSA keypair $vk_t, sk_t$.
- First, the voter encrypts their vote 0/1 using $pk$.
- Next, the voter generates a ZKP that their vote is an encryption of 0 or 1.
- Next, the voter generates a signature on their vote and ZKP using $sk_i$.
- The voter sends their encrypted vote, ZKP, signature, and certificate to the tallyer.
- The tallyer verifies the ZKP, signature, and ceritificate, then signs the encrypted vote and ZKP using $sk_t$.
- The tallyer publishes the encrypted vote, ZKP, and signature.

### Partial Decryption

- On setup, the arbiters have access to their ElGamal secret key $sk_a$.
- The arbiter generates a partial decryption and ZKP.
- The arbiter publishes the partial decryption and ZKP.
- Voters recover the final result by combining all partial decryptions and verifying all ZKPs.

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
