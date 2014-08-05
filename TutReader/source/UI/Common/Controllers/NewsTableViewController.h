//
//  NewsTableViewController.h
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTableViewController : UITableViewController <NSURLConnectionDelegate,NSXMLParserDelegate,UIGestureRecognizerDelegate>

@property (nonatomic) int type;

- (void) initOnlineNewsList;
- (void) initFavoritesNewsList;
- (void) reloadNews;
- (void) selectRow:(int) row;
- (void)removeNewsAtIndex:(int)index;
- (void) localizeTabBarItem;

@end
