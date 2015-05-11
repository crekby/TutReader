//
//  GraphController.h
//  TutReader
//
//  Created by crekby on 8/19/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface GraphController : UIViewController <CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) NSArray* Values;


-(void)initPlot;

@end
