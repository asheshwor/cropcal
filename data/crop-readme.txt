----------------- CROP CALENDAR DATASET DOCUMENTATION ------------------

Author: Bill Sacks (wsacks "at" gmail.com)

Documentation last updated: December 17, 2010

------------------------------------------------------------------------
Table of Contents
------------------------------------------------------------------------

I. Dataset overview
II. Crop calendar maps
  A. Overview
  B. *.2.* and *.Winter.* qualifiers
  C. Variables included in the maps
  D. Notes about map resolution and regridding
  E. Notes about ArcINFO ASCII files
  F. Notes about unfilled vs. filled (extrapolated) files
III. Map figures
IV. Regional climate figures
V. Data sources & calculation of climate variables
  A. Sources of crop calendars
  B. Sources of climate data
  C. Calculation of climate averages
VI. Extrapolation routine
VII. Data coverage
VIII. References


------------------------------------------------------------------------
I. Dataset overview
------------------------------------------------------------------------

This dataset is the result of digitizing and georeferencing existing
observations of crop planting and harvesting dates. We then derived
climate statistics (e.g., the average temperature at which planting
occurs in each region) by merging these crop calendar maps with monthly
climatologies from CRU.

This dataset is described in the following publication:

Sacks, W.J., D. Deryng, J.A. Foley, and N. Ramankutty (2010). Crop
planting dates: An analysis of global patterns. Global Ecology and
Biogeography, 19: 607-620.


The following sets of files are available here:

- Crop calendar maps: Gridded maps of planting dates, harvesting dates,
  etc., for 19 crops. These maps are available at two different
  resolutions (5 minute and 0.5 degree), and in two different formats
  (netCDF and ArcINFO ASCII). For each region where we have a crop
  calendar observation, we have applied that observation to every grid
  cell in the region (i.e., a simple "paint-by-number" approach).

- Map figures: Figures showing maps of planting dates, harvesting dates,
  days between planting and harvest, and a few climatic metrics for each
  crop, such as the average temperature at which the crop is planted in
  each region.

- Regional climate figures: One figure for each region-crop combination.
  These figures show the planting and harvesting dates of that crop in
  that region, along with annual cycles of temperature, precipitation,
  and potential evapotranspiration.


For more information, contact Bill Sacks: wsacks "at" gmail.com


------------------------------------------------------------------------
II. Crop calendar maps
------------------------------------------------------------------------

--- A. Overview ---

These are gridded maps of planting dates, harvesting dates and related
variables, for 19 crops. There is a total of 25 maps, including the
separation of winter vs. spring types, and first vs. second seasons in
double-cropping systems. 

There are 8 sets of maps:

- Two different resolutions: 5 minute and 0.5 degree

- Two different formats: netCDF and ArcINFO ASCII

- Unfilled and filled (i.e., extrapolated in space)


--- B. *.2.* and *.Winter.* qualifiers ---

Maps with names of the format *.2.* contain the crop calendar
information for the second (subordinate) season in a double-cropping
system. Maps with names of the format *.Winter.* contain the crop
calendar information for the winter variety of a grain; the file without
the "Winter" classifier (if present) contains the crop calendar for the
spring variety. We generally put a crop calendar in the "winter"
category if it exhibited the pattern of planting shortly before the
coldest time of year and harvesting around the warmest time of year
(exception: we classified Australian wheat as spring wheat, based on
email communication with D.L. Liu, 3/19/09). In tropical/subtropical
regions, our classification into winter and spring varieties was
somewhat subjective. Some of the regions that we include in the "winter"
cereal maps may actually grow the spring varieties of these cereals.


--- C. Variables included in the maps ---

The following variables are included in all files:

- plant: mean planting day of year

- plant.start: day of year of start of planting period

- plant.end: day of year of end of planting period

- plant.range: number of days between start and end of planting period

- harvest: mean harvest day of year

- harvest.start: day of year of start of harvest period

- harvest.end: day of year of end of harvest period

- harvest.range: number of days between start and end of harvest period

- tot.days: number of days between planting and harvest

- index: the Data ID from the original data (each observation - i.e.,
  each crop-region combination - in the original data was given a unique
  Data ID)


The following variable is included only in the unfilled files:

- political.level: the political unit level at which the data were
  specified (1: national; 2: state / province; 3: sub-state)


The following variable is included only in the filled files:

- filled.index: for extrapolated points, what is the observation ID of
  the nearest neighbor - i.e. the observation used to fill this point


The following variables are included only in the 5-minute unfilled
files:

- harvested.area.fraction: taken directly from Chad Monfreda's data
  (Monfreda et al. 2008) - essentially, the fraction of each grid cell
  in which this crop is grown (but double-cropped areas are counted
  double)

- harvested.area: = harvested.area.fraction * grid cell area


--- D. Notes about map resolution and regridding ---

The "native" format of the data is 5-minute. The 0.5 degree maps were
created by regridding the 5-minute maps. The regridding was done by
treating the "index" map as categorical data, taking the dominant index
in each new 0.5 degree grid cell (if there was a tie, we put an NA [no
data] there). Then we used this regridded index map to assign the other
map variables at 0.5 degree resolution. Thus, we ensured consistency
between all of the regridded maps: if a 0.5 degree grid cell has index =
9, then the other variables will be copied from the data item with index
= 9.


--- E. Notes about ArcINFO ASCII files ---

The ArcINFO ASCII files are provided as gzipped, tarred files; upon
unzipping and untarring these, you will find a directory containing a
*.asc file for each variable. The first 6 lines of each file contain
header information describing the grid and the missing value flag. The
7th line contains the data, in row-major order.

The political.level variable is stored as integer data; all other
variables are stored as floating point data.


--- F. Notes about unfilled vs. filled (extrapolated) files ---

The unfilled maps (files without ".fill" in their names) contain data
only for grid cells in regions where we actually have crop calendar
observations. The filled maps (files with ".fill" in their names)
contain spatially extrapolated crop calendar data. These filled files
could be used, for example, as inputs to a global model that requires
data in every grid cell. See the "Extrapolation routine" section, below,
for details on how we performed this spatial extrapolation. 

However, please, please bear in mind the following caveats about the
extrapolated values before deciding to use them:

** WARNING: THE EXTRAPOLATED VALUES SHOULD BE USED WITH CARE **

** WE HAVE NOT CHECKED THESE EXTRAPOLATED VALUES TO MAKE SURE THEY ARE
REASONABLE IN ALL PLACES **. In fact, they are probably unreasonable in
many places. In some cases you may be using data that have been
extrapolated from a different continent!

** YOU SHOULD ONLY USE THESE EXTRAPOLATED VALUES IF YOU HAVE CHECKED
THEM YOURSELF AND HAVE DETERMINED THEM TO BE REASONABLE ENOUGH FOR YOUR
PURPOSES **

The extrapolation routine that we used is extremely simple - basically a
nearest-neighbor routine. While this is reasonable in some places, it
provides unreasonable results in other places - especially in places far
from any observations.

Crops for which we only have a few observations, or for which the
observations are concentrated in a small area of the world (e.g., Sweet
Potatoes or Yams) should be treated with particular care. For these
crops, the extrapolation routine is often forced to pull data from a
distant location. In some cases, you may get better results by using the
crop calendar map for a different crop for which there is a higher data
density (i.e., using the planting & harvesting dates of a crop with lots
of observations as a proxy for the planting & harvesting dates of
another crop with fewer observations).

Also, use particular care if you want to use the filled values of
plant.start, plant.end and plant.range (and similarly for harvest). I
see these filled values as even less certain than the filled values of
the mean planting / harvesting dates: Since the ranges probably capture
a combination of spatial and temporal variability, it doesn't
necessarily make sense to spatially extrapolate these ranges in the
simple way we do. For example, consider a grid cell whose nearest
neighbor is a very large region that has a very large range in planting
dates because of its large climatic range. It is not necessarily correct
to infer that the range of planting dates of the given grid cell is
itself very wide. 

Finally, note that a few regions have data on the mean planting date,
but no data on the range of planting dates (and similarly for harvest).
For these data, there will be missing values in the maps of plant.start,
plant.end and plant.range (and similarly for harvest), even in the
filled map.


------------------------------------------------------------------------
III. Map figures
------------------------------------------------------------------------

The file 'map_figures.tar.gz' is a gzipped tarred file containing TIFF
images showing maps of the following variables for each crop:

- Planting date: Same as the 'plant' variable in the crop calendar maps

- Harvest date: Same as the 'harvest' variable in the crop calendar maps

- Days between planting and harvest: Same as the 'tot.days' variable in
  the crop calendar maps

- Temperature at planting: For each region, we computed a single value,
  which is the average across time (1961-1990) and space of the
  temperature on the mean planting date in that region. In averaging
  across space, we weighted the temperature of each grid cell by the
  harvested area of the given crop in that grid cell. See the "Data
  sources & calculation of climate variables" section, below, for more
  details.

- Precipitation at planting: Similar to "Temperature at planting", but
  for the average precipitation rate on the mean planting date in each
  region. Note the logarithmic scale. Again, see the "Data sources &
  calculation of climate variables" section, below, for more details.

- Precip over PET at planting: Similar to "Temperature at planting", but
  for the average value of (precipitation) / (potential
  evapotranspiration) on the mean planting date in each region. Note the
  logarithmic scale. Again, see the "Data sources & calculation of
  climate variables" section, below, for more details.

- GDD between planting and harvest: Accumulated growing degree days
  between the average planting date and average harvesting date in each
  region. This calculation uses a base temperature of 5 C and a maximum
  of 30 C. As with the other climatic variables, we computed a single
  value for each region, based on the weighted average temperatures
  across time (1961-1990) and space in that region.


Gray areas on the maps indicate lack of crop calendar observations for
the given crop. Black lines delineate the regions for which we have crop
calendar observations.


------------------------------------------------------------------------
IV. Regional climate figures
------------------------------------------------------------------------

The file 'regional_figures.tar.gz' is a gzipped tarred file containing
one PDF figure for each crop-location combination. Each figure shows
typical planting and harvesting dates for the region, along with annual
cycles of temperature, precipitation and potential evapotranspiration
(PET). Specifically, these figures show:

- Title: Crop and location. The lat & lon give the weighted centroid of
  the region, where the weighting is done by the harvested area of the
  crop in this region (this weighting is described in more detail
  below).

- Subtitle: The total harvested area of the crop in this region,
  according to Monfreda et al. (2008).

- Planting dates: green vertical lines. The dashed and dot-dashed lines
  give the start and end dates of the planting window, and the solid
  line gives the mean of the two.

- Harvesting dates: black vertical lines. The meaning of the three lines
  is similar to that for planting dates.

- Annual cycles of climate variables: The red curves show climatological
  average temperatures for each month, the solid blue curves
  climatological average precipitation, and the dashed blue curves
  climatological average PET. The climatological averages are averages
  across time (1961-1990) and space, with each grid cell weighted by the
  given crop's harvested area in that grid cell. For temperature and
  precipitation, the points give the monthly average values, and the
  lines simply interpolate these monthly averages. The error bars give
  spatial weighted standard deviations (again, weighted by harvested
  area). See the "Data sources & calculation of climate variables"
  section, below, for more details on the calculation of these climate
  variables.


File naming convention: The file names have the format:

	climate.<Crop>.<Location>.<Data ID>.pdf

- <Crop>: this part of the file name can also include qualifiers like
  '.Winter' or '.2' (the latter for the second (subordinate) season in a
  double-cropping system, similar to the naming convention for the crop
  calendar maps, described above).

- <Location>: In many cases, this is the country for which the
  observation applies. But in the case of sub-national data, this will
  give the name of the sub-national region for which the observation
  applies. Note that, in a few cases, there are multiple observations
  that have the same Crop and Location (e.g., for states in India).
  These observations actually apply to different specific regions within
  the named location, as can be seen from the lat & lon values in the
  titles of these figures, or by looking at the crop calendar maps.

- <Data ID>: The Data ID from the original data (each observation -
  i.e., each crop-region combination - in the original data has a unique
  Data ID). This number corresponds to the 'index' in the crop calendar
  maps.


------------------------------------------------------------------------
V. Data sources & calculation of climate variables
------------------------------------------------------------------------

--- A. Sources of crop calendars ---

We compiled observations of crop planting and harvesting dates from six
sources (see below). These sources present ranges of typical planting
and harvesting dates, categorized by crop and region. Most of the
original data were assembled by the United Nation's Food and
Agricultural Organization (FAO) or the United States Department of
Agriculture (USDA) - and in particular, by personnel with expertise in a
given region. Most data were specified at the national level, but we
used sub-national data for the United States, Russia, the Ukraine,
India, Australia and a few other large countries. In general, the
observations gave typical planting and harvesting dates for the 1990s or
early 2000s.

Most data were obtained in graphical format. We digitized the typical
start and end dates for planting and harvesting from these graphs using
DigitizeIt (version 1.5.7; available via http://www.digitizeit.de); we
then computed the mean planting and harvesting dates from these ranges.

The sources of crop calendar data were the following (ordered
approximately from greatest to smallest area coverage):

- FAO's GIEWS (accessed November 5, 2007)

	- Available via http://www.fao.org/giews/workstation/page.jspx -
          Select a country from the "Select Project" list box, and when
          you are in the country project select Tools : Crop Calendar
          from the menu

	- Alternatively, can access the data directly here:
          http://www.fao.org/giews/workstation/data/ - Includes zip
          files for crop calendar images for each continent

	- Provides data for many countries, with an emphasis on
          developing countries, especially Africa. Mostly national-level
          data, but some large countries are divided into two or three
          regions.

- USDA's "Major World Crop Areas and Climatic Profiles" (MWCACP) report,
  and online updates (accessed November 7, 2007)

	- Available via
          http://www.usda.gov/oce/weather/pubs/Other/MWCACP/index.htm 

	- We used the latest updates available as of November 7, 2007.
          However, in some cases, the only data available were from the
          original 1994 report; in these cases, where there were no
          updates available, we used the original 1994 data.

	- Provides data for many countries, with an emphasis on Europe,
          Asia and North America. Mostly national-level data, but some
          large countries are divided into two regions.

- USDA FAS's Crop Explorer (accessed September 9, 2008)

	- Available via http://www.pecad.fas.usda.gov/cropexplorer/

	- Provides high-resolution, sub-national data for Russia and the
          Ukraine. Also, national-level data for Argentina, Cote
          d'Ivoire, Ethiopia, Iran, Iraq, Kenya, Nigeria, Somalia,
          Syria, Tanzania, Turkey and Zimbabwe.

- USDA NASS's 1997 publication, "Usual Planting and Harvesting Dates for
  U.S. Field Crops" (accessed October 15, 2007)

	- Available via
          http://www.nass.usda.gov/Publications/National_Crop_Progress/index.asp

	- Provides state-level data for the United States

- IMD-AGRIMET's "Crop weather calendar of different states of the
  country" (accessed February 5, 2008)

	- Available via http://imdagrimet.org/cwc.htm 

	- Provides very high-resolution, district-level data for India

- USDA FAS Australia's "Index of agricultural crop calendars for
  Australia, Bangladesh, India, Pakistan" (accessed September 9, 2008)

	- Available via
          http://ffas.usda.gov/remote/aus_sas/crop_information/calendars/index_of_clndrs.htm

	- Provides state-level data for Australia


In the case of disagreements between USDA's MWCACP and FAO's GIEWS,
priority was usually given to USDA's MWCACP; but in a few cases, we
either gave priority to FAO's GIEWS or averaged the data from these two
sources. This decision was made based on the spatial resolution of the
two sources, the stated source of the observation in FAO's GIEWS data
set, and how recently the observation was updated in USDA's MWCACP data
set. (We used data from FAO's GIEWS for cotton in Uzbekistan, rice in
Japan, South Korea, Indonesia and Malaysia, and winter wheat and barley
in Algeria, Morocco and Tunisia. We averaged the two sources for maize,
rice and winter wheat in Argentina, winter wheat in South Africa, maize
in eastern South Africa, and second season maize in central & southern
Brazil. In all other cases, we gave priority to USDA's MWCACP.)

In the case of disagreements between national-level data from USDA FAS's
Crop Explorer and either FAO's GIEWS or USDA's MWCACP, priority was
given to FAO's GIEWS or USDA's MWCACP.


--- B. Sources of climate data ---

We used monthly climatologies of temperature, precipitation and sunshine
fraction for the years 1961-1990, from the Climatic Research Unit,
University of East Anglia (the CRU CL 2.0 data set: New et al., 2002).
These data are available at ten-minute spatial resolution; we
interpolated them to five-minute resolution to match the resolution of
the crop maps (described below, under "Calculation of climate
averages"). To compute quantities such as the temperature at planting,
we linearly interpolated these monthly climatologies to daily values.

We also computed climatologies of potential evapotranspiration (PET) for
each region, using the Priestley-Taylor equation with alpha = 1.26
(Priestley & Taylor, 1972):

	PET = 86400 * (1/lambda) * 1.26 * (Delta * Rn)/(Delta + gamma)

Where:

	lambda = 2.495e+06 - dtemp * 2380 [latent heat of vaporization]

	Delta = 2.503e+06 / (237.3 + dtemp)^2 * exp(17.269 * dtemp /
	(237.3 + dtemp)) [rate of change of saturated vapor pressure
	with temperature]

	gamma = 65.05 + dtemp * 0.064 [psychrometric "constant"]

	Rn: daily net radiation, with incoming solar radiation computed
	from solar geometry and sun fraction, and outgoing longwave
	radiation computed as (0.2 + 0.8 * dsun) * (107.0 - dtemp). We
	assume a constant albedo of 0.2 everywhere (because we care most
	about PET around the time of planting, when the land surface is
	generally bare - so we use this value that is typical for soil
	albedo)

	dsun: daily sun fraction (interpolated from monthly values;
	weighted spatial average over the given region, as described
	below)

	dtemp: daily temperature (interpolated from monthly values;
	weighted spatial average over the given region, as described
	below)

Important note for people using these crop calendar data with the
PEGASUS ecosystem model: I calculated PET in the same way as in PEGASUS,
except that I used alpha = 1.26 rather than 1.0. This means that my
values of PET are 1.26 times greater than the values of PET calculated
by PEGASUS.


--- C. Calculation of climate averages ---

For each crop calendar observation, we computed weighted spatial means
and standard deviations of temperature, precipitation and sunshine
fraction over the region for which the observation applied. The
weighting was done based on the harvested area of the given crop, using
the five-minute resolution crop maps produced by Monfreda et al. (2008).
For large regions where a crop is only grown in part of the region, this
weighting ensures that the climate averages apply to the area in which
the crop is actually grown. However, the Monfreda et al. (2008) data set
combines winter and spring wheat in a single map, and similarly for
barley and oats. Thus, in weighting the climate data, we were not able
to distinguish between the harvested area of winter vs. spring crops.
This could lead to incorrect weightings in regions that grow substantial
amounts of both the winter and spring varieties of these crops.

Similarly, the latitude and longitude values presented in the regional
climate figures present the weighted average centroid, with weighting
based on the Monfreda et al. (2008) harvested areas.

There are some places where we have crop calendar data, but the Monfreda
et al. (2008) data sets say that that crop doesn't grow there. In these
cases, the climate averages will be missing, since there are no
harvested area data to use for the weighted averages.


------------------------------------------------------------------------
VI. Extrapolation routine
------------------------------------------------------------------------

NOTE: See also the section containing notes about unfilled vs. filled
(extrapolated) files, in the "Crop calendar maps" section, above. In
particular, please read the caveats in that section before using the
extrapolated (filled) maps.

For the *.fill.* maps, we basically use a nearest neighbor routine, in
which a grid cell with no data is assigned the values of the nearest
region for which we have crop calendar data. However, there are a few
twists to our nearest neighbor routine:

- The geographic location of each crop calendar observation is defined
  using a weighted centroid, where each pixel in the region is weighted
  by the harvested area of the given crop in that pixel. In other words:
  we are not simply using the center of the geographic region, but
  rather the "center" of the harvested portion of that region.

- We divided the world into 4 climate classes: (a) Temperature-limited,
  April-Sept. temperature > Oct-March temperature; (b)
  Temperature-limited, Oct-March temperature > April-Sept. temperature;
  (c) non-temperature-limited, April-Sept precipitation > Oct-March
  precipitation; (d) non-temperature-limited, Oct-March precipitation >
  April-Sept. precipitation. Temperature-limitation was defined as
  having a coldest daily temperature less than 0 C (determined by using
  a gridded dataset that translated the coldest monthly temperature of
  each grid cell into the coldest daily temperature experienced in an
  average year). Then, in finding the nearest neighbor, we only
  considered observations with the same climate class as the grid cell
  of interest. (Exception: if there were no crop calendar observations
  for the climate class of the given grid cell, then we simply used the
  nearest neighbor, disregarding the climate class.)

- For observations that were classified as Temperature-limited (classes
  (a) and (b)), we checked to make sure that the average temperature
  during the growing season was greater than the average annual
  temperature. If it was not, we labeled this observation
  "misclassified". Similarly, for observations classified as
  non-temperature-limited, we made sure that the average precipitation
  during the growing season was greater than the average annual
  precipitation. Then, when doing the extrapolation, we considered these
  "misclassified" observations as not belonging to any climate class.

  An example illustrates the reasoning here: Consider the maize crop
  calendar for NW Mexico (see the figure named climate.Maize.Mexico
  (NW).805.pdf). This region is classified as T-limited, but the
  planting happens in winter (perhaps another, more profitable crop, is
  grown in the summer?). If we used this observation to extrapolate,
  much of the U.S. southwest would adopt this winter corn growing season
  - probably unrealistic.

  I think we label too many points as "misclassified" this way, but I
  think this leads to better extrapolation results than if we didn't
  label anything as "misclassified".

  Exception: we ignore the "misclassified" flag for winter crops, since
  nearly all winter crops are labeled as misclassified according to this
  algorithm. 

We do not do any extrapolation for crop calendars that apply to the
second season in a double-cropping system (the files named *.2.*). Doing
such extrapolation would be problematic in that (1) it would imply that
there is double cropping where there is not, and (2) it might suggest
that the second season of a crop is grown at the same time as the first
season of a crop, if there were data in a region for the first season
but not for the second.


------------------------------------------------------------------------
VII. Data coverage
------------------------------------------------------------------------

The table below lists the crops for which we have compiled crop calendar
observations, along with: the number of observations for each crop; the
percent of the world's harvested area (H.A.) of that crop for which we
have observations (based on Monfreda et al., 2008); and the amount of
harvested area for which we have data at a sub-national resolution
(expressed as a percent of the area for which we have any data).

For crops that are split into multiple categories (e.g., winter &
spring, or main season & second season), % harvested area for each
category is calculated as: (harvested area for which we have
observations in this category) / (total harvested area of this crop) *
100. For example, the denominator for winter wheat is the same as the
denominator for all wheat combined.

Sub-national sometimes means we have data at the state / province level
(or even higher resolution); but sometimes it simply means that a
country is divided into two or three large regions.

** BE CAREFUL IF YOU USE THE CROPS FOR WHICH THERE IS LITTLE DATA. **
   You may be better off picking a similar crop that has more data. 

We have excluded crops from this dataset for which there were fewer than
about 10 observations. In addition, we do not provide data for
sugarcane; for this crop, planting = harvest in many regions (i.e., the
growing season is a full year), which wasn't handled properly by our
data processing scripts.


Crop		# obs.	% H.A.	% sub-national
----------------------------------------------
Barley		103	84%	35%
  - Winter	53	57%	12%
  - Spring	50	39%	58%
Cassava		17	45%	70%
Cotton		65	76%	48%
Groundnuts	40	57%	50%
Maize		192	88%	63%
  - Main season	165	88%	63%
  - 2nd season	27	15%	52%
Millet		73	74%	41%
Oats		61	44%	69%
  - Winter	15	10%	75%
  - Spring	46	34%	67%
Potatoes	60	13%	26%
Pulses		34	11%	25%
Rapeseed-winter	10	66%	0.3%
Rice		183	82%	48%
  - Main season	146	81%	48%
  - 2nd season	37	47%	57%
Rye-winter	40	69%	42%
Sorghum		115	83%	51%
  - Main season	102	80%	48%
  - 2nd season	13	11%	85%
Soybeans	51	92%	75%
Sugarbeets	29	68%	14%
Sunflower	18	66%	6%
Sweet potatoes	21	17%	56%
Wheat		173	76%	52%
  - Winter	138	54%	43%
  - Spring	35	32%	60%
Yams		13	92%	0%


------------------------------------------------------------------------
VIII. References
------------------------------------------------------------------------

This dataset is described in the following publication:

Sacks, W.J., D. Deryng, J.A. Foley, and N. Ramankutty (in press). Crop
planting dates: An analysis of global patterns. Global Ecology and
Biogeography.


Here are other publications referenced in this README file:

Monfreda, C., Ramankutty, N. & Foley, J. (2008) Farming the planet: 2.
Geographic distribution of crop areas, yields, physiological types, and
net primary production in the year 2000. Global Biogeochemical Cycles,
22.

New, M., Lister, D., Hulme, M. & Makin, I. (2002) A high-resolution data
set of surface climate over global land areas. Climate Research, 21,
1-25. 

Priestley, C.H.B. & Taylor, R.J. (1972) On the assessment of surface
heat flux and evaporation using large-scale parameters. Monthly Weather
Review, 100, 81-92. 
