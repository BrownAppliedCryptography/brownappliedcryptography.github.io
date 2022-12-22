---
title: Vote - Homework
name: vote-homework
due: January 1 
---

# Zero-Knowledge Knowledge

1) The Sigma-OR zero knowledge proof protocol starts with simulating the proof for the vote that you aren't casting; this raises the question of why you can't simulate both proofs in the same manner. Explain why this isn't possible (i.e. what information someone who is cheating by crafting a proof for an encryption they didn't make would lack).
2) Most things in our protocol are signed, but our arbiter messages aren't. Explain why arbiters don't need to sign their partial decryptions, assuming their keys are honestly generated.


# Two's a party, three's an election

It'd be nice to generalize our voting protocol to multiple parties; after all, may election systems consider more than two candidates. Consider the following candidate (no pun intended) construction: to vote for candidate $i \in \{0, \ldots, n\}$ for $n > 2$, simply encrypt a vote of $i$; that is, construct a ciphertext that looks like $(g^r, h^r \cdot g^i)$. To decrypt, follow the same protocol as before using homomorphic addition.

1) Explain why this doesn't work as intended.
2) Explain how you would extend our protocol to support multiple parties. Do we need more zero knowledge proofs? If so, simply state what they should prove; you don't need to provide a description of how they should work.


# A Completely Theoretical Attack

1) Explain an attack on voter privacy that can surface if the tallyer and registrar colluded.
2) Explain an attack that can surface if the arbiters all colluded (i can't think of one).
2) Explain an attack if voters didn't sign their votes.
3) Explain an attack if the tallyer didn't sign votes before posting them.
