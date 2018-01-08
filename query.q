// Read price action for a currency pair over a year
readcpy:{[currencyPair;year]value hsym `$string[currencyPair],"/",string year}

// Lists the years of data available from a given currency pair
yearscp:{[currencyPair]key hsym`$string currencyPair}
