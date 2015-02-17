require 'sugar'

class Game
  constructor: ->

    this.player = {
      current_cash: 1000
      bet_amount: 1
      cashout_ceiling: 10000

      cumulative_winnings: ->
        this.bets.sum (bet) => bet.winnings || 0

      solvent: ->
        this.current_cash > 0

      should_cash_out: ->
        this.current_cash >= this.cashout_ceiling

      next_bet: ->
        last_bet = this.bets[this.bets.length - 1]

        if last_bet.outcome == 'win'
          new_bet = { amount: this.bet_amount }
        else
          if this.current_cash > last_bet.amount * 2
            new_bet = { amount: last_bet.amount * 2 }
          else
            new_bet = { amount: this.current_cash }

        new_bet

      record_bet_outcome: (bet) ->
        this.bets.push(bet)
        this.current_cash -= bet.amount
        this.current_cash += bet.winnings
        bet

    }

    this.player.bets = [
      { amount: this.player.bet_amount / 2 }
    ]

    this.roulette = {
      bet_and_spin: (bet) ->
        bet.number = Number.random(1, 40)
        if bet.number <= 19
          bet.outcome = 'win'
          bet.winnings = bet.amount * 2
        else
          bet.outcome = 'loss'
          bet.winnings = 0
        bet

    }


  run: ->
    while this.player.solvent() and not(this.player.should_cash_out())
      bet = this.player.record_bet_outcome(this.roulette.bet_and_spin(this.player.next_bet()))
      # console.log "Bet ##{this.player.bets.length - 1} bet $#{bet.amount}, got #{bet.number}/40, #{bet.outcome} $#{bet.winnings}, player cash is $#{this.player.current_cash}"

      console.log "Made #{this.player.bets.length} bets, player has $#{this.player.current_cash}" if this.player.bets.length % 1000 == 0

    if this.player.solvent()
      this.result = 'win'
    else
      this.result = 'loss'

games = []

100.times (number) ->
  game = new Game()
  game.run()
  console.log "Game #{number} was a #{game.result} in #{game.player.bets.length} bets"
  games.push game

console.log "Wins: #{games.filter( (g) -> g.result == 'win').length}, Losses: #{games.filter( (g) -> g.result == 'loss').length}, Bets: #{games.sum( (g) -> g.player.bets.length)}"
