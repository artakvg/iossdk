//
//  ForkizeDefines.h
//  ForkizeLib
//
//  Created by Artak on 12/3/15.
//  Copyright © 2015 Artak. All rights reserved.
//

#ifndef ForkizeDefines_h
#define ForkizeDefines_h

#ifndef FZDebug
#define FZDebug 1
#endif

#if FZDebug
#   define FZLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define FZLog(...)
#endif

#endif /* ForkizeDefines_h */
