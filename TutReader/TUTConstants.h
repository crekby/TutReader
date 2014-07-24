//
//  TUTConstants.h
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

// MACROS

#define SINGLETON(className) \
static className *_##classNameInstance; \
+ (className *)instance { return _##classNameInstance; } \
+ (void)initialize { if (!_##classNameInstance) {_##classNameInstance = [[className alloc] init];} }

// DEVICE IDENTIFICATORS

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)

// CALLBACKS

typedef void(^CallbackWithDataAndError)(id data, NSError *error);

// DATA TYPES

typedef enum
{
    XML_DATA_TYPE      =         0,
    JSON_DATA_TYPE     =         1,
    CORE_DATA_TYPE     =         2
} DataTypes;

//////////////////////////////////////////////////////////////////////////////////////////

// SHARING

#define GOOGLE_PLUS_CLIENT_ID    @"324432650848-bfhi9sd755b78mdepqsi6m605gqjhsrt.apps.googleusercontent.com"
#define GOOGLE_PLUS_DEEP_LINK_ID @"rest=123456789"
#define GOOGLE_PLUS_TEXT_LENGHT  99

#define EMAIL_SHARE_MESSAGE_BODY @"<div align=\"center\"><table border=\"0\" align=\"center\" width=\"300\"><tr><b>%@</b><br><a href=%@><img src=\"%@\" alt=\"some_text\" height=\"280\" width=\"280\"><br>%@</a></tr></table></div>"

#define SOCIAL_NETWORK_TEXT_LENGHT  137

typedef enum
{
    SocialNetworkTypeTwitter    =    0,
    SocialNetworkTypeFacebook   =    1
} SocialNetworkType;

// GOOGLE ANALYTICS

#define GOOGLE_ANALYTICS_ID      @"UA-53128142-1"
#define GA_DEFAULT_TRACKING_VALUE @1

// ALERTS TEXTS AND TITLES

#define NO_INTERNET_CONNECTION_TITLE       @"Internet Connection"
#define NO_INTERNET_CONNECTION_MESSAGE     @"There is no internet connection"

#define HOST_NOT_REACHABLE_TITLE           @"Host not reachable"
#define HOST_NOT_REACHABLE_MESSAGE         @"News host not reachable. Try again later"

// VIEW TITLES

#define ONLINE                   @"Online"
#define FAVORITE                 @"Favorite"

// CELLS IDENTIFICATORS

#define NEWS_CELL_IDENTIFICATOR  @"newsCell"

// SEGUE IDENTIFICATORS

#define ONLINE_SEGUE_ID          @"onlineBtnSegue"
#define FAVORITES_SEGUE_ID       @"favoritesBtnSegue"

// URLs

#define RSS_URL                  @"http://news.tut.by/rss/all.rss"
#define HOME_PAGE                @"http://news.tut.by/"

// RESOURCES

#define STAR_FULL                @"iconNavBarFavoritesEnabled"
#define STAR_HOLLOW              @"iconNavBarFavorites"

#define STAR_FULL_WHITE          @"star_full_white"
#define STAR_HOLLOW_WHITE        @"star_hollow_white"

#define IMAGE_NOT_AVAILABLE      @"No Image"

// CORE DATA TITLES

#define CD_ENTYTY                @"NewsItem"

#define CD_OBJECT_ID             @"objectID"
#define CD_TITLE                 @"title"
#define CD_TEXT                  @"text"
#define CD_NEWS_URL              @"newsUrl"
#define CD_IMAGE_URL             @"imageUrl"
#define CD_PUBLICATION_DATE      @"pubDate"
#define CD_IS_FAVORITE           @"isFavorite"
#define CD_IMAGE                 @"image"

#define CD_CACHE                 @"Master"

// XML TITLES

#define XML_ITEM                 @"item"
#define XML_TITLE                @"title"
#define XML_NEWS_URL             @"link"
#define XML_NEWS_TEXT            @"description"
#define XML_PUBLICATION_DATE     @"pubDate"
#define XML_DATE_FORMAT          @"EEE, dd MMM yyyy  HH:mm:ss ZZZ"

// HTTP STATUS CODES

#define HTTP_OK                  200