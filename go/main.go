// This Go solver is around 12x faster and 1.5x longer than the Ruby implementation
// Usage: go run main.go path/to/puzzle.txt

package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strconv"
)

type board [81]uint8
type peerMap map[uint8]bool

// board implements Stringer interface
func (gameboard *board) String() string {
	result := ""

	for i := 0; i <= 80; i++ {
		if i > 0 {
			switch {
			case i%27 == 0:
				result += "\n------+-------+------\n"
			case i%9 == 0:
				result += "\n"
			case i%3 == 0:
				result += " | "
			default:
				result += " "
			}
		}

		if gameboard[i] == 0 {
			result += "."
		} else {
			result += strconv.Itoa(int(gameboard[i]))
		}
	}

	return result
}

func updatePeers(gameboard *board, peers *peerMap, currentPosition uint8, peerPosition uint8) {
	if peerPosition != currentPosition {
		digit := gameboard[peerPosition]
		if digit != 0 {
			(*peers)[digit] = true
		}
	}
}

func (gameboard *board) rowPeers(currentPosition uint8) peerMap {
	row_number := currentPosition / 9
	peers := make(peerMap)

	for p := row_number * 9; p < (row_number+1)*9; p++ {
		updatePeers(gameboard, &peers, currentPosition, p)
	}
	return peers
}

func (gameboard *board) columnPeers(currentPosition uint8) peerMap {
	column_number := currentPosition % 9
	peers := make(peerMap)

	for i := 0; i < 9; i++ {
		p := uint8(i*9) + column_number
		updatePeers(gameboard, &peers, currentPosition, p)
	}
	return peers
}

func (gameboard *board) boxPeers(currentPosition uint8) peerMap {
	squareCoordinates := func(p uint8) uint8 { return 10*(p/27) + (p%9)/3 } // xy encoded as 0, 1, 2, 10, 11, 12, 20, 21, 22
	peers := make(peerMap)

	for p := uint8(0); p <= 80; p++ {
		if squareCoordinates(p) != squareCoordinates(currentPosition) {
			continue
		}
		updatePeers(gameboard, &peers, currentPosition, p)
	}
	return peers
}

func (gameboard *board) options(currentPosition uint8) []uint8 {
	var options []uint8

	for digit := uint8(1); digit <= 9; digit++ {
		if digit != gameboard[currentPosition] &&
			!gameboard.rowPeers(currentPosition)[digit] &&
			!gameboard.columnPeers(currentPosition)[digit] &&
			!gameboard.boxPeers(currentPosition)[digit] {
			options = append(options, digit)
		}
	}

	return options
}

func loadPuzzle() board {
	var gameboard board

	buffer, err := ioutil.ReadFile(os.Args[1])
	if err != nil {
		fmt.Println("Error loading the puzzle file")
		os.Exit(1)
	}
	puzzle := regexp.MustCompile("[^0-9.]").ReplaceAllString(string(buffer), "")

	for i, char := range puzzle {
		if digit, err := strconv.ParseUint(string(char), 10, 8); err == nil {
			gameboard[i] = uint8(digit)
		}
	}

	return gameboard
}

func (gameboard *board) solve() (*board, bool) {
	firstEmptyPosition := bytes.IndexByte(gameboard[:], 0)
	if firstEmptyPosition == -1 {
		return gameboard, true
	}

	for _, option := range gameboard.options(uint8(firstEmptyPosition)) {
		var updatedBoard board
		copy(updatedBoard[:], gameboard[:])
		updatedBoard[firstEmptyPosition] = option
		solution, solved := updatedBoard.solve()
		if solved {
			return solution, solved
		}
	}

	return gameboard, false
}

func main() {
	gameboard := board(loadPuzzle())

	if solution, solved := gameboard.solve(); solved {
		fmt.Println(solution) // here the board's String() method will be used, this mechanism works like to_s in Ruby
	}
}
