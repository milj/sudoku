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

def solve(board):
    # TODO
    return board

def load_puzzle():
    if len(sys.argv) < 2:
        sys.exit('No puzzle file given')
    puzzle_filename = sys.argv[1]
    with open(puzzle_filename) as file_object:
        puzzle_str = file_object.read()
        return re.sub(r'[^0-9\.]', '', puzzle_str)


try:
    board = Board(load_puzzle())
    print(solve(board))
except OSError as error:
    print('Error loading the puzzle file: {0}'.format(error.strerror))
