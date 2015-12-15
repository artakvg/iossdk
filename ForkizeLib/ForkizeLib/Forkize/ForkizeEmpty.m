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

-(UserProfile *) getProfile{
    return nil;
}

-(void) trackEvent:(NSString*) eventName withParams:(NSDictionary*) parameters{
}

-(void) purchaseWithProductId:(NSString* ) productId  andCurrency:(NSString*) currency andPrice:(double) price andQuantity: (NSInteger) quantity{

}

-(void) sessionStart{

}

-(void) sessionEnd{

}

-(void) sessionPause{

}

-(void) sessionResume{

}


-(void) eventDuration:(NSString*) eventName{

}

-(void) setSuperProperties:(NSDictionary *) properties{

}

-(void) setSuperPropertiesOnce:(NSDictionary *) properties{

}

-(BOOL) isNewInstall{
    return YES;
}


-(void) identify:(NSString *) userId{

}

-(void) alias:(NSString*) userId{

}

-(void)  pause{

}

-(void)  resume{

}

-(void)  destroy{

}

-(void)  onLowMemory{

}

-(void) onTerminate{

}

-(void) advanceState:(NSString *) state{

}

-(void) resetState:(NSString *) state{

}

-(void) pauseState:(NSString *) state{

}

-(void) resumeState:(NSString *) state{
    
}


@end
