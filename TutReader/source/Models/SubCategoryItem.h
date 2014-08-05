//
//  SubCategoryItem.h
//  TutReader
//
//  Created by crekby on 8/1/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>
#warning название не говорит о том, что этот класс делает
@interface SubCategoryItem : NSObject

@property (nonatomic) NSString* name;

@property (nonatomic) NSString* rssURL;
#warning не понятно, что за парент и зачем он нужен
@property (nonatomic) int parent;

@end
