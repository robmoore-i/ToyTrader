// Given a .csv file unzipped from an archive downloaded from HistData.com,
// reads the csv and fixes the columns. You lose the first minute of data.
readCsv:{`timestamp`open`high`low`close xcol ("SFFFF ";enlist";") 0: x}

// Given a timestamps from the table, converts it into an actual KDB timestamp.
parseDate:{"P"$("D"sv".:"sv'3 cut(0 4;4 2;6 2;9 2;11 2;13 2)sublist\:string x),".000000000"}

// Given a file handle for readCsv, converts it to an appropriate KDB table.
l:{update timestamp:parseDate each timestamp from readCsv x}
