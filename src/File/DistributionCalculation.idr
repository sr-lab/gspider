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
  MkPasswordProbability : (pwd : RestrictedCharString s) ->
                          (prob : Probability) ->
                          PasswordProbability s


||| Totals up the probabilities in a list of probability records.
|||
||| @probs the records to total
totalProb : (probs : List (PasswordProbability s)) -> Probability
totalProb probs = sum (map (\(MkPasswordProbability _ prob) => prob) probs)


||| Removes password probabilities that are invalid on a given system.
|||
||| @s the system
||| @probs the password probabilities
export
removeNonSys : (s : System) -> (probs : List RawPasswordProbability) -> List (PasswordProbability s)
removeNonSys s [] = []
removeNonSys s (x :: xs) =
  case restrictStr s (pwd x) of
    Nothing => removeNonSys s xs
    Just y => (MkPasswordProbability y (prob x)) :: (removeNonSys s xs)


||| Removes password probabilities that are invalid on a given system and redistributes probabilities accordingly.
|||
||| @s the system
||| @probs the password probabilities
export
enforceSys : (s : System) -> (probs : List RawPasswordProbability) -> List (PasswordProbability s)
enforceSys s probs =
  let valid_only = removeNonSys s probs
      surplus_prob = (totalRawProb probs) - (totalProb valid_only) in
      map (\(MkPasswordProbability f g) => MkPasswordProbability f (g + (g * surplus_prob))) valid_only
