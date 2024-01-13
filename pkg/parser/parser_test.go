package parser_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"vim-apm.theprimeagen.tv/pkg/parser"
)


func TestMotionParser(t *testing.T) {
    parsed, consumed, err := parser.Next("003dap")

    assert.Nil(t, err)
    assert.Equal(t, 6, consumed)
    assert.Equal(t, parsed.Data, "dap")
    assert.Equal(t, parsed.Version, 0)
    assert.Equal(t, parsed.Type, parser.Motion)
}
