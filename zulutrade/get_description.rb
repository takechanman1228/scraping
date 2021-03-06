require 'selenium-webdriver'
require 'csv'
require 'pp'

day = Time.now
time = "#{day.year}#{day.month}#{day.day}#{day.hour}#{day.min}"
input_filename="input/user_id_2323.csv";
error_log_filename="output/user_profile_#{time}.log"
output_filename="output/user_profile_#{time}.csv";
output_folder="output/profiles/"

wait = Selenium::WebDriver::Wait.new(:timeout => 10)
userIDs = CSV.read(input_filename)
driver = Selenium::WebDriver.for :chrome
File.open(error_log_filename, "w") do |errorlog|
  File.open(output_filename, "w") do |io|
    userIDs.each{|user_id|
      File.open("#{output_folder}#{user_id[0]}.csv", "w") do |io2|

        begin
          url  = "https://japan.zulutrade.com/trader/#{user_id[0]}?Lang=en"
          p url
          driver.get url
          elements=driver.find_elements(:css,"div#main_ProfileMessages_container p.text").map(&:text)
          pp "#{user_id[0]},\"#{elements[0]}\""
          io.puts "#{user_id[0]},\"#{elements[0]}\""
          io2.puts "#{elements[0]}"
          sleep(5.0)
          pp "success"
        rescue => error
          driver.quit
          driver = Selenium::WebDriver.for :chrome
          errorlog.puts error.message
          next
        end
      end
    }
  end
end
driver.quit
