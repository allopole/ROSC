<!-- README.md is generated from README.Rmd. Please edit that file -->
ROSC
====

ROSC is intended to build and parse messages in the Open Sound Control
(OSC) protocol.

Currently, only building messages is implemented. ROSC builds string
representations of OSC Messages that can then be passed to an external
function that encodes OSC for transport.

About OSC
---------

Open Sound Control (OSC) is a transport-independent, message-oriented
communication protocol for communication among computers, devices. OSC
is differentiaed from the related encodings XML, JSON, YMAL, MIME and
MIDI by use of regular expressions and pattern-matching for dispatching,
and by temporal and atomicity semantics. This package partially
implements the OSC 1.1 Encoding Specification
<http://cnmat.berkeley.edu/content/open-sound-control-11-encoding-specification>.

<http://opensoundcontrol.org/>

Many applications, most programming environmnts, and numerous devices
(including sensor/actuator interfaces such as arduino) have OSC client
and/or server implementations.

See:  
<http://opensoundcontrol.org/implementations>  
<https://en.wikipedia.org/wiki/Open_Sound_Control#Applications>

Python, Matlab, and many other computing languages have OSC
implmentations.

R does not (yet), so here is a first attempt to remedy that.

Building OSC Messages
---------------------

### Functions

-   `oscMessage` - Build OSC Message from user supplied data, address
    pattern, and optional type tag string  
-   `oscType` - Helper function to calculate an OSC Type Tag String from
    user supplied data
-   `listFlatten` - Helper function to recursively flatten a list (and
    vector list elements) into a single-level list of elements each of
    length 1.

### Not (yet) supported:

-   OSC Time Tags
-   OSC Blobs
-   OSC Bundles
-   arrays

### Not (likely to be) supported (ever):

-   the full `libo` extension of OSC.

See
<http://www.cnmat.berkeley.edu/sites/default/files/attachments/2015_Dynamic_Message_Oriented_Middleware.pdf>
for a description. This should be a separate package.

Parsing (Dispatching) Messages
------------------------------

Not yet implemented. This will require writing functions to dispatch OSC
Address Patterns and convert OSC arguments to R data types.

Example building OSC Messages with `ROSC`
-----------------------------------------

``` r
library(ROSC)

## Example OSC address patterns
address <- "/audio/1/foo"
address.with.wildcards <- "/{th,s}ing/n[2-4]/red*"

## Example data to pack into OSC messages
data1 <- "bird"
data2 <- 6:8
data3 <- list(list(3:4,"apple"), TRUE, list(list(5.1,"foo"),NULL))

## Example of a manual type string for data3
data3_typestring <- ",iiSidSN"

## Example OSC messages
OSC1 <- oscMessage(address = address, data = data1)
OSC2 <- oscMessage(address = address, data = data2, typecomma=FALSE) # remove comma from typstring
OSC3 <- oscMessage(address = address, data = data3) # now with a nested list of mixed data types
OSC4 <- oscMessage(address = address, data = data3, double = "f") # convert doubles to 32bit floats
OSC5 <- oscMessage(address = address, data = data3, logical = "integer") # convert logical to ints
```

Sending OSC over UDP
--------------------

OSC is transport-independant, but it typically sent over UDP, and less
often over TCP. UDP is chosen for many applications because of the lower
latency (at the expenses of a theoretical possibility of occasional lost
packets), and because of the ability to broadcast without the need for
first establishing a connection, simplifying communication.

OSC over UDP in native R
------------------------

Unlike TCP socket connections, UDP is not natively supported in R. UDP
clients and servers can be written in RCPP, but none that implement OSC
compliant packets have yet been built. This should be be on a to-do list
for interested R developers.

OSC over UDP via Bash command `oscchief`:
-----------------------------------------

### Dependencies:

#### 1. pkg-config <https://www.freedesktop.org/wiki/Software/pkg-config/>

Install with Homebrew: `$ brew install pkg-config` or see
<https://www.freedesktop.org/wiki/Software/pkg-config/>

#### 2. liblo <http://liblo.sourceforge.net/>

Install liblo from source (requires make):

    $ cd liblo-x.xx
    $ ./configure --prefix=/usr/local --enable-static
    $ make
    $ make install

#### 3. osccheif <http://hypebeast.github.io/oscchief/>

compile and install oscchief (requires make):

    $ git clone https://github.com/hypebeast/oscchief.git oscchief
    $ cd oscchief
    $ make
    $ sudo make install

`oscchief` Usage

    oscchief Version 0.2.0
    Copyright (C) 2013 Sebastian Ruml <sebastian.ruml@gmail.com>

    usage: oscchief send HOST PORT OSCADDRESS TYPES ARGUMENTS
           oscchief send FILENAME
           oscchief listen PORT

    positional arguments:
        HOST: IP address of the host where you want to send your OSC message
        PORT: Port number
        OSCADDRESS: OSC address where you want to send your message
        TYPES: OSC type tags. Supported types:
            i - 32 Bit integer
            h - 64 Bit integer
            f - 32 Bit float
            d - 64 Bit double
            c - Char
            s - String
            T - True (no argument required)
            F - False (no argument required)
            N - Nil (no argument required)

    optional arguments:
         -h - Shows this help message

    Examples:
        oscchief send 192.168.0.10 7028 /osc/address ssiii some integers 10 12 786
        oscchief send 192.168.0.10 7028 /osc/address TTiFi 643 98
        oscchief send 192.168.0.10 7028 /osc/address
        oscchief send 192.168.0.10 7028 /osc/address TF
        oscchief listen 7028

### R interface to `oscchief`

``` r

# Wrapper for system("oscchief send")
oscchief.send <- function (host="localhost", port=12345, osc="/") {
  osc <- gsub(",","",osc) # strip type tag comma for compatibility with oscchief
  command <- paste("oscchief send", host, port, osc)
  system(command)
}

# Define host and port
HOST <- "255.255.255.255" # this ip address means "all ip addresses on the local subnet"
LOCALHOST <- "localhost" # equivalent to "127.0.0.1", i.e. your own machine
PORT <- 6789 # recipient must listen on this port number.  Use any number in the thousands.

# Send OSC messages

oscchief.send(host=HOST, port=PORT, osc=OSC1)

oscchief.send(host=HOST, port=PORT, osc=OSC2)

oscchief.send(host=HOST, port=PORT, osc=OSC3)

oscchief.send(host=HOST, port=PORT, osc=OSC4)

oscchief.send(host=HOST, port=PORT, osc=OSC5)
```

Listen to OSC Messages coming from R over UDP
---------------------------------------------

### Listen in a terminal with `osccheif`:

Listen on port 6789

    $ oscchief listen 6789

### Listen in R, with a wrapper for `oscchief`?

``` r
## You might think you could write a wrapper for system("oscchief listen") like this, but...

# DO NOT RUN THIS IN R:
#    (DOES NOT RETURN MESSAGE TO R SESSION)
#    (NO WAY TO GRACEFULLY KILL LISTENER ONCE STARTED)
#
# oscchief.listen <- function (port=12346) {
#   command <- paste("oscchief listen", port)
#   system(command)
# }
# PORT <- 12346
# oscchief.listen(PORT)
#
```

### Listen in Max <https://cycling74.com/products/max>

Note:

Max receives both doubles (int64) and 64-bit ints (int64) as 0.0, even
in Max7 running in 64 bit mode.  
Max receives floats (float32) correctly. TODO: Check code for `udpsend`.
KLUDGE: Send doubles to Max as float32 (OSC Type “f”):

#### R Code (send to Max)

``` r
ADDRESS <- "/audio/1/foo"
DATA <- list(list(3:4,"apple"), TRUE, list(list(5.1,"foo"),NULL))
OSC <- oscMessage(address = address, data = data3, double = "f") # convert doubles to 32bit floats
HOST <- "localhost"
PORT <- 5678
oscchief.send(host=HOST, port=PORT, osc=OSC)
```

#### Max Code (listen)

Copy entire code block into empty Max patcher:

<pre><code>
----------begin_max5_patcher----------
282.3ocoQsraBCCD7ryWgkOmhRLDBzekppJSxpViB1V9QZPH92qe1RendgKq
zNd1clY8kJD4fbALD7i3mvHzkJDJBE.P4dD4DaYXhYhzHB3c4gij5zSVXwFg
UZtvVPM1ySPDtfHbm3hIvF2QaFTwrCuwEu9hFFrIOP6W0Ti62Epq2DpT5pF7
y4I3iws5MvCzaVszYK6tI.dspJTpuuH4FUdiA7Y.2sseW48jX1yJHYYB4S6c
u4l1Ep62+e4t8uyc6M4NNFYhK94OaT3.92OFFoSOTRSVC7WhOBFKWvrbo3FN
zDmeIKSolAsISNJg+ZeTpCs80wVtH0tN1pgYdgeWDgo82Gq+33zoy4x1Mjzn
xQPKb7bj8Jes5CvurQJU
-----------end_max5_patcher-----------
</code></pre>
