//
//  EventsDAO.m
//  iTennis
//
//  Created by Artak Martirosyan on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import "EventsDAO.h"
#import "SQLiteHelper.h"
#import "FZEvent.h"

#define kIdColIndex 0
#define kUserNameColIndex 1
#define kEventValueColIndex 2

static NSString *const kIdParamName = @":id";
static NSString *const kUserNameParamName = @":userName";
static NSString *const kEventValueParamName = @":eventValue";

static NSString *const kSelectAllEventsSQL = @""
"select Id, UserName, EventValue from Events order by Id";

static NSString *const kSelectEventsByCountAndNotUserSQL = @""
"select Id, UserName, EventValue from Events where UserName<>:userName order by Id asc limit %ld";


static NSString *const kSelectEventWithUserSQL = @""
"select Id, UserName, EventValue from Events where UserName=:userName order by Id";

static NSString *const kSelectEventByCountWithUserSQL = @""
"select Id, UserName, EventValue from Events where UserName=:userName order by Id asc limit %ld";

static NSString *const kInsertEventSQL = @""
"insert into Events (UserName, EventValue) values (:userName, :eventValue)";

static NSString *const kUpdateEventsSQL = @""
"update Events set UserName=:userName, EventValue=:eventValue where Id=:id";



static NSString *const  kDeleteEventSQL = @""
"delete from Events where Id=:id";

static NSString *const  kDeleteEventsSQL = @""
"delete from Events";

static NSString *const  kDeleteEventsCountSQL = @""
"delete from Events order by Id asc limit %ld";

@interface EventsDAO()

@property (nonatomic, strong) SQLiteDatabase *database;




@end
@implementation EventsDAO

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
    event.Id = [row integerAtIndex:kIdColIndex];
    event.eventValue = [row stringAtIndex:kEventValueColIndex];
    event.userName = [row stringAtIndex:kUserNameColIndex];
    
    return event;
}

- (NSArray *) loadEventsWithQuantity:(NSInteger) quantity forUser:(NSString *) userId{

    __block NSMutableArray *eventValues = [NSMutableArray array];
    SQLiteStatement *statement = [self.database statementWithSQLString:[NSString stringWithFormat:kSelectEventByCountWithUserSQL, quantity]];
    
    [statement setString:userId forParam:kUserNameParamName];
    
    
    SQLITE_ROW_CALLBACK(rowCallBack) {
        NSString *eventValue = [row stringAtIndex:kEventValueColIndex];
   
        [eventValues addObject:eventValue];
        
        return YES;
    };
    
    [statement executeQueryWithCallBack:rowCallBack];
    
    return eventValues;
}

- (NSArray *) loadEventsForUser:(NSString *)userId{
    __block NSMutableArray *events = [NSMutableArray array];
    SQLiteStatement *statement = [self.database statementWithSQLString:kSelectEventWithUserSQL];
    
    [statement setString:userId forParam:kUserNameParamName];
    
    
    SQLITE_ROW_CALLBACK(rowCallBack) {
        FZEvent *event  = [self getEventFromSQLiteRow:row];
        [events addObject:event];
        
        return YES;
    };
    
    [statement executeQueryWithCallBack:rowCallBack];
    return events;
}

-(BOOL) updateEvent:(FZEvent *) event{
    SQLiteStatement *statement = [self.database statementWithSQLString:kUpdateEventsSQL];
    
    [statement setString:event.userName forParam:kUserNameParamName];
    [statement setString:event.eventValue forParam:kEventValueParamName];
    [statement setInteger:event.Id forParam:kIdParamName];
    
    return [statement executeUpdate];
}

- (void) updateEvents:(NSArray *) events{
    
    for (FZEvent *event in events) {
        [self updateEvent:event];
    }
}

- (FZEvent *) addEvent:(FZEvent*) event{
    SQLiteStatement *statement = [self.database statementWithSQLString:kInsertEventSQL];
    
    [statement setString:event.eventValue forParam:kEventValueParamName];
    [statement setString:event.userName forParam:kUserNameParamName];
    
    long updateCount = [statement executeUpdate];

    NSAssert(updateCount != 0,@"Unexpected error while adding event chapter");

    event.Id = [statement lastId];
    return event;
}

- (BOOL) addEvents:(NSArray *) events{
    for ( FZEvent *event in events) {
        [self addEvent:event];
    }

    return YES;
}

- (BOOL) removeEvent:(FZEvent *) event{
    SQLiteStatement *deleteStat = [self.database statementWithSQLString:kDeleteEventSQL];
    [deleteStat setInteger:event.Id forParam:kIdParamName];
    
    return [deleteStat executeUpdate];
}

-(BOOL) removeEventWithCount:(NSInteger ) count{
    SQLiteStatement *deleteStat = [self.database statementWithSQLString:[NSString stringWithFormat:kDeleteEventsCountSQL, count]];
    
    return [deleteStat executeUpdate];

}

-(BOOL) removeEvents{
    SQLiteStatement *deleteStat = [self.database statementWithSQLString:kDeleteEventsSQL];
    
    return [deleteStat executeUpdate];
}

@end
