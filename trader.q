// A trader has a table of positions and a holding of cash

// Each position is a volume, currency pair, price and time.
//  eg: 1000 of `eurusd at 1.14778 at 2016.05.02D09:02:00.000000000

// The value of a position is determined by the current price.
// If the price of `eurusd goes to 1.14786 at 2016.05.02D09:03:00.000000000
// then the value of the above position will become 1000*1.14786 = 1147.86
// giving a profitability of 1000 * (1.14786 - 1.14778) = 0.08

// To get the profitability of a trader at a given moment, you take the
// prices of all the assets the trader currently holds and take the difference
// with the corresponding current prices, then multiply by the corresponding
// volumes.

// A buy action is an insertion to the positions table for a trader,
// containing the current time, current price, selected currency pair and
// selected volume.
// The trader's cash holdings has the price * volume subtracted from it.

// A sell action is a deletion from the positions table of a given volume
// of a given asset at the current time and current price.
// The trader's cash holdings is then increased by the price * volume.

// A stop loss is an automatic trade which takes place when the price of some
// asset reaches a certain price specified at the time of making some trade,
// at which point that trade is backed out of under the assumption that the
// trade was simply incorrect.
