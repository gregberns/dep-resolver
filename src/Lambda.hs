{--
Example of reducing a lambda expression

https://stackoverflow.com/questions/34140819/lambda-calculus-reduction-steps

https://gist.github.com/andrusha/2713435

--}

module Lambda where

import Text.Printf

data Lambda pterm =
      PVar pterm
    | PFun pterm (Lambda pterm)
    | PApp (Lambda pterm) (Lambda pterm)
    -- deriving (Eq, Show) 

instance Show a => Show (Lambda a) where
  show (PVar v)       = show v
  show (PFun n t)  = "/" ++ (show n) ++ "." ++ (show t)
  show (PApp t1 t2) = "(" ++ (show t1) ++ ")(" ++ (show t2) ++ ")"

-- (\x.x)y
-- (\x.x)(\y.y)
-- (\x.\y.xy)y
reduce :: Eq a => Lambda a -> Lambda a
reduce (PApp t1 t2) = apply (reduce t1) (reduce t2)
reduce (PFun n t) = PFun n (reduce t)
reduce (PVar x) = PVar x

apply :: Eq a => Lambda a -> Lambda a -> Lambda a
--handle PFun
-- (\x.x)y
-- (\x.x)(\y.y)
apply (PFun n t1) t2 = reduce $ rename n t2 t1 -- call map?
--handles PApp and PVar
apply t1 t2 = PApp t1 t2

fmap' f (PApp t1 t2) = PApp (fmap' f t1) (fmap' f t2)
fmap' f (PFun n t) = PFun n (fmap' f t)
fmap' f (PVar x) = f (PVar x)

rename :: Eq a => a -> Lambda a -> Lambda a -> Lambda a
rename a t1 t2 =
  let 
    replace = \(PVar x) -> if x == a then t1 else PVar x
  in 
    fmap' replace t2

run =
  let
      -- (\y.y)x
      e = PApp (PFun 'x' (PVar 'x')) (PVar 'x')
      -- (\x.x)(\y.y)
      f = PApp (PFun 'x' (PVar 'x')) (PFun 'y' (PVar 'y'))
      -- (\x.\y.xy)y
      -- f = PApp (PFun 'x' (PFun 'y' (PVar 'x'))) (PVar 'y')
  in
    do
      -- show f
      show (reduce f)

