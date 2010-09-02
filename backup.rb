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
x.sites  do
if forums['succeeded']
  forums['message'].each do 
    |forum|
    x.site(:name => forum['name']) do
      x.articles do
        con_posts = Curl::Easy.new('http://disqus.com/api/get_forum_posts/?user_api_key=' + ARGV[0] + '&forum_id=' + forum['id'] + '&api_version=1.1')
        con_posts.max_redirects = 4
        con_posts.perform
        posts = JSON.parse(con_posts.body_str)
        posts['message'].each do
          |post|
          x.article(:message => post['message'])
        end
      end
    end
  end
end
end

