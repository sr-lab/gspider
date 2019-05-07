module Gspider.Types.BoundedDouble


import Data.So


%access public export


||| Double-precision floating-point numbers bounded to fall between a lower and an upper bound.
|||
||| @a the lower bound
||| @b the upper bound
data BoundedDouble : (a, b : Double) -> Type where
  ||| Constructs a bounded double with the specified value.
  |||
  ||| @x the value of the bounded double
  MkBoundedDouble : (x : Double) ->
                    {auto rightSize : So (a <= b)} ->
                    {auto leftId : So (a <= a)} ->
                    {auto rightId : So (b <= b)} ->
                    {auto high : So (a <= x)} ->
                    {auto low : So (x <= b)} ->
                    BoundedDouble a b


||| Addition for bounded doubles that caps the result to be within bounds.
|||
||| @n a bounded double
||| @m a bounded double
private
plus : (n, m : BoundedDouble a b) -> BoundedDouble a b
plus (MkBoundedDouble u) (MkBoundedDouble v) =
  let x = u + v in
  case (choose (a <= x), choose (x <= b)) of -- TODO: Cleaner way to do this?
    (Left _, Left _) => MkBoundedDouble x
    (Right _, _) => MkBoundedDouble a
    (_, Right _) => MkBoundedDouble b


||| Multiplication for bounded doubles that caps the result to be within bounds.
|||
||| @n a bounded double
||| @m a bounded double
private
mult : (n, m : BoundedDouble a b) -> BoundedDouble a b
mult (MkBoundedDouble u) (MkBoundedDouble v) =
  let x = u * v in
  case (choose (a <= x), choose (x <= b)) of -- TODO: Cleaner way to do this?
    (Left _, Left _) => MkBoundedDouble x
    (Right _, _) => MkBoundedDouble a
    (_, Right _) => MkBoundedDouble b


||| Conversion from integers to bounded doubles.
|||
||| @x the integer to convert
private
fromInteger' : (x : Integer) -> BoundedDouble a b
fromInteger' u =
  let x = the Double (cast u) in
    case (choose (a <= x), choose (x <= b), choose (a <= b), choose (a <= a), choose (b <= b)) of
      (Left _, Left _, Left _, Left _, Left _) => MkBoundedDouble x
      (Right _, Left _, Left _, Left _, Left _) => MkBoundedDouble a
      (Left _, Right _, Left _, Left _, Left _) => MkBoundedDouble b
      _ => ?singularity_1 -- We'll never hit this hole.


||| Implement numeric operations for bounded doubles.
Num (BoundedDouble a b) where
    (+) = plus
    (*) = mult
    fromInteger = fromInteger'


||| Equality for bounded doubles is just the same as equality for doubles.
|||
||| @n a bounded double
||| @m a bounded double
eq : (n, m : BoundedDouble a b) -> Bool
eq (MkBoundedDouble u) (MkBoundedDouble v) = u == v


||| Implement equality for bounded doubles.
Eq (BoundedDouble a b) where
    (==) = eq


||| Subtraction for bounded doubles that caps the result to be within bounds.
|||
||| @n a bounded double
||| @m a bounded double
private
sub : (n, m : BoundedDouble a b) -> BoundedDouble a b
sub (MkBoundedDouble u) (MkBoundedDouble v) =
  let x = u - v in
  case (choose (a <= x), choose (x <= b)) of -- TODO: Cleaner way to do this?
    (Left _, Left _) => MkBoundedDouble x
    (Right _, _) => MkBoundedDouble a
    (_, Right _) => MkBoundedDouble b


||| Negation for bounded doubles that caps the result to be within bounds.
|||
||| @n a bounded double
private
negate' : (n : BoundedDouble a b) -> BoundedDouble a b
negate' (MkBoundedDouble u) =
  let x = u * -1 in
  case (choose (a <= x), choose (x <= b)) of -- TODO: Cleaner way to do this?
    (Left _, Left _) => MkBoundedDouble x
    (Right _, _) => MkBoundedDouble a
    (_, Right _) => MkBoundedDouble b


||| Implement negation operations for bounded doubles.
Neg (BoundedDouble a b) where
  negate = negate'
  (-) = sub


||| Division for bounded doubles that caps the result to be within bounds.
|||
||| @n a bounded double
||| @m a bounded double
private
div : (n, m : BoundedDouble a b) -> BoundedDouble a b
div (MkBoundedDouble u) (MkBoundedDouble v) =
  let x = u / v in
  case (choose (a <= x), choose (x <= b)) of -- TODO: Cleaner way to do this?
    (Left _, Left _) => MkBoundedDouble x
    (Right _, _) => MkBoundedDouble a
    (_, Right _) => MkBoundedDouble b


||| Implement fractional operations for bounded doubles.
Fractional (BoundedDouble a b) where
  (/) = div


||| Attempts to convert a double to a bounded double, returning the option type.
|||
||| @a the lower bound
||| @b the upper bound
||| @u the unbounded double
export
tryBound : (a, b, u : Double) -> Maybe (BoundedDouble a b)
tryBound a b u = case (choose (a <= u), choose (u <= b), choose (a <= b), choose (a <= a), choose (b <= b)) of
  (Left _, Left _, Left _, Left _, Left _) => Just (MkBoundedDouble u)
  _ => Nothing
