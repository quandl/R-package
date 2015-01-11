library("zoo")
library("xts")
library("testthat")

Quandl.auth("authenticationtoken")

context("Checking return formats")

test_that("Data is parsed correctly", {
  daily <- Quandl("TESTS/1")
  expect_named(daily, c("Date","Open","High" ,"Low" , "Last", "Close",
                        "Total Trade Quantity", "Turnover (Lacs)"))
  expect_that(dim(daily), equals(c(258,8)))
})

test_that("Metadata is correct", {
  daily <- Quandl("TESTS/1", type="zoo", meta=TRUE)
  expect_that(is.null(attr(daily,"meta")), is_false())
  expect_that(metaData(daily)$source_code, equals("TESTS"))
  expect_that(metaData(daily)$name, equals("Daily Dataset Test"))
})

test_that("Stop and start dates are correct (zoo)", {
  annual <- Quandl("TESTS/4", type="zoo", start_date="1995-01-01", end_date=as.Date("2006-01-01"))
  expect_that(start(annual), equals(1995))
  expect_that(end(annual), equals(2005))
})

test_that("Stop and start dates are correct (xts)", {
  annual <- Quandl("TESTS/4", type="xts", start_date="1995-01-01", end_date=as.Date("2006-01-01"))
  expect_that(start(annual), is_equivalent_to(as.Date("1995-12-31")))
  expect_that(end(annual), is_equivalent_to(as.Date("2005-12-31")))
})

test_that("Collapsed data frequency", {
  dailytoquart <- Quandl("TESTS/1", type="ts", collapse="quarterly")
  expect_that(frequency(dailytoquart), equals(4))
})

test_that("Frequencies are correct across output formats", {
  monthlyts <- Quandl("TESTS/2", type="ts")
  monthlyzoo <- Quandl("TESTS/2", type="zoo")
  monthlyxts <- Quandl("TESTS/2", type="xts")
  expect_that(frequency(monthlyts), equals(12))
  expect_that(frequency(monthlyzoo), equals(12))
  expect_that(frequency(monthlyxts), equals(12))
})

test_that("Data is the same across formats", {
  monthlyts <- Quandl("TESTS/2", type="ts")
  monthlyzoo <- Quandl("TESTS/2", type="zoo")
  monthlyxts <- Quandl("TESTS/2", type="xts")
  expect_that(max(abs(monthlyts - coredata(monthlyzoo))), equals(0))
  expect_that(max(abs(coredata(monthlyzoo) - coredata(monthlyxts))) , equals(0))
})

test_that("Output message lists 3 codes", {
  search.results <- Quandl.search("gas")
  expect_output(search.results, "UN/REFINERYGASPRODUCTION_PAN")
  expect_output(search.results, "BTN_NY_GDP_NGAS_RT_ZS")
  expect_output(search.results, "BLZ_NY_GDP_NGAS_RT_ZS")
})

test_that("Doesn't find anything", {
  search.nothing <- Quandl.search("asfdsgfrg")
  #   doesn't pass it, because there is an error: incorrect number of subscripts
  expect_warning(search.nothing, "we haven't found anything")
})
