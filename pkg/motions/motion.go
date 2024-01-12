package motion

import (
	"errors"
	"fmt"
	"strconv"
	"strings"
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
	case 'y':
	case 'c':
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
	case "W":
	case "e":
	case "E":
	case "b":
	case "B":
	case "0":
	case "^":
	case "~":
	case "$":
	case "h":
	case "H":
	case "j":
	case "J":
	case "k":
	case "l":
	case "L":
	case "G":
		return &SimpleMotion{Count: count, Motion: s}, nil

	case "g":
		return nil, MotionNotImplemented

	case "a":
	case "i":
		return nil, MotionNotImplemented

	case "f":
	case "F":
	case "t":
	case "T":
		return nil, MotionNotImplemented
	}

	return nil, InvalidMotion
}

func parse(s string) (Motion, error) {
	count, s := parseDigit(s)
	if isCommand(s) {
		return parseCommand(s, count)
	}
	return parseSimpleMotion(s, count)
}

func Next(motion string) (Motion, string, error) {
	leftStr, right, found := strings.Cut(motion, ":")

	if !found {
		return nil, motion, nil
	}

	left, err := strconv.Atoi(leftStr)

	if err != nil {
		return nil, motion, fmt.Errorf("Invalid count: %s %w", leftStr, err)
	}

	if len(right) < left {
		return nil, motion, nil
	}

	m, err := parse(right[:left])
	return m, right[left:], err
}
