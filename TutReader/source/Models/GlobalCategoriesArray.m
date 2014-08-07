//
//  GlobalCategoriesArray.m
//  TutReader
//
//  Created by crekby on 8/1/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "GlobalCategoriesArray.h"
#import "NewsCategoryItem.h"
#import "NewsSubCategoryItem.h"

@interface GlobalCategoriesArray()

@property (nonatomic) NSMutableArray* localCategoryArray;

@end

@implementation GlobalCategoriesArray

SINGLETON(GlobalCategoriesArray)
- (void)setupCategories
{
    self.localCategoryArray = [NSMutableArray new];
    [DataProvider instance].newsURL = RSS_URL;
    for (int i=0; i<MAIN_CATEGORIES_COUNT; i++) {
        NewsCategoryItem* catItem = [NewsCategoryItem new];
        catItem.name = [CategoryManager nameForCategoryID:i];
        catItem.isOpen = NO;
        catItem.subCategories = [NSMutableArray new];
        NSDictionary* dict = [NSDictionary dictionaryWithDictionary:[CategoryManager subcategoriesByCategoryID:i]];
        for (NSDictionary* subString in dict) {
            NewsSubCategoryItem* subCatItem = [NewsSubCategoryItem new];
            subCatItem.name = [NSString stringWithFormat:@"%@",subString];
            subCatItem.rssURL = dict[subCatItem.name];
            [catItem.subCategories insertObject:subCatItem atIndex:catItem.subCategories.count];
        }
        [self.localCategoryArray insertObject:catItem atIndex:self.localCategoryArray.count];
    }
}

- (NSMutableArray *)categories
{
    return _localCategoryArray;
}

- (NewsCategoryItem *)categoryAtIndex:(int)index
{
    return _localCategoryArray[index];
}

- (void)expandCategoryAtIndex:(int)index
{
    NSLog(@"EXpand - %d",[self.localCategoryArray[index] subCategories].count);
    NSIndexSet* set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1, [_localCategoryArray[index] subCategories].count)];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [_localCategoryArray insertObjects:[[_localCategoryArray[index] subCategories] sortedArrayUsingDescriptors:sortDescriptors] atIndexes:set];
}

- (void) closeCategoryAtIndex:(int)index
{
    NSLog(@"Close - %d",[self.localCategoryArray[index] subCategories].count);
    NSIndexSet* set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1, [_localCategoryArray[index] subCategories].count)];
    [_localCategoryArray removeObjectsAtIndexes:set];
}


@end
