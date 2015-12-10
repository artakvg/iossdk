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
#import "Reachability.h"
#import "ForkizeDefines.h"

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
    //FZ::Point if permission denied return -100
    return [NSString stringWithFormat:@"%ld", (long)( [UIDevice currentDevice].batteryLevel * 100)];
}

-(void) fetchParams{
    @try {
        // FZ::DONE why we need NSMutableDictionary

        self.deviceParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                                @"Apple", @"device_manufacturer",
                                                [[UIDevice currentDevice] model], @"device_model",
                                                [UIDevice currentDevice].systemVersion, @"device_os_version",
                                                @"ios", @"device_os_name",
                                                [NSString stringWithFormat:@"%ld", (long)[UIScreen mainScreen].bounds.size.width], @"device_width",
                                                [NSString stringWithFormat:@"%ld", (long)[UIScreen mainScreen].bounds.size.height], @"device_height",
                                                [NSString stringWithFormat:@"%ld", (long)[[UIScreen mainScreen] scale]], @"density",
                                                [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode], @"country",
                                                [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0], @"language",
                                                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], @"app_major_version",
                                                [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"app_minor_version",
                                            //    [self getBatteryLevel], @"battery_level",
                                                nil];

    }
    @catch (NSException *exception) {
        FZLog(@"Forkize SDK Exception thrown when device info collecting %@", exception);
    }
}

-(NSString *) getConnectionType{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NSString *type = @"";
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
        type = @"ncon";
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
        type = @"wifi";
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        type = @"mobile";
    }
    
    return type;
}

@end
