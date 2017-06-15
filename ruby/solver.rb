#!/usr/bin/env ruby

require 'set'

# returns puzzle string (81 characters, 1..9 or dots for unknowns)
def load_puzzle
  puzzle_filename = ARGV[0]
  puzzle_str = File.read(puzzle_filename)
  # TODO: handle read error
  puzzle_str.gsub(/[^0-9\.]/, '')
end

def print_puzzle(puzzle)
  puzzle.scan(/.{27}/).map do |x|
    x.scan(/.{9}/).map do |y|
      y.scan(/.{3}/).map do |z|
        z.split('').join(' ')
      end.join(' | ')
    end.join("\n")
  end.join("\n------+-------+------\n")
end

# returns set containing digits of the puzzle on given positions, without the digit on the current position
def digits_on_positions(puzzle, positions, current_position)
  positions
    .reject { |p| p == current_position }
    .map { |p| puzzle[p] }
    .reject { |digit| digit == '.' }
    .to_set
end

# returns row peers of digit in the position i in puzzle string (i in 0..80)
def row_peers(puzzle, i)
  row_number = i / 9
  digits_on_positions(
    puzzle,
    ((row_number * 9)...((row_number + 1) * 9)),
    i
  )
end

# returns column peers of element in the position i in puzzle string (i in 0..80)
def column_peers(puzzle, i)
  column_number = i % 9
  digits_on_positions(
    puzzle,
    (0...9).map { |p| p * 9 + column_number },
    i
  )
end

# returns 3x3 square peers of element in the position i
def square_peers(puzzle, i)
  square_coordinates = ->(p) { [p / 27, (p % 9) / 3] } # returns tuple [row 0..2, column 0..2]
  digits_on_positions(
    puzzle,
    (0..80).select { |p| square_coordinates.call(p) == square_coordinates.call(i) },
    i
  )
end

def peers(puzzle, i)
  row_peers(puzzle, i) + column_peers(puzzle, i) + square_peers(puzzle, i)
end

# returns set of numbers which can be written into position i of the puzzle
def options(puzzle, i)
  Set.new('1'..'9') - peers(puzzle, i)
end

def solve(puzzle)
  first_empty_position = puzzle.index('.')
  return puzzle unless first_empty_position
  options(puzzle, first_empty_position).each do |option|
    updated_puzzle = puzzle.dup
    updated_puzzle[first_empty_position] = option
    solution = solve(updated_puzzle)
    return solution if solution
  end
  nil
end

puzzle = load_puzzle

puts print_puzzle(solve(puzzle))
