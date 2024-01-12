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
