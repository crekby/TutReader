//
//  TUTNews.m
//  TutReader
//
//  Created by crekby on 7/16/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "TUTNews.h"

@implementation TUTNews

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@",self.newsTitle,self.text];
}

@end
