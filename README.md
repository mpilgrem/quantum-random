# quantum-random

[![Build Status](https://travis-ci.org/BlackBrane/quantum-random.svg?branch=master)](https://travis-ci.org/BlackBrane/quantum-random)
[![Hackage](https://img.shields.io/hackage/v/quantum-random.svg)](http://hackage.haskell.org/package/quantum-random)
[![quantum-random on Stackage Nightly](http://stackage.org/package/quantum-random/badge/nightly)](http://stackage.org/nightly/package/quantum-random)


Retrieve, store and manage real quantum random data, originating from vacuum fluctuations of the electromagnetic field and served by [Australian National University](http://qrng.anu.edu.au/).

The package is designed to ensure quantum random data is promptly available for your application by keeping a sufficient amount locally. When depleted to a specified level, more data is downloaded concurrently over SSL. It can be configured by specifying the minimum store size (below which more data are retrieved) the target store size (the size of the store after retrieval) and the default display style.

This functionality is provided by:

* An executable program `qrand`
* A Haskell module `Quantum.Random`.

### Command line usage

Call `qrand` without any command line arguments to launch the interactive program, or alternatively
supply the desired command as arguments to only perform the specified operation.

#### Setup

Assuming GHC and Cabal are installed:

```
cabal update
cabal install quantum-random
qrand fill
```

One might also opt to set appropriate store size defaults before filling:

```
$ qrand
quantum-random> set minsize 150
quantum-random> set tarsize 300
quantum-random> fill
```

#### Available commands

```
add [# bytes]     –  Request specified number of quantum random bytes from ANU and add them to the store
live [# bytes]    –  Request specified number of quantum random bytes from ANU and display them directly
observe [# bytes] –  Take and display data from store, retrieving more if needed. Those taken from the store are removed
peek [# bytes]    –  Display up to the specified number of bytes from the store without removing them
peekAll           –  Display all data from the store without removing them
fill              –  Fill the store to the target size with live ANU quantum random numbers
restore           –  Restore default settings
reinitialize      –  Restore default settings, and refill store to target size
status            –  Display status of store and settings
save [file path]  –  save binary quantum random store file to specified file path
load [file path]  –  load binary file and append data to store
set minSize       –  Set the number of bytes below which the store is refilled
set targetSize    –  Set the number of bytes to have after refilling
set style [style] –  Set the default display style
help/?            –  Display this text
quit              –  Quit
```

Commands are not case-sensitive (except for file paths).

#### Display options

There are a number of available styles for displaying the binary data, including (or combined with) printing a colored block for every 4 bits (every half-byte). The basic display styles are hex, binary, or equivalently arrows (↑/↓) representing quantum mechanical spin states.

So the available display modifiers are:

* `hex`/`hexidecimal`
* `bits`/`binary`
* `spins`
* `colors`
* `colorHex` __(default)__
* `colorBits`/`colorBinary`
* `colorSpins`


You can enter these modifiers after any display command. For example:

`observe 100 colorspins`

`live 50 binary`

### Usage in Haskell code

All user-facing functionality may be accessed from the `Quantum.Random` module, though a user can
also import the constituent modules when only a subset of the functionality is needed.

The most basic service is to retrieve data directly from ANU, which is provided by functions
from the `Quantum.Random.ANU` module. There are two variants yielding either a list of bytes or a
list of booleans. In both cases the argument specifies the number of bytes.

```haskell
fetchQR :: Int -> IO [Word8]
fetchQRBits :: Int -> IO [Bool]
```

Operations involving the data store are exported by `Quantum.Random.Store`. An important one is

```haskell
extract :: Int -> IO [Word8]
```
This also invokes the machinery to retrieve more data and refill the store as needed.

#### Exceptions

Most of the IO actions in the package use a custom exception type `QRException` to handle the unlikely
parse errors that may be encountered. Namely parse failure of either the JSON response object
of the API, or the settings file (which never needs to be edited directly). See the `Quantum.Random.Exceptions` module for details.

Beyond this, the operations for retrieving from the ANU server use `simpleHttp` from the
`http-conduit` package and therefore may throw an `HttpException`.

### Physical Origin

Detailed information on the physical setup used to produce these random numbers can be
found in these papers:

* [Real time demonstration of high bitrate quantum random number generation with coherent laser light](http://arxiv.org/abs/1107.4438)
* [Maximization of Extractable Randomness in a Quantum Random-Number Generator](http://arxiv.org/abs/1411.4512)
