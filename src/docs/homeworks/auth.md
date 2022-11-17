---
title: Auth - Homework
name: auth
due: January 1 
---

The following questions will relate to the Auth project. Please answer the following questions and submit them as a PDF to Gradescope.

# Auth Security

In this problem we'll pick apart some of the details in the Auth protocol and justify their security.

 1) In the key exchange step between the user and the server, the user sends public value $$g^a$$ and the server sends back its public value $$g^b$$ alongside the public value it received, with a signature computed on both. Explain an attack that could arise if the server did not sign both the user's public value alongside their (the server's) public value.
 2) Explain why the setup we have is sufficient; that is, that the user doesn't need to sign anything and that the server doesn't need to send back any more information. You can assume that the user has access to an `ABORT` function it can use to signal to the server to drop the session.

# Hash^2

Our password storage scheme is designed to protect against any computationally bounded adversary that may have corrupted our server or storage from gaining information about user passwords or wrongfully authenticating with our server. Given a (collision-resistant) hash function $$H$$ and a password $$p$$, the following is how we register and login:

**Registration**: First, the server sends a salt $$\sigma$$ to the user, then the user computes $$c = H(p || \sigma)$$ by hashing the password with the salt appended. The user then sends their user id $$id$$ and $$c$$. Next, the server will choose a random $$\rho \in \{0, 1\}^k$$ for some small $$k$$ and compute $$c' = H(c || \rho)$$, which it then stores in the database alongside the salt $$\sigma$$.

**Login**: First, the server sends the stored salt $$\sigma$$ to the user, then the user computes $$c = H(p || \sigma)$$ by hashing the password with the salt appended. The user then sends their user id $$id$$ and $$c$$. The server will then try for all $$\rho \in \{0, 1\}^k$$ computing $$c' = H(c || \rho)$$, and authenticating the user if $$c'$$ matches the stored value for any $$\rho$$.

TODO: These questions could be posed better.
- Explain why this verification scheme is correct; that is, a valid password should be cleared for login.
- Explain what could happen if the server only stored $$c$$ instead of hashing it again to obtain and store $$c'$$. Remember that our adversary may have access to our storage and compute.
- Explain what could happen if the client sent an encryption of $$p$$ instead of hashing it. Remember that our adversary may have access to our storage and compute.

# Chain Trust

The way that our authentication scheme works is that since we trust the server, the server can **delegate trust** to others that it trusts, allowing us to verify the identity of a third-party without consulting directly with the server. 

1) Propose a protocol that allows users to delegate trust to other users. What does delegation look like? What does verification look like?
2) Let's say a secret key for some user has been compromised, and assume we have some way of invalidating certifications (*e.g.* a public revokal board). Which users should have their certificates invalidated?

