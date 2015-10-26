//
//  LocationInstance.h
//  ForkizeLib
//
//  Created by Artak on 9/15/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationInstance : NSObject<CLLocationManagerDelegate>


+ (LocationInstance*) getInstance;

-(void) setListeners;

@property(nonatomic, readonly) double longitude;
@property(nonatomic, readonly) double latitude;

@end
