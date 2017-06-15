# sudoku

A playground repository to try out new programming languages. The first "reference" implementation is in Ruby. Go, Python, Scala etc. will come next.

The input puzzle is assumed to contain digits and dots representing empty cells. Other characters (spaces, newlines, dashes etc.) are ignored and can be used for pretty-formatting the puzzle.

The solvers use depth-first search of the problem space. This is a playground repo so performance is not important as long as the code is clear, easy to reason about and returns correct solutions. For example, the Ruby version could be made faster if the puzzle modifications were done in-place instead of instantiating a new string every time.
