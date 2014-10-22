//
//  CarTableViewCell.m
//  OneRide
//
//  Created by Cory Levy on 8/3/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "CarTableViewCell.h"

@implementation CarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
	self.carNameLabel.textColor = kColorBlue;
	self.fareEstimateLabel.textColor = kColorGrayLight;
	self.timeEstimateLabel.textColor = kColorGrayLight;
	
	self.carNameLabel.font = [UIFont fontWithName:@"OpenSans" size:19];
	self.fareEstimateLabel.font = [UIFont fontWithName:@"OpenSans" size:13];
	self.timeEstimateLabel.font = [UIFont fontWithName:@"OpenSans" size:13];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
