//
//  CacheFilesManager.m
//  TutReader
//
//  Created by crekby on 8/5/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "CacheFilesManager.h"
#import "NSString+MD5.h"

@implementation CacheFilesManager

SINGLETON(CacheFilesManager)

- (void)clearCache
{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:IMAGE_CACHE_DIRECTORY];
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:cacheDirectory error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [cacheDirectory stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
            if (!removeSuccess) {
                // Error handling
                
            }
        }
    } else {
        // Error handling
        
    }
}

- (void)checkCacheForSize
{
    [self calculateFolderSizeWithCallback:^(NSNumber* fileSize, NSError* error)
    {
        if (fileSize.unsignedLongLongValue>MAX_CACHE_SIZE_BYTES) {
            [self clearCache];
        }
    }];
}

- (void)deleteCacheFile:(NSString *)filePath
{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError* error;
    [fileMgr removeItemAtPath:filePath error:&error];
}

- (void)copyFrom:(NSString *)from To:(NSString *)to
{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:FAVORITE_CACHE_DIRECTORY];
    NSError* error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    [fileMgr copyItemAtPath:from toPath:to error:&error];
}

- (NSString *)addCacheFile:(NSData *)file
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:IMAGE_CACHE_DIRECTORY];
    NSError* error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    NSString* imageDataString = [NSString stringWithFormat:@"%@", file];
    NSString* cacheFile = [cacheDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@",[imageDataString md5String]]];
    [file writeToFile:cacheFile atomically:YES];
    return cacheFile;
}

#pragma mark - Private Methods

- (void)calculateFolderSizeWithCallback:(CallbackWithDataAndError) callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:IMAGE_CACHE_DIRECTORY];
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:cacheDirectory error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    NSError* error;
    while (fileName = [filesEnumerator nextObject]) {
        //fileDictionary = [[NSFileManager defaultManager] fileAttributesAtPath: traverseLink:YES];
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[cacheDirectory stringByAppendingPathComponent:fileName] error:&error];
        fileSize += [fileDictionary fileSize];
    }
        if (callback) {
            callback(@(fileSize),nil);
        }
    });
}

@end
