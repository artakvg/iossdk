#import <Foundation/Foundation.h>

@class SQLiteDatabase;
@class FZEvent;

@interface FZEventsDAO : NSObject

- (id) initWithSQLiteDatabase:(SQLiteDatabase *)database;

// ** array of FZEvents
- (BOOL) addEvents:(NSArray *)events;

// ** returned array of eventValues
- (NSArray *) readEventsWithCount:(NSInteger ) count forUser:(NSString *) userId;

- (BOOL) updateEventsForUser:(NSString *) userId withAliasedUser:(NSString *) aliasedUser;

- (BOOL) removeEventsWithCount:(NSInteger ) count forUser:(NSString *) userId;

@end
