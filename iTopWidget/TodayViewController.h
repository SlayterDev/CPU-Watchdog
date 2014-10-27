//
//  TodayViewController.h
//  iTopWidget
//
//  Created by Bradley Slayter on 10/27/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meter.h"
#import "SystemInfo.h"


@interface TodayViewController : UIViewController <SystemInfoDelegate> {
	NSMutableArray *meters;
	NSDateFormatter *formatter;
	UILabel *uptimeLbl;
}

@end
