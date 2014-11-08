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
	
	[SystemInfo standardInfo].delegate = self;
	[[SystemInfo standardInfo] beginTrackingCPU];
	
	self.preferredContentSize = CGSizeMake(0, 50*([[SystemInfo standardInfo] getNumCPUs]+2) + 18);
	
	meters = [NSMutableArray array];
	CGRect lastRect;
	for (int i = 0; i < [[SystemInfo standardInfo] getNumCPUs]+2; i++) {
		Meter *meter = [[Meter alloc] initWithFrame:CGRectMake(30, i*50+10, 320, 30)];
		meter.textAlignment = NSTextAlignmentRight;
		
		float fontSize = 18.0;
		
		if (IS_IPHONE_5 || IS_IPHONE_4) {
			fontSize = 12.0;
			
			CGRect newFrame = meter.frame;
			newFrame.origin.x -= 90;
			meter.frame = newFrame;
		} else if (IS_IPHONE_6) {
			fontSize = 16.0;
			
			CGRect newFrame = meter.frame;
			newFrame.origin.x -= 35;
			meter.frame = newFrame;
		}
		
		meter.font = [UIFont fontWithName:@"Courier-Bold" size:fontSize];
		[self.view addSubview:meter];
		
		UILabel *cpuLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, i*50+10, 70, 30)];
		cpuLbl.textColor = [UIColor whiteColor];
		
		if (IS_IPHONE_5 || IS_IPHONE_4) {
			cpuLbl.font = [UIFont systemFontOfSize:14];
		} else if (IS_IPHONE_6)
			cpuLbl.font = [UIFont systemFontOfSize:15];
		
		if (i < [[SystemInfo standardInfo] getNumCPUs]) {
			[meters addObject:meter];
			cpuLbl.text = [NSString stringWithFormat:@"CPU %d", i];
		} else if (i < [[SystemInfo standardInfo] getNumCPUs]+1) {
			ramMeter = meter;
			cpuLbl.text = [NSString stringWithFormat:@"RAM  "];
		} else {
			diskMeter = meter;
			cpuLbl.text = @"Disk ";
		}
		[self.view addSubview:cpuLbl];
		
		meter.value = 0.0f;
		[meter updateBar];
		
		if (i == [[SystemInfo standardInfo] getNumCPUs]+1)
			lastRect = meter.frame;
	}
	
	uptimeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, lastRect.origin.y+30, 320, 30)];
	NSCalendar *c = [NSCalendar currentCalendar];
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	NSDateComponents* components = [c components:(NSYearCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:[[SystemInfo standardInfo] uptime] toDate:[NSDate date] options:0] ;
#pragma clang diagnostic pop
	NSLog(@"%ld years, %ld days, %ld hours, %ld minutes, %ld seconds",  (long)components.year, (long)components.day,(long)components.hour, (long)components.minute, (long)components.second);
	
	
	uptimeLbl.text = [NSString stringWithFormat:@"Uptime %ld days, %ld hours, %ld minutes, %ld seconds", (long)components.day, (long)components.hour, (long)components.minute, (long)components.second];
	uptimeLbl.textAlignment = NSTextAlignmentCenter;
	
	float upFontSize = 12.0;
	if (IS_IPHONE_5 || IS_IPHONE_4) {
		upFontSize = 11.0;
		uptimeLbl.textAlignment = NSTextAlignmentLeft;
	}
	
	uptimeLbl.font = [UIFont systemFontOfSize:upFontSize];
	uptimeLbl.textColor = [UIColor whiteColor];
	[self.view addSubview:uptimeLbl];
}

-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[SystemInfo standardInfo] stopTimer];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
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
	
	ramMeter.value = ([[SystemInfo standardInfo] totalMemory] - [[SystemInfo standardInfo] freeMemory]) / [[SystemInfo standardInfo] totalMemory];
	[ramMeter updateBar];
	
	NSDictionary *diskInfo = [[SystemInfo standardInfo] getDiskInfo];
	
	if (!diskInfo) {
		NSLog(@"Unable to get disk sizes");
	}
	
	NSNumber *total = diskInfo[@"TotalBytes"];
	NSNumber *free = diskInfo[@"FreeBytes"];
	unsigned long long usedSpace = total.unsignedLongLongValue - free.unsignedLongLongValue;
	int usedInt = (int)(usedSpace/1024/1024);
	int totalInt = (int)(total.unsignedLongLongValue/1024/1024);
	float newVal = (float)usedInt/totalInt;
	diskMeter.value = newVal;
	
	
	if (newVal < 0)
		newVal = 0.15;
	
	[diskMeter updateBar];
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
