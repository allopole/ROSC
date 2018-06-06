#' Construct OSC Type Tag String from Input Data
#'
#' Constructs an Open Sound Control (OSC) Type Tag String from the R data types of the input data.
#'
#'     The input is first converted into a one-level list with all elements length 1 using \code{\link{listFlatten}},
#'     then a string is assembled containing one type tag for each element in the input data.
#'     \code{oscType} detects the R object data type and assigns the OSC style type tag specified for that
#'     dataype in the arguments. Currently, only R data types "integer," "double," "character,"
#'     "NULL," and "logical" are supported. R type "logical" always produces type tag "T" or "F".
#'
#'     An OSC Type Tag String is a string of single character type tags preceded by the "," character.  If a function cannot accept
#'     OSC string representations using comma-initial type strings, the comma may be ommitted with \code{typecomma=FALSE}.
#'     Warning: this would be a non-standard representation of OSC.  Any OSC-compliant function expecting a comma-inital type string may
#'     interpret a type string with comma removed as the first data argument and attempt to construct a new type string dynamically
#'     with heuristic methods.
#'
#'     \code{oscType} is agnostic about the interpretation of type tags.  You can use \code{oscType} to convert R datatypes to
#'     tags conforming to OSC 1.0, OSC 1.1 or libo / odot, for example, or even to non-standard tags.
#'
#'     For reference, the OSC 1.0 and related "libo" typ tag specifications are included here:
#'
#'     \strong{OSC 1.0 TYPE TAGS, including extended types}
#'     \url{http://opensoundcontrol.org/spec-1.0}
#'     \tabular{cl}{
#'     \strong{tag} \tab \strong{definition}\cr
#'     i \tab 32-bit signed integer (big-endian 2'S compliment; equivalent of R type "integer")\cr
#'     u \tab 32-bit unsigned integer (big-endian)\cr
#'     h \tab 64 bit signed integer (big-endian two’s complement)\cr
#'     f \tab 32 bit float (big-endian IEEE 754)\cr
#'     d \tab 64 bit double (IEEE 754; equivalent of R type "double")\cr
#'     c \tab an ascii character, sent as 32 bits\cr
#'     r \tab 32 bit RGBA color stored, each channel stored as an 8-bit value: \emph{e.g.:}\cr
#'       \tab \emph{rgba(1.0,0.8,0.0,1.0) = 11111111 11001100 00000000 11111111 = 4291559679}\cr
#'     m \tab 4 byte MIDI message. Bytes from MSB to LSB are: port id, status byte, data1, data2\cr
#'     s \tab OSC-string (sequence of non-null ASCII characters followed by a null, followed by\cr
#'       \tab 0-3 additional null characters to make the total number of bits a multiple of 32.)\cr
#'     S \tab Alternate type represented as an OSC-string\cr
#'       \tab \emph{e.g. for systems that differentiate "symbols" from "strings"}\cr
#'     b \tab OSC-blob (int32 size count n, followed by n 8-bit bytes of arbitrary binary data,\cr
#'       \tab followed by 0-3 zero bytes to make total number of bits a multiple of 32.)\cr
#'     T \tab True (No data argument is passed)\cr
#'     F \tab False (No data argument is passed)\cr
#'     N \tab Nil or Null (No data argument is passed)\cr
#'     I \tab Infinitum (or "Impulse")\cr
#'     [ \tab Indicates the beginning of an array. The tags following are for data in the Array until a close brace tag is reached.\cr
#'     ] \tab Indicates the end of an array.\cr
#'     t \tab OSC-timetag (64-bit big-endian fixed-point NTP timestamp.)\cr
#'       \tab First 32 bits specify the number of seconds since midnight on January 1, 1900.\cr
#'       \tab Last 32 bits specify fractional parts of a second. (Precision is ~200 picoseconds.)\cr
#'       \tab Special case: 63 zero bits followed by one in least significant bit (000...0001)\cr
#'       \tab means "immediately."
#'     }
#'
#'     \strong{libo TYPE TAGS (an extension of OSC 1.0)}
#'     \url{http://www.cnmat.berkeley.edu/sites/default/files/attachments/2015_Dynamic_Message_Oriented_Middleware.pdf}
#'     \tabular{cl}{
#'     \strong{tag} \tab \strong{definition}\cr
#'     c \tab 8-bit signed integer (big-endian  2'S compliment)\cr
#'     C \tab 8-bit unsigned integer (big-endian  2'S compliment)\cr
#'     u \tab 16-bit signed integer (big-endian  2'S compliment)\cr
#'     U \tab 16-bit unsigned integer (big-endian  2'S compliment)\cr
#'     i \tab 32-bit signed integer (big-endian  2'S compliment; equivalent of R type "integer")\cr
#'     I \tab 32-bit unsigned integer (big-endian  2'S compliment)\cr
#'     h \tab 64 bit signed integer (big-endian two’s complement)\cr
#'     H \tab 64 bit unsigned integer (big-endian two’s complement)\cr
#'     d \tab 64 bit double (IEEE 754; equivalent of R type "double")\cr
#'     s \tab OSC-string\cr
#'     S \tab Alternate type represented as an OSC-string\cr
#'     b \tab OSC-blob\cr
#'     B \tab odot bundle\cr
#'     A \tab executable code\cr
#'     T \tab True (No data argument is passed)\cr
#'     F \tab False (No data argument is passed)\cr
#'     N \tab Nil or Null (No data argument is passed)\cr
#'     t \tab OSC-timetag
#'     }
#'
#' @param data list or vector
#' @param integer character. Tag to use for R data type "integer". Default = "i", specifying a 32-bit signed big-endian 2'S compliment integer. (Identical to the R "integer" type.)
#' @param double character. Tag to use for R data type "integer". Default = "d", specifying a 64 bit IEEE 754 double (Identical the R "double" type.)
#' @param character character. Tag to use for R data type "character". Default = "s", specifying a string.
#' @param null character. Tag to use for R data type "character". Default = "s", specifying a string. ="N", typecomma=TRUE
#' @param typecomma logical. If typecomma=TRUE (default), a comma (",") is prepended to the type tag string.
#'
#' @return character. An "OSC Type Tag String." e.g. ",iisdTNf"
#'
#' @examples
#' oscType(7.1)
#' oscType(7:9)
#' oscType(c("foo","gorp"))
#' data <- list(list(3:4,"apple"), TRUE, list(list(5.1,"foo"),NULL))
#' oscType(data)
#' oscType(data, double = "f", typecomma=FALSE)
#'
#' @export
oscType <- function(data=NULL, integer="i", double = "d", character="s", null="N", typecomma=TRUE) {
  if (is.null(data)) {
    return(NULL)
  } else {

    ## flatten data
    data <- listFlatten(data)

    ## extract data types
    t <- sapply(data,typeof)

    ## map input types to OSC data types
    for (i in 1:length(t)) {
      if (is.logical(data[[i]])) {
        if (data[[i]] == TRUE) {
          t[i] <- "T"
        } else {
          t[i] <- "F"
        }
      }
    }

    t <- gsub("integer",integer,t)
    t <- gsub("double",double,t)
    t <- gsub("character",character,t)
    t <- gsub("NULL",null,t)

    ## return OSC Type Tag String
    t <- paste0(t,collapse = "")
    if (typecomma==TRUE) {t <- paste0(",",t)}
    return(t)
  }
}

