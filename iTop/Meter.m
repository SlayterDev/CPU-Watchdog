//
//  Meter.m
//  iTop
//
//  Created by Bradley Slayter on 10/27/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import "Meter.h"

@implementation Meter

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		
		bracketL = @"[";
		green = @"||||||||||||";
		yellow = @"||||||";
		red = @"||";
		bracketR = @"]";
		totalText = [NSString stringWithFormat:@"%@%@%@%@%@ 100\%%", bracketL, green, yellow, red, bracketR];
		
		NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:totalText attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
		
		[attrStr setAttributes:@{NSForegroundColorAttributeName : [UIColor greenColor]} range:[totalText rangeOfString:green]];
		[attrStr setAttributes:@{NSForegroundColorAttributeName : [UIColor yellowColor]} range:NSMakeRange(13, 6)];
		[attrStr setAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} range:NSMakeRange(19, 2)];
		[attrStr setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]], NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(23, totalText.length-23)];
		self.attributedText = attrStr;
		
	}
	return self;
}

-(void) updateBar {
	int numBars = 20 * self.value;
	
	if (!numBars)
		numBars++;
	
	NSString *string = @"[";
	for (int i = 0; i < 20; i++) {
		if (i < numBars)
			string = [string stringByAppendingString:@"|"];
		else
			string = [string stringByAppendingString:@" "];
	}
	string = [string stringByAppendingString:[NSString stringWithFormat:@"] %3.0f\%%", self.value*100]];
	
	NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	
	[attrStr setAttributes:@{NSForegroundColorAttributeName : [UIColor greenColor]} range:[totalText rangeOfString:green]];
	[attrStr setAttributes:@{NSForegroundColorAttributeName : [UIColor yellowColor]} range:NSMakeRange(13, 6)];
	[attrStr setAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} range:NSMakeRange(19, 2)];
	[attrStr setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]], NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(23, string.length-23)];
	
	self.attributedText = attrStr;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
