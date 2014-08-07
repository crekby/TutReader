//
//  FavoriteNewsManager.h
//  TutReader
//
//  Created by crekby on 7/28/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteNewsManager : NSObject

+ (FavoriteNewsManager*) instance;

- (void) favoriteNewsOperation:(int) operation withNews:(TUTNews*) newsItem andCallback:(CallbackWithDataAndError) callback;

@end
