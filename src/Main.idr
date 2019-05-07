module Gspider.Main

import Data.Vect
import Data.SortedMap

import Core
import File.FrequencyFileParsing
import File.ProbabilityConversion
import File.DistributionCalculation
import File.SystemLoading
import Types.Probability
import Types.AttackFrame
import Types.RestrictedCharString


||| Looks up a password probability in a list.
|||
||| @probs  the list of password probabilities
||| @pwd    the password to look up
lookup : (probs : List (PasswordProbability s)) -> (pwd : RestrictedCharString s) -> Probability
lookup [] _ = imposs
lookup ((MkPasswordProbability pwd' prob) :: probs') pwd =
  if pwd == pwd' then
    prob
  else
    lookup probs' pwd


||| Looks up a password probability in a sorted map.
|||
||| @probs  the list of password probabilities
||| @pwd    the password to look up
lookupEff : (probs : SortedMap (RestrictedCharString s) Probability) -> (pwd : RestrictedCharString s) -> Probability
lookupEff probs pwd =
  case lookup pwd probs of
    Just prob => prob
    _ => imposs


||| Converts a list of password probabilities into a list of tuples.
|||
||| @probs  the list of password probabilities
toTuples : (probs : List (PasswordProbability s)) -> List (RestrictedCharString s, Probability)
toTuples probs = map (\(MkPasswordProbability pwd prob) => (pwd, prob)) probs


||| Loads a password probability distribution.
|||
||| @s      the system
||| @path   the path to the frequency file
loadDist : (s : System) -> (path : String) -> IO (Maybe (Distribution s))
loadDist s path = do
  txt <- readFile path
  case txt of
    (Right txt') =>
      let rows = parse_rows ':' txt'
          raw_probs = to_probs rows
          probs = enforce_sys s raw_probs
          tuples = toTuples probs
      in
      pure (Just (lookupEff (fromList tuples)))
    _ => pure Nothing


||| Loads an attack.
|||
||| @s      the system
||| @path   the path to the file
loadAtt : (s : System) -> (path : String) -> IO (Maybe (List (RestrictedCharString s)))
loadAtt s path = do
  txt <- readFile path
  case txt of
    (Right txt') => pure (Just (convertToRestricted s (lines txt')))
    _ => pure Nothing


||| Initialises a probabilistic attack frame.
|||
||| @att    the attack
||| @dist   the distribution
initFrame : (att : Vect n (RestrictedCharString s)) -> (dist : Distribution s) -> AttackFrame s n 0
initFrame [] dist = Empty dist
initFrame att@(_ :: _) dist = Initial att dist


||| Runs a probabilistic attack frame to completion, printing each probability.
|||
||| @paf    the probabilistic attack frame
runFrame : (paf : AttackFrame s n m) -> IO ()
runFrame (Empty _) = putStrLn "Frame is empty."
runFrame paf@(Initial _ _) = do
  next <- pure (advance paf)
  putStrLn ("Frame is initial.")
  case next of
    Ongoing _ _ _ q => putStrLn (toString q)
    Terminal _ _ q => putStrLn (toString q)
  runFrame next
runFrame paf@(Ongoing _ _ _ _) = do
  next <- pure (advance paf)
  case next of
    Ongoing _ _ _ q => putStrLn (toString q)
    Terminal _ _ q => putStrLn (toString q)
  runFrame next
runFrame (Terminal _ _ _) = putStrLn "Frame is terminal."


main : IO ()
main = do
  [arg_prog, arg_sys, arg_dist, arg_att] <- getArgs -- TODO: Bind alternatives!
  Just s <- loadSystem arg_sys | Nothing => putStrLn "Error: Could not load system."
  Just dist <- loadDist s arg_dist | Nothing => putStrLn "Error: Could not load distribution."
  Just att <- loadAtt s arg_att | Nothing => putStrLn "Error: Could not load attack."
  let frame = initFrame (fromList att) dist -- Initialise probabilistic attack frame.
  runFrame frame -- Run PAF to completion.
