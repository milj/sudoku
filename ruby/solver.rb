#!/usr/bin/env ruby

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

def solve(puzzle)
  puzzle
end

puzzle = load_puzzle

puts print_puzzle(solve(puzzle))
