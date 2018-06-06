#' Construct OSC Message from OSC Address Pattern and Data
#'
#' Constructs a string formated as an Open Sound Control (OSC) message, from user supplied OSC Address Pattern, data, and optional OSC Type Tag String.
#'
#'     oscMessage returns a string representation of an OSC message in the format \code{ADDRESS_PATTERN TYPE_TAG_STRING ARGUMENTS}.
#'     (see \url{http://opensoundcontrol.org/spec-1.0} for details.)
#'
#'     It is up to the function accepting this string representation to implement the actual binary encoding of the OSC Message.
#'
#'     Encoded OSC itself is transport-independent, but is often sent over UDP or TCP connections.
#'
#'     \strong{ADDRESS_PATTERN}
#'
#'     The OSC Address Pattern is a forward-slash delimited string represented a heirarchical
#'     user-defined address space (tree), with wildcards for pattern matching.
#'     The minimal OSC Address Pattern "/" represents the root of the tree.
#'     In OSC parlance, each tree node is referred to as a "container"
#'     and the final node is an "OSC method". The address is a means of
#'     dispatching data to a specified method in a heirarchical tree.
#'
#'     \strong{Wildcards:}
#'     \tabular{cl}{
#'     ? \tab matches any single character\cr
#'     * \tab matches any sequence of zero or more characters\cr
#'     \{\} \tab Curly braces containing a comma-separated list of strings (e.g., \{foo,bar\} )\cr
#'          \tab matches any string in the list.\cr
#'     [] \tab Brackets containing a string (e.g., [asdfq]) matches any character in the string.\cr
#'     - \tab (dash) In square brackets, separating two characters (e.g. [a-d] )\cr
#'       \tab matches a range of characters in ASCII collating sequence.\cr
#'     ! \tab In square brackets, preceding a string (e.g. [!xz] ) negates the entire string.\cr
#'       \tab \emph{e.g. 'a[!xz]' matches 'ay' but not 'ax' or 'az')}\cr
#'     }
#'
#'     Parsing of OSC Address Patterns and wildcards and proper dispatching of data is left to the recipient of the OSC Message.
#'
#'     \strong{ARGUMENTS}
#'
#'     Input data is flattened into a one-level list with all elements length 1, converted to a space-delimited argument string
#'     ('ARGUMENTS' in the OSC Message). \code{oscMessage} currently does not support array arguments, OSC-blobs or OSC-bundles.
#'     Nested lists and vectors of length > 1 will all be flattened.
#'
#'     \strong{TYPE_TAG_STRING}
#'
#'     You can supply your own OSC Type Tage String via the \code{typestring} argument. \code{oscMessage} is agnostic about the legality and interpretation
#'     of type tags. You must ensure that the encoding function and end recipeint of the message understand the type tags used. (See below.)
#'
#'     If \code{typestring='auto'}, oscMessage passes the data to \code{\link{oscType}} to generate the string.
#'     The R datatypes of the input data are mapped to OSC type tags as specified by additional arguments to oscMessage.
#'     Currently, only R data types "integer," "double," "character,"
#'     "NULL," and "logical" are supported. See \code{\link{oscType}} for additional details.
#'
#'     A minimal set of OSC type tags for 32 bit integers, 32 bit floats, and strings is standard across implementations.
#'     However, other data types and corresponding tags depend on the OSC version specification and OSC implementation.
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
#' @param address character. The OSC Address Pattern (see Details).
#' @param data list or vector.
#' @param logical character. R datatype that data of type 'logical' should be converted to prior to processing. Default: \code{logical='logical'}
#' @param typestring character. OSc Type Tag String: a string of non-space characters representing data types, beginning with ",".
#' @param integer character. Tag to use for R data type "integer". Default = "i", specifying a 32-bit signed big-endian 2'S compliment integer. (Identical to the R "integer" type.)
#' @param double character. Tag to use for R data type "integer". Default = "d", specifying a 64 bit IEEE 754 double (Identical the R "double" type.)
#' @param character character. Tag to use for R data type "character". Default = "s", specifying a string.
#' @param null character. Tag to use for R data type "NULL". Default = "N", specifying a "Nil" or null.
#' @param typecomma logocal. If \code{typestring='auto'} and \code{typecomma=TRUE} (the default), a leading comma "," is added to the beginning of the type tag string.
#'
#' @return character. A string representation of an OSC message in the format \code{ADDRESS_PATTERN TYPE_TAG_STRING ARGUMENTS}.
#'
#' @examples
#' address <- "/thing/n1/red"
#' data <- list(list(3:4,"apple"), TRUE, list(list(5.1,"sphere"),NULL))
#' OSC_1 <- oscMessage(address = address, data = data); OSC_1
#'
#' OSC_2 <- oscMessage(address = address, data = data, double = "f"); OSC_2
#'
#' OSC_3 <- oscMessage(address = address, data = data, typecomma=FALSE); OSC_3
#'
#' OSC_4 <- oscMessage(address = address, data = data, logical = "integer"); OSC_4
#'
#' pattern <- "/{th,s}ing/n[2-4]/red*"
#' types <- ",iiSidSN"
#' data <- list(list(3:4,"apple"), TRUE, list(list(5.1,"sphere"),NULL))
#' OSC_5 <- oscMessage(address = pattern, typestring = types, data = data, logical="integer")
#' OSC_5
#'
#' @export
oscMessage <- function(address="/", data=NULL, logical="logical", typestring="auto", integer="i", double = "d", character="s", null="N", typecomma=TRUE) {

  ## flatten data
  d <- data
  if (!is.null(d)) {
    d <- listFlatten(data)
  }

  ## convert logical data
  if (logical == "integer") {
    for (j in 1:length(d)) {
      if (is.logical(d[[j]])) {d[[j]] <- as.integer(d[[j]])}
    }
  }
  if (logical == "double") {
    for (j in 1:length(data)) {
      if (is.logical(d[[j]])) {d[[j]] <- as.double(d[[j]])}
    }
  }

  ## get OSC Type String
  if (typestring=="auto") {
    t <- oscType(
      d, integer=integer, double=double, character=character, null=null,
      typecomma=typecomma)
  } else {
    t <- typestring
  }

  ## contruct OSC argument list from data
  if (!is.null(d)) {
    d <- as.character(d)
    d <- d[!(d %in% c("TRUE","FALSE","NULL"))]
  }

  ## output OSC message
  osc <- paste(address, t, paste(d, collapse = " "), collapse = " ")
  return(osc)
}

### TODO Add time stamp support and full 1.1 spec support
### Accepts data as an atomic vector or list.
### Nested lists will be flattened with listFlatten()

