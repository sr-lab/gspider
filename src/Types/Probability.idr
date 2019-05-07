module Gspider.Types.Probability


import Data.So
import public Types.BoundedDouble -- This needs re-exporting.


%access public export


||| Represents a probability.
public export
Probability : Type
Probability = BoundedDouble 0 1


||| Represents probabilistic impossibility.
export
imposs : Probability
imposs = MkBoundedDouble 0


||| Represents probabilistic certainty.
export
certain : Probability
certain = MkBoundedDouble 1


||| Attempts to convert a double-precision floating-point number to a probability.
|||
||| @x the number to try to convert
export
tryMkProbability : (x : Double) -> Maybe Probability
tryMkProbability x = tryBound 0 1 x


||| Converts from a probability back to a double.
|||
||| @p the probability to convert
export
toDouble : (p : Probability) -> Double
toDouble (MkBoundedDouble x) = x

toString : (p : Probability) -> String
toString (MkBoundedDouble x) = cast x
