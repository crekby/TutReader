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
#define IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
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

// SETTINGS

#define LANGUAGE_SETTINGS_IDENTIFICATOR        @"lang"
#define ENGLISH_LANGUAGE_IDENTIFICATOR         @"en"
#define RUSSIAN_LANGUAGE_IDENTIFICATOR         @"ru"
#define DELETE_CACHE_SETTINGS_IDENTIFICATOR    @"del_cache"
#define APP_VERSION                            @"CFBundleShortVersionString"
#define APP_VERSION_SETTINGS_IDENTIFICATOR     @"app_version"
#define CURRENCY_PERIOD_SETTINGS_IDENTIFICATOR @"currencyPeriod"

#define CITY_NAME_SETTINGS_IDENTIFICATOR       @"cityName"

// CURRENCY RATES PERIODS

typedef enum
{
    currencyPeriodWeek = 0,
    currencyPeriodTwoWeek = 1,
    currencyPeriodMonth = 2,
    currencyPeriodSixMonth = 3,
    currencyPeriodYear = 4
} currencyPeriod;

// CATEGORIES

#define TUT_PREFIX               @"http://news.tut.by/rss/"

// NOTIFICATIONS

#define UPDATE_LOCALIZATION_NOTIFICATION              @"Update_Localization"
#define UPDATE_CURRENT_WEATHER_NOTIFICATION           @"update_current_weather"
#define PAGE_VIEW_CONTROLLER_SETUP_NEWS_NOTIFICATION  @"PageViewControllerSetupNews"
#define NEWS_TABLE_VIEW_RELOAD_NEWS_NOTIFICATION      @"NewsTableViewReloadNews"
#define NEWS_TABLE_VIEW_SELECT_ROW_NOTIFICATION       @"NewsTableViewSelectRow"
#define NEWS_TABLE_VIEW_REMOVE_ROW_NOTIFICATION       @"NewsTableViewRemoveRow"
#define NEWS_TABLE_VIEW_REFRESH_TABLE_NOTIFICATION    @"NewsTAbleViewRefreshTable"

// VIEW TITLES

typedef enum
{
    FAVORITE = 0,
    ONLINE = 1
} newsTypes;

// GOOGLE ANALYTICS FAVORITE OPERATIONS

typedef enum
{
    ADD_TO_FAVORITE = 0,
    REMOVE_FROM_FAVORITE,
    REMOVE_ALL_FROM_FAVORITE
} FavoriteOperations;

// CLASSES NAMES

#define NEWS_CATEGORY_ITEM_CLASS      @"NewsCategoryItem"

// CELLS IDENTIFICATORS

#define NEWS_CELL_IDENTIFICATOR  @"newsCell"
#define CATEGORY_CELL_IDENTIFICATOR @"categoryCell"

// VIEW CONTROLLERS IDENTIFICATORS

#define CATEGORY_TABLE_VIEW_CONTROLLER_IDENTIFICATOR  @"CategoriesTableView"
#define WEB_VIEW_CONTROLLER_IDENTIFICATOR             @"webView"
#define SHARE_VIEW_CONTROLLER_PORTRAIT_IDENTIFICATOR  @"shareViewPortrait"
#define SHARE_VIEW_CONTROLLER_LANDSCAPE_IDENTIFICATOR @"shareViewLandscape"

// COLORS

#define CATEGORY_BUTTON_HIGHLIGHTED_COLOR ([UIColor colorWithRed:0.7 green:0.7 blue:1 alpha:1])

// SANDBOX PATHS

#define DOCUMENTS_DIRECTORY      ([[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject])
#define IMAGE_CACHE_DIRECTORY    @"ImageCache/"
#define FAVORITE_CACHE_DIRECTORY @"FavoriteCache/"
#define MAX_CACHE_SIZE_BYTES     10000000

// SEGUE IDENTIFICATORS

#define ONLINE_SEGUE_ID          @"onlineBtnSegue"
#define FAVORITES_SEGUE_ID       @"favoritesBtnSegue"

// URLs

#define RSS_URL                  @"http://news.tut.by/rss/all.rss" //@"http://m.tut.by/rss/all.rss"
#define HOME_PAGE                @"http://news.tut.by/"
#define AUTO_PAGE                @"http://auto.tut.by/"
#define IT_PAGE                  @"http://it.tut.by/"
#define LADY_PAGE                @"http://lady.tut.by/"
#define SPORT_PAGE               @"http://sport.tut.by/"

#define CURRENCY_RATES_PAGE        @"http://www.nbrb.by/Services/XmlExRates.aspx?ondate=%@&mode=1"
#define CURRENCY_RATES_PERIOD_PAGE @"http://www.nbrb.by/Services/XmlExRatesDyn.aspx?curId=%@&fromDate=%@&toDate=%@"

#define WEATHER_NOW_BY_CITY_URL      @"http://api.openweathermap.org/data/2.5/weather?q=%@&mode=json&units=metric"
#define WEATHER_NOW_BY_LOCATION_URL  @"http://api.openweathermap.org/data/2.5/find?lat=%f&lon=%f&mode=json&units=metric"
#define WEATHER_DAILY_URL            @"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&mode=json&units=metric&cnt=14&lang=%@"
#define WEATHER_SEARCH_CITY_URL      @"http://api.openweathermap.org/data/2.5/find?q=%@&type=like&mode=json&lang=%@"


#define MAIN_CATEGORIES_COUNT    5

// RESOURCES

#define STAR_FULL                @"iconNavBarFavoritesEnabled"
#define STAR_HOLLOW              @"iconNavBarFavorites"

#define STAR_FULL_WHITE          @"star_full_white"
#define STAR_HOLLOW_WHITE        @"star_hollow_white"

#define IMAGE_NOT_AVAILABLE      @"No Image"

// IMAGES

#define STAR_FULL_IMAGE          ([UIImage imageNamed:STAR_FULL])
#define STAR_HOLLOW_IMAGE        ([UIImage imageNamed:STAR_HOLLOW])
#define STAR_FULL_WHITE_IMAGE    ([UIImage imageNamed:STAR_FULL_WHITE])
#define STAR_HOLLOW_WHITE_IMAGE  ([UIImage imageNamed:STAR_HOLLOW_WHITE])

#define SPEAK_IMAGE              ([UIImage imageNamed:@"speech"])
#define PAUSE_IMAGE              ([UIImage imageNamed:@"pause"])

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

#define XML_CURRENCY             @"Currency"
#define XML_RECORD               @"Record"
#define XML_CHARCODE             @"CharCode"
#define XML_CURRENCY_NAME        @"QuotName"
#define XML_RATE                 @"Rate"

// HTTP STATUS CODES

#define HTTP_OK                  200
