//
//  GlobalCategoriesArray.h
//  TutReader
//
//  Created by crekby on 8/1/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryItem.h"

@interface GlobalCategoriesArray : NSObject

+ (GlobalCategoriesArray*) instance;

- (void) initCategories;

- (NSMutableArray*) categories;
- (CategoryItem*) categoryAtIndex:(int) index;

- (void) expandCategoryAtIndex:(int) index;
- (void) closeCategoryAtIndex:(int) index;

@end
