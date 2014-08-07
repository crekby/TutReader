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
#warning можно обойтись одним методом
- (void) addNewsToFavoriteWithIndex:(int) index andCallBack:(CallbackWithDataAndError) callback;
- (void) removeNewsFromFavoriteWithIndex:(int) index andCallBack:(CallbackWithDataAndError) callback;

@end
