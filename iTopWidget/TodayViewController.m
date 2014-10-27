//
//  TodayViewController.m
//  iTopWidget
//
//  Created by Bradley Slayter on 10/27/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	NSLog(@"Hello world");
	[SystemInfo standardInfo].delegate = self;
	[[SystemInfo standardInfo] beginTrackingCPU];
	
	self.preferredContentSize = CGSizeMake(0, 50*[[SystemInfo standardInfo] getNumCPUs]);
	
	meters = [NSMutableArray array];
	for (int i = 0; i < [[SystemInfo standardInfo] getNumCPUs]; i++) {
		Meter *meter = [[Meter alloc] initWithFrame:CGRectMake(30, i*50+10, 320, 30)];
		meter.textAlignment = NSTextAlignmentRight;
		meter.font = [UIFont fontWithName:@"Courier-Bold" size:18];
		[meters addObject:meter];
		[self.view addSubview:meter];
		
		UILabel *cpuLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, i*50+10, 70, 30)];
		cpuLbl.textColor = [UIColor whiteColor];
		cpuLbl.text = [NSString stringWithFormat:@"CPU %d", i];
		[self.view addSubview:cpuLbl];
	}
}

-(void) viewDidDisappear:(BOOL)animated {
	[[SystemInfo standardInfo] stopTimer];
}

-(void) viewWillAppear:(BOOL)animated {
	[[SystemInfo standardInfo] beginTrackingCPU];
}

-(void) systemInfo:(SystemInfo *)sysinfo didUpdateCPU:(NSArray *)usages {
	if (!meters)
		return;
	
	for (int i = 0; i < meters.count; i++) {
		Meter *meter = meters[i];
		meter.value = [usages[i] floatValue];
		[meter updateBar];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
