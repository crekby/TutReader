//
//  GlobalCategoriesArray.m
//  TutReader
//
//  Created by crekby on 8/1/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "GlobalCategoriesArray.h"
#import "CategoryItem.h"
#import "SubCategoryItem.h"

@interface GlobalCategoriesArray()

@property (nonatomic) NSMutableArray* localCategoryArray;

@end

@implementation GlobalCategoriesArray

SINGLETON(GlobalCategoriesArray)

- (void)initCategories
{
    self.localCategoryArray = [NSMutableArray new];
    for (int i=0; i<5; i++) {
        [GlobalNewsArray instance].newsURL = RSS_URL;
        CategoryItem* catItem = [CategoryItem new];
        catItem.name = [CategoryManager nameForCategoryID:i];
        catItem.isOpen = NO;
        catItem.subCategories = [NSMutableArray new];
        NSDictionary* dict = [NSDictionary dictionaryWithDictionary:[CategoryManager subcategoriesByCategoryID:i]];
        for (id subString in dict) {
            SubCategoryItem* subCatItem = [SubCategoryItem new];
            subCatItem.name = [NSString stringWithFormat:@"%@",subString];
            subCatItem.rssURL = [dict valueForKey:subCatItem.name];
            subCatItem.parent = i;
            [catItem.subCategories insertObject:subCatItem atIndex:catItem.subCategories.count];
        }
        [self.localCategoryArray insertObject:catItem atIndex:self.localCategoryArray.count];
    }
}

- (NSMutableArray *)categories
{
    return _localCategoryArray;
}

- (CategoryItem *)categoryAtIndex:(int)index
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
