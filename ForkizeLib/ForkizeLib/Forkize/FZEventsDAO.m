#import "FZEventsDAO.h"
#import "SQLiteHelper.h"
#import "FZEvent.h"

static NSString *const kRidParamName = @":rid";
static NSString *const kUserIdParamName = @":userId";
static NSString *const kEventDataParamName = @":eventData";
static NSString *const kAliasedIdParamName = @":aliasId";

static NSString *const kSelectEventByCountWithUserSQL = @""
"SELECT Rid, UserId, EventData FROM Events WHERE UserId=:userId ORDER BY Rid ASC LIMIT %ld";

static NSString *const kInsertEventSQL = @""
"INSERT INTO Events (UserId, EventData) VALUES (:userId, :eventData)";

static NSString *const kUpdateEventsAliasedSQL = @""
"UPDATE Events SET UserId=:aliasId WHERE UserId=:userId";

static NSString *const  kDeleteEventsCountSQL = @""
"DELETE FROM Events WHERE Rid IN (SELECT Rid FROM Events WHERE UserId=:userId ORDER BY Rid ASC LIMIT %ld)";

@interface FZEventsDAO()

@property (nonatomic, strong) SQLiteDatabase *database;

@end

@implementation FZEventsDAO

@synthesize database = database_;

- (id) initWithSQLiteDatabase:(SQLiteDatabase *)database{
    self = [super init];
    if (nil != self) {
        self.database = database;
    }
    return self;
}

-(FZEvent *) getEventFromSQLiteRow:(SQLiteRow* )row{
    FZEvent *event  = [[FZEvent alloc] init];
    event.rowId = [row integerAtIndex:0];
    event.userId = [row stringAtIndex:1];
    event.eventData = [row stringAtIndex:2];
    
    return event;
}

- (NSArray *) readEventsWithCount:(NSInteger ) count forUser:(NSString *) userId{

    __block NSMutableArray *eventDatas = [NSMutableArray array];
    SQLiteStatement *statement = [self.database statementWithSQLString:[NSString stringWithFormat:kSelectEventByCountWithUserSQL, (long)count]];
    
    [statement setString:userId forParam:kUserIdParamName];
    
    
    SQLITE_ROW_CALLBACK(rowCallBack) {
        // 2 is eventData co
        NSString *eventData = [row stringAtIndex:2];
   
        [eventDatas addObject:eventData];
        
        return YES;
    };
    
    [statement executeQueryWithCallBack:rowCallBack];
    
    return eventDatas;
}

-(BOOL) updateEventsForUser:(NSString *) userId withAliasedUser:(NSString *) aliasedUser{
    SQLiteStatement *statement = [self.database statementWithSQLString:kUpdateEventsAliasedSQL];
    
    [statement setString:userId forParam:kUserIdParamName];
    [statement setString:aliasedUser forParam:kAliasedIdParamName];
   
    return [statement executeUpdate];
}

- (FZEvent *) addEvent:(FZEvent*) event{
    SQLiteStatement *statement = [self.database statementWithSQLString:kInsertEventSQL];
    
    [statement setString:event.userId forParam:kUserIdParamName];
    [statement setString:event.eventData forParam:kEventDataParamName];
    
    long updateCount = [statement executeUpdate];

    NSAssert(updateCount != 0,@"Unexpected error while adding event chapter");

    event.rowId = [statement lastId];
    return event;
}

// FZ::POINT
- (BOOL) addEvents:(NSArray *) events{
    for ( FZEvent *event in events) {
        [self addEvent:event];
    }

    return YES;
}

-(BOOL) removeEventsWithCount:(NSInteger ) count forUser:(NSString *) userId;{
    SQLiteStatement *deleteStat = [self.database statementWithSQLString:[NSString stringWithFormat:kDeleteEventsCountSQL, (long)count]];
    
    [deleteStat setString:userId forParam:kUserIdParamName];
    
    return [deleteStat executeUpdate];

}

@end
