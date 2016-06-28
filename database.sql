-------------------------------------------------------
--       create user table
-------------------------------------------------------
create table if not exists `user`
(
	Id bigint(20) not null auto_increment,
	CreateTime datetime not null,
  	UserCreateTime datetime not null,
  	UserId varchar(128) collate utf8mb4_unicode_ci not null,
	ScreenName varchar(128) collate utf8mb4_unicode_ci not null,
	Name varchar(128) collate utf8mb4_unicode_ci null,
  	Description varchar(2048) collate utf8mb4_unicode_ci null,
  	Url varchar(256) collate utf8mb4_unicode_ci not null,
	Location varchar(256) collate utf8mb4_unicode_ci null,
	FollowersCount int not null,
	FollowingCount int not null,
	FriendsCount int not null,
	FavouritesCount int not null,
	ListedCount int not null,
	StatusesCount int not null,
	Verified bit not null,
  	primary key (Id),
  	unique key UserId (UserId)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

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
--       create topic table
-------------------------------------------------------
create table if not exists topic
(
	Id bigint(20) not null auto_increment,
	Topic varchar(256) not null,
	Keywords varchar(1024) not null,
	Enabled bit not null default 0,
  	primary key (Id),
  	unique key Topic (Topic)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-------------------------------------------------------
--       create tweet topic mapping table
-------------------------------------------------------
create table if not exists TweetTopicMapping
(
	Id bigint(20) not null auto_increment,
	TweetId bigint(20) not null,
	TopicId bigint(20) not null,
  	primary key (Id),
  	unique key TweetIdTopicId (TweetId, TopicId)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-------------------------------------------------------
--       create log table
-------------------------------------------------------
create table if not exists `log`
(
	Id bigint(20) not null auto_increment,
	EventTime datetime not null,
	`Level` int not null, -- 0: information, 1: debug, 2: warning, 3: error, 4: fatal
	Information varchar(4096) null,
  	primary key (Id)
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
select *
from tweet
where TweetId = tweet_id;
end//
delimiter ;

-------------------------------------------------------
--      create merge_user store procedure
-------------------------------------------------------
delimiter //
create procedure merge_user
(
	in CreateTime datetime,
  	in UserCreateTime datetime,
  	in UserId varchar(128) character set utf8mb4,
	in ScreenName varchar(128) character set utf8mb4,
	in `Name` varchar(128) character set utf8mb4,
  	in Description varchar(2048) character set utf8mb4,
  	in Url varchar(256) character set utf8mb4,
	in Location varchar(256) character set utf8mb4,
	in FollowersCount int,
	in FollowingCount int,
	in FriendsCount int,
	in FavouritesCount int,
	in ListedCount int,
	in StatusesCount int,
	in Verified bit
)
begin
insert into `user`
(
	CreateTime,
  	UserCreateTime,
  	UserId,
	ScreenName,
	`Name`,
  	Description,
  	Url,
	Location,
	FollowersCount,
	FollowingCount,
	FriendsCount,
	FavouritesCount,
	ListedCount,
	StatusesCount,
	Verified
)
values
(
	CreateTime,
  	UserCreateTime,
  	UserId,
	ScreenName,
	`Name`,
  	Description,
  	Url,
	Location,
	FollowersCount,
	FollowingCount,
	FriendsCount,
	FavouritesCount,
	ListedCount,
	StatusesCount,
	Verified
)
on duplicate key update
  	UserCreateTime = values(UserCreateTime),
	ScreenName = values(ScreenName),
	`Name` = values(`Name`),
  	Description = values(Description),
  	Url = values(Url),
	Location = values(Location),
	FollowersCount = values(FollowersCount),
	FollowingCount = values(FollowingCount),
	FriendsCount = values(FriendsCount),
	FavouritesCount = values(FavouritesCount),
	ListedCount = values(ListedCount),
	StatusesCount = values(StatusesCount),
	Verified = values(Verified);
end//
delimiter ;

-------------------------------------------------------
--      create get_topic store procedure
-------------------------------------------------------
delimiter //
create procedure get_topics
(
	IncludeDisabled bit
)
select *
from topic
where Enabled = 1 or IncludeDisabled = 1//
delimiter ;

-------------------------------------------------------
--      create merge_tweet_topic store procedure
-------------------------------------------------------
delimiter //
create procedure merge_tweet_topic
(
	in TweetId bigint(20),
	in TopicId bigint(20)
)
begin
insert ignore into TweetTopicMapping 
(
	TweetId,
	TopicId
)
values
(
	TweetId,
	TopicId
)
on duplicate key update
	TweetId = values(TweetId),
	TopicId = values(TopicId);
end//
delimiter ;

-------------------------------------------------------
--      create insert_log store procedure
-------------------------------------------------------
delimiter //
create procedure insert_log
(
	in `Level` int, -- 0: information, 1: debug, 2: warning, 3: error, 4: fatal
	in Information varchar(4096)
)
begin
insert ignore into `log` 
(
	EventTime,
	`Level`,
	Information
)
values
(
	utc_timestamp(),
	`Level`,
	Information
);
end//
delimiter ;

--------------------------------------------------------
--     post deployment script
--------------------------------------------------------
insert ignore into topic (Topic, Keywords, Enabled)
values
(
	'Brexit',
	'Brexit OR "EU referendum"',
	1
),
(
	'Game of Throne',
	'"Game of Thrones" OR "GameofThrones"',
	1
)
on duplicate key update
	Keywords = values(Keywords),
	Enabled = values(Enabled);
