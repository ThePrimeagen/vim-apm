package motions_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"vim-apm.theprimeagen.tv/pkg/motions"
)

func TestParseSimpleMotionNoTimings(t *testing.T) {
	m, err := motions.Parse("1j")
	assert.Nil(t, err)

	count, motion := m.GetMotion()
	assert.Equal(t, 1, count)
	assert.Equal(t, "j", motion)

    timings := m.GetTimings()
	assert.Equal(t, []int{}, timings)
}

func TestParseSimpleMotion(t *testing.T) {
	m, err := motions.Parse("342j69,420")
	assert.Nil(t, err)

	count, motion := m.GetMotion()
	assert.Equal(t, 42, count)
	assert.Equal(t, "j", motion)

    timings := m.GetTimings()
	assert.Equal(t, []int{69, 420}, timings)
}

func TestParseComplexMotion(t *testing.T) {
	m, err := motions.Parse("46d9j777,1337")
	assert.Nil(t, err)

	count, motion := m.GetCommand()

	assert.Equal(t, 6, count)
	assert.Equal(t, "d", motion)

	count, motion = m.GetMotion()
	assert.Equal(t, 9, count)
	assert.Equal(t, "j", motion)

    timings := m.GetTimings()
	assert.Equal(t, []int{777, 1337}, timings)
}
