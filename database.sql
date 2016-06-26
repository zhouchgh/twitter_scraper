-------------------------------------------------------
--       create tweet table
-------------------------------------------------------
create table if not exists tweet
(
	Id bigint(20) not null auto_increment,
	CreateTime datetime not null,
  	TweetCreateTime datetime not null,
  	TweetId varchar(128) collate utf8mb4_unicode_ci not null,
  	UserId varchar(128) collate utf8mb4_unicode_ci not null,
  	Content varchar(1024) collate utf8mb4_unicode_ci not null,
  	Url varchar(256) collate utf8mb4_unicode_ci not null,
  	primary key (Id),
  	unique key TweetId (TweetId)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-------------------------------------------------------
--      create merge_tweet store procedure
-------------------------------------------------------
delimiter //
create procedure merge_tweet
(
	in create_time datetime,
	in tweet_create_time datetime,
	in tweet_id varchar(128),
	in user_id varchar(128),
	in content varchar(256) character set utf8,
	in url varchar(256)
)
begin
insert into tweet
(
	CreateTime,
	TweetCreateTime,
	TweetId,
	UserId,
	Content,
	Url
)
values
(
	create_time,
	tweet_create_time,
	tweet_id,
	user_id,
	content,
	url
)
on duplicate key update
	TweetCreateTime = values(TweetCreateTime),
	UserId = values(UserId),
	Content = values(Content),
	Url = values(Url);
end//
delimiter ;
