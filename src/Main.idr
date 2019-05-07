module Gspider.Main

import Data.Vect

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
||| @probs the list of password probabilities
||| @x the password to look up
lookup : (probs : List (PasswordProbability s)) -> (x : RestrictedCharString s) -> Probability
lookup [] x = imposs
lookup ((MkPasswordProbability pwd prob) :: xs) x = if pwd == x then prob else lookup xs x


||| Loads a distribution.
|||
||| @s the system
||| @path the path to the file
loadDist : (s : System) -> (path : String) -> IO (Maybe (Distribution s))
loadDist s path = do
  txt <- readFile path
  case txt of
    (Right txt') =>
      let rows = parse_rows ':' txt'
          raw_probs = to_probs rows
          probs = enforce_sys s raw_probs
      in
      pure (Just (lookup probs))
    _ => pure Nothing


||| Loads an attack.
|||
||| @s the system
||| @path the path to the file
loadAtt : (s : System) -> (path : String) -> IO (Maybe (List (RestrictedCharString s)))
loadAtt s path = do
  txt <- readFile path
  case txt of
    (Right txt') => pure (Just (convertToRestricted s (lines txt')))
    _ => pure Nothing


||| Initialises a probabilistic attack frame.
|||
||| @att the attack
||| @dist the distribution
initFrame : (att : Vect n (RestrictedCharString s)) -> (dist : Distribution s) -> AttackFrame s n 0
initFrame [] dist = Empty dist
initFrame att@(x :: xs) dist = Initial att dist


||| Runs a probabilistic attack frame to completion, printing each probability.
|||
||| @paf    the probabilistic attack frame
runFrame : (paf : AttackFrame s n m) -> IO ()
runFrame (Empty d) = putStrLn "Frame is empty."
runFrame paf@(Initial p d) = do
  next <- pure (advance paf)
  putStrLn ("Frame is initial.")
  case next of
    Ongoing _ _ _ q => putStrLn (toString q)
    Terminal _ _ q => putStrLn (toString q)
  runFrame next
runFrame paf@(Ongoing p g d q) = do
  next <- pure (advance paf)
  case next of
    Ongoing _ _ _ q => putStrLn (toString q)
    Terminal _ _ q => putStrLn (toString q)
  runFrame next
runFrame (Terminal g d q) = putStrLn "Frame is terminal."


main : IO ()
main = do
  [arg_prog, arg_sys, arg_dist, arg_att] <- getArgs -- TODO: Bind alternatives!
  Just sys <- loadSystem arg_sys | Nothing => putStrLn "Error: Could not load system."
  Just dist <- loadDist sys arg_dist  | Nothing => putStrLn "Error: Could not load distribution."
  Just att <- loadAtt sys arg_att | Nothing => putStrLn "Error: Could not load attack."
  let frame = initFrame (fromList att) dist -- Initialise probabilistic attack frame.
  runFrame frame -- Run PAF to completion.
