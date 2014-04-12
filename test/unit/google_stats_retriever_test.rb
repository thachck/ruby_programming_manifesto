require 'test_helper'
require 'google_stats_retriever'

describe GoogleStatsRetriever do
  subject { GoogleStatsRetriever }
  before do
    GoogleStatsRetriever.stubs(:download_profile_html).returns("html")
    GoogleStatsRetriever.stubs(:match_following_count).returns(2)
    GoogleStatsRetriever.stubs(:match_follower_count).returns(4)
  end

  describe "retrieve(uid)" do
    it "must return a hash with 2 counts in it" do
      result = subject.('+DreamrOKelly')
      result.must_equal({:follower_count=>4, :following_count=>2})
    end
  end

end
