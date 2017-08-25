#!/usr/bin/env python3

"""Sudoku solver
Usage: ./solver.py path/to/puzzle
"""

import re
import sys

class Board():
    def __init__(self, digits):
        self.digits = digits

    def __str__(self):
        """__str__ works like to_s in Ruby or Stringer interface in Go"""
        def line_str(line):
            return (' | ').join(
                map(
                    lambda three_digit_str: (' ').join(list(three_digit_str)),
                    re.findall(r'.{3}' , line)
                )
            )

        def three_boxes_str(boxes):
            return ('\n').join(
                map(
                    line_str,
                    re.findall(r'.{9}' , boxes)
                )
            )

        return ('\n------+-------+------\n').join(
            map(
                three_boxes_str,
                re.findall(r'.{27}', self.digits)
            )
        )

    def options(self, i):
        """returns set of numbers which can be written into position i of the sudoku board"""
        return set([str(x) for x in range(1, 10)]) - self.peers(i)

    def first_empty_position(self):
        """returns the index of the first not-filled board element, None if not found"""
        position = self.digits.find('.')
        if position >= 0:
            return position

    def peers(self, i):
        return self.row_peers(i) | self.column_peers(i) | self.box_peers(i)

    def row_peers(self, i):
        """returns row peers of digit in the position i (i in 0..80)"""
        row_number = i // 9
        return self.digits_on_positions(
            range(row_number * 9, (row_number + 1) * 9),
            i
        )

    def column_peers(self, i):
        """returns column peers of element in the position i (i in 0..80)"""
        column_number = i % 9
        return self.digits_on_positions(
            [p * 9 + column_number for p in range(9)],
            i
        )

    def box_peers(self, i):
        """returns 3x3 box peers of element in the position i (i in 0..80)"""
        def box_coordinates(p):
            return (p // 27, (p % 9) // 3) # (row 0..2, column 0..2)
        return self.digits_on_positions(
            [p for p in range(81) if box_coordinates(p) == box_coordinates(i)],
            i
        )

    def digits_on_positions(self, positions, current_position):
        """returns a set containing digits on given board positions, without the digit on the current position"""
        return set(
            filter(
                lambda digit: digit != '.',
                [self.digits[p] for p in positions if p != current_position]
            )
        )

def solve(board):
    position = board.first_empty_position()
    if position is None:
        return board
    for option in board.options(position):
        solution = solve(Board(
            board.digits[:position] + str(option) + board.digits[position + 1:]
        ))
        if solution is not None:
            return solution
    return None

def load_puzzle():
    if len(sys.argv) < 2:
        sys.exit('No puzzle file given')
    puzzle_filename = sys.argv[1]
    with open(puzzle_filename) as file_object:
        puzzle_str = file_object.read()
        return re.sub(r'[^0-9\.]', '', puzzle_str)

def main():
    try:
        board = Board(load_puzzle())
        print(solve(board))
    except OSError as error:
        print('Error loading the puzzle file: {0}'.format(error.strerror))

main()
