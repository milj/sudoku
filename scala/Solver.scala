import scala.io.Source

object Solver {
  class Board(digits: String) {
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

    def options(i: Int): Set[Char] = Set() // TODO

    // returns Some index of the first not-filled board element, None if not found
    def firstEmptyPosition: Option[Int] = digits indexOf "." match { // () are not required for inputless side effects-free functions
      case -1 => None
      case position => Some(position)
    }
  }

  def solve(board: Board): Board = {
    // TODO: solve
    board
  } 

  def loadPuzzle(filePath: String): String = {
    val bufferedSource = Source.fromFile(filePath) // TODO: handle exceptions
    val puzzle_str = bufferedSource.getLines.mkString
    bufferedSource.close
    puzzle_str.replaceAll("[^0-9.]", "") // implicit return as in Ruby
  }

  def main(args: Array[String]): Unit = {
    val board = new Board(loadPuzzle(args(0)))
    println(solve(board))
  }
}
