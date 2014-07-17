//
//  webViewController.h
//  TutReader
//
//  Created by crekby on 7/17/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUTNews.h"
#import <CoreData/CoreData.h>


@interface webViewController : UIViewController <UIWebViewDelegate,NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (void) initWithNews:(TUTNews*) news;

@end
