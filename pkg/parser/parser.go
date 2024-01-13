package parser

import (
	"errors"

	"vim-apm.theprimeagen.tv/pkg/motions"
	networkutils "vim-apm.theprimeagen.tv/pkg/network_utils"
)

// Weekday - Custom type to hold value for weekday ranging from 1-7
type Type int

// Declare related constants for each weekday starting with index 1
const (
	Motion Type = iota
)

type Parsed struct {
	Version int
	Type    Type
	Data    string
}

func (p *Parsed) AsMotion() (motions.Motion, error) {
    if p.Type == Motion {
        return motions.Parse(p.Data)
    }
    return nil, errors.New("type is not a motion")
}

var VERSION = 0

var counts = map[Type]bool{
    Motion: true,
}

var HEADER_LENGTH = 3
func Next(s string) (*Parsed, int, error) {
    if len(s) < HEADER_LENGTH {
        return nil, 0, nil
    }

    version := networkutils.ToInteger(s[0:1])

    if version != VERSION {
        return nil, 0, errors.New("Invalid Version")
    }

    _type := Type(networkutils.ToInteger(s[1:2]))
    length := networkutils.ToInteger(s[2:3])

    if len(s) < HEADER_LENGTH + length {
        return nil, 0, nil
    }

    _, ok := counts[_type]
    if !ok {
        return nil, 0, errors.New("Invalid Type")
    }

    return &Parsed{
        Version: version,
        Type: _type,
        Data: s[HEADER_LENGTH:length + HEADER_LENGTH],
    }, length + HEADER_LENGTH, nil
}
