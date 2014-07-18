//
//  ipadMainViewController.h
//  TutReader
//
//  Created by crekby on 7/18/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ipadMainViewController : UISplitViewController

- (void) loadNews:(TUTNews*) news;
- (void) reloadNewsTable;

@end
