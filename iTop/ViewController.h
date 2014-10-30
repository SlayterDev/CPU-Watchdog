//
//  ViewController.h
//  iTop
//
//  Created by Bradley Slayter on 10/27/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SystemInfo.h"
#import "Meter.h"
#import "UIImageView+AFNetworking.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6PLUS (IS_IPHONE && [[UIScreen mainScreen] nativeScale] == 3.0)

@interface ViewController : UIViewController <SystemInfoDelegate, UITableViewDataSource, UITableViewDelegate> {
	NSMutableArray *meters;
	Meter *ramMeter;
	Meter *diskMeter;
	
	NSArray *processes;
	UITableView *tableView;
	
	NSMutableArray *icons;
	int iconCount;
}


@end

