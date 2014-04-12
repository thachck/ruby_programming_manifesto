require 'test_helper'
require 'google_matchers'

describe GoogleMatchers do
  subject { GoogleMatchers }

  describe 'match(html)' do
    context 'when there is no matching method' do
      it 'must return 0' do
        subject.match("html").must_equal 0
      end
    end
  end
end
