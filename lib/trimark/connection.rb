module APIConnection
  def conn
    @connection = Faraday.new(url: 'https://vantage.trimarkassoc.com/api/')
  end
end
