require 'test_helper'
require 'google_stats_retriever'

describe GoogleStatsRetriever do
  subject { GoogleStatsRetriever }

  describe "retrieve(uid)" do
    it "must return a hash with 2 counts in it" do
      VCR.use_cassette("dreamr_google_stats_retriever") do
        result = subject.('+DreamrOKelly')
        result.must_equal({:follower_count=>21, :following_count=>9})
      end
    end
  end

end
