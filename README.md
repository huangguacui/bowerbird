
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](http://badges.herokuapp.com/travis/ropensci/bowerbird?branch=master&env=BUILD_NAME=trusty_release&label=linux)](https://travis-ci.org/ropensci/bowerbird) [![Build Status](http://badges.herokuapp.com/travis/ropensci/bowerbird?branch=master&env=BUILD_NAME=osx_release&label=osx)](https://travis-ci.org/ropensci/bowerbird) [![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/5idrimyx0uuv6liu?svg=true)](https://ci.appveyor.com/project/ropensci/bowerbird) [![codecov](https://codecov.io/gh/ropensci/bowerbird/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/bowerbird) [![](https://badges.ropensci.org/139_status.svg)](https://github.com/ropensci/onboarding/issues/139)

Bowerbird
=========

<img align="right" src="https://rawgit.com/ropensci/bowerbird/master/inst/extdata/bowerbird.svg" />

Often it's desirable to have local copies of third-party data sets. Fetching data on the fly from remote sources can be a great strategy, but for speed or other reasons it may be better to have local copies. This is particularly common in environmental and other sciences that deal with large data sets (e.g. satellite or global climate model products). Bowerbird is an R package for maintaining a local collection of data sets from a range of data providers.

A comprehensive introduction to bowerbird can be found at <https://ropensci.github.io/bowerbird/articles/bowerbird.html>, along with full package documentation.

Installing
----------

``` r
install.packages("devtools")
library(devtools)
install_github("ropensci/bowerbird",build_vignettes=TRUE)
```

Usage overview
--------------

### Configuration

Build up a configuration by first defining global options such as the destination on your local file system:

``` r
library(bowerbird)
my_directory <- "~/my/data/directory"
cf <- bb_config(local_file_root = my_directory)
```

Bowerbird must then be told which data sources to synchronize. Let's use data from the Australian 2016 federal election, which is provided as one of the example data sources:

``` r
my_source <- bb_example_sources("Australian Election 2016 House of Representatives data")

## add this data source to the configuration
cf <- bb_add(cf, my_source)
```

Once the configuration has been defined and the data source added to it, we can run the sync process. We set `verbose = TRUE` here so that we see additional progress output:

``` r
status <- bb_sync(cf, verbose = TRUE)
```

Congratulations! You now have your own local copy of your chosen data set. This particular example is fairly small (about 10MB), so it should not take too long to download. Details of the files in this data set are given in the `status$files` object:

``` r
status$files
```

At a later time you can re-run this synchronization process. If the remote files have not changed, and assuming that your configuration has the `clobber` parameter set to 0 ("do not overwrite existing files") or 1 ("overwrite only if the remote file is newer than the local copy") then the sync process will run more quickly because it will not need to re-download any data files.

Data source definitions
-----------------------

The [blueant](https://github.com/AustralianAntarcticDivision/blueant) package provides a suite of bowerbird data source definitions themed around Southern Ocean and Antarctic data, and includes a range of oceanographic, meteorological, topographic, and other environmental data sets.

[![ropensci\_footer](https://ropensci.org/public_images/scar_footer.png)](https://ropensci.org)
