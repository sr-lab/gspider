module Gspider.Types.RestrictedCharString


import Data.So


%access public export


||| Returns true if the given list of characters `str` contains only characters specified in `chars`.
|||
||| @chars the list of permitted characters
||| @str the string to check
private
madeOf' : (chars : List Char) -> (str : List Char) -> Bool
madeOf' chars [] = True
madeOf' chars (x :: xs) = elem x chars && madeOf' chars xs


||| Returns true if the given string `str` contains only characters specified in `chars`.
|||
||| @chars the list of permitted characters
||| @str the string to check
export
madeOf : (chars : List Char) -> (str : String) -> Bool
madeOf chars str = madeOf' chars (unpack str)


||| Strings that are restricted to only a specific set of characters.
|||
||| @allowed the list of characters allowed in the string
data RestrictedCharString : (allowed : List Char) -> Type where
  ||| Constructs a restricted character set string with the specified value.
  |||
  ||| @val the value of the string
  MkRestrictedCharString : (val : String) ->
                           {auto prf : So (madeOf allowed val)} ->
                           RestrictedCharString allowed


||| Attempts to restricts a string to contain only a specific set of characters.
|||
||| @chars the list of characters allowed in the string
||| @str the string to attempt to restrict
export
restrictStr : (chars : List Char) -> (str : String) -> Maybe (RestrictedCharString chars)
restrictStr chars str = case choose (madeOf chars str) of
  Left _ => Just (MkRestrictedCharString str)
  Right _ => Nothing


||| Converts a list of strings to a list of strings with a restricted character set, where possible.
|||
||| @chars the set of characters to use to restrict strings
||| @strs the list of strings to convert
export
convertToRestricted : (chars : List Char) -> (strs : List String) -> List (RestrictedCharString chars)
convertToRestricted chars strs = catMaybes (map (restrictStr chars) strs)


||| Equality for restricted character set strings.
|||
||| @x some restricted character set string
||| @y some restricted character set string
private
equal : (x : RestrictedCharString s) -> (y : RestrictedCharString s) -> Bool
equal (MkRestrictedCharString u) (MkRestrictedCharString v) = u == v


||| Inequality for restricted character set strings.
|||
||| @x some restricted character set string
||| @y some restricted character set string
private
notEqual : (x : RestrictedCharString s) -> (y : RestrictedCharString s) -> Bool
notEqual (MkRestrictedCharString u) (MkRestrictedCharString v) = u /= v


||| Implement equality for restricted character set strings.
Eq (RestrictedCharString s) where
  (==) = equal
  (/=) = notEqual

export
unrestrict : (x : RestrictedCharString s) -> String
unrestrict (MkRestrictedCharString x) = x
