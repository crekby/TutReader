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

@property (nonatomic, assign) NSNumber* max;

@end

@implementation GraphController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void) OrientationDidChangeNotification:(NSNotification*) notification
{
    self.hostView.frame = self.view.frame;
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.data = [NSMutableDictionary new];
    self.max = 0;
    
    for (TUTNews* newsItem in [[DataProvider instance] news]) {
        NSDate *date = newsItem.pubDate;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        NSInteger hour = [components hour];
        NSNumber* value = [self.data objectForKey:[NSString stringWithFormat:@"%d",hour]];
        if (value) {
            value = @(value.intValue+1);
        }
        else
        {
            value = @(1);
        }
        
        if (value.integerValue > self.max.integerValue) {
            self.max = @(value.integerValue);
        }
        
        [self.data setValue:value forKey:[NSString stringWithFormat:@"%d",hour]];
    }
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
	NSString *title = @"News Added By Hour";
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
	[graph.plotAreaFrame setPaddingBottom:30.0f];
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
	CPTAxis *x = axisSet.xAxis;
	x.title = @"Hours";
	x.titleTextStyle = axisTitleStyle;
	x.titleOffset = 15.0f;
	x.axisLineStyle = axisLineStyle;
	x.labelingPolicy = CPTAxisLabelingPolicyNone;
	x.labelTextStyle = axisTextStyle;
	x.majorTickLineStyle = axisLineStyle;
	x.majorTickLength = 4.0f;
	x.tickDirection = CPTSignNegative;
	CGFloat dateCount = 10;
	NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
	NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
	for (int i=0;i<24;i++) {
        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
            if (i % 2 == 0) {
                CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d",i]  textStyle:x.labelTextStyle];
                CGFloat location = i;
                label.tickLocation = CPTDecimalFromCGFloat(location);
                label.offset = x.majorTickLength;
                if (label) {
                    [xLabels addObject:label];
                    [xLocations addObject:[NSNumber numberWithFloat:location]];
                }
            }
        }
        else
        {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d",i]  textStyle:x.labelTextStyle];
            CGFloat location = i;
            label.tickLocation = CPTDecimalFromCGFloat(location);
            label.offset = x.majorTickLength;
            if (label) {
                [xLabels addObject:label];
                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }
        }
	}
	x.axisLabels = xLabels;
	x.majorTickLocations = xLocations;
	// 4 - Configure y-axis
	CPTAxis *y = axisSet.yAxis;
	y.title = @"News";
	y.titleTextStyle = axisTitleStyle;
	y.titleOffset = -40.0f;
	y.axisLineStyle = axisLineStyle;
	y.majorGridLineStyle = gridLineStyle;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
	y.labelTextStyle = axisTextStyle;
	y.labelOffset = 16.0f;
	y.majorTickLineStyle = axisLineStyle;
	y.majorTickLength = 4.0f;
	y.minorTickLength = 2.0f;
	y.tickDirection = CPTSignPositive;
	NSInteger majorIncrement = 5;
	NSInteger minorIncrement = 1;
	CGFloat yMax = self.max.floatValue;  // should determine dynamically based on max price
	NSMutableSet *yLabels = [NSMutableSet set];
	NSMutableSet *yMajorLocations = [NSMutableSet set];
	NSMutableSet *yMinorLocations = [NSMutableSet set];
	for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
		NSUInteger mod = j % majorIncrement;
		if (mod == 0) {
			CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
			NSDecimal location = CPTDecimalFromInteger(j);
			label.tickLocation = location;
			label.offset = -y.majorTickLength - y.labelOffset;
			if (label) {
				[yLabels addObject:label];
			}
			[yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
		} else {
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
	return 24;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	NSInteger valueCount = 24;
	switch (fieldEnum) {
		case CPTScatterPlotFieldX:
			if (index < valueCount) {
                
				return [NSNumber numberWithUnsignedInteger:index];
			}
			break;
			
		case CPTScatterPlotFieldY:
        {
            NSNumber* value = [self.data objectForKey:[NSString stringWithFormat:@"%d",index]];
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
    self.tabBarItem.title = @"Graph";
}
@end
