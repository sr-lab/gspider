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


lookup : (List (PasswordProbability s)) -> RestrictedCharString s -> Probability
lookup [] x = ?lookup_rhs_1
lookup ((MkPasswordProbability ord pwd prob) :: xs) x = if pwd == x then prob else lookup xs x


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


loadAtt : (s : System) -> (path : String) -> IO (Maybe (List (RestrictedCharString s)))
loadAtt s path = do
  txt <- readFile path
  case txt of
    (Right txt') => pure (Just (convertToRestricted s (lines txt')))
    _ => pure Nothing


initFrame : (att : Vect n (RestrictedCharString s)) -> (dist : Distribution s) -> AttackFrame s n 0
initFrame [] dist = Empty dist
initFrame att@(x :: xs) dist = Initial att dist


main : IO ()
main = do
  [arg_prog, arg_sys, arg_dist, arg_att] <- getArgs -- TODO: Bind alternatives!
  Just sys <- loadSystem arg_sys | Nothing => putStrLn "Error: Could not load system."
  Just dist <- loadDist sys arg_dist  | Nothing => putStrLn "Error: Could not load distribution."
  Just att <- loadAtt sys arg_att | Nothing => putStrLn "Error: Could not load attack."
  let frame = initFrame (fromList att) dist
  putStrLn "Hello world!"
-- TOOD: Run PAF to completion.
