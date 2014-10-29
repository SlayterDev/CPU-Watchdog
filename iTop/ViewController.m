//
//  ViewController.m
//  iTop
//
//  Created by Bradley Slayter on 10/27/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[SystemInfo standardInfo].delegate = self;
	[[SystemInfo standardInfo] beginTrackingCPU];
	
	CGSize scrSize = [[UIScreen mainScreen] bounds].size;
	
	meters = [NSMutableArray array];
	NSLog(@"NumCpus: %d", [[SystemInfo standardInfo] getNumCPUs]);
	for (int i = 0; i < [[SystemInfo standardInfo] getNumCPUs]+2; i++) {
		Meter *meter = [[Meter alloc] initWithFrame:CGRectMake(scrSize.width/2-320/2, 70*i+30, 320, 85)];
		meter.textAlignment = NSTextAlignmentCenter;
		
		float fontSize = 20.0;
		
		if (IS_IPHONE_5 || IS_IPHONE_4) {
			fontSize = 14.0;
		}
		
		meter.font = [UIFont fontWithName:@"Courier-Bold" size:fontSize];
		//[meters addObject:meter];
		[self.view addSubview:meter];
		
		int offset = 0;
		if (IS_IPHONE_5 || IS_IPHONE_4)
			offset = 20;
		
		UILabel *cpuLbl = [[UILabel alloc] initWithFrame:CGRectMake(meter.frame.origin.x + offset, meter.frame.origin.y, 100, 30)];
		cpuLbl.textColor = [UIColor whiteColor];
		
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
	}
	
	NSLog(@"Processes:\n%@", [[SystemInfo standardInfo] getProcesses]);
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
	[diskMeter updateBar];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
