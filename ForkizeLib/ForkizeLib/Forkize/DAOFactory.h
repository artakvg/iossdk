//
//  DAOFactory.h
//  iTennis
//
//  Created by Artak Martirosyan on 8/8/13.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZUserDAO;
@class EventsDAO;


@interface DAOFactory : NSObject

+ (DAOFactory *)defaultFactory;

- (FZUserDAO *) userDAO;

- (EventsDAO *) eventsDAO;

@end
