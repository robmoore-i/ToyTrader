// Given a .csv file unzipped from an archive downloaded from HistData.com,
// reads the csv and fixes the columns. You lose the first minute of data.
readCsv:{`timestamp`open`high`low`close xcol ("SFFFF ";enlist";") 0: x}

// Given a timestamps from the table, converts it into an actual KDB timestamp.
parseDate:{"P"$("D"sv".:"sv'3 cut(0 4;4 2;6 2;9 2;11 2;13 2)sublist\:string x),".000000000"}

// Given a table as read from a csv filehandle given as X, updates the
// timestamp column to be an actual timestamp.
updTimestamp:{update timestamp:parseDate each timestamp from x}

// Given a file handle for readCsv, converts it to an appropriate KDB table.
l:{updTimestamp readCsv x}

// Given a file handle for readCsv/l, parses the appropriate KDB table and
// saves it to a splayed table ./CURRENCY_PAIR/YEAR/
s:{
  sx:string x;
  -1 "Saving ",sx," to disk";
  currencyPair:hsym `$lower 1_7#sx;
  yr:`$4#8_sx;
  (` sv (currencyPair;yr;`)) set l x}

// Given a currency pair X, returns a list of file handles corresponding to
// .csv files in the current directory, containing quote data from that pair.
k)csvs:{.q.hsym fs@&:{(x~6#y)&".csv"~-4#y}[.q.upper@$:x;]'$:'fs:!:`:.}
