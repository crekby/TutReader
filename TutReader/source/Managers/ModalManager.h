//
//  ModalManager.h
//  TutReader
//
//  Created by crekby on 8/22/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModalManager : NSObject

+ (ModalManager*) instance;

- (void) showModal:(UIViewController*) modalVC inVieController:(UIViewController*) controller;
- (void)pushViewController:(UIViewController *)controller;

@end
