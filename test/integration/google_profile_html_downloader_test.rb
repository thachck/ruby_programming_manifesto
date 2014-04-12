require 'test_helper'
require 'google_profile_html_downloader'

describe GoogleProfileHtmlDownloader do
  subject { GoogleProfileHtmlDownloader }

  describe 'download(url)' do
    let(:url_with_redirect)  { "https://plus.google.com/116931168402898379226/posts" }
    let(:url_wo_a_redirect)  { "https://plus.google.com/+DreamrOKelly/posts" }
    let(:person_schema_html) { "http://schema.org/Person" }

    context 'when using a uid' do
      it 'must return the profile page html' do
        VCR.use_cassette("google_116931168402898379226") do
          subject.(url_with_redirect).must_include person_schema_html
        end
      end
    end

    context 'when using a url name' do
      it 'must return the profile page html' do
        VCR.use_cassette("google_+DreamrOKelly") do
          subject.(url_wo_a_redirect).must_include person_schema_html
        end
      end
    end
  end
end
