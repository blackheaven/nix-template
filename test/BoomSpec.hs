module BoomSpec
  ( main,
    spec,
  )
where

import Boom
import Test.Hspec

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  it "works" $
    boom 0 `shouldBe` 42
  xit "fails" $
    boom 1 `shouldBe` 43
