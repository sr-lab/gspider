# GSPIDER
Guess success probability slider, for plotting the evolution of password guessing attacks.

![Logo](assets/logo-text-h.svg)

## Overview
GSPIDER (**g**uess **s**uccess **p**robability sl**ider**) is a utility, written in the dependently-typed programming language [Idris](https://www.idris-lang.org/) that plots the evolution of a password guessing attack against a password dataset. At the moment, it's a proof-of-concept, but it's still usable for small-scale models.

## Dependent Types
Dependent types are employed for type-safe reasoning across systems in the GSPIDER model:

### Bounded Double/Probability
The `BoundedDouble` type represents a `Double` but bounded to lie between a lower and an upper bound. Because operations on `Double` are defined as primitive functions, however, this is non-trivial. The `BoundedDouble` type is defined like this:

```idris
||| Double-precision floating-point numbers bounded to fall between a lower and an upper bound.
|||
||| @a the lower bound
||| @b the upper bound
public export
data BoundedDouble : (a, b : Double) -> Type where
  ||| Constructs a bounded double with the specified value.
  |||
  ||| @x the value of the bounded double
  MkBoundedDouble : (x : Double) ->
                    {auto rightSize : So (a <= b)} ->
                    {auto leftId : So (a <= a)} ->
                    {auto rightId : So (b <= b)} ->
                    {auto high : So (a <= x)} ->
                    {auto low : So (x <= b)} ->
                    BoundedDouble a b
```

From here, specifying a `Probability` type is quite straightforward:

```idris
||| Represents a probability.
public export
Probability : Type
Probability = BoundedDouble 0 1
```

### Restricted Character-Set String
At the core of the probabilistic attack frame type is the restricted character-set string, which is a string type restricted to containing some specific set of characters. It's encoded as below.

```idris
||| Returns true if the given list of characters `str` contains only characters specified in `chars`.
|||
||| @chars the list of permitted characters
||| @str the string to check
madeOf' : (chars : List Char) -> (str : List Char) -> Bool
madeOf' chars [] = True
madeOf' chars (x :: xs) = elem x chars && madeOf' chars xs


||| Returns true if the given string `str` contains only characters specified in `chars`.
|||
||| @chars the list of permitted characters
||| @str the string to check
export
madeOf : (chars : List Char) -> (str : String) -> Bool
madeOf chars str = madeOf' chars (unpack str)


||| Strings that are restricted to only a specific set of characters.
|||
||| @allowed the list of characters allowed in the string
public export
data RestrictedCharString : (allowed : List Char) -> Type where
  ||| Constructs a restricted character set string with the specified value.
  |||
  ||| @val the value of the string
  MkRestrictedCharString : (val : String) ->
                           {auto prf : So (madeOf allowed val)} ->
                           RestrictedCharString allowed
```

### Probabilistic Attack Frames
Probabilistic attack frames are a new datatype, used by GSPIDER, to model guessing attack evolution in a type-safe way. They make use of restricted character-set strings to ensure that both the password distribution and guessing attack relate to passwords containing the same specific subset of characters. It wouldn't make sense, for example, to attempt to input the password `hunter2` on an ATM, which only supports numeric passwords. This is one of the problems that dependently-typed PAFs address (see below).

```idris
||| Represents a probabilistic attack frame.
|||
||| @ n the number of pending guesses at this frame
||| @ m the number of made guesses at this frame
public export
data AttackFrame : (s : System) -> (n : Nat) -> (m : Nat) -> Type where
  -- Included for completeness.
  Empty : (d : Distribution s) ->
          AttackFrame s Z Z
  Initial : (p : Vect (S n) (RestrictedCharString s)) ->
            (d : Distribution s) ->
            AttackFrame s (S n) Z
  Ongoing : (p : Vect (S n) (RestrictedCharString s)) ->
            (g : Vect (S m) (RestrictedCharString s)) ->
            (d : Distribution s) ->
            (q : Probability) ->
            AttackFrame s (S n) (S m)
  Terminal : (g : Vect (S m) (RestrictedCharString s)) ->
             (d : Distribution s) ->
             (q : Probability) ->
             AttackFrame s Z (S m)
```

## Limitations
GSPIDER is still very much in the proof-of-concept stage. With this in mind, there are a few limitations:

* Frequency file/attack size are limited to a few thousand entries each. I this this might be stack space related, but more digging is required.
