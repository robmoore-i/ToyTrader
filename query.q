// Read price action for a currency pair over a year
readcpy:{[currencyPair;year]value hsym `$string[currencyPair],"/",string year}

// Lists the years of data available from a given currency pair
yearscp:{[currencyPair]key hsym`$string currencyPair}

// Gets all records for the given currency pair which are between (inclusive)
// the given dates.
readcpr:{[currencyPair;startTimestamp;endTimestamp]
  startYear:`year$startTimestamp;
  endYear:`year$endTimestamp;
  $[startYear=endYear;
    select from readcpy[currencyPair;startYear] where timestamp within (startTimestamp;endTimestamp);
    [
      startYearsData:select from readcpy[currencyPair;startYear] where startTimestamp <= timestamp;
      endYearsData:  select from readcpy[currencyPair;endYear]   where endTimestamp   > timestamp;
      intermediateYears:1 + startYear + til endYear - 1 + startYear;
      intermediateYearsData:raze readcpy[currencyPair;] each intermediateYears;
      startYearsData,intermediateYearsData,endYearsData]]}
