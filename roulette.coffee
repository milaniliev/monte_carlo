require 'sugar'

player = {
  starting_cash: 100

  cashout_ceiling: 10000

  bets: [
    { amount: 1 }
  ]

  cumulative_winnings: ->
    this.bets.sum (bet) => bet.winnings || 0

  current_cash: ->
    this.starting_cash + this.cumulative_winnings()

  solvent: ->
    this.current_cash() > 0

  next_bet: ->
    last_bet = this.bets[this.bets.length - 1]

    if last_bet.outcome == 'win'
      new_bet = { amount: 1 }
    else
      if this.current_cash() > last_bet.amount * 2
        new_bet = { amount: last_bet.amount * 2 }
      else
        new_bet = { amount: this.current_cash() }

    this.bets.push(new_bet)
    new_bet

  place_next_bet: ->
    roulette.bet_and_spin(this.next_bet())

}

roulette = {
  min_bet: 1
  max_bet: 1000
  bet_and_spin: (bet) ->
    number = Number.random(1, 40)
    if number <= 19
      bet.outcome = 'win'
      bet.winnings = bet.amount * 2
    else
      bet.outcome = 'lose'
      bet.winnings = -bet.amount

    console.log "Made #{player.bets.length} bets, player has $#{player.current_cash()}" if player.bets.length % 1000 == 0
    # console.log "Bet ##{player.bets.length} got #{number}, bet #{bet.amount}, #{bet.outcome} $#{bet.winnings}, player cash is $#{player.current_cash()}"
}

while player.solvent() and player.current_cash() < player.cashout_ceiling
  player.place_next_bet()

console.log "Made ##{player.bets.length} bets, player cash is $#{player.current_cash()}"
