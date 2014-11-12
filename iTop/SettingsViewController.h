//
//  SettingsViewController.h
//  CPU Watchdog
//
//  Created by Bradley Slayter on 11/12/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meter.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6PLUS (IS_IPHONE && [[UIScreen mainScreen] nativeScale] == 3.0)

@interface SettingsViewController : UIViewController {
	Meter *meter;
}

@end
