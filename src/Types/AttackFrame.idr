module Gspider.Types.AttackFrame


import Data.Vect

import Core
import Types.RestrictedCharString


%access private


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
            (q : Double) ->
            AttackFrame s (S n) (S m)
  Terminal : (g : Vect (S m) (RestrictedCharString s)) ->
             (d : Distribution s) ->
             (q : Double) ->
             AttackFrame s Z (S m)


||| Gets the probability of a password in a distribution given that it is not present in a collection.
|||
||| @ p the password
||| @ d the distribution
||| @ g the collection
distinctProb : (p : (RestrictedCharString s)) ->
               (d : Distribution s) ->
               (g : Vect n (RestrictedCharString s)) ->
               Double
distinctProb p d g = if elem p g then 0 else d p


||| Advances an attack to the next frame.
|||
||| @ frame the frame to advance
export
advance : (frame : AttackFrame s (S n) m) -> AttackFrame s n (S m)
advance (Initial [p] d) = Terminal [p] d (d p)
advance (Initial (p :: rest@(p' :: ps)) d) = Ongoing rest [p] d (d p)
advance (Ongoing [p] g d q) = Terminal (p :: g) d (q + (distinctProb p d g))
advance (Ongoing (p :: rest@(p' :: ps)) g d q) = Ongoing rest (p :: g) d (q + (distinctProb p d g))


||| Retreats an attack to the previous frame.
|||
||| @ frame the frame to retreat
export
retreat : (frame : AttackFrame s n (S m)) -> AttackFrame s (S n) m
retreat (Ongoing p [g] d q) = Initial (g :: p) d
retreat (Ongoing p (g :: rest@(g' :: gs)) d q) = Ongoing (g :: p) rest d (q - (distinctProb g d rest))
retreat (Terminal [g] d q) = Initial [g] d
retreat (Terminal (g :: rest@(g' :: gs)) d q) = Ongoing [g] rest d (q - (distinctProb g d rest))
