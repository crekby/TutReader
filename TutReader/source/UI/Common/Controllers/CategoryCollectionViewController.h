//
//  CategoryCollectionViewController.h
//  TutReader
//
//  Created by crekby on 8/28/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryCollectionViewDelegate <NSObject>

@optional
- (void) categoriesDidSelect;
@end

@interface CategoryCollectionViewController : UICollectionViewController

@property (nonatomic, strong) id <CategoryCollectionViewDelegate> delegate;

@end
