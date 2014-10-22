//
//  Car.m
//  OneRide
//
//  Created by Cory Levy on 8/2/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "Car.h"

#define kCarIDKey @"id"

@implementation Car
-(id)initWithDictionary:(NSDictionary *)d {
    self = [super init];
    if (self) {
        //init
        _carID = d[kCarIDKey];
        _lat = d[@"lat"];
        _lng = d[@"lng"];
        _name = d[@"name"];
        _service = d[@"which"];
        _eta = d[@"eta"];
        _fareEstimate = d[@"price"];
    }
    return self;
}
@end
