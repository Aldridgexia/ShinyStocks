
# Load packages -----------------------------------------------------------

library(rvest)
library(quantmod)
library(stringr)
library(tidyverse)
library(lubridate)

# Get data ----------------------------------------------------------------

# the following code is borrowed from this link:
# https://stackoverflow.com/questions/44818212/how-do-i-get-all-sp500-corp-code-list-using-r

url <- "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
SP500 <- url %>%
    read_html() %>%
    html_nodes(xpath='//*[@id="mw-content-text"]/div/table[1]') %>%
    html_table()
SP500 <- SP500[[1]]
Tix <- SP500$`Symbol`

# get all ticker's historical data
while(length(Tix) > 0) {
    ticker <- Tix[1]
    getSymbols(ticker)
    saveRDS(get(ticker), str_c("~/ShinyStocks/data/", ticker, ".rds"))
    print(str_c(ticker, " downloaded."))
    Tix <- Tix[-1]
    Sys.sleep(runif(1,2,8))
}

# Calculate returns data --------------------------------------------------------------

setwd("~/ShinyStocks/data/")
all_files <- list.files()

f <- all_files[1]
tmp_data <- readRDS(f)
tmp_return <- dailyReturn(tmp_data, type = "log", leading = FALSE)
colnames(tmp_return) <- str_split(f, "\\.")[[1]][1]
all_returns <- tmp_return

for(f in all_files[-1]) {
    tmp_data <- readRDS(f)
    tmp_return <- dailyReturn(tmp_data, type = "log", leading = FALSE)
    colnames(tmp_return) <- str_split(f, "\\.")[[1]][1]
    all_returns <- cbind(all_returns, tmp_return)
}
class(all_returns)
saveRDS(all_returns, str_c("~/ShinyStocks/data/all_returns.rds"))
