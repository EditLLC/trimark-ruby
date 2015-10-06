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
      it 'should accept a username' do
        @client = TriMark::Client.new do |c|
          c.password = 'Bar'
        end
        assert_equal 'Bar', @client.password
      end
    end

    describe '#device_token' do
      it 'should accept a username' do
        @client = TriMark::Client.new do |c|
          c.device_token = 'abc123'
        end
        assert_equal 'abc123', @client.device_token
      end
    end
  end
end
