--module Probabilities (pdfuniform, pdfnormal, pdfstandardnormal, pdfexponential, cdfuniform, cdfnormal, cdfstandardnormal, cdfexponential) where

{-| Functions for calculating values of common continuous probability distributions. 

# Probability density functions
@docs pdfuniform, pdfnormal, pdfexponential

# Cumulative density functions 
@docs cdfuniform, cdfnormal, cdfexponential

-}

import Debug
import List

{-| Probability density function for a normal distribution with mean mu and standard deviation sigma. This function computes the height of the curve at a given x. -}
--pdfuniform : number -> number -> number -> number
pdfuniform (from,to) x = 
   let 
      a = from
      b = to
      domain = b - a
   in
      if x >= 0 && a <= x && x <= b then (1 / domain) else 0


{-| Probability density function for a normal distribution with mean mu and standard deviation sigma. This function computes the height of the curve at a given x. -}
pdfnormal : number -> number -> number -> number
pdfnormal mu sigma x = 
      let top = 1 / (sigma * sqrt (2 * pi))
          exponent = (-0.5) * ((x - mu) / sigma)^2
      in
          top * e^exponent

{-| Probability density function for a standardized normal distribution, with mean 0 and standard deviation 1. -}
pdfstandardnormal : number -> number
pdfstandardnormal x = pdfnormal 0 1 x

{-| Probability density function for an exponential distribution. -}
pdfexponential : number -> number -> number
pdfexponential lambda x = 
   let 
       pdf = lambda * e^(-lambda * x)
   in
      if x >= 0 then pdf else 0


{-| Cumulative density function for a normal distribution. Returns an approximate one-sided integral of the interval [from, to] using the trapezium rule. More steps/breaks will yield a higher precision. 

    cdfnormal 0 1 10 (-1,1) == 0.681
    map (dec 3 << (\x -> cdfnormal 0 1 x (-1,1))) [2,4,6,10,100] == [0.641,0.673,0.678,0.681,0.683]
    map (dec 3 << (\x -> cdfnormal 0 1 100 (-x,x))) [1,2,3] == [0.683,0.954,0.997]
-}

{-| Cumulative density function for a uniform distribution with mean mu and standard deviation sigma. This function computes the height of the curve at a given x. -}
cdfuniform : number
cdfuniform = 1


cdfnormal : number -> number -> number -> (number,number) -> number
cdfnormal mu sigma nsteps (from,to) = 
   integrate (from,to) nsteps (pdfnormal mu sigma)


{-| Cumulative density function for a standardized normal distribution.  

   cdfznormal 10 (-1,1) == 0.683   -- ≈68 % within ±1 standard deviation around the mean
-}
cdfstandardnormal :  number -> (number,number) -> number
cdfstandardnormal nsteps (from,to) = integrate (from,to) nsteps (pdfnormal 0 1)


cdfexponential : number -> number -> (number,number) -> number
cdfexponential lambda nsteps (from,to) = 
   let from2 = if from >= 0 then from else 0
   in integrate (from2,to) nsteps (pdfexponential lambda)




{-| Approximating an integral with a trapezium/trapezoid shape. -}
trapezium : number -> (number,number) -> number
trapezium dx (x1,x2) = dx * (x1 + x2) / 2

{-| Splitting a list of x values into adjacent bins, as in a histogram. A list [a,b,c,d] becomes [(a,b),(b,c),(c,d)] -}
bins : [number] -> [(number,number)]
bins ys = zip (take ((length ys)-1) ys) (tail ys)

{-| Integrating a function f over an interval in a given number of steps. -}
integrate : (number,number) -> number -> (number -> number) -> number
integrate (from,to) nsteps f =  
   let dxrange = (to - from) -- length of the interval
       dx = dxrange / (nsteps) -- size of chunks (trapezia) to calculate individually
       interpolator = map (\x -> (x / nsteps)) [0..nsteps]
       steps = map (\x -> from + x * dxrange) interpolator
       ys = map f steps
       trapezia = bins ys
   in
       abs <| sum <| map (trapezium dx) trapezia

{-| Finding the approximate derivative of a function at a given point. -}
slope : number -> number -> (number -> number) -> number
slope dx x f =
   let
       offset = dx / 2
       x1 = x - offset
       x2 = x + offset 
       y1 = f x1
       y2 = f x2
   in
       (y2 - y1) / dx

{-| Finding the tangent (derivative) of a function at a given point.  
Returns a record containing slope and intercept. -}
--tangent : ...
tangent dx x f =  
   let
       m = dec 3 <| slope dx x f
       b = (f x) - (m * x)
   in
       { slope = m, intercept = b, x = x, dx = dx }





{- Utility functions -}
{-| Factorial for a number n is the product of [1..n]. It can be used to calculate combinations and permutations. It is implemented backwards and recursively, starting with n * (n-1), then (n * (n-1)) * (n-2), and so on. -}
factorial : number -> number
factorial n = if n < 1 then 1 else n * factorial (n-1)

{-| Rounds a number n to m number of decimals -}
dec : number -> number -> number
dec m n = (toFloat << round <| n * 10^m) / (10^m)

{-| Normalize values to the range of 0,1  -}
normalize : (number,number) -> number -> number
normalize (xmin,xmax) x = (x - xmin) / (xmax - xmin)




{- HARDCORE TESTING ROUTINES BELOW :-) -}

--main = asText <| pdfnormal 0 1 0
--main = asText <| zip [1,2,3] <| map (dec 3 << cdfnormal 0 1 100) [(-1,1),(-2,2),(-3,3)]
--main = asText <| map (dec 3 << (\x -> cdfnormal 0 1 100 (-x,x))) [1,2,3]
--main = asText <| map (dec 3 << (\x -> cdfnormal 0 1 x (-1,1))) [2,4,6,10,100]
--main = asText <| chunks [1,2,3] 
--main = asText <| map (\(a,b) -> (dec 3 a, dec 3 b)) <| integrate (-1,1) 10 (pdfnormal 0 1)
--main = asText <| integrate (-1,1) 10 (pdfnormal 0 1)
--main = asText <| cdfnormal 0 1 10 (-1,1)
--main = asText <| zip [1,2,3] <| map (dec 3 << cdfnormal 0 1 100) [(-1,1),(-2,2),(-3,3)]
--main = asText <| cdfexponential 0.5 10 (0,2) 
--main = asText <| cdfznormal 100 (-1,1)
--main = asText <| cdfexponential (1/20) 100 (0,5)
--main = asText <| 1 - cdfexponential (1/20) 100 (0,40)
--main = asText <| integrate (25,30) 100 <| pdfuniform (0,30)
--main = asText <| normalize (0,8) 4
--main = asText <| cdfuniform
--main = asText <| dec 3 <| integrate (0,1) 100 (\x -> e^x)
--main = asText <| dec 3 <| integrate (1,pi) 100 (\x -> 1/x)
--main = asText <| slope 0.01 2 (\x -> 1/x)
--main = asText <| tangent 0.01 2 (\x -> 1/x)
