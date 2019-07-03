module Gspider.Core


import Types.RestrictedCharString


%access private


||| Represents a system as a list of supported password characters.
public export
System : Type -- System is a type alias for a character list.
System = List Char


||| Represents a password probability distribution for a system.
|||
||| @s the system
public export
Distribution : (s : System) -> Type
Distribution s = (RestrictedCharString s) -> Double
