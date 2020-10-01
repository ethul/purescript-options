-- Importing modules
module Test.Main where

import Prelude

import Data.Functor.Contravariant (cmap)
import Data.Maybe (Maybe(..))
import Data.Options (Option, Options, optional, options, opt, (:=))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Foreign (Foreign)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner (runSpec)
-- defining vars
data Shape = Circle | Square | Triangle
-- object
instance shapeShow :: Show Shape where
  show Circle = "circle"
  show Square = "square"
  show Triangle = "triangle"

foreign import data MyOptions :: Type

aStringOption :: Option MyOptions String
aStringOption = opt "aStringOption"

anIntOption :: Option MyOptions Int
anIntOption = opt "anIntOption"

aBooleanOption :: Option MyOptions Boolean
aBooleanOption = opt "aBooleanOption"

anOptionalStringOption :: Option MyOptions (Maybe String)
anOptionalStringOption = optional (opt "anOptionalStringOption")

anotherOptionalStringOption :: Option MyOptions (Maybe String)
anotherOptionalStringOption = optional (opt "anotherOptionalStringOption")

aShapeOption :: Option MyOptions Shape
aShapeOption = cmap show (opt "shape")

aFunctionOption :: Option MyOptions (Int -> Int -> Int -> Int)
aFunctionOption = opt "aFunctionOption"

anArrayOfShapesOption :: Option MyOptions (Array Shape)
anArrayOfShapesOption = cmap (map show) (opt "anArrayOfShapesOption")

myOptions :: Options MyOptions
myOptions = aStringOption := "aaa" <>
       anIntOption := 10 <>
       aBooleanOption := true <>
       anOptionalStringOption := Just "c" <>
       anotherOptionalStringOption := Nothing <>
       aShapeOption := Square <>
       aFunctionOption := (\a b c -> a + b + c) <>
       anArrayOfShapesOption := [Square, Circle, Triangle]

foreign import showForeign :: Foreign -> String

main :: Effect Unit
main = do
  launchAff_
    $ runSpec [ consoleReporter ] do
        describe "end-to-end" do
          it "works as expected" do
            let expected = """{"aStringOption":"aaa","anIntOption":10,"aBooleanOption":true,"anOptionalStringOption":"c","shape":"square","anArrayOfShapesOption":["square","circle","triangle"]}"""
            let actual = showForeign $ options myOptions

            actual `shouldEqual` expected
        describe "opt" do
          it "works with `String`s" do
            let expected = """{"aStringOption":"hello, world"}"""
            let actual = showForeign $ options $ (:=) aStringOption "hello, world"

            actual `shouldEqual` expected
          it "works with `Int`s" do
            let expected = """{"anIntOption":74}"""
            let actual = showForeign $ options $ (:=) anIntOption 74

            actual `shouldEqual` expected
          it "works with `Boolean`s" do
            let expected = """{"aBooleanOption":true}"""
            let actual = showForeign $ options $ (:=) aBooleanOption true

            actual `shouldEqual` expected
          it "works with `Array`s" do
            let expected = """{"anArrayOfShapesOption":["square","circle","triangle"]}"""
            let actual = showForeign $ options $ (:=) anArrayOfShapesOption [Square, Circle, Triangle]

            actual `shouldEqual` expected
          it "does nothing for functions" do
            let expected = """{}"""
            let actual = showForeign $ options $ (:=) aFunctionOption (\a b c -> a + b + c)

            actual `shouldEqual` expected
        describe "optional" do
          it "includes the option when it is provided" do
            let expected = """{"anotherOptionalStringOption":"provided"}"""
            let actual = showForeign $ options $ (:=) anotherOptionalStringOption $ Just "provided"

            actual `shouldEqual` expected
          it "excludes the option when it is not provided" do
            let expected = """{}"""
            let actual = showForeign $ options $ (:=) anotherOptionalStringOption Nothing

            actual `shouldEqual` expected
