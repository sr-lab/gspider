module Gspider.File.FrequencyFileParsing


%access export


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
private
parse_fields : (fields : List String) -> Maybe PasswordFrequency
parse_fields [] = Nothing
parse_fields (key :: []) = Nothing
parse_fields (key :: value :: _) = Just (MkPasswordFrequency key (cast value))


||| Attempts to transform a raw data row to a frequency file record.
|||
||| @delim the delimiter that separates fields in the frequency file
||| @row the raw data row to attempt to transform
private
parse_row : (delim : Char) -> (row : String) -> Maybe PasswordFrequency
parse_row delim row = parse_fields (split (== delim) row)


||| Transforms raw frequency file data to a list of password frequencies.
|||
||| @delim the delimiter that separates fields in the frequency file
||| @rows the raw data rows to transform
parse_rows : (delim : Char) -> (rows : String) -> List PasswordFrequency
parse_rows delim rows = catMaybes (map (parse_row delim) (lines rows))
