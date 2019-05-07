# GSPIDER
Guess success probability slider, for plotting the evolution of password guessing attacks.

![Logo](assets/logo-text-h.svg)

## Overview
GSPIDER (**g**uess **s**uccess **p**robability sl**ider**) is a utility, written in the dependently-typed programming language [Idris](https://www.idris-lang.org/) that plots the evolution of a password guessing attack against a password dataset.

### Probabilistic Attack Frames
A probabilistic attack frame is a new datatype, used by GSPIDER, to model guessing attack evolution in a type-safe way.
