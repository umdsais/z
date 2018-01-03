require 'rails_helper'

describe RedirectController do
  let(:url) { FactoryGirl.create(:url) }

  describe 'GET /:keyword' do
    describe 'url exists' do
      it 'redirects back to the referring page' do
        get :index, keyword: url.keyword
        expect(response).to redirect_to url.url
      end
    end
    describe 'url does not exist' do
      it 'redirects back to the root path' do
        get :index, keyword: "5#{url.keyword}"
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'Click count /:keyword' do
    describe 'user agent google' do
      it 'should not count' do
        @request.user_agent = "Googlebot/2.1"
        get :index, keyword: url.keyword
        newURL = Url.find(url.id)
        expect(url.total_clicks).to eq(newURL.total_clicks)
      end
    end
    describe 'user agent chrome' do
      it 'should count' do
        @request.user_agent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
        get :index, keyword: url.keyword
        newURL = Url.find(url.id)
        expect(url.total_clicks).not_to eq(newURL.total_clicks)
      end
    end
  end
  

  describe 'Resque queue' do
    describe 'clicking' do
      it 'should increment' do
        resque_length = Resque.size(:geo_queue)
        @request.user_agent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
        get :index, keyword: url.keyword
        new_resque_length = Resque.size(:geo_queue)
        expect(new_resque_length).not_to eq(resque_length)
      end
    end
    describe 'run' do
      it 'should run job' do
        Resque.inline do
          initial_clicks = url.clicks.length
          @request.user_agent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
          get :index, keyword: url.keyword
          expect(initial_clicks).not_to eq(url.clicks.length)
        end
      end
    end
  end
end
