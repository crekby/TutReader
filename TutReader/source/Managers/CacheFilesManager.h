//
//  CacheFilesManager.h
//  TutReader
//
//  Created by crekby on 8/5/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheFilesManager : NSObject

+(CacheFilesManager*) instance;

- (void) clearCache;
- (NSString*) addCacheFile:(NSData*) file;
- (void) deleteCacheFile:(NSString*) filePath;
- (void) copyFrom:(NSString*) from To:(NSString*) to;

- (void) checkCacheForSize;

@end
