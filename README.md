
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/AustralianAntarcticDivision/bowerbird.svg?branch=master)](https://travis-ci.org/AustralianAntarcticDivision/bowerbird) [![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/5idrimyx0uuv6liu?svg=true)](https://ci.appveyor.com/project/raymondben/bowerbird) [![codecov](https://codecov.io/gh/AustralianAntarcticDivision/bowerbird/branch/master/graph/badge.svg)](https://codecov.io/gh/AustralianAntarcticDivision/bowerbird)

Bowerbird
=========

<img align="right" src="https://rawgit.com/AustralianAntarcticDivision/bowerbird/master/inst/extdata/bowerbird.svg" />

Often it's desirable to have local copies of third-party data sets. Fetching data on the fly from remote sources can be a great strategy, but for speed or other reasons it may be better to have local copies. This is particularly common in environmental and other sciences that deal with large data sets (e.g. satellite or global climate model products). Bowerbird is an R package for maintaining a local collection of data sets from a range of data providers.

Bowerbird can be used in several different modes:

-   interactively from the R console, to download or update data files on an as-needed basis
-   from the command line, perhaps as a regular scheduled task
-   programatically, including from within other R packages, scripts, or R markdown documents that require local copies of particular data files.

When might you consider using bowerbird rather than, say, [curl](https://cran.r-project.org/package=curl) or [crul](https://cran.r-project.org/package=crul)? The principal advantage of bowerbird is that it can download files recursively. In many cases, it is only necessary to specify the top-level URL, and bowerbird can recursively download linked resources. Bowerbird can also:

-   decompress downloaded files (if the remote server provides them in, say, zipped or gzipped form).

-   incrementally update files that you have previously downloaded. Bowerbird can be instructed not to re-download files that exist locally, unless they have changed on the remote server. Compressed files will also only be decompressed if changed.

Installing
----------

``` r
install.packages("devtools")
library(devtools)
install_github("AustralianAntarcticDivision/bowerbird",build_vignettes=TRUE)
```

Bowerbird uses the third-party utility `wget` to do the heavy lifting of recursively downloading files from data providers. `wget` is typically installed by default on Linux. On Windows you can use the `bb_install_wget()` function to install it. Otherwise download `wget` yourself (e.g. from <https://eternallybored.org/misc/wget/current/wget.exe>) and make sure it is on your path.

Usage
-----

### Configuration

Build up a configuration by first defining global options such as the destination on your local file system:

``` r
cf <- bb_config(local_file_root="~/your/data/directory")
```

Bowerbird must then be told which data sources to synchronize. Use the `bb_source()` function to define a data source. Let's use data from the 2016 Australian federal election as an example:

``` r
my_source <- bb_source(
    name="Australian Election 2016 House of Representatives data",
    id="aus-election-house-2016",
    description="House of Representatives results from the 2016 Australian election.",
    doc_url="http://results.aec.gov.au/",
    citation="Copyright Commonwealth of Australia 2017. As far as practicable, material for which the copyright is owned by a third party will be clearly labelled. The AEC has made all reasonable efforts to ensure that this material has been reproduced on this website with the full consent of the copyright owners.",
    source_url=c("http://results.aec.gov.au/20499/Website/HouseDownloadsMenu-20499-Csv.htm"),
    license="CC-BY",
    method=list("bb_handler_wget",recursive=TRUE,level=1,accept="csv",no_if_modified_since=TRUE,execute=c("robots=off"),reject_regex="Website/UserControls"),
    collection_size=0.01)

cf <- bb_config(local_file_root="~/temp/data/bbtest") %>%
    bb_add(my_source)
```

### First-time synchronization

Once the configuration has been defined, run the sync process:

``` r
bb_sync(cf)
```

Congratulations! You now have your own local copy of your chosen data sets. This particular example is fairly small (about 10MB, as you can see from the `collection_size` entry --- which is in GB), so it should not take too long to download.

At a later time you can re-run this synchronization process. If the remote files have not changed, and assuming that your configuration has the `clobber` parameter set to 0 (do not overwrite existing files) or 1 (overwrite only if the remote file is newer than the local copy) then the sync process will run more quickly because it will not need to re-download any data files.

### Prepackaged data source definitions

A few example data source definitions are provided as part of the bowerbird package --- see the list at the bottom of this document. Other packages (e.g. [blueant](https://github.com/AustralianAntarcticDivision/blueant)) provide themed sets of data sources that can be used with bowerbird.

Nuances
-------

### Data source definitions

The philosophy of bowerbird is to use the `wget` utility as much as possible to handle web transactions. Using `wget` (and its recursive download functionality) simplifies the process of writing and maintaining data source definitions. Typically, one only needs to provide the top-level URL and appropriate flags to pass to `wget`, along with some basic metadata (primarily intended to be read by the user).

However, one of the consequences of this approach is that bowerbird actually knows very little about the data files that it maintains, which can be limiting in some respects. It is not generally possible, for example, to provide the user with an indication of download progress (progress bar or similar) for a given data source because neither bowerbird nor `wget` actually know how many files are in it. Data sources do have a `collection_size` entry, to give the user some indication of the disk space required, but this is only approximate (and must be hand-coded by the data source maintainer). See the 'Reducing download sizes' section below for tips on retrieving only a subset of a large data source.

### Data source handlers

The `bb_handler_wget` R function provides a wrapper around `wget` that should be sufficient for many data sources. However, some data sources can't be retrieved using only simple `wget` calls, and so the `method` for such data sources will need to be something more elaborate than `bb_handler_wget`. Notes will be added here about defining new handler functions, but in the meantime look at e.g. `bb_handler_oceandata` or `bb_handler_earthdata`, which provide handlers for [oceandata](https://oceandata.sci.gsfc.nasa.gov/) and [earthdata](https://earthdata.nasa.gov/) data sources.

### Choosing a data directory

It's up to you where you want your data collection kept, and to provide that location to bowerbird. A common use case for bowerbird is maintaining a central data collection for multiple users, in which case that location is likely to be some sort of networked file share. However, if you are keeping a collection for your own use, you might like to look at <https://github.com/r-lib/rappdirs> to help find a suitable directory location.

### Defining data sources

Data sources are defined using the `bb_source()` function:

``` r
my_source <- bb_source(
    name="Geoscience Australia multibeam bathymetric grids of the Macquarie Ridge",
    id="10.4225/25/53D9B12E0F96E",
    description="This is a compilation of all the processed multibeam bathymetry data that are publicly available in Geoscience Australia's data holding for the Macquarie Ridge.",
    doc_url="http://www.ga.gov.au/metadata-gateway/metadata/record/gcat_b9224f95-a416-07f8-e044-00144fdd4fa6/XYZ+multibeam+bathymetric+grids+of+the+Macquarie+Ridge",
    citation="Spinoccia, M., 2012. XYZ multibeam bathymetric grids of the Macquarie Ridge. Geoscience Australia, Canberra.",
    source_url="http://www.ga.gov.au/corporate_data/73697/Macquarie_ESRI_Raster.zip",
    license="CC-BY 4.0",
    method=list("bb_handler_wget",recursive=TRUE),
    postprocess=list("bb_unzip"),
    collection_size=0.4,
    data_group="Topography")
```

Some particularly important components of this definition are:

1.  The `id` uniquely identifies the data source. If the data source has a DOI, use that. Otherwise, if the original data provider has an identifier for this dataset, that is probably a good choice here (include the data version number if there is one). The `id` should be something that changes when the data set is updated. A DOI is ideal for this. The `name` entry should be a human-readable but still concise name for the data set.

2.  The `license` and `citation` are important so that users know what conditions govern the usage of the data, and the appropriate citation to use to acknowledge the data providers. The `doc_url` entry should refer to a metadata or documentation page that describes the data in detail.

3.  The `method` and `source_url` define how this data will be retrieved. Most sources will use the `bb_handler_wget` method function, which is a wrapper around the `wget` utility. If you are unfamiliar with wget, consult the [wget manual](https://www.gnu.org/software/wget/manual/wget.html) or one of the many online tutorials. You can also see the in-built wget help by running `bb_wget("--help")`.

Some subtleties to bear in mind:

1.  If the data source delivers compressed files, you will most likely want to decompress them after downloading. The postprocess options `bb_decompress`, `bb_unzip`, etc will do this for you. By default, these *do not* delete the compressed files after decompressing. The reason for this is so that on the next synchronization run, the local (compressed) copy can be compared to the remote compressed copy, and the download can be skipped if nothing has changed. Deleting local compressed files will save space on your file system, but may result in every file being re-downloaded on every synchronization run.

2.  The `method` parameter is specified as a list, where the first entry is the function to use and the remaining entries are data-source-specific arguments to pass to that function. You will probably want to specify `recursive=TRUE` in these arguments, even if the data source doesn't require a recursive download. The synchronization process saves files relative to the `local_file_root` directory specified in the call to `bb_config`. If `recursive=TRUE` is specified, then wget creates a directory structure that follows the URL structure. For example, calling `bb_wget("http://www.somewhere.org/monkey/banana/dataset.zip",recursive=TRUE)` will save the local file `www.somewhere.org/monkey/banana/dataset.zip`. Thus, specifying `recursive=TRUE` will keep data files from different sources naturally separated into their own directories. Without this flag, you are likely to get all downloaded files saved into your `local_file_root`. (Note that `recursive` has a default setting of `TRUE` in `bb_wget` for this reason.)

3.  If you want to include/exclude certain files from being downloaded, use the `accept`, `reject`, `accept_regex`, and `reject_regex` flags. Note that `accept` and `reject` apply to file names (not the full path), and can be comma-separated lists of file name suffixes or patterns. The `accept_regex` and `reject_regex` flags apply to the full path but can only be a single regular expression each.

4.  Remember that any `wget_global_flags` defined via `bb_config` will be applied to every data source in addition to their specific `method` flags.

5.  Several wget flags are set by the `bb_handler_wget` function itself. The `--user` and `--password` flags are populated with any values supplied to the `user` and `password` parameters of the source. Similarly, the `clobber` parameter supplied to `bb_config` controls the overwrite behaviour: if `clobber` is 0 then the `--no-clobber` flag is added to each wget call; if `clobber` is 1 then the `--timestamping` flag is added.

6.  If `wget` is not behaving as expected, try adding the `debug=TRUE` parameter to see additional diagnostic output.

### Modifying data sources

#### Authentication

Some data providers require users to log in. The `authentication_note` column in the configuration table should indicate when this is the case, including a reference (e.g. the URL via which an account can be obtained). For these sources, you will need to provide your user name and password, e.g.:

``` r
mysrc <- subset(bb_example_sources(),name=="CMEMS global gridded SSH reprocessed (1993-ongoing)")
mysrc$user <- "yourusername"
mysrc$password <- "yourpassword"
cf <- bb_add(cf,mysrc)

## or, using dplyr
library(dplyr)
mysrc <- bb_example_sources() %>%
  filter(name=="CMEMS global gridded SSH reprocessed (1993-ongoing)") %>%
  mutate(user="yourusername",password="yourpassword")
cf <- cf %>% bb_add(mysrc)
```

#### Reducing download sizes

Sometimes you might only want part of a data collection. Perhaps you only want a few years from a long-term collection, or perhaps the data are provided in multiple formats and you only need one. If the data source uses the `bb_handler_wget` method, you can restrict what is downloaded by modifying the arguments passed through the data source's `method` parameter, particularly the `accept`, `reject`, `accept_regex`, and `reject_regex` options. If you are modifying an existing data source configuration, you most likely want to leave the original method flags intact and just add extra flags.

Say a particular data provider arranges their files in yearly directories. It would be fairly easy to restrict ourselves to, say, only the 2017 data:

``` r
mysrc <- mysrc %>%
  mutate(method=c(method,list(accept_regex="/2017/")))
cf <- cf %>% bb_add(mysrc)
```

See the notes above for further guidances on the accept/reject flags.

Alternatively, for data sources that are divided into subdirectories, one could replace the whole-data-source `source_url` with one or more that point to the specific subdirectories that are wanted.

### Parallelized sync

If you have many data sources in your configuration, running the sync in parallel is likely to speed the process up considerably (unless your bandwidth is the limiting factor). A logical approach to this would be to split a configuration, with a subset of data sources in each (see `bb_subset`), and run those subsets in parallel. One potential catch to keep in mind would be data sources that hit the same remote data provider. If they overlap overlap in terms of the parts of the remote site that they are mirroring, that might invoke odd behaviour (race conditions, simultaneous downloads of the same file by different parallel processes, etc).

### Data provenance and reproducible research

An aspect of reproducible research is knowing which data were used to perform an analysis, and potentially archiving those data to an appropriate repository. Bowerbird can assist with this: see `vignette("data_provenance")`.

Data source summary
-------------------

These are the example data source definitions that are provided as part of the bowerbird package.

### Data group: Altimetry

#### CMEMS global gridded SSH reprocessed (1993-ongoing)

For the Global Ocean - Multimission altimeter satellite gridded sea surface heights and derived variables computed with respect to a twenty-year mean. Previously distributed by Aviso+, no change in the scientific content. All the missions are homogenized with respect to a reference mission which is currently OSTM/Jason-2. VARIABLES

-   sea\_surface\_height\_above\_sea\_level (SSH)

-   surface\_geostrophic\_eastward\_sea\_water\_velocity\_assuming\_sea\_level\_for\_geoid (UVG)

-   surface\_geostrophic\_northward\_sea\_water\_velocity\_assuming\_sea\_level\_for\_geoid (UVG)

-   sea\_surface\_height\_above\_geoid (SSH)

-   surface\_geostrophic\_eastward\_sea\_water\_velocity (UVG)

-   surface\_geostrophic\_northward\_sea\_water\_velocity (UVG)

Authentication note: Copernicus Marine login required, see <http://marine.copernicus.eu/services-portfolio/register-now/>

Approximate size: 310 GB

Documentation link: <http://cmems-resources.cls.fr/?option=com_csw&view=details&tab=info&product_id=SEALEVEL_GLO_PHY_L4_REP_OBSERVATIONS_008_047>

### Data group: Electoral

#### Australian Election 2016 House of Representatives data

House of Representatives results from the 2016 Australian election.

Approximate size: 0.01 GB

Documentation link: <http://results.aec.gov.au/>

### Data group: Ocean colour

#### Oceandata SeaWiFS Level-3 mapped monthly 9km chl-a

Monthly remote-sensing chlorophyll-a from the SeaWiFS satellite at 9km spatial resolution

Approximate size: 7.2 GB

Documentation link: <https://oceancolor.gsfc.nasa.gov/>

### Data group: Sea ice

#### Sea Ice Trends and Climatologies from SMMR and SSM/I-SSMIS, Version 2

NSIDC provides this data set to aid in the investigations of the variability and trends of sea ice cover. Ice cover in these data are indicated by sea ice concentration: the percentage of the ocean surface covered by ice. The ice-covered area indicates how much ice is present; it is the total area of a pixel multiplied by the ice concentration in that pixel. Ice persistence is the percentage of months over the data set time period that ice existed at a location. The ice-extent indicates whether ice is present; here, ice is considered to exist in a pixel if the sea ice concentration exceeds 15 percent. This data set provides users with data about total ice-covered areas, sea ice extent, ice persistence, and monthly climatologies of sea ice concentrations.

Authentication note: Requires Earthdata login, see <https://urs.earthdata.nasa.gov/>. Note that you will also need to authorize the application 'nsidc-daacdata' (see 'My Applications' at <https://urs.earthdata.nasa.gov/profile>)

Approximate size: 0.02 GB

Documentation link: <https://nsidc.org/data/NSIDC-0192/versions/2>

### Data group: Sea surface temperature

#### NOAA OI SST V2

Weekly and monthly mean and long-term monthly mean SST data, 1-degree resolution, 1981 to present. Ice concentration data are also included, which are the ice concentration values input to the SST analysis

Approximate size: 0.9 GB

Documentation link: <http://www.esrl.noaa.gov/psd/data/gridded/data.noaa.oisst.v2.html>

### Data group: Topography

#### Bathymetry of Lake Superior

A draft version of the Lake Superior Bathymetry was compiled as a component of a NOAA project to rescue Great Lakes lake floor geological and geophysical data, and make it more accessible to the public. No time frame has been set for completing bathymetric contours of Lake Superior, though a 3 arc-second (~90 meter cell size) grid is available.

Approximate size: 0.03 GB

Documentation link: <https://www.ngdc.noaa.gov/mgg/greatlakes/superior.html>
