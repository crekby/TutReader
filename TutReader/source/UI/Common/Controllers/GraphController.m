//
//  GraphController.m
//  TutReader
//
//  Created by crekby on 8/19/14.
//  Copyright (c) 2014 crekby. All rights reserved.
//

#import "GraphController.h"


@interface GraphController ()

@property (nonatomic, strong) NSMutableDictionary* data;

@property (nonatomic, assign) CGFloat max;
@property (nonatomic, assign) CGFloat min;

@end

@implementation GraphController

- (void) OrientationDidChangeNotification:(NSNotification*) notification
{
    if (IS_IPHONE) {
        self.hostView.frame = self.view.frame;
    }
}

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.tabBarController.navigationItem.titleView) {
        self.tabBarController.navigationItem.titleView = nil;
    }
    self.tabBarController.navigationItem.title = AMLocalizedString(@"GRAPH_TITLE", nil);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.min = [self.Values[0] floatValue];
    for (NSNumber* number in self.Values) {
        if (number.floatValue > self.max) {
            self.max = number.floatValue;
        }
        if (self.min > number.floatValue) {
            self.min = number.floatValue;
        }
        
    }
    self.max += 50;
//    self.data = [NSMutableDictionary new];
//    for (int i=0; i < [DataProvider instance].numberOfSections; i++) {
//        for (TUTNews* newsItem in [[DataProvider instance] newsInSection:i]) {
//            NSDate *date = newsItem.pubDate;
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
//            NSInteger hour = [components hour];
//            NSNumber* value = [self.data objectForKey:[NSString stringWithFormat:@"%d",hour]];
//            if (value) {
//                value = @(value.intValue+1);
//            }
//            else
//            {
//                value = @(1);
//            }
//            
//            [self.data setValue:value forKey:[NSString stringWithFormat:@"%d",hour]];
//        }
//    }
    [self initPlot];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
	self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
	self.hostView.allowPinchScaling = YES;
	[self.view addSubview:self.hostView];
}

-(void)configureGraph {
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	[graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
	self.hostView.hostedGraph = graph;
	// 2 - Set graph title
	NSString *title = @"";
	graph.title = title;
	// 3 - Create and set text style
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
	// 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
	//[graph.plotAreaFrame setPaddingBottom:30.0f];
    //[graph.plotAreaFrame setPaddingTop:50.0f];
    graph.paddingLeft = 0;
    graph.paddingRight = 0;
    graph.paddingTop = 0;
    graph.paddingBottom = 0;
    graph.plotAreaFrame.borderWidth = 0;
    graph.plotAreaFrame.cornerRadius = 0;
	// 5 - Enable user interactions for plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
	// 1 - Get graph and plot space
	CPTGraph *graph = self.hostView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	// 2 - Create the three plots
	CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
	aaplPlot.dataSource = self;
	aaplPlot.identifier = @"123";
	CPTColor *aaplColor = [CPTColor redColor];
	[graph addPlot:aaplPlot toPlotSpace:plotSpace];
	// 3 - Set up plot space
	[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, nil]];
	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
	plotSpace.xRange = xRange;
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
	[yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
	plotSpace.yRange = yRange;
	// 4 - Create styles and symbols
	CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
	aaplLineStyle.lineWidth = 2.5;
	aaplLineStyle.lineColor = aaplColor;
	aaplPlot.dataLineStyle = aaplLineStyle;
	CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	aaplSymbolLineStyle.lineColor = aaplColor;
	CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
	aaplSymbol.lineStyle = aaplSymbolLineStyle;
	aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
	aaplPlot.plotSymbol = aaplSymbol;
}

-(void)configureAxes {
	// 1 - Create styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor whiteColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [CPTColor whiteColor];
	CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
	axisTextStyle.color = [CPTColor whiteColor];
	axisTextStyle.fontName = @"Helvetica-Bold";
	axisTextStyle.fontSize = 11.0f;
	CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor whiteColor];
	tickLineStyle.lineWidth = 2.0f;
	CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor blackColor];
	tickLineStyle.lineWidth = 1.0f;
	// 2 - Get axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
	// 3 - Configure x-axis
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(self.min-100);
	CPTAxis *x = axisSet.xAxis;
	x.title = @"";
    axisSet.xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
    axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:-29];
    x.titleTextStyle = axisTitleStyle;
	x.titleOffset = 15.0f;
	x.axisLineStyle = axisLineStyle;
	x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
	x.labelTextStyle = axisTextStyle;
	x.majorTickLineStyle = axisLineStyle;
	x.majorTickLength = 10.0f;
	x.tickDirection = CPTSignPositive;
	CGFloat dateCount = self.Values.count;
	NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
	NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
//	for (int i=0;i<self.Values.count;i++) {
//    // Configure X axis labels
//        
//                            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d",i]  textStyle:x.labelTextStyle];
//                            CGFloat location = i;
//                            label.tickLocation = CPTDecimalFromCGFloat(location);
//                            label.offset = x.majorTickLength;
//                            if (label) {
//                                [xLabels addObject:label];
//                                [xLocations addObject:[NSNumber numberWithFloat:location]];
//                            }
//
//	}
	x.axisLabels = xLabels;
	x.majorTickLocations = xLocations;
	// 4 - Configure y-axis
	CPTAxis *y = axisSet.yAxis;
	y.title = @"";
	y.titleTextStyle = axisTitleStyle;
	y.titleOffset = 200.0f;
	y.axisLineStyle = axisLineStyle;
	y.majorGridLineStyle = gridLineStyle;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
	y.labelTextStyle = axisTextStyle;
	y.labelOffset = -10.0f;
	y.majorTickLineStyle = axisLineStyle;
	y.majorTickLength = 4.0f;
	y.minorTickLength = 2.0f;
	y.tickDirection = CPTSignPositive;
	NSInteger majorIncrement = 400;
	NSInteger minorIncrement = 200;
    
    if (self.max < 100) {
        minorIncrement = 1;
        majorIncrement = 5;
    }
    else if (self.max < 1000)
    {
        minorIncrement = 5;
        majorIncrement = 10;
    }
    else if (self.max < 2000) {
        minorIncrement = 10;
        majorIncrement = 50;
    }
    else if (self.max < 10000)
    {
        minorIncrement = 50;
        majorIncrement = 100;
    }
    else if (self.max < 20000)
    {
        minorIncrement = 100;
        majorIncrement = 200;
    }
    
	CGFloat yMax = self.max;  // should determine dynamically based on max price
	NSMutableSet *yLabels = [NSMutableSet set];
	NSMutableSet *yMajorLocations = [NSMutableSet set];
	NSMutableSet *yMinorLocations = [NSMutableSet set];
	for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
		NSUInteger mod = j % majorIncrement;
        
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%li", (long)j] textStyle:y.labelTextStyle];
        NSDecimal location = CPTDecimalFromInteger(j);
        label.tickLocation = location;
        label.offset = -y.majorTickLength - y.labelOffset;
        if (label) {
            [yLabels addObject:label];
        }
        
		if (mod == 0)
        {
			[yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
		}
        else
        {
			[yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
		}
	}
	y.axisLabels = yLabels;
	y.majorTickLocations = yMajorLocations;
	y.minorTickLocations = yMinorLocations;
}

#pragma mark - Rotation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return self.Values.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	NSInteger valueCount = self.Values.count;
	switch (fieldEnum) {
		case CPTScatterPlotFieldX:
			if (index < valueCount) {
                
				return [NSNumber numberWithUnsignedInteger:index];
			}
			break;
			
		case CPTScatterPlotFieldY:
        {
            NSNumber* value = self.Values[index];
            if (!value) {
                value = @(0);
            }
            return value;
        }
			
            
			break;
	}
	return [NSDecimalNumber zero];
}

- (void) localizeTabBarItem
{
    self.tabBarItem.title = AMLocalizedString(@"GRAPH_TITLE", nil);
    if (self.tabBarController.selectedViewController == self) {
        self.tabBarController.navigationItem.title = AMLocalizedString(@"GRAPH_TITLE", nil);
    }
}
@end
