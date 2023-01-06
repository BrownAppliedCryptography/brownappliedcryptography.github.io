---
title: Cipher
name: cipher
due: January 1
---

Theme Song: [Mission Impossible Main Theme](https://www.youtube.com/watch?v=XAYhNHhxN0A)

Welcome to CSCI 1515! Throughout the semester, you'll implement numerous systems using production-grade cryptographic primitives. This assignment is meant to get you up to speed with C++ and the protocols you'll spend the semester with. If you ever have any questions, don't hesitate to ask a TA for support!

---

# Background Knowledge

In this assignment you'll be implementing a few foundational cryptographic protocols. In order to fully understand why these protocols are correct and secure, we review some of the number theory underlying these constructions. Don't worry; the rest of the course won't rely on a deep understanding of the math behind these protocols. Critically, we don't go over any advanced or involved proofs in this handout or course; rather, we introduce the results that are useful and ask that you take them at face value. If you are interested in the number theory, we recommend reading Appendix A of *A Graduate Course in Cryptography*. It is, however, crucial that you understand the purpose and use of each protocol, and knowing how they work under the hood can help you gain some of that understanding.


## Elementary Number Theory

The following is an overview of the number theory necessary to understand the encryption protocols in this homework. You can safely skip this section if you're already familiar with number theory, or if you're more comfortable engaging with the protocols directly (we'll use language and terminology from this section, but not deeply). **This section may seem intimidating; to reiterate, you do not need to understand this math deeply to implement this assignment, and you certainly don't need it for the rest of the course.**

### Divisibility and GCDs

Consider two integers $a$ and $b$. We say that $a$ **divides** $b$ if there exists some other integer, $c$, such that $ac = b$. We denote $a$ divides $b$ as $a \mid b$. This notion of divisibility by a particular integer $m$ can generalize to categorize all integers by considering remainders under division by $m$. Given some integers $a, b$. We say that $a$ and $b$ are **congruent mod $m$** if there exists some integer $k$ such that $a + km = b$. In other words, it means that $a$ and $b$ differ by a multiple of $m$, or that when divided by $m$, they yield the same remainder. We write $a \equiv b \text{ mod } m$ when this is the case.

Recall **greatest common divisors**, or GCDs for short. Given two integers $a, b$, the GCD of $a$ and $b$ is the largest integer $d$ such that $d \mid a$ and $d \mid b$. We say that two integers are **coprime** when their GCD is 1. Calculating the GCD of two integers can be done efficiently using the [Euclidean Algorithm](https://en.wikipedia.org/wiki/Euclidean_algorithm), and calculating integers $s, t$ such that $sa + tb = gcd(a, b)$ can be done efficiently using the [Extended Euclidean Algorithm](https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm). We eschew a detailed explanation of either algorithm in favor of the Wikipedia articles.

### Groups

To work with some theorems more nicely in general, and to allow us to generalize some of the following protocols, we introduce the notion of a group. A **group** is defined as a set $G$ and an operation $\cdot$ such that the following three properties hold:
1. **Identity**: there exists some identity element $e$ such that for any element $a \in G$ we have that $e \cdot a = a \cdot e = a$ (0 under addition and 1 under multiplication).
2. **Associativity**:  for all elements of the group $a, b \in G$, we have that $a \cdot b = b \cdot a$ (true for addition and multiplication).
3. **Inverses**: for every element $a \in G$, there exists an inverse $-a \in G$ such that $a + (-a) = e$ ($-a$ for any $a$ under addition).

The set of integers modulo $m$ under addition, denoted $\mathbb{Z}_m$, is a group. Moreover, the set of integers modulo some prime $p$ under multiplication is also a group. The set of integers modulo some composite integer $m$ isn't necessarily a group, but if you only consider the integers that are coprime to $m$, then we can construct a special group called the **multiplicative group of units**.

Given that $gcd(a, m) = 1$, finding an inverse is as simple as running the Extended Euclidean Algorithm. Taking the relation $sa + tm = 1$ mod $m$, we find that we get some $sa \equiv 1 \text{ mod } m$ where $s$ is the inverse of 1. If $m$ is prime, then $gcd(a, m) = 1$ for all $a$, which means that all $a$ has an inverse that we can calculate in this fashion. Thus, $\mathbb{Z}_m^*$ containing the set of integers coprime to $m$ is a group, and will be the group we use for the rest of this section.

Lastly, a **cyclic group** is a group $G$ in which there is some element, $g$ that **generates** the whole group; that is, all elements of $G$ are some power of $g$ (all $a = g^e$ for some $e$). This happens to be true for all of the groups we've considered so far, so we can assume that some generator exists and use it accordingly.

### Fast Powering

We take an aside and consider group elements of the form $g^e \text{ mod } m$. Unfortunately, computing such an element naively by multiplying $g$ by itself $e$ times is very inefficient; thankfully, by employing [Exponentiation by squaring](https://en.wikipedia.org/wiki/Exponentiation_by_squaring) we can speed this process up exponentially. In short, we notice that $g^e$ is equivalent to the product of $g^{b_i}$ where $b_i$ are the powers of 2 that add up to $e$. By repeatedly squaring $g$ and only multiplying our result by the powers of 2 that are included in $e$, we can compute $g^e$ in logarithmic time. We eschew a detailed explanation of either algorithm in favor of the Wikipedia article.

### Fermat's Little Theorem and Euler's Theorem

We end this section with two more useful results, which we state without proof. [Fermat's Little Theorem](https://en.wikipedia.org/wiki/Fermat%27s_little_theorem) (FLT) states that given a prime $p$, it is the case that for any $a$,  $a^p \equiv a \text{ mod } p$. Equivalently, $a^{p-1} \equiv 1 \text{ mod } p$.

[Euler's Theorem](https://en.wikipedia.org/wiki/Euler%27s_theorem), which is like a generalized FLT, states that given any integer $m$, it is the case that for any $a$, $a^{\phi(m)} \equiv a \text{ mod } m$. Equivalently, $a^{\phi(m)-1} \equiv 1 \text{ mod } m$. Note that $\phi(m)$ is [Euler's totient function](https://en.wikipedia.org/wiki/Euler%27s_totient_function), defined as the number of elements coprime to $m$ that are less than $m$. In particular, for prime $p$, $\phi(p) = p-1$ and if $m = pq$ for primes $p, q$, $\phi(m) = (p-1)(q-1)$.


## Diffie-Hellman Key Exchange

We now step away from number theory and consider some real cryptographic protocols. Let's say two parties, Alice and Bob (we typically name our honest parties Alice and Bob, and any adversaries Eve), want to decide on a shared key to encrypt some messages. For example, they may want to apply the [one-time pad](https://en.wikipedia.org/wiki/One-time_pad) and so they need a shared, secret $k$-bit integer to do so. The **[Diffie-Hellman key exchange](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange)** protocol, developed in 1976, is one method of coming to a shared secret. Diffie-Hellman will be used *extensively* throughout the rest of the course to compute shared secrets.

Diffie-Hellman is quite simple. Alice and Bob first come to agreement on a public base $g$, which can be any group element such that $g$ is a generator of a prime order group (for example, a generating element of $\mathcal{Z}^*_p$). In general, we wish to keep our groups large enough where an adversary can't brute-force their way into finding out secret key. After deciding on $g$, Alice and Bob each pick a secret random integer, denoted $a, b$ respectively. Alice will compute and send $g^a$ to Bob, and Bob will compute and send $g^b$ to Alice. Finally, both parties will compute $g^{ab}$ by exponentiating what they receive from the other party with their secret integer. This value, $g^{ab}$, is the shared secret. (Remember that fast-powering is what makes this efficient; otherwise, computing large exponents will take a long time!)

Correctness is clear since the operations clearly end up with the same values on both parties. What might not be clear is why this is secure; can an adversary Eve figure out $g^{ab}$ given what has been transmitted; namely, $g^a$ and $g^b$? In truth, we don't know whether Eve can efficiently solve this problem; the hardness of this problem is called the Diffie-Hellman assumption ([decisional](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange), [computational](https://en.wikipedia.org/wiki/Computational_Diffie%E2%80%93Hellman_assumption)), and it is very similar to the [Discrete logarithm](https://en.wikipedia.org/wiki/Discrete_logarithm) assumption. But, for large enough groups, all known techniques take too long to break security of this cryptosystem.


## ElGamal Encryption

With Diffie-Hellman, we can come to a shared key in order to send a message. This is useful for **symmetric-key encryption**, which is where both Alice and Bob encrypt and decrypt using a shared key. However, what if we can't communicate to find a shared key in advance? We can instead rely on **assymmetric-key encryption**, also known as **public-key encryption**, which allows Alice to send messages to Bob, but not vice versa. In general, Bob will have some private key $sk$ and some public key $pk$ and publish only $pk$. Alice will then use $pk$ to encrypt messages to Bob that can only be decrypted with $sk$. We explore an example of such a system now. The **[ElGamal encryption](https://en.wikipedia.org/wiki/ElGamal_encryption)** system, developed in 1985, is such a public key cryptosystem.  It is based on Diffie-Hellman and operates in a very similar way.

ElGamal is quite simple. First, Bob will generate system parameters by choosing a public base $g$, which can be any group element such that $g$ is a generator of a prime order group; for example, a generating element of $\mathcal{Z}^*_p$. He then chooses a random integer $x$ from the range $[1, p-1]$ and computes $g^x$. We have then that $pk = g^x$ and $sk = x$, so Bob publishes $pk$.

When Alice wants to encrypt a message $m$, which can be any integer in the range $[1, p-1]$, she first chooses a random integer $y$ from the range $[1, p-1]$ and computes $s = pk^y$. Then, she computes $c_1 = g^y$ and $c_2 = m \cdot s$ and sends both to Bob. To decrypt, Bob computes $c_2 \cdot (c_1^{sk})^{-1}$ by exponentiating $c_1$ by his secret key, then computing inverses using the Extended Euclidean Algorithm, and finally multiplying by $c_2$.

Correctness is simple when we expand; notice that $c_2 \cdot (c_1^{sk})^{-1} = m \cdot g^{xy} \cdot g^{-xy} = m$; so Bob recovers the original message. Security of this protocol relies on the same assumptions as Diffie-Hellman; we eschew a rigorous security proof in favor of a mathematical cryptography course.


## RSA Encryption

We explore one more public-key cryptosystem, known as **[RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)#Key_generation)** (Rivest-Shamir-Adleman). Unlike Diffie-Hellman and ElGamal, RSA doesn't rely on the hardness of the discrete logarithm problem; rather, it relies on the hardness of factoring large integers. That is, given large enough $n = pq$, it is computationally infeasible to find $p$ or $q$.

RSA is quite simple. First, Bob will generate system parameters by choosing two large primes $p, q$. He then computes $n = pq$, and then chooses some integer $e$ such that $gcd(e, (p-1)(q-1)) = 1$. Lastly, since $e$ is coprime to $(p-1)(q-1)$, we can find some $d \equiv e^{-1} \text{ mod } (p-1)(q-1)$. We have then that $pk = n, e$ and $sk = p, q, d$, so Bob publishes $pk$.

When Alice wants to encrypt a message $m$, which can be any integer in the range $[1, n-1]$, Alice simply computes $c = m^e \text{ mod } n$ and sends it to Bob. To decrypt, Bob computes $c^d \text{ mod } n$.

Correctness relies on Euler's theorem; we have that $\phi(n) = \phi(pq) = (p-1)(q-1)$, which means that $ed \equiv 1 \text{ mod } (p-1)(q-1)$, or that $ed - 1 = k(p-1)(q-1)$ for some integer $k$. Then, $c^d \equiv m^{ed} \equiv m^{k(p-1)(q-1) + 1} \equiv m \text{ mod } n$ by Euler's theorem. Security relies on the fact that factoring $n$ is hard; without factoring $n$, an adversary Eve cannot discover a suitable decryption exponent $d$, and is stuck; we eschew a rigorous security proof in favor of a mathematical cryptography course.


## DSA Signature

Orthogonal to the problem of encryption is message integrity. Let's say all of our channels are being controlled by an adversary Eve; how can we protect our messages from being tampered with without out knowledge? One solution to this problem is to **sign** our messages; by having the signature be difficult to compute without knowledge of a secret key and dependent on the message, Eve will be unable to sign altered messages. We explore the [Digital Signature Algorithm](https://en.wikipedia.org/wiki/Digital_Signature_Algorithm#1._Key_generation), or DSA for short, which solves this problem.

DSA is not very simple, but bear with us. Assume that Bob wants to sign messages to Alice. First, Bob chooses two primes $q, p$ such that $p-1$ is a multiple of $q$. Next, he chooses a random integer $h$ from the range $[2, p-2]$ and computes $g = h^{p-1}/q \text{ mod } p$. Bob publishes $p, q, g$ as public parameters for verification.

When Bob wishes to sign a message $m$, which can be any integer, he first chooses a random integer $k$ from the range $[1, q-1]$ and computes $r = (g^k \text{ mod } p) \text{ mod } q$ (be very careful of the order of mods; it is important for correctness) and $s = (k^{-1} \cdot (m + xr)) \text{ mod } q$. Bob outputs $(r, s)$ as his signature.

When Alice wishes to verify that a message-signature pair, $m, (r, s)$ is valid, she computes  $w = s^{-1} \text{ mod } q$, $u_1 = m \cdot w \text{ mod }q$, $u_2 = r \cdot w \text{ mod } q$, and finally, $v = (g^{u_1} \cdot y^{u_2} \text{ mod } p) \text{ mod } q$. She knows the signature is valid if and only if $v = r$.

Correctness is clear if expand carefully. First, notice that $g = h^{(p-1)/q} \text{ mod } p \implies g^q \equiv h^{p-1} \equiv 1 \text{ mod } p$ by FLT. We have from construction that $k = w \cdot m + w \cdot x \cdot r$ where $w = s^{-1} \text{ mod } q$. Thus, $g^k \equiv g^{H(m) w} g^{xrs} \equiv g^{H(m)w} y^{rw} \equiv g^{u_1} y^{u_2} \equiv v$.

Security of this protocol relies on the same assumptions as Diffie-Hellman; we eschew a rigorous security proof in favor of a mathematical cryptography course.

It's worth noting that often we want to compute signatures for messages that might fall outside of the acceptable range for this algorithm. To make sure that this is doable efficiently, we usually employ a hash function to shrink the size of a message for signing. An appropriate hash function should be chosen, however, as to not compromise security of the protocol.


## A Word of Caution

While we are having you implement some protocols on your own, know that this is an exercise to help you understand these algorithms, not a warrant to use home-rolled protocols in the wild. Building these protocols so that they are efficient and work securely all the time is a fools' errand, and we are all better off using standardized implementations from well-vetted libraries (as we will do for the rest of the course). A pledge for another protocol, AES, rings true:

> I promise that once I see how simple AES really is, I will not implement it in production
code even though it will be really fun. This agreement will remain in effect until I learn
all about side-channel attacks and countermeasures to the point where I lose all interest
in implementing AES myself.


---

# Assignment Specification

Please note: you may NOT change any of the function headers defined in the stencil. Doing so will break the autograder; if you don't understand a function header, please ask us what it means and we'll be happy to clarify.

## Cryptographic Protocols

In this assignment you will implement four cryptographic protocols: Diffie-Hellman key exchange, El Gamal encryption, RSA encryption, and DSA signatures. Using what you know about these protocols from class and from the descriptions above, implement the function headers in `src/cipher.cpp`. We recommend doing them in the order they are introduced, but there is no best way to complete this assignment. In particular, you should edit the following functions:

- `CryptoPP::Integer diffie_hellman(CryptoPP::Integer p, CryptoPP::Integer a, CryptoPP::Integer B)`
- `std::pair<CryptoPP::Integer, CryptoPP::Integer> elgamal_encrypt(CryptoPP::Integer p, CryptoPP::Integer g, CryptoPP::Integer A, CryptoPP::Integer m)`
- `CryptoPP::Integer elgamal_decrypt(CryptoPP::Integer p, CryptoPP::Integer a, CryptoPP::Integer c1, CryptoPP::Integer c2)`
- `CryptoPP::Integer rsa_encrypt(CryptoPP::Integer n, CryptoPP::Integer e, CryptoPP::Integer m)`
- `CryptoPP::Integer rsa_decrypt(CryptoPP::Integer n, CryptoPP::Integer d, CryptoPP::Integer c)`
- `std::pair<CryptoPP::Integer, CryptoPP::Integer> dsa_sign(CryptoPP::Integer p, CryptoPP::Integer q, CryptoPP::Integer g, CryptoPP::Integer a, CryptoPP::Integer m)`
- `bool dsa_verify(CryptoPP::Integer p, CryptoPP::Integer q, CryptoPP::Integer g, CryptoPP::Integer A, CryptoPP::Integer m, CryptoPP::Integer s1, CryptoPP::Integer s2)`

Remember to use the provided functions to compute random values and powers. Using outside functions for any of the protocols isn't permitted.

## C++

Throughout this course, we will use C++. We use C++ because it is the language in which most cryptographic libraries are written, especially those used later in the course. Moreover, it is a highly performant language that affords us great control over the systems we build.

Our development environment makes it very easy for you to write and build C++. In terms of syntax, we recommend [cppreference](https://en.cppreference.com/w/) and [learncpp](https://www.learncpp.com/) as good resources to help you learn. In general, we won't be using very advanced C++ features, but it is good to understand basic syntax.

## Libraries: CryptoPP

In this and future assignments, we will be using CryptoPP as our library of choice for our basic cryptographic primitives. CryptoPP is a widely used and trusted suite of cryptographic primitives; others like it include OpenSSL. We will introduce other libraries as the course goes along and make sure that you have all of the documentation you need on hand to build what we ask you to build.

You may find the following functions useful:
- `CryptoPP::EuclideanMultiplicativeInverse`

You may find the following wiki pages useful during this assignment:
- [CryptoPP Integer](https://www.cryptopp.com/wiki/Integer)
- [CryptoPP nbtheory](https://cryptopp.com/docs/ref/nbtheory_8h.html#ad0e863f715f6a4cf0b40c341e45c55b9)

---

# Getting Started

First, make sure you have a local development environment set up! See the [development environment guide](/misc/devenv) for help, and let us know via EdStem or TA Hours if you need help getting your dev environment set up.

To get started, get your stencil repository [here](https://classroom.github.com/a/ljae0sqs) and clone it into the `devenv/home` folder. From here you can access the code from both your computer and from the Docker container.

## Running

We use `cmake` in this course to manage builds. You won't need to know any cmake beyond what we detail in this section, but be aware that it exists and will be used to build your projects.

To build the project, `cd`  into the `build` folder and run `cmake ..`. This will generate a set of Makefiles building the whole project. From here, you can run `make` to generate a binary you can run, and you can run `make check` to run any tests you write in the `test` folder.

## Testing

You may write tests in any of the `test/**.cpp` files in the Doctest format. If you want to add any new tests, make sure to add the file in line 4 of `test/CMakeLists.txt` so that `cmake` can pick up on the new files. Examples have been included in the assignment stencil. To run the tests run `make test` in the `build` directory.

---

# FAQ

- **That's a lot of math; will the rest of the course have any math?** : No, this course is a programming course. The necessary math will be included in each handout, but you will not be required to use it deeply; only to understand it in the context of cryptography and security.

---