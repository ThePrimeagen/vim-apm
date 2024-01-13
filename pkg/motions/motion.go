package motions

import (
	"errors"
	"strconv"
	"strings"
	"unicode"

	networkutils "vim-apm.theprimeagen.tv/pkg/network_utils"
)

// Anatomy of a motion
// <num>motion
// <num>cmd<num>motion
// <num>cmd<num>text_objct_motions

type SimpleMotion struct {
	Count   int
	Motion  string
	Timings []int
}

type CommandMotion struct {
	Count   int
	Command string
	Motion  *SimpleMotion
	Timings []int
}

type Motion interface {
	parseTimings(s string) error
	GetMotion() (int, string)
	GetCommand() (int, string)
	GetTimings() []int
}

func parseTimings(s string) ([]int, error) {
	timings := strings.SplitN(s, ",", -1)
	int_timings := []int{}
	for _, t := range timings {
		int_value, err := strconv.Atoi(t)
		if err != nil {
			// what do we do here?
			return nil, errors.New("Invalid Timing")
		}

		int_timings = append(int_timings, int_value)
	}

	return int_timings, nil
}

var InvalidMotion = errors.New("Invalid Motion")
var MotionNotImplemented = errors.New("Motion Not Implemented")

func (m *SimpleMotion) GetMotion() (int, string) {
	return m.Count, m.Motion
}

func (m *SimpleMotion) GetTimings() []int {
	return m.Timings
}

func (m *CommandMotion) GetTimings() []int {
	return m.Timings
}

func (m *SimpleMotion) parseTimings(s string) error {
	int_timings, err := parseTimings(s)
	if err != nil {
		return err
	}

	m.Timings = int_timings
	return nil
}

func (m *CommandMotion) parseTimings(s string) error {
	int_timings, err := parseTimings(s)
	if err != nil {
		return err
	}

	m.Timings = int_timings
	return nil
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

    case 'd', 'y', 'c', 'v':
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
		Timings: []int{},
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

	case "w", "G", "L", "l", "k", "J", "j", "H", "h", "$", "~", "^", "0", "B", "b", "E", "e", "W":
		return &SimpleMotion{
			Count:   count,
			Motion:  s,
			Timings: []int{},
		}, nil

	case "g":
		return nil, MotionNotImplemented

	case "a", "i":

		if len(s) != 2 {
			return nil, InvalidMotion
		}

		switch s[1:2] {
		case "p", "]", "[", ")", "(", "}", "{", "W", "w", "b":
            return &SimpleMotion{
                Count:   count,
                Motion:  s,
                Timings: []int{},
            }, nil
		}

		return nil, InvalidMotion

	case "f" , "F", "t", "T":
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

func Parse(s string) (Motion, error) {
	motion_len := networkutils.ToInteger(s[0:1])
	motion, err := parse(s[1 : motion_len+1])
	if err != nil {
		return nil, err
	}

    if len(s) == motion_len + 1 {
        return motion, nil
    }

	err = motion.parseTimings(s[motion_len+1:])
	if err != nil {
		return nil, err
	}

	return motion, nil
}
