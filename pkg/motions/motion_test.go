package motions_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"vim-apm.theprimeagen.tv/pkg/motions"
)

func TestParseSimpleMotion(t *testing.T) {
	m, err := motions.Parse("9j")
	assert.Nil(t, err)

	count, motion := m.GetMotion()
	assert.Equal(t, 9, count)
	assert.Equal(t, "j", motion)
}

func TestParseComplexMotion(t *testing.T) {
	m, err := motions.Parse("6d9j")
	assert.Nil(t, err)

	count, motion := m.GetCommand()

	assert.Equal(t, 6, count)
	assert.Equal(t, "d", motion)

	count, motion = m.GetMotion()
	assert.Equal(t, 9, count)
	assert.Equal(t, "j", motion)
}
