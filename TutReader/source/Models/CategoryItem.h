//
//  CategoryItem.h
//  TutReader
//
//  Created by crekby on 8/1/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "SubCategoryItem.h"
#warning название не говорит о том, что это за подкатегория
@interface CategoryItem : SubCategoryItem

@property (nonatomic, strong) NSMutableArray* subCategories;

@property (nonatomic) BOOL isOpen;

@end
