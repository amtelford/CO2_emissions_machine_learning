## Import data from a single xlsx sheet
library(readxl)
loc <- readline(prompt="Enter file path: ") ## Requires full path to xlsx file
regions <- c('OECD Americas',
             'OECD Asia Oceania',
             'OECD Europe',
             'Non-OECD Europe and Eurasia',
             'Africa',
             'Asia',
             'China',
             'Non-OECD Americas',
             'Middle East')

## Import a single sheet as csv
import_sheet <- function(sheetname, skip_lines) {
  read_excel(path=loc, sheet=sheetname, skip=skip_lines, na = "..")
}

## Find names of regions in the data
find_regions <- function(data, regions){
  i <- 1
  region_index <- NULL
  for (region in regions){
    region_index[i] <- grep(pattern=paste('^',region, sep=''), x=data)
    names(region_index)[i] <- region
    i <- i+1
  }
  return(region_index)
}

## Rearrange data to move region names into a separate column
assign_regions <- function(data, region_index){
  data$region <- NA
  start <- 1
  i <- 1
  for (i in 1:length(region_index)){
    data$region[start:region_index[i]] <- names(region_index[i])
    start <- region_index[i] + 1
  }
  return(data)
}

## Remove region names from COUNTRY column
remove_regions <- function(data, regions){
  data <- data[-region_index,]## Remove regions in Country column
  return(data)
}

## Wrangle data to move years from column names to values in a new column YEAR
library(tidyr)
library(dplyr)
years_as_obs <- function(data, new_column=""){
  data %>%
    gather(year, !!new_column, -c(country,region)) ## '!!' drops the implicit quotations
}

## CO2 FC sheet wrangling
co2data <- import_sheet('CO2 FC', 3)
## Remove entries that are not countries
co2data <- co2data[-(178:191),]
co2data <- co2data[-(1:20),]
colnames(co2data)[1] <- 'country'
## Assign regions from columns 'country'
region_index <- find_regions(co2data$country, regions)
region_index<- sort(region_index)
co2data <- assign_regions(co2data, region_index)
co2data<-remove_regions(co2data, regions)
co2data <- years_as_obs(co2data, "co2")
co2data$year <- as.integer(co2data$year)
co2data$co2 <- as.numeric(co2data$co2)

## POP sheet wrangling
popdata <- import_sheet('POP', 3)
## Remove entries that are not countries
popdata <- popdata[-(176:189),]
popdata <- popdata[-(1:18),]
colnames(popdata)[1] <- 'country'
## Assign regions from columns 'country'
region_index <- find_regions(popdata$country, regions)
region_index<- sort(region_index)
popdata <- assign_regions(popdata, region_index)
popdata<-remove_regions(popdata, regions)
popdata <- years_as_obs(popdata, "population")
popdata$year <- as.integer(popdata$year)
popdata$population <- as.numeric(popdata$population)

## GDP PPP sheet wrangling
gdpdata <- import_sheet('GDP PPP', 3)
## Remove entries that are not countries
gdpdata <- gdpdata[-(176:189),]
gdpdata <- gdpdata[-(1:18),]
colnames(gdpdata)[1] <- 'country'
## Assign regions from columns 'country'
region_index <- find_regions(gdpdata$country, regions)
region_index<- sort(region_index)
gdpdata <- assign_regions(gdpdata, region_index)
gdpdata<-remove_regions(gdpdata, regions)
gdpdata <- years_as_obs(gdpdata, "gdp")
gdpdata$year <- as.integer(gdpdata$year)
gdpdata$gdp <- as.numeric(gdpdata$gdp)

## TPES sheet wrangling
tpesdata <- import_sheet('TPES PJ', 3)
## Remove entries that are not countries
tpesdata <- tpesdata[-(178:191),]
tpesdata <- tpesdata[-(1:20),]
colnames(tpesdata)[1] <- 'country'
## Assign regions from columns 'country'
region_index <- find_regions(tpesdata$country, regions)
region_index<- sort(region_index)
tpesdata <- assign_regions(tpesdata, region_index)
tpesdata<-remove_regions(tpesdata, regions)
tpesdata <- years_as_obs(tpesdata, "tpes")
tpesdata$year <- as.integer(tpesdata$year)
tpesdata$tpes <- as.numeric(tpesdata$tpes)

## Aggregate datasets
full_data <- full_join(co2data, popdata, by=c("year", "country", "region"))
full_data <- full_join(full_data, gdpdata, by=c("year", "country", "region"))
full_data <- full_join(full_data, tpesdata, by=c("year", "country", "region"))
full_data$region <- as.factor(full_data$region)
