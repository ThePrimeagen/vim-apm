defmodule VimApm.MotionTest do
  use VimApm.DataCase

  alias VimApm.Apm

  describe "vim-apm" do
    test "handle_motion" do
      apm = Apm.new(level_time: 1000)

      now = 0
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert apm.level == 1
      assert apm.progress == 0.1

      now = 500
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert apm.level == 1
      assert apm.progress == 0.1 - 0.05 + 0.1

      now = 1501
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert apm.level == 1
      assert apm.progress == 0.1

      # you will notice that there are ten here, that is because floating point numbers suck ass
      # now 0.1 + 0.1 ... ten times == 0.9999999999999999 not 1.. because computers suck ass
      # so to simply by pass this i added one extra, guaranteed to cause a leveling up event
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert apm.level == 2
      assert apm.progress == 0.1

      now = 2502
      apm = Apm.handle_server_message(apm, %{"type" => "motion", "value" => %{"chars" => "w"}}, now)
      assert apm.level == 1
      assert apm.progress == 0.1

    end
  end
end

