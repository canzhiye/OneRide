//
//  SettingsViewController.h
//  OneRide
//
//  Created by Cory Levy on 8/2/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction)close:(id)sender;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
