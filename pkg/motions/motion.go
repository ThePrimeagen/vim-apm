package motion

import (
	"fmt"
	"strconv"
	"strings"
)

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
	Motion  SimpleMotion
}

type Motion interface {
	GetMotion() (int, string)
	GetCommand() (int, string)
}

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

func parseSimple

func Next(motion string) (*Motion, string, error) {
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

    motion = right[left:]

    return nil, motion, nil
}
