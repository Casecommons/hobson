# Hobson

A distributed test run framework built on resque

# Setup

  0. Add a config/hobson.yml file that looks like this to your development workstation

        ---
        :redis:
          :host: ec2-0-0-0-0.compute-1.amazonaws.com
          :db: 3
          :namespace: 'hobson'
          :port: 6380

  0. Add the same config to any machines you intend to be workers with an additional workspace entry

        :workspace: /Users/change/work/change

  0. add hobson to applications your Gemfile
  0. run:

        $ bundle install
        $ bundle exec hobson

  0. to start a worker run:

        $ bundle exec hobson work

  0. to kick off a "test run" run:

        $ bundle exec hobson run

# TODO

  0. WHY ARE THERE EMPTY TESTS?
  0. CONFIRM YOU'RE RUNNING ALL TESTS!!!!!

  0. add test balancing
    0. append test duration times (if passed) to a global store
    0. make it easy to get the duration estimate for a given test
    0. balance tests across workers with respect to test type & est. test duration
    0. add tuning configurations for things like
      0. min / max jobs per test_run
      0. min / max tests per job

  0. add multiple projects
    Hobson
      Project
        Workspace
        TestRun
          Tests
          Job

  0. add branch monitoring
    0. add a TV monitoring page

  0. show test runtime estimation on status page
  0. add custom formatters that dump failures to individual files and upload those artifacts immediately
  0. add rerun failed tests functionality &|| add auto rerun of failed tests
  0. rename test_run/job/application etc.



# Life cycle

  0. enqueue a ScheduleTestRun resque job for a given sha
    * check out the given sha
    * prepare the environment
    * discover the tests that are needed to run
    * add a list of tests to the TestRun data
    * schedule N RunTests resque jobs for Y jobs (balancing is done in this step)
    * teardown environment
  0. Hobson::RunTests jobs are run
    * check out the given sha
    * prepare the environment
    * run the subset of tests
    * report the result for each test (with backtrace and associated artifacts)
    * teardown environment

# running tests
  * check out the given sha
  * prepare the environment
  * execute test command (using PTY for non-blocking read)
    * use a special formatter that writes the current test to a file followed by its result
    * loop and read from PTY stdin and update redis with that status of what test is being run and then its status
  * report the result for each test (with backtrace and associated artifacts)
  * teardown environment








# Data Stored in Redis
TestRun
  - id                String
  - sha               String
  - scheduled_build   Datetime
  - started_building  Datetime
  - scheduled_jobs    Datetime
  - tests
    - name     String
    - state    String (waiting|started|complete)
    - result   String (pass|fail|pending)
    - duration Float  (seconds)
  - jobs
    - index                 Integer
    - scheduled_at          Datetime
    - checking_out_code     Datetime
    - preparing_environment Datetime
    - running_tests         Datetime
    - saving_artifacts      Datetime
    - tearing_down          Datetime
    - completed_at          Datetime



# Single Redis Hash
  {
    sha                               =>
    scheduled_build_at                => "Fri Nov 18 10:15:03 -0800 2011"
    started_building_at               => "Fri Nov 18 10:15:03 -0800 2011"
    scheduled_jobs_at                 => "Fri Nov 18 10:15:03 -0800 2011"
    job:#{n}:scheduled_at             => "Fri Nov 18 10:15:03 -0800 2011"
    job:#{n}:checking_out_code_at     => "Fri Nov 18 10:15:03 -0800 2011"
    jon:#{n}:preparing_environment_at => "Fri Nov 18 10:15:03 -0800 2011"
    jon:#{n}:running_tests_at         => "Fri Nov 18 10:15:03 -0800 2011"
    jon:#{n}:saving_artifacts_at      => "Fri Nov 18 10:15:03 -0800 2011"
    jon:#{n}:tearing_down_at          => "Fri Nov 18 10:15:03 -0800 2011"
    jon:#{n}:completed_at             => "Fri Nov 18 10:15:03 -0800 2011"
    test:#{test_name}:status          => ("waiting"|"started"|"complete")
    test:#{test_name}:result          => ("pass"|"fail"|"pending")
    test:#{test_name}:duration        => 23.854
  }




