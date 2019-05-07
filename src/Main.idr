module Gspider.Main

import Core
import File.FrequencyFileParsing
import File.ProbabilityConversion
import File.DistributionCalculation
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


main : IO ()
main = putStrLn "Hello world!"
-- TODO: Load attack, sys and dist from args.
-- TODO: Put everything into PAF.
-- TOOD: Run PAF to completion.
