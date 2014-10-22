//
//  API.h
//  OneRide
//
//  Created by Cory Levy on 8/2/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface API : NSObject

+ (void)loginWithUberUsename:(NSString*)username
                uberPassword:(NSString*)password
               facebookToken:(NSString*)facebookToken
                         lat:(NSString*)lat
                      andLng:(NSString*)lng
                     success:(void(^)(NSDictionary *output))successBlock
                       error:(void(^)(NSError *error))errorBlock;

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
			  error:(void(^)(NSError *error))errorBlock;

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
                         error:(void(^)(NSError *error))errorBlock;

+ (void)cancelRideFromService:(NSString*)service
				   requestID:(NSString*)requestID
					 success:(void(^)())successBlock
					   error:(void(^)(NSError *error))errorBlock;

+ (void)cancelSummon:(NSString*)service
         email:(NSString*)email
            password:(NSString*)password
            rideID:(NSString*)rideID
           success:(void(^)())successBlock
             error:(void(^)(NSError *error))errorBlock;

+ (void)foursquareLocationsAtLat:(NSString*)lat
						  andLng:(NSString*)lng
					   withQuery:(NSString*)q
						 success:(void(^)(NSArray *output))successBlock
						   error:(void(^)(NSError *error))errorBlock;

+ (void)calculateRideInfoFrom:(NSString*)driverCoords
			   toUserLocation:(NSString*)userCoords
				toDestination:(NSString*)destinationCoords
				   withMinFee:(float)feeMin
				 andPickupFee:(float)feePickup
				andFeePerMile:(float)feePerMile
				 andFeePerMin:(float)feePerMin
					  success:(void(^)(NSString *eta, NSString *fareEst))successBlock
						error:(void(^)(NSError *error))errorBlock;


+ (BOOL)loggedIn;
@end
