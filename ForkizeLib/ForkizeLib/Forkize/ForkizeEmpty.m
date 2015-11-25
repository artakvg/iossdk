//
//  ForkizeEmpty.m
//  ForkizeLib
//
//  Created by Artak on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "ForkizeEmpty.h"

@implementation ForkizeEmpty

-(void) authorize:(NSString *)appId andAppKey:(NSString *)appKey{

}

-(void) trackEvent:(NSString*) eventName andParams:(NSDictionary*) parameters{
}

-(void) purchaseWithProductId:(NSString* ) productId  andCurrency:(NSString*) currency andPrice:(double) price andQuantity: (NSInteger) quantity{

}

-(void) sessionStart{

}

-(void) sessionEnd{

}

-(void) eventDurationWithName:(NSString*) eventName{

}

-(void) setSuperProperties:(NSDictionary *) properties{

}

-(void) setSuperPropertiesOnce:(NSDictionary *) properties{

}

-(void) identify:(NSString *) userId{

}

-(void) alias:(NSString*) userId{

}

-(void)  onPause{

}

-(void)  onResume{

}

-(void)  onDestroy{

}

-(void)  onLowMemory{

}

-(void) onTerminate{

}

@end
