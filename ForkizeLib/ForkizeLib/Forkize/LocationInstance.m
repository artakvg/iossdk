//
//  LocationInstance.m
//  ForkizeLib
//
//  Created by Artak on 9/15/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

// FZ::TODO improve LocationInstance
// how we should test it with various devices
// what about destroy ?? what will happen ?

#import "LocationInstance.h"
#import <UIKit/UIKit.h>
#import "ForkizeDefines.h"

@interface LocationInstance()

@property (nonatomic, strong) CLLocationManager * locationManager;
@property(nonatomic, assign) double longitude;
@property(nonatomic, assign) double latitude;

@end
@implementation LocationInstance

-(instancetype) init{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    return self;
}

+ (LocationInstance*) getInstance{
    static LocationInstance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LocationInstance alloc] init];
    });
    return sharedInstance;
}

-(void) setListeners{
    
//    // FZ::TODO
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//         [self.locationManager requestWhenInUseAuthorization];
//    }
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate

/*
 *  locationManager:didUpdateLocations:
 *
 *  Discussion:
 *    Invoked when new locations are available.  Required for delivery of
 *    deferred locations.  If implemented, updates will
 *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
 *
 *    locations is an array of CLLocation objects in chronological order.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray *)locations __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_6_0){

    CLLocation *currentLocation = [locations objectAtIndex:0];
    self.latitude = currentLocation.coordinate.latitude;
    self.longitude = currentLocation.coordinate.longitude;
}

/*
 *  locationManager:didFailWithError:
 *
 *  Discussion:
 *    Invoked when an error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
    didFailWithError:(NSError *)error{
    FZLog(@"FZ::LOG - Localtion manager failed with error %@", error);
}

/*
 *  locationManager:didChangeAuthorizationStatus:
 *
 *  Discussion:
 *    Invoked when the authorization status changes for this application.
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status __OSX_AVAILABLE_STARTING(__MAC_10_7,__IPHONE_4_2){
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            FZLog(@"Forkize SDK User still thinking..");
        } break;
        case kCLAuthorizationStatusDenied: {
            FZLog(@"Forkize SDK Location manager authorization denied");
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [self.locationManager startUpdatingLocation]; //Will update location immediately
        } break;
        default:
            break;
    }
}

/*
 *  Discussion:
 *    Invoked when location updates are automatically paused.
 */
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_6_0){

}

/*
 *  Discussion:
 *    Invoked when location updates are automatically resumed.
 *
 *    In the event that your application is terminated while suspended, you will
 *	  not receive this notification.
 */
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_6_0){

}


@end
