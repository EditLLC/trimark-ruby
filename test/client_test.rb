require 'test_helper'

class ClientTest < Minitest::Test
  describe 'initialization' do
    describe '#username' do
      it 'should accept a username' do
        @client = TriMark::Client.new do |c|
          c.username = 'Foo'
        end
        assert_equal 'Foo', @client.username
      end
    end

    describe '#password' do
      it 'should accept a password' do
        @client = TriMark::Client.new do |c|
          c.password = 'Bar'
        end
        assert_equal 'Bar', @client.password
      end
    end

    describe '#device_token' do
      it 'should create a valid device UUID' do
        @client = TriMark::Client.new do |c|
          c.device_token = SecureRandom.uuid
        end
        assert_equal 36, @client.device_token.length
      end
    end

    describe '#access_token' do
      it 'should accept an access token' do
        @client = TriMark::Client.new do |c|
          c.access_token = 'uuddlrlrba'
        end
        assert_equal 'uuddlrlrba', @client.access_token
      end
    end
  end

  describe 'the authentication process' do
    login_url = 'https://vantage.trimarkassoc.com/api/login'

    before do
      @client = TriMark::Client.new do |c|
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
        assert_raises(TriMark::AuthError) do
          @client.login
        end
      end

      it 'should return a valid access token and assign it to the client instance' do
        valid_response = YAML.load_file('test/fixtures/trimark_valid_auth.yml')
        stub_request(:post, login_url).to_return(body: valid_response)
        @client.login.wont_be_nil
        @client.access_token.must_equal 'ACCESS_TOKEN'
      end
    end
  end

  describe 'the site attribute and history query process' do
    site_info_url = 'https://vantage.trimarkassoc.com/api/company/1/site/1'

    before do
      @client = TriMark::Client.new do |c|
        c.username = 'Such'
        c.password = 'Login'
        c.device_token = 'WoW!'
        c.access_token = 'TESTING'
        c.company_id = 1
      end
    end

    describe '#site_query' do
      it 'should raise a Trimark::QueryError' do
        stub_request(:get, site_info_url).to_return(body: 'null')
        assert_raises(TriMark::QueryError) do
          @client.site_query(1)
        end
      end
    end
  end
end
