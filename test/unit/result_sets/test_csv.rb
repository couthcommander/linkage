require File.expand_path("../../test_result_sets", __FILE__)

class UnitTests::TestResultSets::TestCSV < Test::Unit::TestCase
  def setup
    @tmpdir = Dir.mktmpdir('linkage')
  end

  def teardown
    FileUtils.remove_entry_secure(@tmpdir)
  end

  test "no directory option uses current directory" do
    result_set = Linkage::ResultSets::CSV.new

    expected_score_file = './scores.csv'
    score_set = stub('score set')
    Linkage::ScoreSets::CSV.expects(:new).with(expected_score_file, {}).returns(score_set)
    assert_same score_set, result_set.score_set

    expected_match_file = './matches.csv'
    match_set = stub('match set')
    Linkage::MatchSets::CSV.expects(:new).with(expected_match_file, {}).returns(match_set)
    assert_same match_set, result_set.match_set
  end

  test "directory option" do
    opts = {
      :dir => File.join(@tmpdir, 'foo')
    }
    result_set = Linkage::ResultSets::CSV.new(opts)
    assert Dir.exist?(opts[:dir])

    expected_score_file = File.join(@tmpdir, 'foo', 'scores.csv')
    score_set = stub('score set')
    Linkage::ScoreSets::CSV.expects(:new).with(expected_score_file, {}).returns(score_set)
    assert_same score_set, result_set.score_set

    expected_match_file = File.join(@tmpdir, 'foo', 'matches.csv')
    match_set = stub('match set')
    Linkage::MatchSets::CSV.expects(:new).with(expected_match_file, {}).returns(match_set)
    assert_same match_set, result_set.match_set
  end

  test "directory argument" do
    dir = File.join(@tmpdir, 'foo')
    result_set = Linkage::ResultSets::CSV.new(dir)
    assert Dir.exist?(dir)

    expected_score_file = File.join(@tmpdir, 'foo', 'scores.csv')
    score_set = stub('score set')
    Linkage::ScoreSets::CSV.expects(:new).with(expected_score_file, {}).returns(score_set)
    assert_same score_set, result_set.score_set

    expected_match_file = File.join(@tmpdir, 'foo', 'matches.csv')
    match_set = stub('match set')
    Linkage::MatchSets::CSV.expects(:new).with(expected_match_file, {}).returns(match_set)
    assert_same match_set, result_set.match_set
  end

  test "custom filenames" do
    opts = {
      :dir => File.join(@tmpdir, 'foo'),
      :scores => {:filename => 'foo-scores.csv'},
      :matches => {:filename => 'foo-matches.csv'}
    }
    result_set = Linkage::ResultSets::CSV.new(opts)
    assert Dir.exist?(opts[:dir])

    expected_score_file = File.join(@tmpdir, 'foo', 'foo-scores.csv')
    score_set = stub('score set')
    Linkage::ScoreSets::CSV.expects(:new).with(expected_score_file, {}).returns(score_set)
    assert_same score_set, result_set.score_set

    expected_match_file = File.join(@tmpdir, 'foo', 'foo-matches.csv')
    match_set = stub('match set')
    Linkage::MatchSets::CSV.expects(:new).with(expected_match_file, {}).returns(match_set)
    assert_same match_set, result_set.match_set
  end

  test "miscellaneous options" do
    opts = {
      :dir => File.join(@tmpdir, 'foo'),
      :scores => {:foo => 'bar'},
      :matches => {:baz => 'qux'}
    }
    result_set = Linkage::ResultSets::CSV.new(opts)
    assert Dir.exist?(opts[:dir])

    expected_score_file = File.join(@tmpdir, 'foo', 'scores.csv')
    score_set = stub('score set')
    Linkage::ScoreSets::CSV.expects(:new).with(expected_score_file, :foo => 'bar').returns(score_set)
    assert_same score_set, result_set.score_set

    expected_match_file = File.join(@tmpdir, 'foo', 'matches.csv')
    match_set = stub('match set')
    Linkage::MatchSets::CSV.expects(:new).with(expected_match_file, :baz => 'qux').returns(match_set)
    assert_same match_set, result_set.match_set
  end

  test "registers itself" do
    assert_same Linkage::ResultSets::CSV, Linkage::ResultSet['csv']
  end
end
