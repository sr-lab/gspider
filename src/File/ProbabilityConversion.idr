module Gspider.File.ProbabilityConversion


import File.FrequencyFileParsing
import Types.Probability


%access private


||| Represents a password probability with no restriction on password character set.
|||
public export
record RawPasswordProbability where
  ||| Constructs a password probability with no restriction on password character set.
  |||
  ||| @ord the guessing order
  ||| @pwd the password
  ||| @prob the probability
  constructor MkRawPasswordProbability
  pwd : String
  prob : Probability


||| Totals up the probabilities in a list of raw probability records.
|||
||| @probs the records to total
export
total_raw_prob : (probs : List RawPasswordProbability) -> Probability
total_raw_prob probs = sum (map prob probs)


||| Attempts to convert a password frequency to a raw password probability.
|||
||| @m the magnitude of the entire dataset
||| @f the frequency to attempt to convert
to_prob : (m : Double) -> (f : PasswordFrequency) -> Maybe RawPasswordProbability
to_prob m f =
  case tryMkProbability ((cast (freq f)) / m) of
    Nothing => Nothing
    Just p =>  Just (MkRawPasswordProbability (pwd f) p)


||| Totals up the frequencies of every password in a list of password frequencies.
|||
||| @rows the data rows to total
total_freq : (rows : List PasswordFrequency) -> Int
total_freq rows = sum (map freq rows)


||| Converts a list of password frequencies to password probabilities.
|||
||| @freqs the data rows to total
export
to_probs : (freqs : List PasswordFrequency) -> List RawPasswordProbability
to_probs freqs = catMaybes (map (to_prob (cast (total_freq freqs))) freqs)
