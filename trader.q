// A trader has a table of positions and a holding of cash
\d .trader

// Initialises a trader with some (c)ash.
init:{[c]`cash`trades`holdings!(c;flip `side`timestamp`cpair`price`vol!()$\:"sjsfp";flip `cpair`vol!()$\:"sj")}

// Trader buys an (a)sset at a given (t)ime, (p)rice and (v)olume.
buy:{[trader;t;a;p;v]
  trader[`trades],:(`buy;t;a;p;v);
  $[a in trader[`holdings;`cpair];
    trader[`holdings]:update vol:vol+v from trader[`holdings] where cpair=a;
    trader[`holdings],:(a;v)];
  trader[`cash]-:p*v;
  trader}

// Trader sells an (a)sset, at a specified (t)ime, (p)rice and (v)olume.
// Assumed to have enough of the asset to make the trade.
sell:{[trader;t;a;p;v]
  trader[`trades],:(`sell;t;a;p;v);
  trader[`holdings]:update vol:vol-v from trader[`holdings] where cpair=a;
  trader[`cash]+:p*v;
  trader}

// Trader executes a trade.
exc:{[trader;trade]
  $[`buy=trade`side;
    buy[trader;]  . 1_value trade;
    sell[trader;] . 1_value trade]}
// Fold trade execution over a list of trades.
excList:{[tr;ts].trader.exc/[tr;ts]}

// Generates (n) random trades from the (d)ata given on an (a)sset, with a
// specified min volume(mnv) and max volume(mxv).
randomTrades:{[n;a;d;mnv;mxv]
  trades:d@n?count d;
  ([]
    side:n?`buy`sell;
    timestamp:trades`timestamp;
    cpair:n#a;
    price:trades`open;
    vol:mnv+n?mxv-mnv)}