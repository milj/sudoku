// This one is around 12x faster and 1.5x longer than implementation in Ruby
// Usage: go run main.go path/to/puzzle.txt

package main

import (
  "fmt"
  "strconv"
  "os"
  "io/ioutil"
  "regexp"
  "bytes"
)

func loadPuzzle() [81]uint8 {
  var board [81]uint8

  buffer, err := ioutil.ReadFile(os.Args[1])
  if err != nil {
    panic("Error loading the puzzle file")
  }
  puzzle := regexp.MustCompile("[^0-9.]").ReplaceAllString(string(buffer), "")

  for i, char := range puzzle {
    digit, err := strconv.ParseUint(string(char), 10, 8)
    if err == nil {
      board[i] = uint8(digit)
    }
  }

  return board
}

func printPuzzle(board [81]uint8) string {
  result := ""
  for i := 0; i <= 80; i++ {
    if i > 0 {
      if i % 27 == 0 {
        result += "\n------+-------+------\n"
      } else if i % 9 == 0 {
        result += "\n"
      } else if i % 3 == 0 {
        result += " | "
      } else {
        result += " "
      }
    }

    if board[i] == 0 {
      result += "."
    } else {
      result += strconv.Itoa(int(board[i]))
    }
  }
  return result
}

func rowPeers(board [81]uint8, currentPosition uint8) map[uint8]bool {
  row_number := currentPosition / 9
  peers := make(map[uint8]bool)

  for p := row_number * 9; p < (row_number + 1) * 9; p++ {
    if p == currentPosition {
      continue
    }
    digit := board[p]
    if digit != 0 {
      peers[digit] = true
    }

  }
  return peers
}

func columnPeers(board [81]uint8, currentPosition uint8) map[uint8]bool {
  column_number := currentPosition % 9
  peers := make(map[uint8]bool)

  for i := 0; i < 9; i++ {
    p := uint8(i * 9) + column_number
    if p == currentPosition {
      continue
    }
    digit := board[p]
    if digit != 0 {
      peers[digit] = true
    }

  }
  return peers
}

func boxPeers (board [81]uint8, currentPosition uint8) map[uint8]bool {
  squareCoordinates := func(p uint8) uint8 { return 10 * (p / 27) + (p % 9) / 3 } // 0, 1, 2, 10, 11, 12, 20, 21, 22
  peers := make(map[uint8]bool)

  for p := uint8(0); p <= 80; p++ {
    if p == currentPosition || squareCoordinates(p) != squareCoordinates(currentPosition) {
      continue
    }

    digit := board[p]
    if digit != 0 {
      peers[digit] = true
    }
  }
  return peers
}

func options (board [81]uint8, currentPosition uint8) []uint8 {
  var options []uint8

  for digit := uint8(1); digit <= 9; digit++ {
    if digit != board[currentPosition] &&
      !rowPeers(board, currentPosition)[digit] &&
      !columnPeers(board, currentPosition)[digit] &&
      !boxPeers(board, currentPosition)[digit] {
      options = append(options, digit)
    }
  }

  return options
}

func solve(board [81]uint8) ([81]uint8, bool) {
  firstEmptyPosition := bytes.IndexByte(board[:], 0)
  if firstEmptyPosition == -1 {
    return board, true
  }

  for _, option := range options(board, uint8(firstEmptyPosition)) {
    var updatedBoard [81]uint8
    copy(updatedBoard[:], board[:])
    updatedBoard[firstEmptyPosition] = option
    solution, solved := solve(updatedBoard)
    if solved {
      return solution, solved
    }
  }
  return board, false
}

func main() {
  board := loadPuzzle()
  solution, solved := solve(board)
  if solved {
    fmt.Println(printPuzzle(solution))
  }
}
