---
title: Cipher
name: cipher
due: January 1 
---

Theme Song: <a href="https://www.youtube.com/watch?v=XAYhNHhxN0A">Mission Impossible Main Theme</a>

Welcome to CSCI 1515! Throughout the semester, you'll implement numerous systems using production-grade cryptographic primitives. This assignment is meant to get you up to speed with C++ and the low-level primitives you'll spend the semester with. If you ever have any questions, don't hesitate to ask a TA for support!

---

# Background Knowledge



## Elementary Number Theory

## ElGamal Encryption

## RSA Encryption

## DSA Signature

## Diffie-Hellman Key Exchange

---

# Assignment Spec

## C++

Throughout this course, we will use C++. We use C++ because it is the language in which most cryptographic libraries are written, especially those used later in the course. Moreover, it is a highly performant language that affords us great control over the systems we build.

Our development environment makes it very easy for you to write and build C++. In terms of syntax, we recommend [cppreference](https://en.cppreference.com/w/) and [learncpp](https://www.learncpp.com/) as good resources to help you learn. In general, we won't be using very advanced C++ features, but it is good to understand basic syntax.

We use `cmake` in this course to manage builds. More information about how to use it is in the Getting Started section below; you won't need to know any cmake to participate in the course, but be aware that it exists and will be used to build your projects.

## Ciphers

In this assignment you will implement four cryptographic protocols: El Gamal encryption, RSA encryption, DSA signatures, and Diffie-Hellman key exchange. Using what you know about these schemes from class and from the descriptions above, implement the function headers in `src/cipher.cxx`.

## Testing

You may write tests in `test/test.cxx` in the Doctest format. Examples have been included in the assignment stencil. To run the tests run `make test` in the `build` directory.

## Getting Started

First, make sure you have a local development environment set up! See the [development environment guide](/misc/devenv) for help, and let us know via EdStem or TA Hours if you need help getting your dev environment set up.

To get started, get your stencil repository [here]() and clone it into the `devenv/home` folder. From here you can access the code from both your computer and from the Docker container.

Please note: you may NOT change any of the function headers defined in the stencil. Doing so will break the autograder; if you don't understand a function header, please ask us what it means and we'll be happy to clarify.

---

# FAQ

---