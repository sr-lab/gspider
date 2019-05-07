module Gspider.File.DistributionCalculation


import Core
import Types.RestrictedCharString
import Types.Probability
import File.FrequencyFileParsing
import File.ProbabilityConversion


%access private


||| Represents a password probability.
|||
public export
data PasswordProbability : (s : System) -> Type where
  MkPasswordProbability : (ord : Int) ->
                          (pwd : RestrictedCharString s) ->
                          (prob : Probability) ->
                          PasswordProbability s


||| Totals up the probabilities in a list of probability records.
|||
||| @probs the records to total
total_prob : (probs : List (PasswordProbability s)) -> Probability
total_prob probs = sum (map (\(MkPasswordProbability _ _ prob) => prob) probs)


||| Removes password probabilities that are invalid on a given system.
|||
||| @s the system
||| @probs the password probabilities
export
remove_non_sys : (s : System) -> (probs : List RawPasswordProbability) -> List (PasswordProbability s)
remove_non_sys s [] = []
remove_non_sys s (x :: xs) =
  case restrictStr s (pwd x) of
    Nothing => remove_non_sys s xs
    Just y => (MkPasswordProbability (ord x) y (prob x)) :: (remove_non_sys s xs)


||| Removes password probabilities that are invalid on a given system and renormalizes valid probabilities accordingly.
|||
||| @s the system
||| @probs the password probabilities
export
enforce_sys : (s : System) -> (probs : List RawPasswordProbability) -> List (PasswordProbability s)
enforce_sys s probs =
  let valid_only = remove_non_sys s probs
      surplus_prob = (total_prob probs) - (total_prob valid_only) in
      map (\(MkPasswordProbability d f g) => MkPasswordProbability d f (g + (g * surplus_prob))) valid_only
