require 'curb'
require 'json'
require 'builder'

x = Builder::XmlMarkup.new(:target => $stdout, :indent => 1)
x.instruct!
con = Curl::Easy.new('http://disqus.com/api/get_forum_list/?user_api_key=' + ARGV[0] + '&api_version=1.1')
con.max_redirects = 4
con.on_success{
  forum_names = ''
  forums = JSON.parse(con.body_str)
  x.sites  do
    if forums['succeeded']
      forums['message'].each do 
        |forum|
        x.site(:name => forum['name']) do
          x.comments do
            con_posts = Curl::Easy.new('http://disqus.com/api/get_forum_posts/?user_api_key=' + ARGV[0] + '&forum_id=' + forum['id'] + '&api_version=1.1')
            con_posts.max_redirects = 4
            con_posts.on_success{
              posts = JSON.parse(con_posts.body_str)
              posts['message'].each do
                |post|
                x.comment do
                  x.message(post['message'])
                  x.status(post['status'])
                  x.ip(post['ip_address'])
                  x.created(post['created_at'])
                  x.author(post['anonymous_author'])
                end
              end
            }
            con_posts.perform
        end
      end
    end
  end
end
}
con.perform

