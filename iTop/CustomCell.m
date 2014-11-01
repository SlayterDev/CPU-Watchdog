//
//  CustomCell.m
//  CPU Watchdog
//
//  Created by Bradley Slayter on 10/31/14.
//  Copyright (c) 2014 Flipped Bit. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.imageView.bounds = CGRectMake(0,0,40,40);
	self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x - 10, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
