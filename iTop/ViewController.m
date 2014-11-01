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
	
	
	CGRect lastRect;
	CGRect firstRect;
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
			
			if (i == 0)
				firstRect = meter.frame;
		} else if (i < [[SystemInfo standardInfo] getNumCPUs]+1) {
			ramMeter = meter;
			cpuLbl.text = [NSString stringWithFormat:@"RAM  "];
		} else {
			diskMeter = meter;
			cpuLbl.text = @"Disk ";
			lastRect = diskMeter.frame;
		}
		
		meter.value = 0.0;
		[meter updateBar];
		
		[self.view addSubview:cpuLbl];
	}
	
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	infoButton.frame = CGRectMake(7.5, firstRect.origin.y, 30, 30);
	infoButton.tintColor = [UIColor whiteColor];
	[infoButton addTarget:self action:@selector(infoButtn:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:infoButton];
	
	NSLog(@"Processes:\n%@", [[SystemInfo standardInfo] getProcesses]);
	processes = [[SystemInfo standardInfo] getProcesses];
	processes = [self reverseArray:[processes mutableCopy]];
	
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, lastRect.origin.y+80, scrSize.width+20, scrSize.height-(lastRect.origin.y+40)) style:UITableViewStyleGrouped];
	tableView.dataSource = self;
	tableView.delegate = self;
	[tableView setSeparatorColor:[UIColor blackColor]];
	[tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	tableView.contentInset = UIEdgeInsetsMake(0, -20, 0, 0);
	tableView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:tableView];
	[tableView reloadData];
	[self getIcons];
	
	[self informAboutWidget];
}

-(void) infoButtn:(id)sender {
	AboutController *conroller = [[AboutController alloc] initWithStyle:UITableViewStyleGrouped];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:conroller];
	[self presentViewController:nav animated:YES completion:nil];
}

-(void) informAboutWidget {
	NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
	if (![[userPrefs objectForKey:@"GotIt"] boolValue]) {
		[[[UIAlertView alloc] initWithTitle:@"Welcome" message:@"\"CPU Watchdog\" includes a handy widget to track system health right from the Notification Center! Just swipe down to add it!" delegate:self cancelButtonTitle:@"Don't show again" otherButtonTitles:@"Dismiss", nil] show];
	}
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.cancelButtonIndex) {
		NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
		[userPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"GotIt"];
		[userPrefs synchronize];
	}
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restart) name:UIApplicationDidBecomeActiveNotification object:nil];
	
}

-(void) restart {
	[[SystemInfo standardInfo] beginTrackingCPU];
	NSLog(@"Processes:\n%@", [[SystemInfo standardInfo] getProcesses]);
	processes = [[SystemInfo standardInfo] getProcesses];
	processes = [self reverseArray:[processes mutableCopy]];
	[tableView reloadData];
	[self getIcons];
}

-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[SystemInfo standardInfo] stopTimer];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIApplicationDidBecomeActiveNotification
												  object:nil];
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

#pragma mark - TableView Stuff

-(NSMutableArray *) reverseArray:(NSMutableArray *)array {
	int i = 0;
	int j = (int)array.count - 1;
	while (i < j) {
		[array exchangeObjectAtIndex:i withObjectAtIndex:j];
		i++;
		j--;
	}
	
	return array;
}

-(void) getIcons {
	iconCount = 0;
	for (NSMutableDictionary *dict in processes) {
		NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&country=us&entity=software", dict[@"ProcessName"]];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			//code executed in the background
			//2
			NSData* kivaData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
			//3
			NSDictionary* json = nil;
			if (kivaData) {
				json = [NSJSONSerialization JSONObjectWithData:kivaData options:kNilOptions error:nil];
				//NSLog(@"Response: %@", json);
			}
			
			//4
			dispatch_async(dispatch_get_main_queue(), ^{
				//code executed on the main queue
				//5
				if (!icons) {
					icons = [NSMutableArray arrayWithCapacity:processes.count];
					
					for (int i = 0; i < processes.count; i++)
						[icons addObject:@""];
				}
				if ([json[@"results"] count])
					[dict setObject:json[@"results"][0][@"artworkUrl512"] forKey:@"iconURL"];
				
				
				iconCount++;
				if (iconCount == processes.count)
					[tableView reloadData];
			});
			
		});
	}
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
	// Background color
	view.tintColor = [UIColor blackColor];
	
	// Text Color
	UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
	[header.textLabel setTextColor:[UIColor whiteColor]];
	
	// Another way to set the background color
	// Note: does not preserve gradient effect of original header
	// header.contentView.backgroundColor = [UIColor blackColor];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"       Apps Currently Running";
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return processes.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 55.0;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	[cell.contentView setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:92.0/255.0 blue:98.0/255.0 alpha:1.0]];
	[cell setLayoutMargins:UIEdgeInsetsZero];
	
	//[cell setBackgroundColor:[UIColor colorWithRed:34.9f green:36.1f blue:38.4f alpha:1.0]];
	//[cell.backgroundView setBackgroundColor:[UIColor colorWithRed:34.9f green:36.1f blue:38.4f alpha:1.0]];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	CustomCell *cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	
	cell.textLabel.text = [[processes objectAtIndex:indexPath.row] objectForKey:@"ProcessName"];
	cell.textLabel.textColor = [UIColor whiteColor];
	
	cell.imageView.contentMode = UIViewContentModeScaleToFill;
	cell.imageView.layer.masksToBounds = YES;
	cell.imageView.layer.cornerRadius = 10.0;
	
	//[cell setBackgroundColor:[UIColor colorWithRed:34.9 green:36.1 blue:38.4 alpha:1.0]];
	
	if ([[processes objectAtIndex:indexPath.row] objectForKey:@"iconURL"]) {
		[cell.imageView setImageWithURL:[NSURL URLWithString:[[processes objectAtIndex:indexPath.row] objectForKey:@"iconURL"]] placeholderImage:[UIImage imageNamed:@"iphone-128.png"]];
		
		[[processes objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:YES] forKey:@"imageSet"];
	} else {
		cell.imageView.image = [UIImage imageNamed:@"iphone-128.png"];
	}
	
	return cell;
}

@end
