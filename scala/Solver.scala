import scala.io.Source

object Solver {

  // TODO: class Board {

  def toString(board: String): String = {
    """.{27}""".r.findAllIn(board).map(three_boxes_str =>  // does """ come from Python?
      """.{9}""".r.findAllIn(three_boxes_str).map(line_str =>
        """.{3}""".r.findAllIn(line_str).map(three_digit_str =>
          three_digit_str.mkString(" ") // string can be used as an iterable collection
        ).mkString(" | ")
      ).mkString("\n")
    ).mkString("\n------+-------+------\n") // mkString is equivalent to join in Ruby
  }

  // }

  def solve(board: String): String = {
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
    val board = loadPuzzle(args(0))
    println(toString(solve(board)))
  }
}
