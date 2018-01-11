// Remove silly data points and fix up the timestamp column.
makePlottable:{[t]
  t:delete from t where open < 0;
  t:delete from t where open > avg[open]+10*sdev open;
  t:delete from t where open < avg[open]-10*sdev open;
  update timestamp:{{(10#x),"-",11 8 sublist x} string x} each timestamp from t}

saveGnuplotCandlesticksScript:{[plotTitle]
  gnuLinePlotText:"set xdata time\nset timefmt \"%Y.%m.%d-%H:%M:%S\"\nset datafile separator \",\"\nset autoscale x\nset title '",plotTitle,"'\nset terminal png size 1600,1200 enhanced font \"Helvetica,20\"\nset output '",plotTitle,".png'\nset boxwidth 0.01 absolute\nset style fill empty\nplot '",plotTitle,".csv' using 1:2:3:4:5 with candlesticks title \"",plotTitle,"\"";
  h:hopen hsym `$plotTitle,".gnu";
  h each gnuLinePlotText;
  hclose h;
  hsym `$plotTitle,".gnu"}

// t must have columns in the order timestamp-open-high-low-close, with types "pffff"
plotCandlesticks:{[t;plotTitle]
  (hsym `$plotCsv:plotTitle,".csv") 0: .h.tx[`csv;makePlottable t];
  saveGnuplotCandlesticksScript plotTitle;
  system "gnuplot ",plotGnu:plotTitle,".gnu";
  system "rm ",plotCsv," ",plotGnu;
  system "xdg-open ",plotTitle,".png"}

\l query.q

// Plot a single year from some currency pair
plotcpy:{[currencyPair;year]
  t:readcpy[currencyPair;year];
  plotCandlesticks[t;string[currencyPair],"-",string year];}