#!/usr/bin/env ruby

require 'set'

# returns puzzle string (81 characters, 1..9 or dots for unknowns)
def load_puzzle
  puzzle_filename = ARGV[0]
  puzzle_str = File.read(puzzle_filename)
  #TODO handle read error
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

# returns row peers of element in the position i in puzzle string (i in 0..80)
def row_peers(puzzle, i)
  row_number = i / 9
  peers = Set.new
  ((row_number * 9)...((row_number + 1) * 9))
    .select { |j| j != i }
    .map { |j| puzzle[j] }
    .select { |digit| digit != '.' }
    .each { |digit| peers.add(digit) }
  peers
end

def column_peers(puzzle, i)
  column_number = i % 9
  peers = Set.new
  (0...9)
    .map { |j| j * 9 + column_number }
    .select { |j| j != i }
    .map { |j| puzzle[j] }
    .select { |digit| digit != '.' }
    .each { |digit| peers.add(digit) }
  peers
end

def square_peers(puzzle, i)
  square_coordinates = ->(i) { [i / 27, (i % 9) / 3] }  # row 0..2, column 0..2
  peers = Set.new
  (0..80)
    .select { |j| square_coordinates.call(j) == square_coordinates.call(i) }
    .select { |j| j != i }
    .map { |j| puzzle[j] }
    .select { |digit| digit != '.' }
    .each { |digit| peers.add(digit) }
  peers
end

def peers(puzzle, i)
  row_peers(puzzle, i) + column_peers(puzzle, i) + square_peers(puzzle, i)
end

# returns numbers which can be written into position i
def possibilities(puzzle, i)
  Set.new('1'..'9') - peers(puzzle, i)
end

def solved?(puzzle)
  puzzle.scan(/[0-9]/).length == 81
end

def solve(puzzle)
  if solved?(puzzle)
    puzzle
  else
    puzzle
  end
end

puzzle = load_puzzle

puts print_puzzle(solve(puzzle))
