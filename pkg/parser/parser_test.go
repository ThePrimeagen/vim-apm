package parser_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"vim-apm.theprimeagen.tv/pkg/parser"
)


func TestMotionParser(t *testing.T) {
    parsed, consumed, err := parser.Next("00?3dap69,420,1337")

    assert.Nil(t, err)
    assert.Equal(t, 18, consumed)
    assert.Equal(t, parsed.Data, "3dap69,420,1337")
    assert.Equal(t, parsed.Version, 0)
    assert.Equal(t, parsed.Type, parser.Motion)

    motion, err := parsed.AsMotion()
    assert.Nil(t, err)

    count, cmd := motion.GetCommand()
    motion_count, m := motion.GetMotion()

    assert.Equal(t, 1, count)
    assert.Equal(t, cmd, "d")

    assert.Equal(t, 1, motion_count)
    assert.Equal(t, m, "ap")

    timings := motion.GetTimings()
    assert.Equal(t, []int{69, 420, 1337}, timings)
}
