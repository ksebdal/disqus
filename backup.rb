require 'curb'
require 'json'
require 'builder'

x = Builder::XmlMarkup.new(:target => $stdout, :indent => 1)
x.instruct!
con = Curl::Easy.new('http://disqus.com/api/get_forum_list/?user_api_key=' + ARGV[0] + '&api_version=1.1')
con.max_redirects = 4
con.perform
forum_names = ''
forums = JSON.parse(con.body_str)
if forums['succeeded']
  x.articles  do
  forums['message'].each do 
    |forum|
  #  puts forum['name']
  #  puts forum['id']
  
    #con2 = Curl::Easy.new('http://disqus.com/api/get_forum_posts/?user_api_key=' + ARGV[0]'&forum_id=' + forum['id'] + '&api_version=1.1') 
    #con2.max_redirects = 4
    #con2.perform
    #posts = JSON.parse(con2.body_str)
    #puts posts
  end
  end
  
end
