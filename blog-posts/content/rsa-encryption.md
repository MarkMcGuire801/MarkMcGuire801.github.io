This is a "quick" writeup meant to break down exactly what RSA is, does, and how it works, at as simple a level as possible. Because of this there will be quite a few chains where one concept being defined leads to one or more additional concepts being defined. If you already know what certain items are, just give it a quick glance for a refresher and move on to the next thing.

---

## What is Cryptography?

Cryptography is the science of securing communications so that only the intended parties can access certain information. This is accomplished through many different techniques, but generally speaking these systems work to encrypt messages. They take an input, do something to it to scramble things around, and then produce a mess of an output. The key part of this process is that the actions taken in the middle have some sort of secret rhyme or reason to them.

Let's take pig latin as an example:

<div class="blog-callout">
<strong>Input (Plaintext):</strong> "Hello World"
</div>

For the scrambling in the middle we'll use an **algorithm** — a set of instructions to scramble the plaintext, or the "how-to": Move a specific group of letters to the end of each word, and then attach a new ending to that word.

So now we know *how* we're scrambling this, but we just have a plain set of rules. We have the how, but not the "with what." The **key** is the part of the system that accomplishes this. Let's make that specific group of letters be "The first letter of a word if it's a consonant" — vowels at the start are left alone. The new ending we attach is "-ay."

Following the rules and applying the key, "Hello World" turns into **"Ellohay Orldway"** — this is called the **ciphertext**.

Now, pig latin is fairly insecure — most people know how it works, and even if you don't, everything could be figured out from scratch fairly easily. Modern cryptography uses very specific techniques and mathematical concepts to ensure that this isn't the case.

---

## What Is RSA?

RSA is a **public-key cryptosystem** developed by Ron Rivest, Adi Shamir, and Leonard Adleman at MIT in 1977. Public-key cryptosystems are also known as **asymmetric encryption**. In this kind of cryptographic system everyone knows what the algorithm is, but there are actually two different keys. There is one key that everybody is aware of called the **public key**, and this is used to take a message and scramble it. The other key is kept private and is used to decrypt the messages that the public key encrypts.

You might be thinking "Well, can't someone just steal someone's encrypted message and use the public key to decrypt it since everyone knows it?" — and you'd be completely right to ask this. Unfortunately for anyone hoping to do this, because of how RSA creates the public and private keys, this is impossible. The way the public key scrambles messages is very easy to do forwards, but is nearly impossible to undo just because of the math behind how it's created. This math is also why the private key *can* decrypt these messages — the two are mathematically linked together so that one can go forwards but not back, and the other can very easily go backwards.

---

## Encryption & Decryption

Before getting too deep into the background math, let's take a quick look at how encryption and decryption are actually performed with RSA.

First, all of the background math is done and the **public key** is sent to anybody we want to be able to send us encrypted messages. This public key is made up of results from all of the background math, and looks like **(n, e)**. Just as a reminder, everybody knows the algorithm and the rules for RSA — this public key is just the values that message senders use to scramble their messages.

When someone wants to send a message, they turn it into a positive integer (whole number) that has to be less than whatever value *n* is. As an added step of security, this process is done through something called a **padding scheme** that both the sender and recipient agree on. This padding scheme takes the message, turns it into a number, and then sprinkles in some junk information. This is done because the RSA algorithm is **deterministic** — meaning if I input "Hello World" and it scrambles to "aL1Cx09E", it will scramble to that every single time.

Due to this property, attackers can put together something called a **Rainbow Table** where they run a bunch of information through a cryptosystem and then check if any encrypted messages match what they've already computed.

For example: if an attacker has a database of common passwords and runs them all through a deterministic algorithm, they're left with a table of what each password looks like in ciphertext:

```
1234 = abcd
2345 = bcde
```

If they then compromise a company and see all customer passwords stored in ciphertext, they can compare against their rainbow table:

```
Jennifer Mack   = lmno
David Lightman  = bcde
```

They already know **bcde = 2345**, so they now know this user's password. Padding neutralizes this attack. If the system adds "1" to each end before encrypting, **1234 ≠ 112341** so they produce different ciphertext. The system also needs to know to remove "1" from each end when decrypting — so this rule must be kept secret to prevent attackers from guessing.

With that aside: we take our message, turn it into a positive number less than *n*, pad it using an agreed method, and then encrypt it with the following formula:

<div class="blog-math">c ≡ m<sup>e</sup> (mod n)</div>

<div class="blog-callout">
<strong>c</strong> = ciphertext &nbsp;&nbsp;
<strong>m</strong> = message as a number &nbsp;&nbsp;
<strong>e</strong> = part of the public key &nbsp;&nbsp;
<strong>n</strong> = part of the public key
</div>

The recipient uses their private key to recover the original message:

<div class="blog-math">c<sup>d</sup> ≡ (m<sup>e</sup>)<sup>d</sup> ≡ m (mod n)</div>

<div class="blog-callout">
<strong>c</strong> = ciphertext &nbsp;&nbsp;
<strong>d</strong> = part of the private key &nbsp;&nbsp;
<strong>m</strong> = the original message
</div>

After computing c<sup>d</sup>, the padded original message is returned. Remove the padding and you're left with a perfectly pristine plaintext.

---

## Modular Arithmetic

Regular everyday math, or **standard arithmetic**, uses an infinite number line. If we do 5 + 5 that equals 10; add 5 again and we get 15.

**Modular arithmetic** is more accurately described as a finite number circle, rather than an infinite number line. If you've seen a problem like *x + y ≡ z (mod n)*, that's modular arithmetic.

With the previous example, let's say we have a modulus of 12 (mod 12). We now have a number circle with digits 0–11:

```
5 + 5  ≡ 10 (mod 12)
10 + 5 ≡  3 (mod 12)
```

You may have noticed that modular arithmetic doesn't use the = sign. Instead of x being equal to y, x is *congruent* to y — meaning "this number lands in the same spot on the number circle." With 10 + 5 ≡ 3 (mod 12): we start at 10, go to 11, and since going above n−1 resets us to 0, we end at 3. We would have gotten the same result starting at 3, so 10 + 5 is congruent to 3 in a mod 12 system.

<div class="blog-callout">
<strong>Special characteristic:</strong> There are only whole numbers in modular arithmetic.
</div>

---

## Foundational Number Theory

### Factors

A factor is any whole number that divides evenly into another number without a remainder — numbers you can multiply together to produce a given product.

<div class="blog-callout"><strong>Example:</strong> The factors of 10 are 1, 2, 5, and 10.</div>

### Composite Numbers

Non-prime numbers larger than one, or any number that can be reached by multiplying numbers other than 1 and itself.

<div class="blog-callout"><strong>Example:</strong> 6 = 3 × 2</div>

### Prime Numbers

Any number whose only whole factors are 1 and itself.

<div class="blog-callout"><strong>Example:</strong> To reach 7 with whole number multiplication you can only perform 7 × 1.</div>

---

## Trapdoor Functions & Prime Factorization

**Trapdoor functions** are mathematical functions that are easy to compute in one direction, but extremely difficult to reverse without special information.

**Prime factorization** is one such trapdoor function. It is the process of breaking down composite numbers into their prime building blocks.

- 60 = 10 × 6
- 10 = 2 × 5 (both prime)
- 6 = 2 × 3 (both prime)
- Prime factorization of 60: 2 × 2 × 3 × 5, or (2²) × 3 × 5

<div class="blog-callout">
<strong>Special characteristic:</strong> Prime factorization is extremely computationally expensive for very large numbers. Computers must essentially brute-force every possible combination of numbers that could be the prime factors.
</div>

To illustrate: RSA creates a number *n* from two very large prime numbers, *p* and *q*. Even knowing there are only two prime factors, in RSA each one is approximately 300 digits long, and *n* ends up as a 617-digit number. There are more 300-digit prime numbers than there are atoms in the observable universe. While it could theoretically be factored, "eventually" in this context means hundreds of trillions of years using classical computers.

---

## Piecewise Functions & Carmichael's Totient Function

A **piecewise function** essentially means: "Input *n*, apply one of these various algorithms depending on the value of *n*." The Carmichael totient function is slightly recursive: if *n* can be broken down into prime factors, you use the third equation, which then applies the first equation to each prime factor separately and finds the least common multiple of the results.

This specific piecewise function is used in one of the key generation steps for RSA.

---

## Coprime Numbers

Numbers are **coprime** to each other when they share no common factors other than 1. These numbers don't have to be prime themselves.

- 21: factors are 1, 3, 7, 21
- 22: factors are 1, 2, 11, 22
- The only overlap is 1, so they are coprime

<div class="blog-callout">
<strong>Special characteristics:</strong><br>
1 is coprime to every number since the only factor it can share with another number is 1.<br>
Prime numbers are always coprime to each other.
</div>

---

## Euler's Totient Function

Euler's Totient Function (φ) asks: "If we look at numbers smaller than *n*, how many of those are coprime to *n*?"

*Example:* **φ(6) = 2**

- 1, 2, 3, 4, 5 are all smaller than 6
- 2, 3, and 4 share factors with 6 other than 1 (2 shares 2; 3 shares 3; 4 shares 2)
- The remaining coprimes are: 1 and 5

<div class="blog-callout">
<strong>Special characteristic:</strong> For prime numbers, φ will always equal n − 1. So φ(181) = 180. Because prime numbers have only 1 and themselves as factors, all smaller numbers can only share 1 as a common factor.
</div>

---

## Multiplicative Inverse (Reciprocal)

The **multiplicative inverse** of a number is simple: if we have 5 (expressed as 5/1), the inverse is 1/5, and 5/1 × 1/5 = 1. Essentially, "What number multiplied by *x* makes the result equal 1?" This can also be expressed as x⁻¹.

In modular arithmetic the perspective shifts to: "What whole number undoes multiplication by x?"

<div class="blog-math">a × x ≡ 1 (mod m)</div>

Finding x such that 5x ≡ 1 (mod 11), testing whole numbers:

```
5 × 1 ≡  5 (mod 11)
5 × 2 ≡ 10 (mod 11)
...
5 × 9 ≡ 45 (mod 11)  →  45 = 4 × 11 + 1  →  remainder 1
```

<div class="blog-callout">
<strong>Therefore:</strong> 5 × 9 ≡ 1 (mod 11), so the modular inverse of 5 mod 11 is 9.
</div>

<div class="blog-callout">
<strong>Important:</strong> In modular arithmetic not every number has a reciprocal. A modular inverse exists if and only if <em>a</em> and <em>m</em> are coprime.
</div>

The previous example used brute force. For larger numbers we use the **Extended Euclidean Algorithm**.

---

## The Extended Euclidean Algorithm & Bézout's Identity

**Bézout's Identity** is a foundational aspect of number theory. If *a* and *b* are integers with a greatest common divisor of *d* (i.e., gcd(a, b) = d), then there exist integers *x* and *y* such that:

<div class="blog-math">ax + by = d</div>

Simply put: if *a* and *b* have a gcd of *d*, then a×something + b×something = d. Bézout tells you they exist; the Extended Euclidean Algorithm helps you find them.

If a and b are coprime we can simplify to:

<div class="blog-math">ax + by = 1</div>

And in a modular system:

<div class="blog-math">ax ≡ 1 (mod b)</div>

<div class="blog-callout">
<strong>This means:</strong> x is the modular reciprocal of a modulo b, and running the extended Euclidean algorithm will always terminate at 1.
</div>

Let's work through an example using the RSA equivalents: **e = 23, d = x, λ(n) = 30**

<div class="blog-math">23 × d ≡ 1 (mod 30)</div>

This asks: "What number leaves a remainder of 1 in a mod 30 system when multiplied by 23?"

### Phase 1: Standard Euclidean Algorithm

Use successive integer division to find gcd(23, 30). Integer division notation: **a = (b × q) + r**

- **a** = Dividend &nbsp; **b** = Divisor &nbsp; **q** = Quotient &nbsp; **r** = Remainder

```
30 = 1×23 + 7   →   30/23 = 1 remainder 7
23 = 3×7  + 2   →   23/7  = 3 remainder 2
 7 = 3×2  + 1   →    7/2  = 3 remainder 1
 2 = 2×1  + 0   →    2/1  = 2, no remainder — stop
```

Last non-zero remainder = 1, confirming gcd(23, 30) = 1 and a reciprocal exists.

### Phase 2: Back-Substitution

We work backwards through Phase 1, isolating remainders and substituting them into each other until we express 1 as a combination of 30 and 23.

Starting from the last useful equation and isolating remainder 1:

```
1 = 7 − 3(2)
```

Re-write step 2 to isolate its remainder (2):

```
2 = 23 − 3(7)
```

Substitute 2 into the isolated 1 equation:

```
1 = 7 − 3(23 − 3(7))
```

Distribute and group:

```
1 = 7 − 3(23) + 9(7)  →  1 = 10(7) − 3(23)
```

Expand 7 using step 1 (7 = 30 − 1×23):

```
1 = 10(30 − 1(23)) − 3(23)
1 = 10(30) − 10(23) − 3(23)
1 = 10(30) − 13(23)
```

Convert to modular form (mod 30). Since 10×30 is a multiple of 30, it cancels out:

```
−13(23) ≡ 1 (mod 30)
```

The inverse is −13. To convert to a positive value, add the modulus (30):

<div class="blog-callout">
<strong>−13 + 30 = 17  →  d = 17</strong>
</div>

---

## RSA Walkthrough

With all of the building blocks in place, let's walk through each step of RSA key generation and map it back to the concepts we covered.

### Step 1 — Choose Two Distinct Large Primes

*p* and *q* are kept secret.

<div class="blog-callout">
<strong>p = 7 &nbsp;&nbsp; q = 11</strong><br>
These aren't large enough to be secure, but they make the math easy to follow. In practice, p and q are chosen from primes between 2<sup>1023</sup> and 2<sup>1024</sup>, corresponding to a 2048-bit key.
</div>

### Step 2 — Compute n = p × q

*n* is part of both the public key (e, n) and the private key (d, n).

<div class="blog-callout">
<strong>7 × 11 = 77 &nbsp;&nbsp; → &nbsp;&nbsp; n = 77</strong>
</div>

This links directly to the trapdoor function. It's trivial to multiply two large primes together, but if an attacker only knows *n*, recovering *p* and *q* would take hundreds of trillions of years on classical computers.

### Step 3 — Compute λ(n)

Using Carmichael's totient function: since *n = pq* and both are prime, λ(p) = p − 1 and λ(q) = q − 1, so λ(n) = lcm(p − 1, q − 1).

```
lcm(φ(7−1), φ(11−1)) = lcm(φ(6), φ(10)) = lcm(6, 10) = 30
```

<div class="blog-callout">
<strong>λ(n) = 30 — kept secret</strong>
</div>

### Step 4 — Choose e

Pick an integer *e* such that 1 < e < λ(n) and gcd(e, λ(n)) = 1 — that is, *e* and λ(n) must be coprime.

<div class="blog-callout">
<strong>e = 23 — part of the public key (e, n)</strong>
</div>

### Step 5 — Determine d

Find the modular multiplicative inverse of *e* modulo λ(n): d ≡ e⁻¹ (mod λ(n)). This is exactly the Extended Euclidean Algorithm we completed above.

```
23 × d ≡ 1 (mod 30)
```

<div class="blog-callout">
<strong>d = 17 — part of the private key (d, n)</strong>
</div>

### The Keys

<div class="blog-callout"><strong>Public Key: &nbsp;&nbsp; (e, n) = (23, 77)</strong></div>
<div class="blog-callout"><strong>Private Key: &nbsp;&nbsp; (d, n) = (17, 77)</strong></div>
<div class="blog-callout"><strong>Other Secrets: &nbsp;&nbsp; λ(n), p, q — with any of these, the private key can be derived</strong></div>

Both keys share *n*, which acts as a constant for all calculations. *e* can encrypt a message, and *d* reverses that process because it is literally the mathematical "undo button" for *e*.

---

## Revisiting Encryption & Decryption

In order to complete the circle here, let's take the values we calculated and see how they apply to the actual encryption and decryption formulae. One other thing to note is that RSA is usually used for very small numbers. For this example our message will equal 2 when converted to integer form, because larger numbers were crashing even the most extreme "big number" calculators I could find. Also remember that the integer m has to be above 0 but less than n, in this case 77.

**Encryption:**

<div class="blog-math">c ≡ m<sup>e</sup> (mod n) → c ≡ m<sup>23</sup> (mod 77)</div>

**Decryption:**

<div class="blog-math">c<sup>d</sup> ≡ (m<sup>e</sup>)<sup>d</sup> ≡ m (mod n) → c<sup>17</sup> ≡ (m<sup>23</sup>)<sup>17</sup> ≡ m (mod 77)</div>

A slightly more useful form:

<div class="blog-math">c<sup>d</sup> (mod n) ≡ m</div>

Let's say I want to encrypt the message "hi" — for simplicity we'll say hi = 2 as the padding scheme, so m = 2.

**Encryption:**

```
c ≡ 2^23 (mod 77) ≡ 74
```

So the plaintext "hi" becomes the ciphertext **74**.

**Decryption:**

```
c^d (mod n) → 74^17 (mod 77) = 2
```

Since the padding scheme is an agreed upon part of the equation, the recipient will know that 2 = "hi."

---

## Real World Security

Because we had to use very small numbers to make things more digestible, this is unfortunately an insecure setup. Because e = 23 and n = 77 are known, an attacker could brute force c = 74. Since m is between 0 and 77 they just need to calculate x²³ for all values between those numbers to see what lands on ciphertext 74. The second they compute 2²³ = 74 they know the plaintext message was 2. This is why padding and proper key sizes are so important.

In our example there were only 76 possible messages. In the real world we usually ensure there are **2²⁰⁴⁸** possible messages, which is a 617-digit number. Just for fun, and to put things into perspective here is 2²⁰⁴⁸ written out in plain English, e.g. 1000 = one thousand:

<div class="blog-bignum">
Thirty-Two Quattuorducentillion Three Hundred Seventeen Treducentillion Six Duoducentillion Seventy-One Unducentillion Three Hundred Eleven Ducentillion Seven Novemnonagintacentillion Three Hundred Octononagintacentillion Seven Hundred Fourteen Septennonagintacentillion Eight Hundred Seventy-Six Sexnonagintacentillion Six Hundred Eighty-Eight Quinnonagintacentillion Six Hundred Sixty-Nine Quattuornonagintacentillion Nine Hundred Fifty-One Trenonagintacentillion Nine Hundred Sixty Duononagintacentillion Four Hundred Forty-Four Unnonagintacentillion One Hundred Two Nonagintacentillion Six Hundred Sixty-Nine Novemoctogintacentillion Seven Hundred Fifteen Octooctogintacentillion Four Hundred Eighty-Four Septenoctogintacentillion Thirty-Two Sexoctogintacentillion One Hundred Thirty Quinoctogintacentillion Three Hundred Forty-Five Quattuoroctogintacentillion Four Hundred Twenty-Seven Treoctogintacentillion Five Hundred Twenty-Four Duooctogintacentillion Six Hundred Fifty-Five Unoctogintacentillion One Hundred Thirty-Eight Octogintacentillion Eight Hundred Sixty-Seven Novemseptuagintacentillion Eight Hundred Ninety Octoseptuagintacentillion Eight Hundred Ninety-Three Septenseptuagintacentillion One Hundred Ninety-Seven Sexseptuagintacentillion Two Hundred One Quinseptuagintacentillion Four Hundred Eleven Quattuorseptuagintacentillion Five Hundred Twenty-Two Treseptuagintacentillion Nine Hundred Thirteen Duoseptuagintacentillion Four Hundred Sixty-Three Unseptuagintacentillion Six Hundred Eighty-Eight Septuagintacentillion Seven Hundred Seventeen Novemsexagintacentillion Nine Hundred Sixty Octosexagintacentillion Nine Hundred Twenty-One Septensexagintacentillion Eight Hundred Ninety-Eight Sexsexagintacentillion Nineteen Quinsexagintacentillion Four Hundred Ninety-Four Quattuorsexagintacentillion One Hundred Nineteen Tresexagintacentillion Five Hundred Fifty-Nine Duosexagintacentillion One Hundred Fifty Unsexagintacentillion Four Hundred Ninety Sexagintacentillion Nine Hundred Twenty-One Novemquinquagintacentillion Ninety-Five Octoquinquagintacentillion Eighty-Eight Septenquinquagintacentillion One Hundred Fifty-Two Sexquinquagintacentillion Three Hundred Eighty-Six Quinquinquagintacentillion Four Hundred Forty-Eight Quattuorquinquagintacentillion Two Hundred Eighty-Three Trequinquagintacentillion One Hundred Twenty Duoquinquagintacentillion Six Hundred Thirty Unquinquagintacentillion Eight Hundred Seventy-Seven Quinquagintacentillion Three Hundred Sixty-Seven Novemquadragintacentillion Three Hundred Octoquadragintacentillion Nine Hundred Ninety-Six Septenquadragintacentillion Ninety-One Sexquadragintacentillion Seven Hundred Fifty Quinquadragintacentillion One Hundred Ninety-Seven Quattuorquadragintacentillion Seven Hundred Fifty Trequadragintacentillion Three Hundred Eighty-Nine Duoquadragintacentillion Six Hundred Fifty-Two Unquadragintacentillion One Hundred Six Quadragintacentillion Seven Hundred Ninety-Six Novemtrigintacentillion Fifty-Seven Octotrigintacentillion Six Hundred Thirty-Eight Septentrigintacentillion Three Hundred Eighty-Four Sextrigintacentillion Sixty-Seven Quintrigintacentillion Five Hundred Sixty-Eight Quattuortrigintacentillion Two Hundred Seventy-Six Tretrigintacentillion Seven Hundred Ninety-Two Duotrigintacentillion Two Hundred Eighteen Untrigintacentillion Six Hundred Forty-Two Trigintacentillion Six Hundred Nineteen Novemviginticentillion Seven Hundred Fifty-Six Octoviginticentillion One Hundred Sixty-One Septenviginticentillion Eight Hundred Thirty-Eight Sexviginticentillion Ninety-Four Quinviginticentillion Three Hundred Thirty-Eight Quattuorviginticentillion Four Hundred Seventy-Six Treviginticentillion One Hundred Seventy Duoviginticentillion Four Hundred Seventy Unviginticentillion Five Hundred Eighty-One Viginticentillion Six Hundred Forty-Five Novemdecicentillion Eight Hundred Fifty-Two Octodecicentillion Thirty-Six Septendecicentillion Three Hundred Five Sexdecicentillion Forty-Two Quindecicentillion Eight Hundred Eighty-Seven Quattuordecicentillion Five Hundred Seventy-Five Tredecicentillion Eight Hundred Ninety-One Duodecicentillion Five Hundred Forty-One Undecicentillion Sixty-Five Decicentillion Eight Hundred Eight Novemcentillion Six Hundred Seven Octocentillion Five Hundred Fifty-Two Septencentillion Three Hundred Ninety-Nine Sexcentillion One Hundred Twenty-Three Quincentillion Nine Hundred Thirty Quattuorcentillion Three Hundred Eighty-Five Trescentillion Five Hundred Twenty-One Duocentillion Nine Hundred Fourteen Uncentillion Three Hundred Thirty-Three Centillion Three Hundred Eighty-Nine Novemnonagintillion Six Hundred Sixty-Eight Octononagintillion Three Hundred Forty-Two Septennonagintillion Four Hundred Twenty Sexnonagintillion Six Hundred Eighty-Four Quinnonagintillion Nine Hundred Seventy-Four Quattuornonagintillion Seven Hundred Eighty-Six Trenonagintillion Five Hundred Sixty-Four Duononagintillion Five Hundred Sixty-Nine Unnonagintillion Four Hundred Ninety-Four Nonagintillion Eight Hundred Fifty-Six Novemoctogintillion One Hundred Seventy-Six Octooctogintillion Thirty-Five Septenoctogintillion Three Hundred Twenty-Six Sexoctogintillion Three Hundred Twenty-Two Quinoctogintillion Fifty-Eight Quattuoroctogintillion Seventy-Seven Treoctogintillion Eight Hundred Five Duooctogintillion Six Hundred Fifty-Nine Unoctogintillion Three Hundred Thirty-One Octogintillion Twenty-Six Novemseptuagintillion One Hundred Ninety-Two Octoseptuagintillion Seven Hundred Eight Septenseptuagintillion Four Hundred Sixty Sexseptuagintillion Three Hundred Fourteen Quinseptuagintillion One Hundred Fifty Quattuorseptuagintillion Two Hundred Fifty-Eight Treseptuagintillion Five Hundred Ninety-Two Duoseptuagintillion Eight Hundred Sixty-Four Unseptuagintillion One Hundred Seventy-Seven Septuagintillion One Hundred Sixteen Novemsexagintillion Seven Hundred Twenty-Five Octosexagintillion Nine Hundred Forty-Three Septensexagintillion Six Hundred Three Sexsexagintillion Seven Hundred Eighteen Quinsexagintillion Four Hundred Sixty-One Quattuorsexagintillion Eight Hundred Fifty-Seven Tresexagintillion Three Hundred Fifty-Seven Duosexagintillion Five Hundred Ninety-Eight Unsexagintillion Three Hundred Fifty-One Sexagintillion One Hundred Fifty-Two Novemquinquagintillion Three Hundred One Octoquinquagintillion Six Hundred Forty-Five Septenquinquagintillion Nine Hundred Four Sexquinquagintillion Four Hundred Three Quinquinquagintillion Six Hundred Ninety-Seven Quattuorquinquagintillion Six Hundred Thirteen Trequinquagintillion Two Hundred Thirty-Three Duoquinquagintillion Two Hundred Eighty-Seven Unquinquagintillion Two Hundred Thirty-One Quinquagintillion Two Hundred Twenty-Seven Novemquadragintillion One Hundred Twenty-Five Octoquadragintillion Six Hundred Eighty-Four Septenquadragintillion Seven Hundred Ten Sexquadragintillion Eight Hundred Twenty Quinquadragintillion Two Hundred Nine Quattuorquadragintillion Seven Hundred Twenty-Five Trequadragintillion One Hundred Fifty-Seven Duoquadragintillion One Hundred One Unquadragintillion Seven Hundred Twenty-Six Quadragintillion Nine Hundred Thirty-One Novemtrigintillion Three Hundred Twenty-Three Octotrigintillion Four Hundred Sixty-Nine Septentrigintillion Six Hundred Seventy-Eight Sextrigintillion Five Hundred Forty-Two Quintrigintillion Five Hundred Eighty Quattuortrigintillion Six Hundred Fifty-Six Tretrigintillion Six Hundred Ninety-Seven Duotrigintillion Nine Hundred Thirty-Five Untrigintillion Forty-Five Trigintillion Nine Hundred Ninety-Seven Novemvigintillion Two Hundred Sixty-Eight Octovigintillion Three Hundred Fifty-Two Septenvigintillion Nine Hundred Ninety-Eight Sexvigintillion Six Hundred Thirty-Eight Quinvigintillion Two Hundred Fifteen Quattuorvigintillion Five Hundred Twenty-Five Trevigintillion One Hundred Sixty-Six Duovigintillion Three Hundred Eighty-Nine Unvigintillion Four Hundred Thirty-Seven Vigintillion Three Hundred Thirty-Five Novemdecillion Five Hundred Forty-Three Octodecillion Six Hundred Two Septendecillion One Hundred Thirty-Five Sexdecillion Four Hundred Thirty-Three Quindecillion Two Hundred Twenty-Nine Quattuordecillion Six Hundred Four Tredecillion Six Hundred Forty-Five Duodecillion Three Hundred Eighteen Undecillion Four Hundred Seventy-Eight Decillion Six Hundred Four Nonillion Nine Hundred Fifty-Two Octillion One Hundred Forty-Eight Septillion One Hundred Ninety-Three Sextillion Five Hundred Fifty-Five Quintillion Eight Hundred Fifty-Three Quadrillion Six Hundred Eleven Trillion Fifty-Nine Billion Five Hundred Ninety-Six Million Two Hundred Thirty Thousand Six Hundred Fifty-Six point Zero. (And a partridge in a pear tree…)
</div>

*(Number conversion courtesy of [DenCode](https://dencode.com/en/number/english))*

---

## Closing Thoughts

I hope this has made the inner workings of RSA a bit more accessible. The concepts here can be quite a bit to digest; it personally took three days of learning about all of these concepts and writing this to feel like I actually had a grasp on what was going on.

This whole process left me with a much deeper appreciation for how certain aspects of cybersecurity actually work. The math is genuinely interesting, and there have been so many hands at work over hundreds of years to get to this point. Euler lived in the 1700s; Robert Carmichael defined his function in 1910; the father of number theory himself, Pierre de Fermat, lived in the 1600s; and then there are the geniuses who contributed to computing itself — Ada Lovelace, Alan Turing, and many others. Mountains of work, hundreds of years, these (what are essentially)wizards spanning history, and we're left with wildly cool frameworks that keep billions of people on the internet safe and secure.

*Thank you for reading! If you have any feedback feel free to connect via my Linkedin or Email!*
