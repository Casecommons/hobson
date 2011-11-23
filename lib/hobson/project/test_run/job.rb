class Hobson::Project::TestRun::Job

  attr_reader :test_run, :index
  delegate :logger, :workspace, :to => :test_run

  def initialize test_run, index
    @test_run, @index = test_run, index
  end

  def tests
    test_run.tests.find_all{|test| test.job == index }.map(&:name)
  end

  def inspect
    "#<#{self.class} #{index}>"
  end
  alias_method :to_s, :inspect

  def logger
    @logger ||= Log4r::Logger.new("#{test_run.logger.name}::Job(#{index})")
  end

end

%w{persistence status hooks artifacts actions}.each{|file| require "hobson/project/test_run/job/#{file}" }
