//
//  FavoriteImage.m
//  TutReader
//
//  Created by crekby on 8/7/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "FavoriteImage.h"

@implementation FavoriteImage

SINGLETON(FavoriteImage)

- (UIImage*) imageForNews:(TUTNews *)newsItem
{
    if (IS_IOS7) {
        return (newsItem.isFavorite) ? STAR_FULL_IMAGE : STAR_HOLLOW_IMAGE;
    }
    else
    {
        return (newsItem.isFavorite) ? STAR_FULL_WHITE_IMAGE : STAR_HOLLOW_WHITE_IMAGE;
    }
}

@end
