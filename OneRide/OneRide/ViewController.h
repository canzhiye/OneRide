//
//  ViewController.h
//  OneRide
//
//  Created by Cory Levy on 8/2/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Car.h"
#import <Mapbox/Mapbox.h>
#import "CarTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NSData+Base64.h"
#import <CoreLocation/CoreLocation.h>
#import "DestinationViewController.h"
enum {
    kLyftRequest = 1,
    kSidecarRequest,
    kSummonRequest
} k;

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIToolbarDelegate, RMMapViewDelegate, UIAlertViewDelegate, DestinationViewControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSTimer *pingTimer;
@property (nonatomic, strong) RMMapView *mapView;
@property (nonatomic, strong) NSMutableArray *carsArray;
@property (nonatomic, assign) BOOL hasAssignedDestination;

@property (nonatomic, strong) NSString *destinationLat, *destinationLng;
@property (nonatomic, strong) NSString *userLat, *userLng;

@property (nonatomic, strong) NSString *uberToken;
@property (nonatomic, strong) NSString *uberRideID;

@property (nonatomic, strong) NSString *lyftToken;
@property (nonatomic, strong) NSString *lyftID;

@property (nonatomic, strong) NSMutableDictionary *cache;

@property (nonatomic, strong) IBOutlet UITableView *carsTableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedController;
@property (nonatomic, strong) IBOutlet UIToolbar *sortToolbar;
@property (nonatomic, strong) IBOutlet UIButton *requestButton;
@property (nonatomic, strong) IBOutlet UIView *destinationContainerView;
@property (nonatomic, strong) IBOutlet UILabel *destinationLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;

@property (nonatomic, strong) UIAlertView *workingAlert;

@property (nonatomic, strong) CLLocationManager *locationManager;

- (IBAction)sortThenReload;

@end
