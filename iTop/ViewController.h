//
//  ViewController.h
//  iTop
//
//  Created by Bradley Slayter on 10/27/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemInfo.h"
#import "Meter.h"

@interface ViewController : UIViewController <SystemInfoDelegate> {
	NSMutableArray *meters;
}


@end

