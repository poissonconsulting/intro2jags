
# intro2jags

<!-- badges: start -->

[![R-CMD-check](https://github.com/poissonconsulting/intro2jags/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/poissonconsulting/intro2jags/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of intro2jags is to load necessary packages and useful
functions and datasets for the CMI Introduction to Coding Bayesian
Models Course.

## Installation

To install the latest development version of intro2jags:

``` r
install.packages("remotes")
remotes::install_github("poissonconsulting/intro2jags")
```

And to load the package into the current R session:

``` r
# This will load several helpful packages into R.
library(intro2jags)
```

## Example Usage

### Datasets Automatically Loaded

After loading the package, the datasets can be loaded into the
environment by using the `data()` function.

``` r
# e.g., the `penguins` dataset
data(penguins)
```

Currently, the package has 3 datasets:

1.  `penguins`
2.  `climate`
3.  `starfish`

## Licensing

Copyright (c) 2024 Poisson Consulting

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
“Software”), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
