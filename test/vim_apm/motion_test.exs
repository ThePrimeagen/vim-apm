defmodule VimApm.MotionTest do
  use VimApm.DataCase

  alias VimApm.Motion

  describe "add/3" do
    test "add and drops happen" do
      motion = Motion.new(max_age: 1000)

      now = 0
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert motion.length == 1
      assert motion.apm == 1

      now = 500
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w2"}}, now)
      assert motion.length == 2
      assert motion.apm == 2

      now = 999
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w3"}}, now)
      assert motion.length == 3
      assert motion.apm == 3

      now = 1000
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w4"}}, now)
      assert motion.length == 4
      assert motion.apm == 4

      now = 1001
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w5"}}, now)
      assert motion.length == 4
      assert motion.apm == 4
    end

    test "ensure calculated_apm is correct" do
      motion = Motion.new(max_age: 120_000)

      now = 0
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert Motion.calculate_total_apm(motion) == 0.5

      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w2"}}, now)
      assert Motion.calculate_total_apm(motion) == 1

      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w3"}}, now)
      assert Motion.calculate_total_apm(motion) == 1.5
    end

    test "test repeats" do
      motion = Motion.new(max_age: 60_000)

      now = 0
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert Motion.calculate_total_apm(motion) == 1
      assert motion.length == 1

      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert Motion.calculate_total_apm(motion) < 2 # calculating this is hard... and it changes frequently.
      assert motion.length == 2
    end

    test "test modes" do
      motion = Motion.new(max_age: 1_000)

      now = 0

      motion =
        Motion.add(
          motion,
          %{
            "type" => "mode_times",
            "value" => %{
              "n" => 150,
              "i" => 15,
              "v" => 0,
              "untracked" => 0
            }
          },
          now
        )

      assert %{
               "n" => 150,
               "i" => 15,
               "v" => 0,
               "untracked" => 0
             } == motion.mode_times

      now = 999

      motion =
        Motion.add(
          motion,
          %{
            "type" => "mode_times",
            "value" => %{
              "n" => 250,
              "i" => 190,
              "v" => 42,
              "untracked" => 69
            }
          },
          now
        )

      assert %{
               "n" => 150 + 250,
               "i" => 190 + 15,
               "v" => 0 + 42,
               "untracked" => 0 + 69
             } == motion.mode_times

      now = 1001

      motion =
        Motion.add(
          motion,
          %{
            "type" => "mode_times",
            "value" => %{
              "n" => 69000,
              "i" => 70000,
              "v" => 71000,
              "untracked" => 72000
            }
          },
          now
        )

      assert %{
               "n" => 69000 + 250,
               "i" => 190 + 70000,
               "v" => 42 + 71000,
               "untracked" => 69 + 72000
             } == motion.mode_times
    end

    test "test cpm times" do
      motion = Motion.new(max_age: 1000)

      now = 0

      motion = Motion.add(motion, %{
        "type" => "insert_report",
        "value" => %{"time" => 150, "raw_typed" => 30, "changed" => 50}
      }, now)

      assert 30 == motion.cpm_raw
      assert 50 == motion.cpm_changed
      assert 150 == motion.time_in_insert

      now = 1000

      motion = Motion.add(motion, %{
        "type" => "insert_report",
        "value" => %{"time" => 420, "raw_typed" => 69, "changed" => 42}
      }, now)

      assert 30 + 69 == motion.cpm_raw
      assert 50 + 42 == motion.cpm_changed
      assert 150 + 420 == motion.time_in_insert


      now = 1001
      motion = Motion.add(motion, %{
        "type" => "insert_report",
        "value" => %{"time" => 1337, "raw_typed" => 420, "changed" => 69}
      }, now)

      assert 69 + 420 == motion.cpm_raw
      assert 42 + 69 == motion.cpm_changed
      assert 420 + 1337 == motion.time_in_insert
    end
  end
end
