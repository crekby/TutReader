//
//  PageViewController.h
//  TutReader
//
//  Created by crekby on 7/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>
#warning уверен, что все делегаты должны быть паблик?
@interface PageViewController : UIPageViewController <UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIPopoverControllerDelegate,UINavigationControllerDelegate>

- (void) initNews;

@end
