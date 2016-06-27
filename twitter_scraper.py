#!/usr/bin/python

#-----------------------------------------------------------------------
# import packet
#-----------------------------------------------------------------------
import twitter
import pymysql.cursors
from datetime import datetime
import time
import urllib

#---------------------------------------------------------------------
# function
#---------------------------------------------------------------------
def log(cursor, level, information):
	cursor.callproc('insert_log', (level, information,))

#----------------------------------------------------------------------
# load configuration
#----------------------------------------------------------------------
config = {}
execfile("twitter_scraper.conf", config)
twitter_url_template = config['twitter_url_template']
twitter_user_profile_template = config['twitter_user_profile_template']
window_size_minite = config['window_size_minite']
page_size = config['page_size']

#-----------------------------------------------------------------------
# create twitter API object
#-----------------------------------------------------------------------
api = twitter.Api(config['consumer_key'], config['consumer_secret'], config['access_token_key'], config['access_token_secret'], sleep_on_rate_limit=True)

last_since_id = {}
#-----------------------------------------------------------------------
# start next schedule
#-----------------------------------------------------------------------
while(True):
	# create mysql cursor object
	conn = pymysql.connect(config['host'], config['user'], config['password'], config['database'], charset='utf8mb4', cursorclass=pymysql.cursors.DictCursor)  
	cursor = conn.cursor()

	log(cursor, 0, 'Fetch start......')

	# get all topics
	cursor.callproc('get_topics', (0,))
	topics = cursor.fetchall()

	for topic in topics:
		# iniialize var for topic
		topic_id = topic['Id']
		topic_name = topic['Topic']
		keywords = topic['Keywords']
		if topic_name not in last_since_id:
			last_since_id[topic_name] = 0
		first_fetch = True
		total_count = 0
		since_id = last_since_id[topic_name]

		log(cursor, 0, 'Start fetch topic "' + topic_name + '" (since_id = ' + str(last_since_id[topic_name]) + ')')

		# set fetch count
		fecth_count = page_size
		while(fecth_count == page_size):
			# format search query
			if first_fetch:
				search_query = {'q':keywords, 'lang':'en', 'since_id':str(since_id), 'count':str(page_size), 'result_type':'recent'}
			else:
				search_query = {'q':keywords, 'lang':'en', 'since_id':str(since_id), 'max_id':str(max_id), 'count':str(page_size), 'result_type':'recent'}

			# perform a basic search 
			# Twitter API docs:
			# https://dev.twitter.com/docs/api/1/get/search
			results = api.GetSearch(raw_query = urllib.urlencode(search_query))
			fecth_count = len(results)
			total_count	+= fecth_count

			# calculate since_id 
			if first_fetch:
				last_since_id[topic_name] = results[0].id if fecth_count > 0 else 0
				first_fetch = False
		
			# calculate max_id
			max_id = results[-1].id - 1 if fecth_count > 0 else 0
		
			# Loop through each of the results, and print its content.
			for result in results:
				# insert tweet information
				current_time = datetime.now()
				tweet_create_time = datetime.strptime(result.created_at,'%a %b %d %H:%M:%S +0000 %Y').strftime('%Y-%m-%d %H:%M:%S')
				tweet_id = result.id_str
				user_id = str(result.user.id)
				content = result.text.encode('ascii', 'ignore')
				url = twitter_url_template.replace('{UserId}', user_id).replace('{TweetId}', tweet_id)
				cursor.callproc('merge_tweet', (current_time, tweet_create_time, tweet_id, user_id, content, url,))
				# insert tweet topic mapping
				tweet = cursor.fetchone()
				cursor.callproc('merge_tweet_topic', (tweet['Id'], topic_id,))
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
				cursor.callproc('merge_user', (current_time, user_create_time, user_id, user_screen_name, user_name, user_description, user_url, user_location, user_followers_count, user_followings_count, 	user_friends_count, user_favourites_count, user_listed_count, user_status_count, user_verified,))

			log(cursor, 0, 'Fetched ' + str(fecth_count) + ' tweets at this call. (max_id = ' + str(max_id) + ')')

		log(cursor, 0, 'Fetch complete for topic "' + topic_name + '". Fetched ' + str(total_count) + ' tweets at this schedule.')

	log(cursor, 0, 'Fetch complete for this schedule.')

	# commite all db insertions
	conn.commit()

	# close db connection
	conn.close()

	# sleep until next schedule
	time.sleep(window_size_minite * 60)
