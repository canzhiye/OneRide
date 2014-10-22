//
//  ViewController.m
//  OneRide
//
//  Created by Cory Levy on 8/2/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "ViewController.h"
#import "API.h"
#import "LoginViewController.h"

@interface ViewController ()

@end

@implementation UINavigationBar (CustomBar)

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
	
    if ([subview isKindOfClass:[UIImageView class]]) {
        [subview setClipsToBounds:YES];
    }
}

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];

    _cache = [[NSMutableDictionary alloc] init];
    
    self.carsTableView.separatorInset = UIEdgeInsetsZero;
    
    self.hasAssignedDestination = NO;
    self.destinationContainerView.alpha = 0.0;
    self.destinationLat = @"";
    self.destinationLng = @"";
    self.requestButton.backgroundColor = kColorBlue;
    self.requestButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:17];
    
    self.addressLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:13];
    self.destinationLabel.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:15];
    self.addressLabel.textColor = kColorGray;
    self.destinationLabel.textColor = kColorGray;
    
    self.carsArray = [[NSMutableArray alloc] init];
    
    RMMapboxSource *source = [[RMMapboxSource alloc] initWithMapID:kMapId];
    self.mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 505) andTilesource:source];
    
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake([self.userLat floatValue], [self.userLng floatValue]);
    self.mapView.zoom = 16;
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
    self.carsTableView.tableHeaderView = self.mapView;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.mapView.frame.size.width/2)-19, (self.mapView.frame.size.height/2)-54, 38, 54)];
    imageView.image = [UIImage imageNamed:@"icon_pin"];
    imageView.tag = 100;
    
    [self.mapView addSubview:imageView];
    [self.mapView setShowsUserLocation:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAuth:) name:@"updateAuth" object:nil];
    
    self.userLat = [NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.latitude];
    self.userLng = [NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.longitude];
    
    if (![API loggedIn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"login" sender:self];
        });
    } else {
        self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(ping) userInfo:nil repeats:YES];
        [self ping];
    }
}
-(void)updateAuth:(NSNotification*)n {
    NSDictionary *authDict = n.object;
    self.uberToken = authDict[@"uber_token"];
    self.lyftToken = authDict[@"lyft_token"];
    self.lyftID = authDict[@"lyft_id"];
    
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(ping) userInfo:nil repeats:YES];
    [self ping];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"locations: %@",locations);
    CLLocation *location = [locations firstObject];
    self.userLat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    self.userLng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake([self.userLat floatValue], [self.userLng floatValue]);
    
    [manager stopUpdatingLocation];
}
#pragma mark - UITableView
#pragma mark Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.carsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CarTableViewCell *cell = (CarTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CarCell"];
    if (!cell)
		cell = [[CarTableViewCell alloc] init];
	
	Car *car = self.carsArray[indexPath.row];
    cell.carNameLabel.text = car.name;
	cell.fareEstimateLabel.text = [NSString stringWithFormat:@"Around $%d",[car.fareEstimate intValue]];
    cell.timeEstimateLabel.text = [NSString stringWithFormat:@"About %d mins", (int)([car.eta intValue] / 60)];
    
    if (self.hasAssignedDestination) {
        
    } else {
        cell.fareEstimateLabel.text = @"Please choose a destination!";
    }
    
    //display proper image
    if ([car.service isEqualToString:@"lyft"]) {
		cell.serviceLogo.image = [UIImage imageNamed:@"cell_icon_lyft"];
    } else if ([car.service isEqualToString:@"sidecar"]) {
		cell.serviceLogo.image = [UIImage imageNamed:@"cell_icon_sidecar"];
    } else if ([car.service isEqualToString:@"summon"]) {
		cell.serviceLogo.image = [UIImage imageNamed:@"cell_icon_summon"];
    } else if ([car.service isEqualToString:@"uber"]) {
		cell.serviceLogo.image = [UIImage imageNamed:@"cell_icon_uber"];
	}
    
    return cell;
}

#pragma mark Delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//request proper car
    if (self.hasAssignedDestination) {
        Car *car = self.carsArray[indexPath.row];
        
        //make proper request
        NSString *message;
        if ([car.service isEqualToString:@"uber"]) {
            message = @"Are you sure you want to request this Uber?";
        } else if ([car.service isEqualToString:@"lyft"]) {
            message = @"Are you sure you want to request this Lyft?";
        } else if ([car.service isEqualToString:@"sidecar"]) {
            message = @"Are you sure you want to request this Sidecar?";
        } else if ([car.service isEqualToString:@"summon"]) {
            message = @"Are you sure you want to request this Summon?";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride Request!" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        if ([car.service isEqualToString:@"uber"]) {
            alert.tag = kUberRequestTag;
            self.uberRideID = car.carID;
        } else if ([car.service isEqualToString:@"lyft"]) {
            alert.tag = kLyftRequestTag;
        } else if ([car.service isEqualToString:@"sidecar"]) {
            alert.tag = kSidecarRequestTag;
        } else if ([car.service isEqualToString:@"summon"]) {
            alert.tag = kSummonRequestTag;
        }
        
        [alert show];
    }
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        //NO
        NSLog(@"");
    } else if (buttonIndex == 1) {
        //YES
        switch (alertView.tag) {
            case kUberRequestTag:
                [API requestRideFromService:@"uber" lat:self.userLat lng:self.userLng uberToken:self.uberToken uberRideID:self.uberRideID lyftToken:nil sidecarUsername:nil sidecarPassword:nil summonEmail:nil summonPassword:nil success:^(NSDictionary *output) {
                    NSLog(@"UBER REQUESTED: %@",output);
                } error:^(NSError *error) {
                    NSLog(@"ERROR REQUESTING UBER: %@",error);
                }];
                break;
            case kLyftRequestTag:
                [API requestRideFromService:@"lyft" lat:self.userLat lng:self.userLng uberToken:nil uberRideID:nil lyftToken:self.lyftToken sidecarUsername:nil sidecarPassword:nil summonEmail:nil summonPassword:nil success:^(NSDictionary *output) {
                    NSLog(@"LYFT REQUESTED: %@",output);
                } error:^(NSError *error) {
                    NSLog(@"ERROR REQUESTING LYFT: %@",error);
                }];
                break;
            case kSidecarRequestTag: {
                UIApplication *app = [UIApplication sharedApplication];
                NSString *path = @"sidecar://";
                NSURL *url = [NSURL URLWithString:path];
                [app openURL:url];
            }
                break;
            case kSummonRequestTag:
                
                break;
                
            default:
                break;
        }
    }
    
    
    if (alertView.tag == 0) {
//        [API requestLyftWithLat:self.userLat lng:self.userLng lyftToke:kLyftToken success:^(NSString *rideID) {
//            //
//            _workingAlert = [[UIAlertView alloc] initWithTitle:@"Lyft" message:@"Working on your Lyft request." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//            self.workingAlert.tag = 100;
//            [self.workingAlert show];
//            
//            [[NSUserDefaults standardUserDefaults] setObject:rideID forKey:@"lyft_ride_id"];
//            
//        } error:^(NSError *error) {
//            //
//        }];
        
    } else if (alertView.tag == 1) {
        
    } else if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            // YES
//            [API requestSummonWithLat:self.userLat lng:self.userLng success:^(NSString *requestID) {
//                //
//                UIAlertView *workingAlert = [[UIAlertView alloc] initWithTitle:@"Summon" message:@"Working on your Summon request." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
//                workingAlert.tag = 100;
//                [workingAlert show];
//                
//                [[NSUserDefaults standardUserDefaults] setObject:requestID forKey:@"summon_ride_id"];
//                
//            } error:^(NSError *error) {
//                //
//            }];
            
        } else if (buttonIndex == 1) {
            // NO
        }
    } else if (alertView.tag == 100) {
        //Cancel request!!!
        if ([alertView.title isEqualToString:@"Lyft"]) {
            NSString *rideID = [[NSUserDefaults standardUserDefaults] objectForKey:@"lyft_ride_id"];
//            [API cancelLyft:@"lyft" lyftToken:kLyftToken rideID:rideID lat:self.userLat lng:self.userLng success:^{
//                //success
//            } error:^(NSError *error) {
//                
//            }];
            
        } else if ([alertView.title isEqualToString:@"Sidecar"]) {
            
        } else if ([alertView.title isEqualToString:@"Summon"]) {
            NSString *rideID = [[NSUserDefaults standardUserDefaults] objectForKey:@"summon_ride_id"];
            
            [API cancelSummon:@"summon" email:@"canzhiye@gmail.com" password:@"password" rideID:rideID success:^{
                //
            } error:^(NSError *error) {
                //
            }];
        }
    }
    
}
#pragma mark - UIToolBar

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
	return UIBarPositionTop;
}

#pragma mark - API

- (void)ping {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (self.hasAssignedDestination) {
        self.carsTableView.scrollEnabled = YES;
    } else {
        self.carsTableView.scrollEnabled = NO;
    }
    
    [API pingWithLat:self.userLat andLng:self.userLng destLat:self.destinationLat destLng:self.destinationLng uberToken:self.uberToken lyftToken:self.lyftToken lyftID:self.lyftID sidecarID:kSidecarID sidecarPassword:kSidecarPassword success:^(NSDictionary *output) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        self.carsArray = [[NSMutableArray alloc] init];
        NSMutableArray *annotationsArray = [[NSMutableArray alloc]init];
        
        [self.mapView removeAllAnnotations];
        
        NSArray *ridesArray = output[@"rides"];
        
        for (int i = 0; i < ridesArray.count; i++) {
            NSString *accepted = ridesArray[i][@"status"];
            NSLog(@"accepted? %@",accepted);
            if ([accepted isEqualToString:@"accepted"]) {
                [self.workingAlert dismissWithClickedButtonIndex:-1 animated:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Success! #fuckitshipit" delegate:nil cancelButtonTitle:@"#hellllyeah" otherButtonTitles:nil];
                [alert show];
            }

            CLLocationDegrees lat = [ridesArray[i][@"lat"] doubleValue];
            CLLocationDegrees lng = [ridesArray[i][@"lng"] doubleValue];
            NSString* title = ridesArray[i][@"which"];
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lng);
            RMAnnotation *annotation = [[RMAnnotation alloc]initWithMapView:self.mapView coordinate:coordinate andTitle:title];
            [annotationsArray addObject:annotation];
            
            Car *car = [[Car alloc]initWithDictionary:ridesArray[i]];
            if ([car.eta length] == 0 || [car.fareEstimate length] == 0) {
                NSString *key = [NSString stringWithFormat:@"%@-%@",car.service,car.carID];
                
                if ([[self.cache allKeys] containsObject:key]) {
                    
                    // Cached
                    NSDictionary *cachedInfo = [self.cache objectForKey:key];
                    car.eta = [cachedInfo objectForKey:@"eta"];
                    car.fareEstimate = [cachedInfo objectForKey:@"fare"];
                    
                } else {
                    // Not cached
                    if ([self.destinationLat length] > 0 && [self.destinationLng length] > 0) {
                        
                        //Calculate the price depending on the car service
                        float minFee;
                        float pickupFee;
                        float perMileFee;
                        float perMinFee;
                        
                        NSDictionary *pricing = ridesArray[i][@"pricing"];

                        if ([car.service isEqualToString:@"uber"]) {
                            minFee = [[pricing[@"minimum"] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
                            pickupFee = [[pricing[@"base"] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
                            perMileFee = [[pricing[@"perDistanceUnit"] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
                            perMinFee = [[pricing[@"perMinute"] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
                        } else if ([car.service isEqualToString:@"lyft"]) {
                            minFee = [[pricing[@"minimum"] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
                            pickupFee = [[pricing[@"pickup"] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
                            perMileFee = [[pricing[@"perMile"] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
                            perMinFee = [[pricing[@"perMinute"] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
                        }
                        
                        [API calculateRideInfoFrom:[NSString stringWithFormat:@"%@,%@", car.lat, car.lng]
                                    toUserLocation:[NSString stringWithFormat:@"%@,%@", self.userLat, self.userLng]
                                     toDestination:[NSString stringWithFormat:@"%@,%@",self.destinationLat, self.destinationLng]
                                        withMinFee:minFee
                                      andPickupFee:pickupFee
                                     andFeePerMile:perMileFee
                                      andFeePerMin:perMinFee
                                           success:^(NSString *eta, NSString *fareEst) {
                                               
                                               [self.cache setObject:@{
                                                                       @"eta" : eta,
                                                                       @"fare" : fareEst
                                                                       }
                                                              forKey:key
                                                ];
                                               car.eta = eta;
                                               car.fareEstimate = fareEst;
                                               [self sortThenReload];
                                               
                                           }
                                             error:nil
                         ];
                        
                    }
                }
            }
            
            [self.carsArray addObject:car];
        }
        
        [self sortThenReload];
        [self.mapView addAnnotations:annotationsArray];
    } error:^(NSError *error) {
        NSLog(@"ERROR: %@",error);
    }];
}

- (IBAction)sortThenReload
{
	if (self.segmentedController.selectedSegmentIndex == 0) {
		
		// Order by eta
		[self.carsArray sortUsingComparator:^NSComparisonResult(Car *a, Car *b) {
			return [a.eta floatValue] >= [b.eta floatValue];
		}];
		
	} else {
		
		// Order by price
		[self.carsArray sortUsingComparator:^NSComparisonResult(Car *a, Car *b) {
			return [a.fareEstimate floatValue] >= [b.fareEstimate floatValue];
		}];
		
	}
	
	[self.carsTableView reloadData];
}

#pragma mark - MapBox

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    RMMarker *marker = nil;
    if ([annotation.title isEqualToString:@"lyft"]) {
        marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"icon_car_lyft"]];
    } else if ([annotation.title isEqualToString:@"sidecar"]) {
        marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"icon_car_sidecar"]];
    } else if ([annotation.title isEqualToString:@"summon"]) {
        marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"icon_summon"]];
    } else if ([annotation.title isEqualToString:@"uber"]) {
        marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"icon_car_uber"]];
    } else {
        //marker = [[RMMarker alloc]initWithUIImage:[UIImage imageNamed:@"icon_pin"]];
    }
    return marker;
}
- (void)mapView:(RMMapView *)mapView didUpdateUserLocation:(RMUserLocation *)userLocation
{
    self.userLat = [NSString stringWithFormat:@"%f",mapView.centerCoordinate.latitude];
    self.userLng = [NSString stringWithFormat:@"%f",mapView.centerCoordinate.longitude];
    
    NSLog(@"lat: %@ lng: %@", self.userLat, self.userLng);
}
- (void)mapViewRegionDidChange:(RMMapView *)mapView {
    self.userLat = [NSString stringWithFormat:@"%f",mapView.centerCoordinate.latitude];
    self.userLng = [NSString stringWithFormat:@"%f",mapView.centerCoordinate.longitude];
    
    NSLog(@"lat: %@ lng: %@", self.userLat, self.userLng);
}


#pragma mark - Set destination

- (void)setDestination:(NSString *)name
			   address:(NSString *)address
				   lat:(NSString *)lat
				   lng:(NSString *)lng
{
    self.hasAssignedDestination = YES;
    
    self.destinationLat = [NSString stringWithFormat:@"%@",lat];
    self.destinationLng = [NSString stringWithFormat:@"%@",lng];
    
    if (self.hasAssignedDestination) {
        self.carsTableView.scrollEnabled = YES;
    } else {
        self.carsTableView.scrollEnabled = NO;
    }
	
	self.carsTableView.contentInset = UIEdgeInsetsMake(64+40, 0, 0, 0);
	self.carsTableView.scrollIndicatorInsets = self.carsTableView.contentInset;
	self.sortToolbar.alpha = 1.0f;
	
	self.requestButton.alpha = 0.0;
    self.destinationContainerView.alpha = 1.0;
	
    self.destinationLabel.text = name;
    self.addressLabel.text = address;
	
	self.carsTableView.contentOffset = CGPointMake(1, -64-40);
	self.mapView.frame = CGRectMake(0, 0, 320, 150);
	self.carsTableView.tableHeaderView = self.mapView;
    
    UIImageView *iv = (UIImageView*)[self.mapView viewWithTag:100];
    [iv removeFromSuperview];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.mapView.frame.size.width/2)-19, (self.mapView.frame.size.height/2)-54, 38, 54)];
    imageView.image = [UIImage imageNamed:@"icon_pin"];
    [self.mapView addSubview:imageView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"presentDestination"] ||
		[segue.identifier isEqualToString:@"presentDestinationTwo"]) {
		
		UINavigationController *navigationController = (UINavigationController*)segue.destinationViewController;
		
		// Set delegate
		DestinationViewController *d = (DestinationViewController*)navigationController.viewControllers[0];
        d.userLat = self.userLat;
        d.userLng = self.userLng;
		d.delegate = self;
	} else if ([segue.identifier isEqualToString:@"login"]) {
        UINavigationController *navigationController = (UINavigationController*)segue.destinationViewController;
        LoginViewController *loginViewController = (LoginViewController*)navigationController.viewControllers[0];
        loginViewController.userLat = self.userLat;
        loginViewController.userLng = self.userLng;
    }
}

@end
