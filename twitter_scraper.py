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
api = twitter.Api(config['consumer_key'], config['consumer_secret'], config['access_token_key'], config['access_token_secret'], sleep_on_rate_limit=True)

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

twitter_user_profile_template = config['twitter_user_profile_template']
twitter_url_template = config['twitter_url_template']

for result in results:
	# insert tweet information
	current_time = datetime.now()
	tweet_create_time = datetime.strptime(result.created_at,'%a %b %d %H:%M:%S +0000 %Y').strftime('%Y-%m-%d %H:%M:%S')
	tweet_id = result.id_str
	user_id = str(result.user.id)
	content = result.text.encode('ascii', 'ignore')
	url = twitter_url_template.replace('{UserId}', user_id).replace('{TweetId}', tweet_id)
	cursor.callproc('merge_tweet', (current_time, tweet_create_time, tweet_id, user_id, content, url,))
	# insert user information
	user_create_time = datetime.strptime(result.user.created_at,'%a %b %d %H:%M:%S +0000 %Y').strftime('%Y-%m-%d %H:%M:%S')
	user_screen_name = result.user.screen_name
	user_name = result.user.name
	user_description = result.user.description
	user_url = twitter_user_profile_template.replace('{UserScreenName}', user_screen_name)
	user_location = result.user.location
	user_followers_count = result.user.followers_count
	user_followings_count = result.user.friends_count
	user_friends_count = result.user.friends_count
	user_favourites_count = result.user.favourites_count
	user_listed_count = result.user.listed_count
	user_status_count = result.user.statuses_count
	user_verified = result.user.verified
	cursor.callproc('merge_user', (current_time, user_create_time, user_id, user_screen_name, user_name, user_description, user_url, user_location, user_followers_count, user_followings_count, user_friends_count, user_favourites_count, user_listed_count, user_status_count, user_verified,))
conn.commit()
conn.close()

