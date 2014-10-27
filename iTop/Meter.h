//
//  Meter.h
//  iTop
//
//  Created by Bradley Slayter on 10/27/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Meter : UILabel {
	NSString *bracketL;
	NSString *green;
	NSString *yellow;
	NSString *red;
	NSString *bracketR;
	NSString *totalText;
}

@property (nonatomic, assign) float value;

-(void) updateBar;

@end
