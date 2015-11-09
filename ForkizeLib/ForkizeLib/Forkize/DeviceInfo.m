//
//  DeviceInfo.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "DeviceInfo.h"
#import "ForkizeHelper.h"
#import <UIKit/UIKit.h>

@interface DeviceInfo ()

@property (nonatomic, strong) NSDictionary *deviceParams;

@end

@implementation DeviceInfo

+ (DeviceInfo*) getInstance {
    static DeviceInfo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DeviceInfo alloc] init];
    });
    return sharedInstance;
}

-(NSDictionary *) getDeviceInfo{
    if (self.deviceParams == nil) {
        [self fetchParams];
    }
    
    return self.deviceParams;
}

-(NSString *) getBatteryLevel{
    return [NSString stringWithFormat:@"%ld", (long)( [UIDevice currentDevice].batteryLevel * 100)];
}

-(void) fetchParams{
    @try {
        // FZ::TODO why we need NSMutableDictionary
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
       
        [mutDict setObject:@"Apple" forKey:@"device_manufacturer"];
        [mutDict setObject:[[UIDevice currentDevice] model] forKey:@"device_model"];
        [mutDict setObject:[UIDevice currentDevice].systemVersion forKey:@"device_os_version"];
        [mutDict setObject:@"ios" forKey:@"device_os_name"];
        
        [mutDict setObject:[NSString stringWithFormat:@"%ld", (long)[UIScreen mainScreen].bounds.size.width] forKey:@"device_width"];
        [mutDict setObject:[NSString stringWithFormat:@"%ld", (long)[UIScreen mainScreen].bounds.size.height] forKey:@"device_height"];
        [mutDict setObject:[NSString stringWithFormat:@"%ld", (long)[[UIScreen mainScreen] scale]] forKey:@"density"];
        
        [mutDict setObject:[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode] forKey:@"country"];
        [mutDict setObject:[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0] forKey:@"language"];
        [mutDict setObject:[ [[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"app_major_version"];
        [mutDict setObject:[ [[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"app_minor_version"];
        [mutDict setObject:[self getBatteryLevel] forKey:@"battery_level"];
        
        self.deviceParams = [NSDictionary dictionaryWithDictionary:mutDict];

    }
    @catch (NSException *exception) {
        NSLog(@"Forkize SDK Exception thrown when device info collecting %@", exception);
    }
  
}

@end
