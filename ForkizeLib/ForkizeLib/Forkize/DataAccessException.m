#import "DataAccessException.h"

static NSString *const kDataAccessExceptionName = @"Error while accessing data";
static NSString *const kDataAccessExceptionFormat = @"%1@ [ErrorCode = %ld]";

@implementation DataAccessException

#pragma mark -
#pragma mark Static Interface

+ (DataAccessException *)exceptionWithReason:(NSString *)reason {
  
	DataAccessException *exception = [[DataAccessException alloc] initWithName:kDataAccessExceptionName 
																		reason:reason 
																	  userInfo:nil];
	return exception;
}

+ (DataAccessException *)exceptionWithReason:(NSString *)reason code:(NSInteger)code {
    
	DataAccessException *exception = [[DataAccessException alloc] initWithName:kDataAccessExceptionName 
																		reason:[NSString stringWithFormat:kDataAccessExceptionFormat, reason, (long)code, nil]
																	  userInfo:nil];
	return exception;
}

@end
