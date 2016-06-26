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
