//
//  TUTConstants.h
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

// DEVICE IDENTIFICATORS

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

// VIEW TITLES

#define ONLINE                @"Online"
#define FAVORITE              @"Favorite"

// SEGUE IDENTIFICATORS

#define ONLINE_SEGUE_ID       @"onlineBtnSegue"
#define FAVORITES_SEGUE_ID    @"favoritesBtnSegue"

// URLs

#define RSS_URL               @"http://news.tut.by/rss/all.rss"

// RESOURCES

#define STAR_FULL             @"star_full"
#define STAR_HALLOW           @"star_hallow"

#define IMAGE_NOT_AVAILABLE   @"No Image"

// CORE DATA TITLES

#define CD_ENTYTY                @"NEWS"

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