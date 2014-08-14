//
//  GlobalCategoriesArray.h
//  TutReader
//
//  Created by crekby on 8/1/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsCategoryItem.h"

@interface GlobalCategoriesArray : NSObject

+ (GlobalCategoriesArray*) instance;

- (void) setupCategories;

- (NSMutableArray*) categories;
- (NewsCategoryItem*) categoryAtIndex:(unsigned long) index;

- (void) expandCategoryAtIndex:(unsigned long) index;
- (void) closeCategoryAtIndex:(unsigned long) index;

@end
