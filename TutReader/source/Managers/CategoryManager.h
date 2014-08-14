//
//  CategoryManager.h
//  TutReader
//
//  Created by crekby on 7/31/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryManager : NSObject

+ (id) subcategoriesByCategoryID:(unsigned long) ID;

+ (id) subcategoriesForTUT;
+ (id) subcategoriesForAuto;
+ (id) subcategoriesForIT;
+ (id) subcategoriesForLady;
+ (id) subcategoriesForSport;

+ (id) nameForCategoryID:(unsigned long) ID;

+ (unsigned long) subcategoriesCountByCategoryID:(unsigned long) ID;

typedef enum
{
    TUT = 0,
    AUTO,
    IT,
    LADY,
    SPORT
} TUT_Categories;

typedef enum
{
    CATEGORY = 0,
    SUBCATEGORY
} CategoryType;

@end
