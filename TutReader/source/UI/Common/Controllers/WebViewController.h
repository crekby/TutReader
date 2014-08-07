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


@interface WebViewController : UIViewController <UIWebViewDelegate,NSFetchedResultsControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) TUTNews* loadedNews;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (void) setupNews;
- (void) loadWithNews:(TUTNews*) news;

@end
