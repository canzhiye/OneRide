//
//  CarTableViewCell.h
//  OneRide
//
//  Created by Cory Levy on 8/3/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *carNameLabel, *timeEstimateLabel, *fareEstimateLabel;
@property (nonatomic, strong) IBOutlet UIImageView *serviceLogo;
@end
