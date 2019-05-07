module Gspider.File.FrequencyFileParsing


%access private


||| Represents a password frequency.
public export
record PasswordFrequency where
  ||| Constructs a password frequency.
  |||
  ||| @ord the guessing order
  ||| @pwd the password
  ||| @freq the frequency
  constructor MkPasswordFrequency
  pwd : String
  freq : Int


||| Attempts to transform a list of fields to a password frequency.
|||
||| @fields the list of fields to attempt to transform
parseFields : (fields : List String) -> Maybe PasswordFrequency
parseFields [] = Nothing
parseFields (key :: []) = Nothing
parseFields (key :: value :: _) = Just (MkPasswordFrequency key (cast value))


||| Attempts to transform a raw data row to a frequency file record.
|||
||| @delim the delimiter that separates fields in the frequency file
||| @row the raw data row to attempt to transform
parseRow : (delim : Char) -> (row : String) -> Maybe PasswordFrequency
parseRow delim row = parseFields (split (== delim) row)


||| Transforms raw frequency file data to a list of password frequencies.
|||
||| @delim the delimiter that separates fields in the frequency file
||| @rows the raw data rows to transform
export
parseRows : (delim : Char) -> (rows : String) -> List PasswordFrequency
parseRows delim rows = catMaybes (map (parseRow delim) (lines rows))
