require 'test_helper'

class ClientTest < Minitest::Test
  describe 'initialization' do
    describe '#username' do
      it 'should accept a username' do
        @client = Trimark::Client.new do |c|
          c.username = 'Foo'
        end
        assert_equal 'Foo', @client.username
      end
    end

    describe '#password' do
      it 'should accept a password' do
        @client = Trimark::Client.new do |c|
          c.password = 'Bar'
        end
        assert_equal 'Bar', @client.password
      end
    end

    describe '#device_token' do
      it 'should create a valid device UUID' do
        @client = Trimark::Client.new do |c|
          c.device_token = SecureRandom.uuid
        end
        assert_equal 36, @client.device_token.length
      end
    end

    describe '#access_token' do
      it 'should accept an access token' do
        @client = Trimark::Client.new do |c|
          c.access_token = 'uuddlrlrba'
        end
        assert_equal 'uuddlrlrba', @client.access_token
      end
    end

    describe '#company_id' do
      it 'should accept a company id' do
        @client = Trimark::Client.new do |c|
          c.company_id = 0
        end
        assert_equal 0, @client.company_id
      end
    end
  end

  describe 'the authentication process' do
    login_url = 'https://vantage.trimarkassoc.com/api/login'

    before do
      @client = Trimark::Client.new do |c|
        c.username = 'Such'
        c.password = 'Login'
        c.device_token = 'WoW!'
        c.access_token = nil
      end
    end

    describe '#login' do
      it 'should raise a Trimark::AuthError when supplied invalid credentials' do
        invalid_response = YAML.load_file('test/fixtures/trimark_invalid_auth.yml')
        stub_request(:post, login_url).to_return(body: invalid_response)
        assert_raises(Trimark::AuthError) do
          @client.login
        end
      end

      it 'should return a valid access token and assign it to the client instance' do
        valid_response = YAML.load_file('test/fixtures/trimark_valid_auth.yml')
        stub_request(:post, login_url).to_return(body: valid_response)

        @client.login.must_equal 'ACCESS_TOKEN'
        @client.access_token.must_equal 'ACCESS_TOKEN'
      end

      it 'should set the company id on successful login' do
        valid_response = YAML.load_file('test/fixtures/trimark_valid_auth.yml')
        stub_request(:post, login_url).to_return(body: valid_response)

        @client.login.must_equal 'ACCESS_TOKEN'
        @client.company_id.must_equal 'FOO'
      end
    end
  end

  describe '#sites' do
    site_url = 'https://vantage.trimarkassoc.com/api/company/1/site'

    before do
      @client = Trimark::Client.new do |c|
        c.username = 'Such'
        c.password = 'Login'
        c.device_token = 'WoW!'
        c.access_token = 'TESTING'
        c.company_id = 1
      end
    end

    describe 'when the query is successful' do
      it 'should return an array of site objects'  do
        expected = Trimark::Site.new({
          "SiteId" => 60,
          "Name" => "Well #4",
          "SiteType" => "Well",
          "Longitude" => -120.301121,
          "Latitude" => 36.147533,
          "StatusRawValue" => 22,
          "Status" => "Active",
          "StatusType" => "UCON",
          "IsAvailable" => true,
          "Location" => "West Hills Farms - Well #4, Coalinga"
        }) 

        valid_response = YAML.load_file('test/fixtures/trimark_valid_sites.yml')
        stub_request(:get, site_url).to_return(body: valid_response)

        assert_equal expected.attributes, @client.sites.first.attributes
      end
    end    

    describe 'when the query is not successful' do
      it 'should raise an exception'  do
        stub_request(:get, site_url).to_return(body: 'null')

        assert_raises(Trimark::QueryError) do
          @client.sites
        end    
      end
    end
  end

  describe 'the site attribute and history query process' do
    site_info_url = 'https://vantage.trimarkassoc.com/api/company/1/site/1'

    query_hash = {
      query: {
        beginDateTime: '2015-08-31 01:01',
        endDateTime: '2015-09-01 01:01',
        intervalType: 'Day',
        pointIds: '39'
      }
    }

    before do
      @client = Trimark::Client.new do |c|
        c.username = 'Such'
        c.password = 'Login'
        c.device_token = 'WoW!'
        c.access_token = 'TESTING'
        c.company_id = 1
      end
    end

    describe '#site_query' do
      it 'should raise a Trimark::QueryError for invalid / unauthorized sites' do
        stub_request(:get, site_info_url).to_return(body: 'null')
        assert_raises(Trimark::QueryError) do
          @client.site_query(1)
        end
      end

      it 'should raise a Trimark::QueryError if the client hasnt logged in' do
        @client.access_token = nil
        stub_request(:get, site_info_url)
        assert_raises(Trimark::QueryError) do
          @client.site_query(1)
        end
      end

      it 'should raise a Trimark::QueryError if too many arguments are passed in' do
        stub_request(:get, site_info_url)
        assert_raises(Trimark::QueryError) do
          @client.site_query(1, 1, 1)
        end
      end

      it 'should return site information for the specified site' do
        valid_response = YAML.load_file('test/fixtures/trimark_valid_site_info.yml')
        stub_request(:get, site_info_url).to_return(body: valid_response)

        @client.site_query(1).must_include 'SiteId'
      end

      it 'should return site history information for the specified site' do
        site_history_url = Addressable::Template.new(
          site_info_url + '/history/{?query*}'
        ).expand(query_hash)

        valid_response = YAML.load_file('test/fixtures/trimark_valid_site_history.yml')
        stub_request(:get, site_history_url).to_return(body: valid_response)
        @client.site_query(1, query_hash).must_include 'PointId'
      end
    end
  end
end
