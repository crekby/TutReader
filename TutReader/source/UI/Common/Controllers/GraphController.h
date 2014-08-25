//
//  GraphController.h
//  TutReader
//
//  Created by crekby on 8/19/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphController : UIViewController <CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *hostView;

@property (nonatomic, weak) NSArray* xValues;
@property (nonatomic, strong) NSArray* Values;


-(void)initPlot;

@end
