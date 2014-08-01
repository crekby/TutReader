//
//  CategoryTableViewController.h
//  TutReader
//
//  Created by crekby on 7/28/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryControllerDelegate <NSObject>

@optional
- (void) categoriesWillClose;
- (void) categoriesDidClose;
@end

@interface CategoryTableViewController : UITableViewController

@property (nonatomic, strong) id <CategoryControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, strong) NSMutableArray* categoriesContent;

- (void) openCategoryListAboveView:(UIView*) view;
- (void) closeCategoryList;

@end
