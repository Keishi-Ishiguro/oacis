require 'spec_helper'

describe DataIncluder do
  
  before(:each) do
    @sim = FactoryGirl.create(:simulator,
                              parameter_sets_count: 1, runs_count: 1)
    @prm = @sim.parameter_sets.first
    @run = @prm.runs.first

    @temp_dir = Pathname.new('__temp')
    FileUtils.mkdir_p(@temp_dir)
  end

  after(:each) do
    FileUtils.rm_r(@temp_dir) if File.directory?(@temp_dir)
  end

  describe ".perform" do

    describe "for a successful run" do

      before(:each) do
        ENV['CM_WORK_DIR'] = @temp_dir.expand_path.to_s

        run_info = {"id" => @run.id, "command" => @run.command}
        SimulatorRunner.perform(run_info)

        @work_dir = Pathname.new(ENV['CM_WORK_DIR']).join(@run.id)
        @arg = {"run_id" => @run.id, "work_dir" => @work_dir.to_s}
      end


      it "copies all the files in the work dir to run_directory" do
        dummy_dir = @work_dir.join('__dummy_dir__')
        FileUtils.mkdir_p(dummy_dir)
        DataIncluder.perform(@arg)
        File.exist?(@run.dir.join('_stdout.txt')).should be_true
        File.exist?(@run.dir.join('_stderr.txt')).should be_true
        File.directory?(@run.dir.join('__dummy_dir__')).should be_true
      end

      it "does not copy '_input.json', '_output.json', and '_run_status.json'" do
        filenames = ['_input.json', '_output.json', '_run_status.json']
        filenames.each do |f|
          FileUtils.touch( @work_dir.join(f) )
        end

        DataIncluder.perform(@arg)
        filenames.each do |f|
          File.exist?( @run.dir.join(f) ).should be_false
        end
      end

      it "updates attributes of Run" do
        stat = JSON.load( File.open(@work_dir.join('_run_status.json')) )
        DataIncluder.perform(@arg)
        @run.reload
        @run.status.should eq(:finished)
        @run.hostname.should_not be_nil
        @run.hostname.should eq(stat["hostname"])
        @run.cpu_time.should eq(stat["cpu_time"])
        @run.real_time.should eq(stat["real_time"])
        @run.started_at.should be_a(DateTime)
        @run.finished_at.should be_a(DateTime)
        @run.included_at.should be_a(DateTime)
      end

      it "removes working directory after copy has successfully finished" do
        DataIncluder.perform(@arg)
        File.directory?(@work_dir).should be_false
      end

    end

    describe "for a failed run" do

      before(:each) do
        ENV['CM_WORK_DIR'] = @temp_dir.expand_path.to_s

        run_info = {"id" => @run.id, "command" => "INVALID_CMD"}
        SimulatorRunner.perform(run_info)

        @work_dir = Pathname.new(ENV['CM_WORK_DIR']).join(@run.id)
        @arg = {"run_id" => @run.id, "work_dir" => @work_dir.to_s}
      end

      it "updates attributes of Run" do
        stat = JSON.load( File.open(@work_dir.join('_run_status.json')) )
        DataIncluder.perform(@arg)
        @run.reload
        @run.status.should eq(:failed)
        @run.hostname.should eq(stat["hostname"])
        @run.cpu_time.should eq(stat["cpu_time"])
        @run.real_time.should eq(stat["real_time"])
        @run.started_at.should be_a(DateTime)
        @run.finished_at.should be_a(DateTime)
        @run.included_at.should be_a(DateTime)
      end
    end

    context "when file copy fails" do

      it "does not remove working directory"

      it "updates status of Run to failed"
    end
  end
end