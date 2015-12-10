//
//  DeviceInfo.h
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject

+(DeviceInfo*) getInstance;

-(NSDictionary *) getDeviceInfo;

-(NSString *) getBatteryLevel;
-(NSString *) getConnectionType;

@end
