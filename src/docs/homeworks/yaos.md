---
title: Yao's - Homework
name: yaos-homework
due: January 1 
---

The following questions will relate to the Yao's project. Please answer the following questions and submit them as a PDF to Gradescope.

# Oblivious Transfer

Our protocol only supports 1-of-2 OT, which is sufficient for garbled circuits. However, 1-of-n OT may be more useful in the general case, for example in information retrieval. Explain how we can extend the protocol we've been using to 1-of-n OT. You don't need to prove security; security of the original scheme should clearly imply security of your scheme. Hint: 1-of-2 OT should be a special case of the extended protocol. 

# Malicious Circuits

As is, our protocol doesn't protect against malicious adversaries. For instance, the garbler doesn't have to garble the circuit that they agreed on, nor do they have to share the final output with the other party.

1) Consider a boolean circuit where the garbler has 32 bits of input, the evaluator has 32 bits of input, and the circuit has 32 bits of output; an example could be a 32-bit adder, but other functions are fair game. Describe in detail an attack that allows the garbler to learn both the evaluator's input and the output of the circuit.
2) Suppose we wish to boost security of this protocol by allowing the evaluator to be sure that each gate was generated honestly; for instance, an AND gate is actually an AND gate, and not an OR gate. This way, the evaluator can be sure that the function they're evaluating is the one they agreed on. What primitive might be useful in this situation? A single-phrase response suffices.

# Optimized Circuits

There are a plethora of optimizations one could apply to make garbled circuits more efficient to evaluate. We explore one in particular, called Free-XOR. Let $w_x^i$ be the $i$-label of the $x$-th wire (e.g. the 0-label of the 10-th wire). In Free-XOR, instead of computing both $w_x^0$ and $w_x^1$ as pseudorandom tagged values, we compute $w_x^0$ normally and compute $w_x^1$ as the XOR of the 0-wire and a secret value, $R || 1$; $w_x^1 := w_x^0 XOR (R || 1)$. Then, when garbling an XOR gate with input wires with 0-labels $w_x^0$, $w_y^0$, we set the output wire's 0-label to be $w_z^0 := w_x^0 XOR w_y^0$ and the 1-label $w_z^1 := w_z^0 XOR (R || 1)$.

1) Explain how we evaluate a garbled XOR gate using this optimization and why it works. You do not need to explain why it is secure.
2) We can apply a similar principle to NOT gates to make them free. Explain how we do this. You do not need to explain why it is secure.