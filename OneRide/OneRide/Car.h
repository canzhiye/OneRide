//
//  Car.h
//  OneRide
//
//  Created by Cory Levy on 8/2/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Car : NSObject

@property (nonatomic, strong) NSString *carID, *lat, *lng, *name, *eta, *fareEstimate, *service;
-(id)initWithDictionary:(NSDictionary *)d;
@end
