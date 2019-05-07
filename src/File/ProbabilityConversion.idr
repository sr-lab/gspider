module Gspider.File.ProbabilityConversion


import File.FrequencyFileParsing
import Types.Probability


%access export


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


||| Totals up the probabilities in a list of probability records.
|||
||| @probs the records to total
total_prob : (probs : List RawPasswordProbability) -> Probability
total_prob probs = sum (map prob probs)


||| Attempts to convert a password frequency to password probability.
|||
||| @m the magnitude of the entire dataset
||| @f the frequency to attempt to convert
export
to_prob : (m : Double) -> (f : PasswordFrequency) -> Maybe RawPasswordProbability
to_prob m f =
  case tryMkProbability ((cast (freq f)) / m) of
    Nothing => Nothing
    Just p =>  Just (MkRawPasswordProbability (pwd f) p)


||| Totals up the frequencies of every password in a list of password frequencies.
|||
||| @rows the data rows to total
private
total_freq : (rows : List PasswordFrequency) -> Int
total_freq rows = sum (map freq rows)


||| Converts a list of password frequencies to password probabilities.
|||
||| @freqs the data rows to total
to_probs : (freqs : List PasswordFrequency) -> List RawPasswordProbability
to_probs freqs = catMaybes (map (to_prob (cast (total_freq freqs))) freqs)
