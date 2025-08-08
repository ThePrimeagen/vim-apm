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
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert 4 == motion.apm

      motion = Motion.add(motion, %{"type" => "insert_report", "value" => %{"time" => 100, "raw_typed" => 10, "changed" => 20}}, now)
      motion = Motion.add(motion, %{"type" => "insert_report", "value" => %{"time" => 200, "raw_typed" => 25, "changed" => 50}}, now)

      # TODO: this is not going to be a great way to do things.  please forgive me future self for this.
      raw = Float.round(35 / 5 / 2, 2)
      changed = Float.round(70 / 5 / 2, 2)
      apm = Float.round(4 / 2, 2)

      assert {
        # calculated (apm + raw)... raw
        apm + raw,

        # apm
        apm,

        # raw
        raw,

        # changed
        changed
      } == Motion.calculate_total_apm(motion)
    end

    test "test repeats" do
      motion = Motion.new(max_age: 60_000)

      now = 0
      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert motion.length == 1
      assert motion.apm == 1

      motion = Motion.add(motion, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert motion.length == 2
      assert motion.apm == 2
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
