#!/usr/bin/env ruby
# Usage: ./solver.rb path/to/puzzle.txt

require 'set'

class Board
  attr_accessor :digits # a string holding the board state

  def initialize(digits)
    @digits = digits
  end

  def to_s
    digits.scan(/.{27}/).map do |x|
      x.scan(/.{9}/).map do |y|
        y.scan(/.{3}/).map do |z|
          z.split('').join(' ')
        end.join(' | ')
      end.join("\n")
    end.join("\n------+-------+------\n")
  end

  # returns set of numbers which can be written into position i of the sudoku board
  def options(i)
    Set.new('1'..'9') - peers(i)
  end

  def first_empty_position
    digits.index('.')
  end

  private

  def peers(i)
    row_peers(i) + column_peers(i) + box_peers(i)
  end

  # returns row peers of digit in the position i (i in 0..80)
  def row_peers(i)
    row_number = i / 9
    digits_on_positions(
      row_number * 9...(row_number + 1) * 9,
      i
    )
  end

  # returns column peers of element in the position i (i in 0..80)
  def column_peers(i)
    column_number = i % 9
    digits_on_positions(
      (0...9).map { |p| p * 9 + column_number },
      i
    )
  end

  # returns 3x3 box peers of element in the position i (i in 0..80)
  def box_peers(i)
    box_coordinates = ->(p) { [p / 27, (p % 9) / 3] } # returns a tuple [row 0..2, column 0..2], this is actually an array, no tuples in Ruby. Using a lambda as Ruby lacks nested methods too.
    digits_on_positions(
      (0..80).select { |p| box_coordinates.call(p) == box_coordinates.call(i) },
      i
    )
  end

  # returns a set containing digits on given board positions, without the digit on the current position
  def digits_on_positions(positions, current_position)
    positions
      .reject { |p| p == current_position }
      .map { |p| digits[p] }
      .reject { |digit| digit == '.' }
      .to_set
  end
end

# returns a Board instance containing a solved puzzle
def solve(board)
  position = board.first_empty_position
  return board unless position
  board.options(position).each do |option|
    solution = solve(Board.new(
      board.digits[0...position] + option + board.digits[position + 1..-1]
    ))
    return solution if solution
  end
  nil
end

# loads puzzle string (81 characters, 1..9 or dots for unknowns) from a file
def load_puzzle
  puzzle_filename = ARGV[0]
  raise 'No puzzle file given' unless puzzle_filename
  puzzle_str = File.read(puzzle_filename)
  puzzle_str.gsub(/[^0-9\.]/, '')
end

begin
  board = Board.new(load_puzzle)
  puts solve(board)
rescue RuntimeError => e
  puts e.message
rescue Errno::ENOENT
  puts 'Error loading the puzzle file'
end
