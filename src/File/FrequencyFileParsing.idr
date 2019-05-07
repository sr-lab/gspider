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
  ord: Int
  pwd : String
  freq : Int


||| Attempts to transform a list of fields to a password frequency.
|||
||| @fields the list of fields to attempt to transform
private
parse_fields : (fields : List String) -> Maybe PasswordFrequency
parse_fields [] = Nothing
parse_fields (key :: []) = Nothing
parse_fields (ord :: key :: value :: _) = Just (MkPasswordFrequency (cast ord) key (cast value))


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


||| Attempts to transform a list of fields to a password frequency, with a user-supplied guessing order.
|||
||| @fields the list of fields to attempt to transform
||| @ord the guessing order to assign to the row
private
parse_fields_ord : (fields : List String) -> (ord : Int) -> Maybe PasswordFrequency
parse_fields_ord [] _ = Nothing
parse_fields_ord (key :: []) _ = Nothing
parse_fields_ord (key :: value :: _) ord = Just (MkPasswordFrequency ord key (cast value))


||| Attempts to transform a raw data row to a frequency file record, with a user-supplied guessing order.
|||
||| @delim the delimiter that separates fields in the frequency file
||| @row the raw data row to attempt to transform
||| @ord the guessing order to assign to the row
parse_row_ord : (delim : Char) -> (row : String) -> (ord : Int) -> Maybe PasswordFrequency
parse_row_ord delim row ord = parse_fields_ord (split (== delim) row) ord
