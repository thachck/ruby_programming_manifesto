require 'test_helper'
require 'google_following_count_matcher'

describe GoogleFollowingCountMatcher do
  subject { GoogleFollowingCountMatcher }
  let(:html) { File.read(File.expand_path("../../fixtures/google_dreamr_profile.html", __FILE__)) }

  describe "match_followings(html)" do
    it "must match the following count" do
      subject.send(:match_followings, html).must_equal 9
    end
  end
end
