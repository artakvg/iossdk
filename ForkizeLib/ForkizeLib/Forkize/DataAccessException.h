#import <Foundation/Foundation.h>

//Data Access Exception class.
//Is thrown from all DAO classes
@interface DataAccessException : NSException

//Static initializers
+ (DataAccessException *)exceptionWithReason:(NSString *)reason;
+ (DataAccessException *)exceptionWithReason:(NSString *)reason code:(NSInteger)code;

@end
