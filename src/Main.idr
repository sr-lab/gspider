module Gspider.Main


import Data.Vect
import Data.SortedMap

import Core
import Probabilistic
import File.FrequencyFileParsing
import File.SystemLoading
import Types.AttackFrame
import Types.RestrictedCharString


||| Looks up a password probability in a sorted map.
|||
||| @probs  the list of password probabilities
||| @pwd    the password to look up
lookupEff : (probs : SortedMap (RestrictedCharString s) Double) -> (pwd : RestrictedCharString s) -> Double
lookupEff probs pwd =
  case lookup pwd probs of
    Just prob => prob
    _ => 0


||| Unzips a list of password frequency records into two lists.
|||
||| @freqs  the list of password frequencies
splitFreqRecords : (freqs : List PasswordFrequency) -> (List String, List Int)
splitFreqRecords [] = ([], [])
splitFreqRecords (x :: xs) =
  let (ps, fs) = splitFreqRecords xs in
  ((pwd x) :: ps, (freq x) :: fs)


||| Converts a system and a list of password frequency records to a distribution.
|||
||| @s      the system to convert under
||| @freqs  the frequencies to use to build the distribution
toDist : (s : System) -> (freqs : List PasswordFrequency) -> Prob (RestrictedCharString s)
toDist s [] = flat []
toDist s freqs =
  let (ps, fs) = splitFreqRecords freqs in
  shape (convertToRestricted s ps) (map cast fs)
  

||| Loads a password probability distribution.
|||
||| @s      the system
||| @path   the path to the frequency file
loadDist : (s : System) -> (path : String) -> IO (Maybe (Distribution s))
loadDist s path = do
  txt <- readFile path
  case txt of
    (Right txt') =>
      let rows = parseRows ':' txt'
          dist = toDist s rows
          tuples = runProb dist
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
runFrame : (paf : AttackFrame _ _ _) -> IO ()
runFrame (Empty _) = putStrLn "Frame is empty."
runFrame paf@(Initial _ _) = do
  next <- pure (advance paf)
  putStrLn ("Frame is initial.")
  case next of
    Ongoing _ _ _ q => putStrLn (cast q)
    Terminal _ _ q => putStrLn (cast q)
  runFrame next
runFrame paf@(Ongoing _ _ _ _) = do
  next <- pure (advance paf)
  case next of
    Ongoing _ _ _ q => putStrLn (cast q)
    Terminal _ _ q => putStrLn (cast q)
  runFrame next
runFrame (Terminal _ _ _) = putStrLn "Frame is terminal."


main : IO ()
main = do
  [_, arg_sys, arg_dist, arg_att] <- getArgs -- TODO: Bind alternatives!
  Just s <- loadSystem arg_sys | Nothing => putStrLn "Error: Could not load system."
  Just dist <- loadDist s arg_dist | Nothing => putStrLn "Error: Could not load distribution."
  Just att <- (if arg_att == "ideal" then loadAtt s arg_att else loadAtt s arg_att) | Nothing => putStrLn "Error: Could not load attack."
  let frame = initFrame (fromList att) dist -- Initialise probabilistic attack frame.
  runFrame frame -- Run PAF to completion.
