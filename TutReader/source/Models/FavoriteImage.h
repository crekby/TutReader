//
//  FavoriteImage.h
//  TutReader
//
//  Created by crekby on 8/7/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteImage : NSObject

+(FavoriteImage*) instance;

- (UIImage*) imageForNews:(TUTNews *)newsItem;

@end
