/**
 * Sudoku solver
 * Usage: scala Solver.scala path/to/puzzle.txt
 */

import scala.io.Source

// This Scala solver is 2.6 times faster than the Ruby implementation. The length of the source code is almost equal.
object Solver {
  class Board(val digits: String) { // val makes digits visible from outside
    // Object's toString is similar to to_s (Ruby), __str__ (Python), Stringer interface (Go)
    override def toString(): String = {
      """.{27}""".r.findAllIn(digits).map(three_boxes_str => // does """ come from Python?
        """.{9}""".r.findAllIn(three_boxes_str).map(line_str =>
          """.{3}""".r.findAllIn(line_str).map(three_digit_str =>
            three_digit_str.mkString(" ") // string can be used as an iterable collection
          ).mkString(" | ")
        ).mkString("\n")
      ).mkString("\n------+-------+------\n") // mkString is equivalent to join in Ruby
    }

    def options(i: Int): Set[Char] = ('1' to '9').toSet -- peers(i)

    /**
     * returns Some index of the first not-filled board element, None if not found
     */
    def firstEmptyPosition: Option[Int] = digits indexOf "." match { // () are not required for inputless side effects-free functions
      case -1 => None
      case position => Some(position)
    }

    private[this] def peers(i: Int): Set[Char] = rowPeers(i) ++ columnPeers(i) ++ boxPeers(i)

    /**
     * returns row peers of digit in the position i (i in 0 to 80)
     */
    private[this] def rowPeers(i: Int): Set[Char] = {
      val rowNumber = i / 9
      digitsOnPositions(
        rowNumber * 9 until (rowNumber + 1) * 9, // first-class range, as in Ruby
        i
      )
    }

    /**
     * returns column peers of element in the position i (i in 0 to 80)
     */
    private[this] def columnPeers(i: Int): Set[Char] = {
      val columnNumber = i % 9
      digitsOnPositions(
        (0 to 8) map (_ * 9 + columnNumber), // placeholder syntax (_) reminds me of &:method_name to_proc construct in Rails or reader macros #() in Clojure
        i
      )
    }

    /**
     * returns 3x3 box peers of element in the position i (i in 0 to 80)
     */
    private[this] def boxPeers(i: Int): Set[Char] = {
      def boxCoordinates(p: Int): (Int, Int) = {
        (p / 27, (p % 9) / 3) // (row 0..2, column 0..2)
      }
      digitsOnPositions(
        (0 to 80) filter (boxCoordinates(_) == boxCoordinates(i)),
        i
      )
    }

    /**
     * returns a set containing digits on given board positions, without the digit on the current position
     */
    private[this] def digitsOnPositions(positions: Seq[Int], currentPosition: Int): Set[Char] = {
      positions.filter(_ != currentPosition).map(digits(_)).filter(_ != '.').toSet
    }
  }

  def solve(board: Board): Option[Board] = {
    board.firstEmptyPosition match {
      case None => Some(board)
      case Some(position) => {
        for (option <- board.options(position)) {
          val solution = solve(new Board(
            board.digits.substring(0, position) + option + board.digits.substring(position + 1, board.digits.length)
          ))
          if (solution.isDefined) return solution
        }
        return None
      }
    }
  }

  def loadPuzzle(filePath: String): String = {
    val bufferedSource = Source.fromFile(filePath) // TODO: handle exceptions
    val puzzle_str = bufferedSource.getLines.mkString
    bufferedSource.close
    puzzle_str.replaceAll("[^0-9.]", "") // implicit return as in Ruby
  }

  def main(args: Array[String]): Unit = {
    val board = new Board(loadPuzzle(args(0)))
    solve(board) match {
      case Some(solution) => println(solution)
      case None => println("Could not solve this puzzle.")
    }
  }
}
