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
	for (int i = 0; i < [[SystemInfo standardInfo] getNumCPUs]; i++) {
		Meter *meter = [[Meter alloc] initWithFrame:CGRectMake(scrSize.width/2-320/2, 70*i+30, 320, 85)];
		//meter.center = self.view.center;
		meter.textAlignment = NSTextAlignmentCenter;
		meter.font = [UIFont fontWithName:@"Courier-Bold" size:20];
		[meters addObject:meter];
		[self.view addSubview:meter];
		
		UILabel *cpuLbl = [[UILabel alloc] initWithFrame:CGRectMake(meter.frame.origin.x, meter.frame.origin.y, 100, 30)];
		cpuLbl.textColor = [UIColor whiteColor];
		cpuLbl.text = [NSString stringWithFormat:@"CPU %d", i];
		[self.view addSubview:cpuLbl];
	}
	
	UILabel *ramSize = [[UILabel alloc] initWithFrame:CGRectMake(scrSize.width/2-320/2, scrSize.height - 75, 320, 50)];
	ramSize.text = [NSString stringWithFormat:@"Remaining Ram: %.0fMB/%.0fMB", [[SystemInfo standardInfo] freeMemory], [[SystemInfo standardInfo] totalMemory]];
	ramSize.textColor = [UIColor whiteColor];
	[self.view addSubview:ramSize];
	
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
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
