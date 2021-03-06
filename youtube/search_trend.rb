#!/usr/bin/ruby
require 'net/http'
require 'uri'
require 'json'
require 'logger'
require 'pp'
require 'complex'
require 'rubygems'
require 'google/api_client'
require 'trollop'
require 'pp'
require 'mysql'

DEVELOPER_KEY = 'AIzaSyBwE3CH2GCKAWnxT1xXoTjrk-p20EW5Tlw'
YOUTUBE_API_SERVICE_NAME = 'youtube'
YOUTUBE_API_VERSION = 'v3'
LOG_FILE='log/log.log'
ERROR_LOG_FILE='log/error.log'

def get_service
  client = Google::APIClient.new(
    :key => DEVELOPER_KEY,
    :authorization => nil,
    :application_name => $PROGRAM_NAME,
    :application_version => '1.0.0'
  )
  youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

  return client, youtube
end
=begin
def get_json(location, limit = 10)
  raise ArgumentError, 'too many HTTP redirects' if limit == 0
  uri = URI.parse(location)
  begin
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end
    case response
    when Net::HTTPSuccess
      json = response.body
      JSON.parse(json)
    when Net::HTTPRedirection
      location = response['location']
      warn "redirected to #{location}"
      get_json(location, limit - 1)
    else
      puts [uri.to_s, response.value].join(" : ")
      # handle error
    end
  rescue => e
    puts [uri.to_s, e.class, e].join(" : ")
    # handle error
  end
end
=end

def main
  opts = Trollop::options do
    opt :q, 'Search term', :type => String, :default => 'AKB48'
    opt :max_results, 'Max results', :type => :int, :default => 50
  end

  client, youtube = get_service

  begin

    connection = Mysql::connect("tk2-219-19173.vs.sakura.ne.jp", "root", "Take1228", "videos")
    # 文字コードをUTF8に設定
    connection.query("set character set utf8")


    # Call the search.list method to retrieve results matching the specified
    # query term.
    search_response = client.execute!(
      :api_method => youtube.search.list,
      :parameters => {
        :part => 'snippet',
        :q => opts[:q],
        :maxResults => opts[:max_results]
      }
    )

    videos = []

    # Add each result to the appropriate list, and then display the lists of
    # matching videos, channels, and playlists.
    search_response.data.items.each do |search_result|
      case search_result.id.kind
        when 'youtube#video'
          pp search_result
          videos << "#{search_result.snippet.title} (#{search_result.id.videoId})"
          # rs = connection.query("insert into posts (title,body,url) values ('#{search_result.snippet.title}',
          # '#{search_result.snippet.title} ',
          # '#{search_result.id.videoId}')")
          p "insert into posts (title,body,url) values ('#{search_result.snippet.title}',
          '#{search_result.snippet.title} ',
          '#{search_result.id.videoId}')"
      end
    end

    puts "Videos:\n", videos, "\n"
  rescue Google::APIClient::TransmissionError => e
    puts e.result.body
  end
end
main
