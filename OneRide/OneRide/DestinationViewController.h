//
//  DestinationViewController.h
//  OneRide
//
//  Created by Cory Levy on 8/3/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DestinationViewControllerDelegate;

@interface DestinationViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISearchBar *placesSearchBar;
@property (nonatomic, strong) NSMutableArray *searchResultsArray;
@property (nonatomic, strong) NSTimer *searchTimer;

@property (nonatomic, strong) NSString *userLat, *userLng;

@property (nonatomic, weak) id <DestinationViewControllerDelegate>delegate;

- (IBAction)close:(id)sender;

@end

@protocol DestinationViewControllerDelegate <NSObject>

- (void)setDestination:(NSString *)name
			   address:(NSString *)address
				   lat:(NSString*)lat
				   lng:(NSString*)lng;

@end


