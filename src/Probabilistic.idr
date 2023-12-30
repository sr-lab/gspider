||| This file consists of utility types and functions for programming with probabilities.
||| Adapted by Saul Johnosn (@lambdacasserole) for Idris v1.3.4 from: https://github.com/fieldstrength/probability
||| Date: 30/12/2023

module Gspider.Probabilistic


%access private


public export
normalize : List Double -> List Double
normalize l = (/ (sum l)) <$> l

public export
data Probability p a = Pr (List (a,p))

public export
Prob : Type -> Type
Prob = Probability Double

public export
runProb : Probability p a -> List (a,p)
runProb (Pr l) = l

public export
flat : List a -> Prob a
flat l = let s = (1 / (cast $ length l))
  in Pr $ (\x => (x,s)) <$> l

public export
shape : List a -> List Double -> Prob a
shape xs ps = Pr $ zipWith MkPair xs (normalize ps)
