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
            con_threads = Curl::Easy.new('http://disqus.com/api/get_thread_list/?user_api_key=' + ARGV[0] + '&forum_id=' + forum['id'] + '&api_version=1.1')
            con_threads.max_redirects = 4
            con_threads.on_success{
              threads = JSON.parse(con_threads.body_str)
              thread_ids = Array.new
              threads['message'].each do
                |thread|
                thread_ids.push(thread['id'])
              end
              con_num_posts = Curl::Easy.new('http://disqus.com/api/get_num_posts/?user_api_key=' + ARGV[0] + '&thread_ids=' + thread_ids.join(',') + '&api_version=1.1')
              con_num_posts.max_redirects = 4
              sum_posts = 0
              con_num_posts.on_success{
                num_posts = JSON.parse(con_num_posts.body_str)
                num_posts['message'].each do
                  |num_post|
                  sum_posts += num_post[1][0]
                end
              }
              con_num_posts.perform
              sum_posts
              con_posts = Curl::Easy.new('http://disqus.com/api/get_forum_posts/?user_api_key=' + ARGV[0] + '&forum_id=' + forum['id'] + '&limit=' + sum_posts.to_s + '&api_version=1.1')
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
          }
          con_threads.perform
        end
      end
    end
  end
end
}
con.perform

