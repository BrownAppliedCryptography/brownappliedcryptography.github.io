---
title: A Primer on Sockets
name: sockets
---

At the heart of cryptography is secure communication between two or more distinct parties. It wouldn't be very exciting to just share secrets with yourself!

In this class, we hope that you can focus on the *cryptographic* part of communication as opposed to the *networking* part.

We want you to focus on questions that have more of a cryptographic flavor such as:
- How do I encrypt this message before sending it?
- How do I decrypt this message I just received?
- How do I know that this message wasn't tampered with during transport?
- How can I verify that the "sender" really sent this message?

As opposed to questions that have a networking flavor such as:
- How do we encode a string into bytes to send over a network?
- How do we transfer raw data from one client to another?

Unfortunately, it's hard to disentangle these two subjects in applied cryptography. At the end of the day, as cryptographers we'll need to understand at least some general networking concepts. Read on to discover more!

# Unique Identifiers
Imagine if you wanted to send mail to someone else. There's two distinct parts we need for a successful setup:
1) You need to know their address and name
2) They need to be willing to receive your mail
Likewise, to connect with some other client over a network, you'll need to know their *IP address* and *port number*.

Their IP address will get you to the machine you are trying to send information to, like how a mailing address will get you to somebody's house.

The port number helps identify which specific process on that machine you are trying to send information to. Just as a name on our letter specifies who in the household we're trying to send a message to, the port number specifies which process on the destination machine we're trying to send a message to.

Although *you*, the sender, know what address and port you want to **connect** to, we also need to have the receiver **listen** and **accept** on the address and port we're trying to send to.

# Sockets

Let's say we know our destination's IP address and port number. To actually connect with them, we use socket programming.

In socket programming, the two parties are often split into a **server** and **client**.

On the server side, they must first create a socket. The socket's IP address is just the address of the computer. To actually get a port number associated with it, the socket must be bound to a specific port and listen for incoming connections.

On the client side, they must also first create a socket. The client, who is the one who initiates the connection, must know their destination's IP address and port number. They must then call connect on the address and port and finally we have a connection between server and client.

![[Pasted image 20221116054030.png]]

*https://www.cs.uregina.ca/Links/class-info/330/Sockets/sockets.htmlsource*
