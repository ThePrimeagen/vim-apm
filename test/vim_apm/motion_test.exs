defmodule VimApm.MotionTest do
  use VimApm.DataCase

  alias VimApm.Motion

  describe "add/3" do
    test "add and drops happen" do
      motion = Motion.new(max_age: 1000)

      now = 0
      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w"}}, now)
      assert motion.length == 1
      assert motion.apm == 1

      now = 500
      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w2"}}, now)
      assert motion.length == 2
      assert motion.apm == 2

      now = 999
      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w3"}}, now)
      assert motion.length == 3
      assert motion.apm == 3

      now = 1000
      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w4"}}, now)
      assert motion.length == 4
      assert motion.apm == 4

      now = 1001
      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w5"}}, now)
      assert motion.length == 4
      assert motion.apm == 4

    end

    test "ensure calculated_apm is correct" do
      motion = Motion.new(max_age: 120_000)

      now = 0
      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w"}}, now)
      assert Motion.calculate_apm(motion) == 0.5

      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w2"}}, now)
      assert Motion.calculate_apm(motion) == 1

      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w3"}}, now)
      assert Motion.calculate_apm(motion) == 1.5
    end

    test "test repeats" do
      motion = Motion.new(max_age: 60_000)

      now = 0
      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w"}}, now)
      assert Motion.calculate_apm(motion) == 1
      assert motion.length == 1

      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w"}}, now)
      assert Motion.calculate_apm(motion) == 1.9
      assert motion.length == 2

      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w"}}, now)
      assert Motion.calculate_apm(motion) == 2.7
      assert motion.length == 3

      motion = Motion.add(motion, %{type: "motion", value: %{chars: "w"}}, now)
      assert Motion.calculate_apm(motion) == 3.4
      assert motion.length == 4
    end

  end
end
