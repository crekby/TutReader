//
//  NewsTableViewController.h
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTableViewController : UITableViewController <NSURLConnectionDelegate,NSXMLParserDelegate,UIGestureRecognizerDelegate>

@property (nonatomic) int newsType;

- (void) localizeTabBarItem;

@end
