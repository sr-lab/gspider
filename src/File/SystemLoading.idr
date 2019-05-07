module Gspider.File.SystemLoading


import Core


%access private


||| Unescapes a system character string if necessary.
|||
||| @s the system character string to unescape
unescapeSystemChar : (s : String) -> Maybe Char
unescapeSystemChar "SPACE" = Just ' '
unescapeSystemChar s = head' (unpack s)


||| Loads a system from a file.
|||
||| @path the path to the file to load
export
loadSystem : (path : String) -> IO (Maybe System)
loadSystem path =
  do
    txt <- readFile path
    case txt of
      Left _ => pure Nothing -- File read failure.
      Right txt' =>
        let rawChars = split (== ' ') txt'
            chars = map unescapeSystemChar rawChars in
            pure (Just (catMaybes chars))
