\l ga.q
\l query.q
\l trader.q
t:readcpy[`eurgbp;2011]

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

// Dependent on the declaration of variable t at this point.
if[not `t in key value `.;'t]
if[98h<>type t;'ttype]

// €500 profit, 10 trades, 10 buys.
goal:(500;10;10)

// Base config
soughtNumberOfTrades:10
minVol:512
maxVol:1023
startingCash:soughtNumberOfTrades*maxVol
volGeneLength:ceiling 2 xlog minVol

// Config based on quotes (t)able
nQuotes:count t
quoteGeneLength:ceiling 2 xlog nQuotes
chromosomeSize:1+quoteGeneLength+volGeneLength
finalPrices:(enlist`eurgbp)!enlist(last t)`close

// Using the quotes (t)able, converts a 29-bit (g)ene into a dictionary trade
expressTradeGene:{[t;g]
  quote:t@2 sv (1;quoteGeneLength) sublist g;
  `side`timestamp`cpair`price`vol!($[first g;`buy;`sell];quote`timestamp;`eurgbp;quote`open;2 sv 1,neg[volGeneLength]#g)}

randomQuoteGene:{{((quoteGeneLength-count x)#0),x} 2 vs rand nQuotes}
randomVolGene:{volGeneLength?2}
randomSideGene:{rand 2}

randomTradeGene:{raze (randomSideGene;randomQuoteGene;randomVolGene)@\:`}
randomChromosome:{raze randomTradeGene each soughtNumberOfTrades#0}

// Using an initial amount of (c)ash, execute all of the (t)rades and report
// the final value of assets and number of executed trades, using the given
// final (p)rices dictionary to assess the cash acquired through liquidation
// at the end of the period.
executeTrades:{[c;t;p]
  trader:.trader.excList[.trader.init c;t];
  liquidated:sum p*k!0^trader[`holdings]@k:key p;
  ((liquidated+trader`cash)-c;count trader[`trades])}

// Using the quotes (t)able, find profit for a 290-bit (c)hromosome, the number of trades made and the number of buys.
executeChromosome:{[t;c]
  trades:`timestamp xasc expressTradeGene[t;] each chromosomeSize cut c;
  buys:count where trades[`side]=`buy;
  executeTrades[startingCash;trades;finalPrices],buys}

// Given a 3-list of (profit;trades-executed;buys-executed), score the result.
// Reciprocal of quadratic cost, weighted 5* on profit.
scoreFitness:{[goal;attempt]"f"$reciprocal sum 5 1 1*'{d*d:x-y}'[goal;attempt]}

// Given a quotes (t)able and a (g)oal for a (p)opulation, give a table with rows of executed value and fitness.
showPopulationPerformance:{[t;g;p]
  ex:executeChromosome[t;] each p;
  ([]
    evaluation:ex;
    fitness:scoreFitness[g;] each ex)}

// For a quotes (t)able, (g)oal, initial population (s)ize, a crsRate, mutRate and the maximum number of generations
// to search for, iMax, produces a table of chromosomes with the best performance.
findTrades:{[t;crsRate;mutRate;iMax;s;g]
  p:randomChromosome each s#0;
  chromosomes:evolve[crsRate;mutRate;executeChromosome[t;];scoreFitness;g;iMax;p];
  (showPopulationPerformance[t;g;chromosomes];chromosomes)}
