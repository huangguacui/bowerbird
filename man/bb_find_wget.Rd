% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wget.R
\name{bb_find_wget}
\alias{bb_find_wget}
\title{Find the wget executable}
\usage{
bb_find_wget(install = FALSE, error = TRUE)
}
\arguments{
\item{install}{logical: attempt to install the executable if it is not found? (Windows only)}

\item{error}{logical: if wget is not found, raise an error. If \code{FALSE}, do not raise an error but return NULL}
}
\value{
the path to the wget executable, or (if error is \code{FALSE}) NULL if it was not found
}
\description{
This function will return the path to the wget executable if it can be found on the local system, and optionally install it if it is not found. Installation (if required) currently only works on Windows platforms. The wget.exe executable will be downloaded from https://eternallybored.org/misc/wget/ installed into your appdata directory (typically something like C:/Users/username/AppData/Roaming/)
}
\examples{
\dontrun{
  wget_path <- bb_find_wget()
  wget_path <- bb_find_wget(install=TRUE) ## install (on windows) if needed
}

}
\references{
https://eternallybored.org/misc/wget/
}
\seealso{
\code{\link{bb_install_wget}}
}
