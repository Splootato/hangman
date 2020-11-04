# frozen_string_literal: true

require 'yaml'

class Selection
  def initialize
    save?
  end

  def save?
    puts "Welcome to Hangman!\n"
    puts 'Would you like to start a new game (n) or a saved game (s) ?'
    response = gets.chomp
    if response == 'n'
      fetch_words
    elsif response == 's'
      load_save
    else
      save?
    end
  end

  def load_save

    save = File.open('save.txt', 'r') { |f| YAML.load(f) }

    @word = save[:word]
    @lines = save[:lines]
    @incorrect_guesses = save[:incorrect_guesses]
    @hangman_stage = save[:hangman_stage]
    @turns = save[:turns]
    puts 'You have loaded a saved game'
    Game.new(@word, @lines, @incorrect_guesses, @turns, @hangman_stage)
  end

  def fetch_words
    @word = nil
    @lines = nil
    word_array = []
    File.open('5desk.txt').readlines.each do |line|
      word_array.push(line.strip)
    end
    select_word(word_array)
  end

  def select_word(word_array)
    word = word_array.sample
    if word.length > 4 && word.length < 13
      @word = word
      guess_lines
    else select_word(word_array)
    end
  end

  def guess_lines
    lines = @word.split('').map { '_' }
    @lines = lines.join('')
    Game.new(@word, @lines)
  end
end

class Game < Selection
  def initialize(word, lines, incorrect_guesses = [], turns = 6, hangman_stage = 0)
    @word = word
    @lines = lines
    @guess = nil
    @turns = turns
    @incorrect_guesses = incorrect_guesses
    @hangman_stage = hangman_stage
    puts @lines.split('').join(' ')
    player_guess
  end

  def player_guess
    check_winner
    turns_left
    take_guess
    display_lines
    display_hangman
    player_guess
  end

  def check_winner
    if @lines.delete(' ') == @word.downcase
      puts "The word was #{@word}!"
      puts 'You win! Would you like to play again? (y/n)'
      answer = gets.chomp
      system 'clear'
      if answer == 'y'
        Selection.new
      else
        exit!
      end
    end
  end
  
  def take_guess
    puts "Guess a letter... or press '1' to save or '2' to load."
    puts "Previous guesses: #{@incorrect_guesses.join(' ')}"
    answer = gets.chomp
    if answer == '1'
      save_game
    elsif answer == '2'
      Selection.new(load_save)
    else
      @guess = answer
    end
    system 'clear'
  end

  def turns_left
    puts "You have #{@turns} turns left."
    if @turns <= 0
      game_over
    end
  end

  def game_over
    puts "The word was #{@word}!"
    puts 'Game over! Would you like to play again? (y/n)'
    answer = gets.chomp
    system 'clear'
    if answer == 'y'
      Selection.new
    else
      exit!
    end
  end

  def display_lines
    to_downcase
  end

  def to_downcase
    current_guess = @guess.downcase
    word = @word.downcase.split('')
    current_line = @lines.delete(' ').split('')
    check_match(current_guess, word, current_line)
  end

  def check_match(current_guess, word, current_line)
    if word.include?(current_guess)
      word.each_with_index { |l, i| current_line[i] = current_guess if l == current_guess }
    else 
      @incorrect_guesses.push(current_guess)
      @turns -= 1
      @hangman_stage += 1
    end
    put_line(current_line)
  end

  def put_line(current_line)
    @lines = current_line.join(' ')
    puts @lines
  end

  def save_game
    save = YAML.dump({
                       word: @word,
                       lines: @lines,
                       incorrect_guesses: @incorrect_guesses,
                       hangman_stage: @hangman_stage,
                       turns: @turns
    })

    File.open('save.txt', 'w') { |f| f.write save}
    puts 'Game Saved!'
    Selection.new
  end

  def display_hangman

    if @hangman_stage == 0
      print %{
        _____.
             |
             |
             |
             |
        } 
    elsif @hangman_stage == 1
      print %{
        _____.
         O   |
             |
             |
             |
        }
    elsif @hangman_stage == 2
      print %{
        _____.
         O   |
         |   |
             |
             |
        }
    elsif @hangman_stage == 3
      print %{
        _____.
         O   |
        /|   |
             |
             |
        }
    elsif @hangman_stage == 4
      print %{
        _____.
         O   |
        /|\\  |
             |
             |
        }
    elsif @hangman_stage == 5
      print %{
        _____.
         O   |
        /|\\  |
        /    |
             |
        }
    elsif @hangman_stage == 6
      print %{
        _____.
         O   |
        /|\\  |
        / \\  |
             |
        }
    end
  end
end
