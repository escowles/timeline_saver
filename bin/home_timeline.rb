#!/usr/bin/env ruby

require 'fileutils'
require 'yaml'
require 'twitter'

def twitter_client
  @twitter_client ||= new_twitter_client
end

def new_twitter_client
  Twitter::REST::Client.new do |client|
    client.consumer_key = config['consumer_key']
    client.consumer_secret = config['consumer_secret']
    client.access_token = config['access_token']
    client.access_token_secret = config['access_token_secret']
  end
end

def config
  @config ||= YAML.load_file(File.join(Dir.home, '.twarclight'))
end

def data_dir
  config['data_dir']
end

def save(tweet)
  puts tweet.id
  FileUtils.mkdir_p(File.join(data_dir, tweet.id.to_s[0..2]))
  File.open(File.join(data_dir, tweet.id.to_s[0..2], tweet.id.to_s), 'wb') {|f| f.write(tweet.attrs.to_json) }
end

def opts
  opts = { count: 200 }
  opts[:since_id] = last_id if last_id
  opts
end

def last_id
  last_file = Dir.glob("#{data_dir}/*").sort.last
  @last_id ||= File.basename(last_file) if last_file
end

begin
  twitter_client.home_timeline(opts).each do |tweet|
    # since_id last id
    save tweet
  end
rescue Twitter::Error::RequestTimeout => timeout
  puts "timeout"
  STDOUT.flush
rescue Twitter::Error::TooManyRequests => error
  puts "rate limit exceeded, wait at least #{error.rate_limit.reset_in + 1}s..."
  STDOUT.flush
end
