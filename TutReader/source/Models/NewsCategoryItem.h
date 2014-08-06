//
//  CategoryItem.h
//  TutReader
//
//  Created by crekby on 8/1/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "NewsSubCategoryItem.h"

@interface NewsCategoryItem : NewsSubCategoryItem

@property (nonatomic, strong) NSMutableArray* subCategories;

@property (nonatomic) BOOL isOpen;

@end
