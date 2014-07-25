//
//  ipadMainViewController.h
//  TutReader
//
//  Created by crekby on 7/18/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IpadMainViewController : UISplitViewController

- (void) loadNews;
- (void) reloadNewsTable;
- (void) selectRow: (int) row;

@end
