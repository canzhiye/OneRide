//
//  API.m
//  OneRide
//
//  Created by Cory Levy on 8/2/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "API.h"

@implementation API

+ (void)loginWithUberUsename:(NSString*)username
                uberPassword:(NSString*)password
               facebookToken:(NSString*)facebookToken
                         lat:(NSString*)lat
                      andLng:(NSString*)lng
                     success:(void (^)(NSDictionary *ouput))successBlock
                       error:(void (^)(NSError *error))errorBlock {
    // facebook_token, uber_email, uber_password, lat, lng
    
    NSDictionary *body = @{
                           @"uber_email" : username,
                           @"uber_password" : password,
                           @"facebook_token" :facebookToken,
                           @"lat" : lat,
                           @"lng" : lng
                           };
    
    [API performRequestWithURL:[NSString stringWithFormat:@"%@/login", kDomain]
					  withBody:body
						isPost:YES
					   success:^(NSDictionary *output) {
						   
						   if (successBlock)
							   successBlock(output);
					   }
	 ];
}
// lyft_token, lyft_id, lat, lng, sidecar_id, sidecar_password, dest_lat, dest_lng, uber_token
+ (void)pingWithLat:(NSString*)lat
             andLng:(NSString*)lng
            destLat:(NSString*)destLat
            destLng:(NSString*)destLng
          uberToken:(NSString*)uberToken
          lyftToken:(NSString*)lyftToken
             lyftID:(NSString*)lyftID
          sidecarID:(NSString*)sidecarID
    sidecarPassword:(NSString*)sidecarPassword
            success:(void(^)(NSDictionary *ouput))successBlock
			  error:(void(^)(NSError *error))errorBlock {
    if (!uberToken) {
        uberToken = @"none";
    }
    NSDictionary *body = @{
                        @"lat": lat,
                        @"lng": lng,
                        @"dest_lat" : destLat,
                        @"dest_lng" : destLng,
                        @"uber_token" : uberToken,
                        @"lyft_token": lyftToken,
                        @"lyft_id": lyftID,
                        @"sidecar_id" : kSidecarID,
                        @"sidecar_password" : kSidecarPassword
                        };
    
    [API performRequestWithURL:[NSString stringWithFormat:@"%@/ping",kDomain]
                      withBody:body
                        isPost:YES
                       success:^(NSDictionary *output) {
        successBlock(output);
    }];
}

+ (void)requestRideFromService:(NSString*)service
                           lat:(NSString*)lat
                           lng:(NSString*)lng
                     uberToken:(NSString*)uberToken
                    uberRideID:(NSString*)uberRideID
                     lyftToken:(NSString*)lyftToken
               sidecarUsername:(NSString*)sidecarUsername
               sidecarPassword:(NSString*)sidecarPassword
                   summonEmail:(NSString*)summonEmail
                summonPassword:(NSString*)summonPassword
                       success:(void(^)(NSDictionary *output))successBlock
                         error:(void(^)(NSError *error))errorBlock {
    NSDictionary *body;
    
    if ([service isEqualToString:@"uber"]) {
        body = @{
                 @"uber_token" : uberToken,
                 @"uber_ride_id" : uberRideID,
                 @"lat" : lat,
                 @"lng" : lng
                 };
    } else if ([service isEqualToString:@"lyft"]) {
        body = @{
                 @"lyft_token" : lyftToken,
                 @"lat" : lat,
                 @"lng" : lng
                 };
        
    } else if ([service isEqualToString:@"sidecar"]) {
        
    } else if ([service isEqualToString:@"summon"]) {
        
    }
    
    [API performRequestWithURL:[NSString stringWithFormat:@"%@/pickup/%@", kDomain, service] withBody:body isPost:YES success:^(NSDictionary *output) {
        successBlock(output);
    }];
}
+ (void)cancelRideFromService:(NSString *)service requestID:(NSString *)requestID success:(void (^)())successBlock error:(void (^)(NSError *))errorBlock {
    
}
+ (void)requestSummonWithLat:(NSString*)lat
                         lng:(NSString*)lng
                     success:(void(^)(NSString*requestID))successBlock
                       error:(void(^)(NSError *error))errorBlock {

    [API performRequestWithURL:[NSString stringWithFormat:@"%@/pickup/summon", kDomain]
					  withBody:@{
								 @"username" : @"canzhiye@gmail.com",
                                 @"password" : @"password",
                                 @"lat" : lat,
                                 @"lon" : lng
								 }
						isPost:YES
					   success:^(NSDictionary *output) {
						   
						   NSLog(@"output: %@", output);
                           successBlock(output[@""]);
					   }
	 ];
}


+ (void)cancelLyft:(NSString*)service
         lyftToken:(NSString*)lyftToken
            rideID:(NSString*)rideID
               lat:(NSString*)lat
               lng:(NSString*)lon
           success:(void(^)())successBlock
             error:(void(^)(NSError *error))errorBlock {
    [API performRequestWithURL:[NSString stringWithFormat:@"%@/cancel/lyft",kDomain]
					  withBody:@{@"lyft_token": lyftToken,
                                 @"lyft_id" : rideID,
                                 @"ride_id" : rideID,
                                 @"lat" : lat,
                                 @"lon" : lon
                                 }
						isPost:YES
					   success:^(NSDictionary *output) {
						   //
                           NSLog(@"Lyft Cancelled %@", output);
					   }
	 ];
    
}

+ (void)cancelSummon:(NSString*)service
               email:(NSString*)email
            password:(NSString*)password
              rideID:(NSString*)rideID
             success:(void(^)())successBlock
               error:(void(^)(NSError *error))errorBlock {
    [API performRequestWithURL:[NSString stringWithFormat:@"%@/cancel/summon",kDomain]
					  withBody:@{@"email": @"canzhiye@gmail.com",
                                 @"password" : @"password",
                                 @"ride_id" : rideID
                                 }
						isPost:YES
					   success:^(NSDictionary *output) {
						   
						   NSLog(@"Summon Cancelled");
						   
					   }
	 ];
    
}


#pragma mark -

+ (void)foursquareLocationsAtLat:(NSString*)lat
						  andLng:(NSString*)lng
					   withQuery:(NSString*)q
						 success:(void(^)(NSArray *output))successBlock
						   error:(void(^)(NSError *error))errorBlock
{
	[API performRequestWithURL:@"https://api.foursquare.com/v2/venues/search"
					  withBody:@{
								 @"client_id" : kFoursquareId,
								 @"client_secret" : kFoursquareSecret,
								 @"v" : @"20140803",
								 @"ll" : [NSString stringWithFormat:@"%@,%@", lat, lng],
								 @"query" : q
								 }
						isPost:NO
					   success:^(NSDictionary *output) {
						   
						   NSArray *venues = output[@"response"][@"venues"];
						   if (![venues isKindOfClass:[NSArray class]])
							   return;
						   
						   NSMutableArray *outputArray = [[NSMutableArray alloc] init];
						   for (NSDictionary *dictionary in venues) {
							   NSDictionary *location = dictionary[@"location"];
							   
							   [outputArray addObject:@{
														@"id" : dictionary[@"id"],
														@"location" : @{
																@"address" : location[@"formattedAddress"][0],
																@"lat" : location[@"lat"],
																@"lng" : location[@"lng"]
																},
														@"name" : dictionary[@"name"]
														}
								];
						   }
						   
						   successBlock(outputArray);
					   }
	 ];
}

+ (void)calculateRideInfoFrom:(NSString*)driverCoords
			   toUserLocation:(NSString*)userCoords
				toDestination:(NSString*)destinationCoords
				   withMinFee:(float)feeMin
				 andPickupFee:(float)feePickup
				andFeePerMile:(float)feePerMile
				 andFeePerMin:(float)feePerMin
					  success:(void(^)(NSString *eta, NSString *fareEst))successBlock
						error:(void(^)(NSError *error))errorBlock
{
	[API performRequestWithURL:@"http://maps.googleapis.com/maps/api/directions/json"
					  withBody:@{
								 @"origin" : driverCoords,
								 @"waypoints" : userCoords,
								 @"destination" : destinationCoords
								 }
						isPost:NO
					   success:^(NSDictionary *output) {
						   
						   if (![[output allKeys] containsObject:@"routes"])
							   return;
						   
						   NSArray *routes = [output objectForKey:@"routes"];
						   if ([routes count] == 0)
							   return;
						   
						   NSString *eta = @"";
						   NSString *estFare = @"";
						   
						   for (NSDictionary *route in routes) {
							   
							   int i = 0;
							   for (NSDictionary *leg in [route objectForKey:@"legs"]) {
								   NSString *duration = [NSString stringWithFormat:@"%@",leg[@"duration"][@"value"]]; // seconds
								   NSString *distance = [NSString stringWithFormat:@"%@",leg[@"distance"][@"value"]]; // miles
								   
								   if (i == 0) {
									
									   // Calculate ETA
									   eta = duration;
									   
								   } else if (i == 1) {
									   
									   // Calculate Fare
									   float timeFee = feePerMin * ([duration floatValue] / 60.0f);
									   float distanceFee  = feePerMile * ([distance floatValue] / 1609.34f);
									   float fare = MAX(feeMin, feePickup + timeFee + distanceFee);
									   estFare = [NSString stringWithFormat:@"%f",fare];
									   
								   }
								   
								   i++;
							   }
						   }
						   
						   if (successBlock)
							   successBlock(eta, estFare);
					   }
	 ];
}

#pragma mark - Requests

+ (void)logRequest:(NSURLRequest*)request
	  withResponse:(NSURLResponse*)response
		  andError:(NSError*)error
		   andData:(NSData*)data
{
    NSLog(@"********************************");
    NSLog(@"URL: %@",request.URL.absoluteString);
    NSLog(@"ERROR: %@",error.localizedDescription);
    NSLog(@"BODY: %@",response);
    NSLog(@"RESPONSE: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"********************************");
}

+ (void)performRequestWithURL:(NSString*)url
					 withBody:(NSDictionary*)bodyDictionary
					   isPost:(BOOL)post
					  success:(void(^)(NSDictionary *output))completed
{
    if (!post && [bodyDictionary count] > 0) {
        url = [NSString stringWithFormat:@"%@?", url];
        
        int i = 0;
        for (NSString *key in [bodyDictionary allKeys]) {
            if (i != 0)
                url = [NSString stringWithFormat:@"%@&", url];
            
            url = [NSString stringWithFormat:@"%@%@=%@", url, key, [[NSString stringWithFormat:@"%@",[bodyDictionary objectForKey:key]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            i++;
        }
    }
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    if (post) {
        [request setHTTPMethod:@"POST"];
        NSError *error = nil;
        NSData *postdata = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:&error];
        [request setHTTPBody:postdata];
        
    } else {
        [request setHTTPMethod:@"GET"];
    }
	
    [request setTimeoutInterval:15.0f];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		
		NSError *jsonError;
        //NSLog(@"output: (%@) %@",url ,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		
		if (!data) {
            completed(nil);
            return;
        }
		
		NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
																		   options:kNilOptions
																			 error:&jsonError];
        //NSLog(@"%@",responseDictionary);
		
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completed(responseDictionary);
        });
    }];
}
+(BOOL)loggedIn {
    //NSKeyedUnarchiver and stuff
    return NO;
}
@end
