---
title: Signal - Homework
name: signal-homework
due: January 1 
---

The following questions will relate to the Signal project. Please answer the following questions and submit them as a PDF to Gradescope.

# 1) What-then-What?

We wish to ensure that messages we send aren't tampered with in transit or forged by a third-party adversary. To do this, we leverage the fact that we have shared secrets $s_1, s_2$ and compute MACs. We'll review a few different methods for calculating MACs given a block cipher $E$. For all of the following we try to encrypt a message $m$ using shared secret $s$.

**Method 1 (MAC-then-encrypt)**: First, we compute a MAC on the plaintext $t = MAC(s_1, m)$ and encrypt the whole message $c = E(s_2, m || t)$. To decrypt and verify we obtain $m || t = D(s_2, c)$, then parse $m$ and $t$ and verify that $t == MAC(s_1, m)$.

**Method 2 (Encrypt-and-MAC)**: First, we compute a MAC on the plaintext $t = MAC(s_1, m)$ and encrypt the message $c = E(s_2, m)$, then output $(c, t)$. To decrypt and verify we obtain $m = D(s_2, c)$, then verify that $t == MAC(s_1, m)$.

**Method 3 (Encrypt-then-MAC)**: First, we encrypt the message $c = E(s_2, m)$ and then generate a MAC on the ciphertext $t = MAC(s_1, c)$. To decrypt and verify we check that $t == MAC(s_1, c)$, then obtain the message $m = D(s_2, c)$.

We don't expect formal reductions; rather, just informal ideas on how an adversary might exploit each of the protocols we laid out. Note that MACs are not necessarily hiding; that is, they may reveal some information about the message it was generated on. Moreover, 

1) Explain why MAC-then-encrypt is vulnerable to an attack on ciphertext integrity; that is, why might an adversary be able to tamper with our ciphertext?
2) Explain why Encrypt-and-MAC is vulnerable to an attack on message secrecy; that is, why might an adversary learn something about our message $m$?
3) Explain why Encrypt-then-MAC is not vulnerable to either attack described above.


# 2) Who-in-the-Where?

Our protocol so far ensures that two parties can establish a shared secret, but it doesn't ensure that we know exactly who we're talking to. Indeed, an adversary could pretend to be who we're talking to and we would be none the wiser. Describe a man-in-the-middle attack that compromises the security of our application.


# 3) What, again?

Our protocol also isn't secure against replay attacks, in which once a secure channel is established, messages could be sent multiple times to generate duplicate responses. Consider an application that upon receiving a suitable message, will send a dollar to charity.

1) Describe a replay attack that exploits this system.
2) Propose a mechanism for protecting against this attack.
