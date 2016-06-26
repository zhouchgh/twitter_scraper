#!/usr/bin/python

#-----------------------------------------------------------------------
# import packet
#-----------------------------------------------------------------------
import twitter
import pymysql.cursors
from datetime import datetime

#----------------------------------------------------------------------
# load configuration
#----------------------------------------------------------------------
config = {}
execfile("twitter_scraper.conf", config)

#-----------------------------------------------------------------------
# create twitter API object
#-----------------------------------------------------------------------
api = twitter.Api(config['consumer_key'], config['consumer_secret'], config['access_token_key'], config['access_token_secret'])

initial_schedule_time = datetime.now()

#-----------------------------------------------------------------------
# create mysql cursor object
#-----------------------------------------------------------------------
conn = pymysql.connect(config['host'], config['user'], config['password'], config['database'], charset='utf8mb4', cursorclass=pymysql.cursors.DictCursor)  
cursor = conn.cursor()

#-----------------------------------------------------------------------
# perform a basic search 
# Twitter API docs:
# https://dev.twitter.com/docs/api/1/get/search
#-----------------------------------------------------------------------
results = api.GetSearch(raw_query = config['twitter_search_query'])

#-----------------------------------------------------------------------
# Loop through each of the results, and print its content.
#-----------------------------------------------------------------------

for result in results:
	current_time = datetime.now()
	tweet_create_time = datetime.strptime(result.created_at,'%a %b %d %H:%M:%S +0000 %Y').strftime('%Y-%m-%d %H:%M:%S')
	tweet_id = result.id_str
	user_id = str(result.user.id)
	content = result.text.encode('ascii', 'ignore')
	url = twitter_url_template.replace('{UserId}', user_id).replace('{TweetId}', tweet_id)
	cursor.callproc('merge_tweet', (current_time, tweet_create_time, tweet_id, user_id, content, url,))
conn.commit()
conn.close()

