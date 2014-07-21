//
//  NewsTableViewController.h
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTableViewController : UITableViewController <NSURLConnectionDelegate,NSXMLParserDelegate>

- (void) initOnlineNewsList;
- (void) initFavoritesNewsList;
- (void) reloadNews;

@property (strong, nonatomic) IBOutlet UITableView *newsTableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@end
