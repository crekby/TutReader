//
//  GlobalNewsArray.h
//  TutReader
//
//  Created by crekby on 7/25/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewController.h"

#warning создай класс DataProvider и вынеси туда методы, которые тебе нужны. GlobalNewsArray выглядит херовенько ;)

@interface GlobalNewsArray : NSMutableArray

+ (GlobalNewsArray*) instance;
@property (nonatomic) NSString* newsURL;
@property (nonatomic) BOOL needToRaload;

#warning зачем этот метод?
- (void) newArray;
- (void) setNews:(NSMutableArray*) news;
- (NSMutableArray*) news;
- (TUTNews*) newsAtIndex:(int) index;
- (void) refreshNewsList;
#warning зачем, если можно news.count
- (int) newsCount;
- (void) insertNews: (TUTNews*) news;
- (TUTNews*) selectedNews;
- (void) setSelectedNews:(int) index;
- (int) selectedItem;
#warning мухи отдельно - котлеты отдельно. Если у тебя класс хранит новости, то что тут делает какой-то контроллер?
- (int) indexOfViewController:(WebViewController*) controller;
- (void) removeNewsAtIndex:(int) index;
#warning row используется в таблице. Зачем в какой-то отдельном классе хранить индекс строки?
- (int) rowForNews:(TUTNews*) news;
#warning непонятно, что именно нужно перегрузить
- (BOOL)needToRaload;

@end
