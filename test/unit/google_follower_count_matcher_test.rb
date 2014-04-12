require 'test_helper'
require 'google_follower_count_matcher'

describe GoogleFollowerCountMatcher do
  subject { GoogleFollowerCountMatcher }
  let(:html) { File.read(File.expand_path("../../fixtures/google_dreamr_profile.html", __FILE__)) }

  describe "match_followers(html)" do
    it "must match the follower count" do
      subject.send(:match_followers, html).must_equal 21
    end
  end
end
