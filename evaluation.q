\d .evl

// Using an initial amount of (c)ash, execute all of the (t)rades and report
// the final value of assets, using the given final (p)rices dictionary to
// assess the cash acquired through liquidation at the end of the period.
finalProfit:{[c;t;p]
  trader:.trader.excList[.trader.init c;t];
  liquidated:sum p*k!0^trader[`holdings]@k:key p;
  (liquidated+trader`cash)-c}