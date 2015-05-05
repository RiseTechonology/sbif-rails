require 'net/http'
require 'json'
require 'date'

module Sbif
  module Base
    API_KEY = ''
    URL = 'http://api.sbif.cl/api-sbifv3/recursos_api'

    def get_current
      current_time = Time.now
      return get_by_day(current_time.year, current_time.month, current_time.day)
    end

    def get_by_day(year, month, day)
      date = Date.new(year, month, day)
      currencies_response = Array.new
      # looking for business day
      loop do
        url = "#{URL}/#{name}/#{date.year.to_s}/#{date.month.to_s}/dias/#{date.day}?apikey=#{API_KEY}&formato=json"
        uri = URI(url)
        response = Net::HTTP.get uri
        currencies_response = JSON.parse response
        date -= 1
        break if currencies_response["#{plural_name}"]
      end
      currency = Sbif::Currency.new(date,currencies_response["#{plural_name}"][0]['Valor'].gsub('.', '').gsub(',', '.').to_f)
      return currency
    end

    def get_by_month(year, month)
      url = "#{URL}/#{self.name}/#{year.to_s}/#{month.to_s}?apikey=#{API_KEY}&formato=json"
      uri = URI(url)
      response = Net::HTTP.get uri
      currencies_response = JSON.parse response
      currencies = Array.new
      currencies_response["#{plural_name}"].each do |currency|
        currency_date = currency['Fecha'].to_s.split('-')
        date = Date.new(currency_date[0].to_i,currency_date[1].to_i,currency_date[2].to_i)
        currencies << Currency.new(date, currency['Valor'].gsub('.', '').gsub(',', '.').to_f)
      end
      return currencies
    end

    def get_by_year(year)
      url = "#{URL}/#{self.name}/#{year.to_s}?apikey=#{API_KEY}&formato=json"
      uri = URI(url)
      response = Net::HTTP.get uri
      currencies_response = JSON.parse response
      currencies = Array.new
      currencies_response["#{plural_name}"].each do |currency|
        currency_date = currency['Fecha'].to_s.split('-')
        date = Date.new(currency_date[0].to_i,currency_date[1].to_i,currency_date[2].to_i)
        currencies << Currency.new(date, currency['Valor'].gsub('.', '').gsub(',', '.').to_f)
      end
      return currencies
    end
  end
end
