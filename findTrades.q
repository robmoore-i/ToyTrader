\l ga.q
\l trader.q

// ========================================================================================
// PROBLEM: Find 10 trades for a table of quotes, t, which yield a €500 profit using €10230
// ========================================================================================

// A trade contains a:
// Side: Buy or sell: 1 bit
// Quote index: 19 bits
// Volume: 9 bits (gives a value between 512 and 1024 when prepended with a 1)

// Example:
// q)// BUY ============ QUOTE-NUM ==============  ====== VOL ======
// q)g:  1  0 1 1 1 1 0 1 1 1 0 1 1 1 0 0 0 0 0 0  0 0 0 1 0 1 0 1 0
// q)expressChromosome g
// side     | `buy
// timestamp| 2011.10.04D21:07:00.000000000
// cpair    | `eurgbp
// price    | 0.8605
// vol      | 554
// q)

randomChromosome:{[nQuotes;qgl;vgl;nTrades;x]
  randomTradeGene:{[nQuotes;qgl;vgl;x]
    randomSideGene:{rand 2};
    randomQuoteGene:{[qgl;nQuotes;x]{((x-count y)#0),y}[qgl;] 2 vs rand nQuotes}[qgl;nQuotes;];
    randomVolGene:{[x;y]x?2}[vgl;];
    raze (randomSideGene;randomQuoteGene;randomVolGene)@\:`}[nQuotes;qgl;vgl;];
  raze randomTradeGene each nTrades#0}

// Chop the given 290-bit (c)hromosome into it's consituent trades of given (s)ize.
// Given the intended lengths of the quote and vol genes (qgl, vgl), as well as the quotes (t)able,
//   execute the trades on a trader with some initial (r)eserve of cash, where the final (p)rices are given.
// Return a 3-list of (final-profit;num-trades-execute;num-buys-executed).
executeChromosome:{[t;qgl;vgl;cSize;cash;lastPx;c]
  expressTradeGene:{[qgl;vgl;t;g]
    quote:t@2 sv (1;qgl) sublist g;
    `side`timestamp`cpair`price`vol!($[first g;`buy;`sell];quote`timestamp;`eurgbp;quote`open;2 sv 1,neg[vgl]#g)}[qgl;vgl;t;];
  trades:`timestamp xasc expressTradeGene each cSize cut c;
  buys:count where trades[`side]=`buy;
  trader:.trader.excList[.trader.init cash;trades];
  liquidated:sum lastPx*k!0^trader[`holdings]@k:key lastPx;
  (liquidated+trader[`cash]-cash;count trader[`trades];buys)}

// Given two 3-lists of (profit;trades-executed;buys-executed), produce a float valued fitness score.
// Reciprocal of quadratic cost, weighted 5* on profit.
scoreFitness:{[goal;attempt]"f"$reciprocal sum 5 1 1*'{d*d:x-y}'[goal;attempt]}

// Given a (g)oal for a (p)opulation and a way of (exc)uting chromosomes,
// Return a table with rows of executed value and corresponding fitness.
showPopulationPerformance:{[exc;g;p]
  ex:exc each p;
  ([]evaluation:ex;fitness:scoreFitness[g;] each ex)}

// For a quotes (t)able, (g)oal, initial population (s)ize, a crsRate, mutRate and the maximum number of generations
// to search for, iMax, produces a table of chromosomes with the best performance.
// Find (n) trades with a given max volume (vMax), with profit closest to the (targetProfit), favouring more trades
// and more buys, using a genetic algorithm from an initial (s)et of chromosomes with given cross-rate (crsRate),
// mutation-rate (mutRate) and a defined number of (i)terations.
findTrades:{[t;n;vMax;targetProfit;s;crsRate;mutRate;i]
  // Set up the many variables
  goal:(targetProfit;n;n);
  vMin:"j"$2 xexp -1+ceiling 2 xlog vMax;
  cash:n*vMax;
  vgl:ceiling 2 xlog vMin;
  nQuotes:count t;
  qgl:ceiling 2 xlog nQuotes;
  cSize:1+qgl+vgl;
  lastPx:(enlist`eurgbp)!enlist(last t)`close;
  // Create the required projections
  rch:randomChromosome[nQuotes;qgl;vgl;n;];
  exc:executeChromosome[t;qgl;vgl;cSize;cash;lastPx;];
  // Run the genetic algorithm
  chromosomes:evolve[crsRate;mutRate;exc;scoreFitness;goal;i;rch each s#0];
  // Produce the results
  (showPopulationPerformance[exc;goal;chromosomes];chromosomes)}