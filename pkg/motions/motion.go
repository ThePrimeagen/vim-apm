package motions

import (
	"errors"
	"strconv"
	"unicode"
)

// Anatomy of a motion
// <num>motion
// <num>cmd<num>motion
// <num>cmd<num>text_objct_motions

type SimpleMotion struct {
	Count  int
	Motion string
}

type CommandMotion struct {
	Count   int
	Command string
	Motion  *SimpleMotion
}

type Motion interface {
	GetMotion() (int, string)
	GetCommand() (int, string)
}

var InvalidMotion = errors.New("Invalid Motion")
var MotionNotImplemented = errors.New("Motion Not Implemented")

func (m *SimpleMotion) GetMotion() (int, string) {
	return m.Count, m.Motion
}

func (m *CommandMotion) GetMotion() (int, string) {
	return m.Motion.GetMotion()
}

func (m *CommandMotion) GetCommand() (int, string) {
	return m.Count, m.Command
}

func (m *SimpleMotion) GetCommand() (int, string) {
	return 0, ""
}

func isDigit(s string) bool {
	_, err := strconv.Atoi(s)
	return err == nil
}

func isCommand(s string) bool {
	first := ' '
	for _, c := range s {
		if !unicode.IsDigit(c) {
			first = c
			break
		}
	}

	switch first {
	case 'd':
		fallthrough
	case 'y':
		fallthrough
	case 'c':
		fallthrough
	case 'v':
		return true
	}

	return false
}

func parseCommand(s string, count int) (Motion, error) {
	cmd := s[0:1]
	motionCount, rest := parseDigit(s[1:])
	motion, error := parseSimpleMotion(rest, motionCount)

	if error != nil {
		return nil, error
	}
	return &CommandMotion{
		Count:   count,
		Command: cmd,
		Motion:  motion.(*SimpleMotion),
	}, nil
}

func parseDigit(s string) (int, string) {
	out := ""
	for _, c := range s {
		if isDigit(string(c)) {
			out += string(c)
		} else {
			break
		}
	}

	if len(out) == 0 {
		return 1, s
	}

	val, _ := strconv.Atoi(out)
	return val, s[len(out):]
}

func parseSimpleMotion(s string, count int) (Motion, error) {
	switch s[0:1] {
	case "w":
		fallthrough
	case "W":
		fallthrough
	case "e":
		fallthrough
	case "E":
		fallthrough
	case "b":
		fallthrough
	case "B":
		fallthrough
	case "0":
		fallthrough
	case "^":
		fallthrough
	case "~":
		fallthrough
	case "$":
		fallthrough
	case "h":
		fallthrough
	case "H":
		fallthrough
	case "j":
		fallthrough
	case "J":
		fallthrough
	case "k":
		fallthrough
	case "l":
		fallthrough
	case "L":
		fallthrough
	case "G":
		return &SimpleMotion{Count: count, Motion: s}, nil

	case "g":
		return nil, MotionNotImplemented

	case "a":
		fallthrough
	case "i":
		return nil, MotionNotImplemented

	case "f":
		fallthrough
	case "F":
		fallthrough
	case "t":
		fallthrough
	case "T":
		return nil, MotionNotImplemented
	}

	return nil, InvalidMotion
}

func Parse(s string) (Motion, error) {
	count, s := parseDigit(s)

	if isCommand(s) {
		return parseCommand(s, count)
	}

	return parseSimpleMotion(s, count)
}
