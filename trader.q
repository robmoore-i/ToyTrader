// A trader has a table of positions and a holding of cash
\d .trader

// Initialises a trader with some (c)ash.
init:{[c]`cash`trades`holdings!(c;flip `type`timestamp`cpair`price`vol!()$\:"sjsfp";flip `cpair`vol!()$\:"sj")}

// Trader buys an (a)sset, at a specified (t)ime, (p)rice and (v)olume.
buy:{[trader;a;t;p;v]
  trader[`trades],:(`buy;t;a;p;v);
  $[a in trader[`holdings;`cpair];
    trader[`holdings]:update vol:vol+v from trader.holdings where cpair=a;
    trader[`holdings],:(a;v)];
  trader[`cash]-:p*v;
  trader}

// Trader sells an (a)sset, at a specified (t)ime, (p)rice and (v)olume.
// Assumed to have enough of the asset to make the trade.
sell:{[trader;a;t;p;v]
  trader[`trades],:(`sell;t;a;p;v);
  trader[`holdings]:update vol:vol-v from trader[`holdings] where cpair=a;
  trader[`cash]+:p*v;
  trader}