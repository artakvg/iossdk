#import "SQLiteHelper.h"
#import "DataAccessException.h"

#define FORMAT(X, Y) [NSString stringWithFormat:X, Y, nil]
#define FORMAT2(X, Y, Z) [NSString stringWithFormat:X, Y, Z, nil]


@implementation SQLiteRow

#pragma mark -
#pragma mark Memory Management

- (id)init {
	THROW_CANT_CREATE_INSTANCE;
}

- (id)initWithsqlite3_stmt_:(sqlite3_stmt *)statement {
	NSParameterAssert(statement != NULL);
	self = [super init];
	if (nil != self) {
		statement_ = statement;
	}
	return self;
}

#pragma mark -
#pragma mark Public Interface

- (NSString *)stringAtIndex:(NSInteger)index {
	NSParameterAssert(index>=0 && index<sqlite3_column_count(statement_));
	const char *cString = (const char *) sqlite3_column_text(statement_, (int)index);
	if (cString == NULL)
		return nil;
	return [[NSString alloc] initWithUTF8String:cString] ;
}

- (NSInteger)integerAtIndex:(NSInteger)index {
    NSParameterAssert(index>=0 && index<sqlite3_column_count(statement_));
	return sqlite3_column_int(statement_, (int)index);
}

- (NSDate *)dateAtIndex:(NSInteger)index {
	NSParameterAssert(index>=0 && index<sqlite3_column_count(statement_));
	return [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(statement_, (int)index)];
}

- (float)floatAtIndex:(NSInteger)index{
	NSParameterAssert(index>=0 && index<sqlite3_column_count(statement_));
	return sqlite3_column_double(statement_, (int)index);
}

@end

#pragma mark -

@implementation SQLiteStatement

#pragma mark -
#pragma mark Memory Management

- (id)init {
	THROW_CANT_CREATE_INSTANCE;
}

- (id)initWithsqlite3_stmt_:(sqlite3_stmt *)statement sqlite3_database:(sqlite3 *)database {
	NSParameterAssert(statement != NULL && database != NULL);
	self = [super init];
	if (nil != self) {
		statement_ = statement;
		database_ = database;
	}
	return self;
}

//- (void)dealloc {
//	sqlite3_finalize(statement_);
//	[super dealloc];
//}

#pragma mark -
#pragma mark Params Binding

- (void)reset {
	int result = sqlite3_reset(statement_);
	NSAssert(result == SQLITE_OK, FORMAT(@"Error resetting statement [%d]", result));
	sqlite3_clear_bindings(statement_);
	NSAssert(result == SQLITE_OK, FORMAT(@"Error clearing bindings [%d]", result));
}

- (int)indexOfParam:(NSString *)param {
	NSParameterAssert(param != nil);
	int result = sqlite3_bind_parameter_index(statement_, [param cStringUsingEncoding:NSUTF8StringEncoding]);
	NSAssert(result != SQLITE_OK, ([NSString stringWithFormat:@"Param %@ could not be found", param]));
	
	return result;
}

- (void)setString:(NSString *)string forParam:(NSString *)param {
	//call of indexOfParam: message will check the param contract
	if (string == nil) {
		return;
	}
	
	int result = sqlite3_bind_text(statement_, [self indexOfParam:param], [string cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
	NSAssert(result == SQLITE_OK, ([NSString stringWithFormat:@"Param %@ could not be set", param]));
}

- (void)setInteger:(NSInteger)integer forParam:(NSString *)param {
	//call of indexOfParam: message will check the param contract
	int result = sqlite3_bind_int(statement_, [self indexOfParam:param], (int)integer);
	NSAssert(result == SQLITE_OK, ([NSString stringWithFormat:@"Param %@ could not be set", param]));
}

- (void)setFloat:(float)value forParam:(NSString *)param {
	//call of indexOfParam: message will check the param contract
	int result = sqlite3_bind_double(statement_, [self indexOfParam:param], value);
	NSAssert(result == SQLITE_OK, ([NSString stringWithFormat:@"Param %@ could not be set", param]));
}

- (void)setDate:(NSDate *)date forParam:(NSString *)param {
	//call of indexOfParam: message will check the param contract
	if (date == nil) {
		return;
	}
	int result = sqlite3_bind_double(statement_, [self indexOfParam:param], [date timeIntervalSince1970]);
	NSAssert(result == SQLITE_OK, ([NSString stringWithFormat:@"Param %@ could not be set", param]));
}

#pragma mark -
#pragma mark Execution

- (void)executeQueryWithCallBack:(BOOL (^)(SQLiteRow *))callBack {
	NSParameterAssert(callBack != nil);
	SQLiteRow *row = [[SQLiteRow alloc] initWithsqlite3_stmt_:statement_];
	int result = SQLITE_OK;
	do {
		result = sqlite3_step(statement_);
		if (result == SQLITE_DONE)
			break;
		
		if (result == SQLITE_ROW) {
			if (!callBack(row))
				break;
		}
		else {
			@throw [DataAccessException exceptionWithReason:@"Unexpected result during the iteration." 
													   code:result];
		}
	} while(result == SQLITE_ROW);
}

- (NSInteger) executeSelectColumnInt {
    SQLiteRow *row = [[SQLiteRow alloc] initWithsqlite3_stmt_:statement_];
    int result = SQLITE_OK;
	
	result = sqlite3_step(statement_);
    if (result != SQLITE_DONE && result != SQLITE_ROW) {
        return NSNotFound;
    }
    return [row integerAtIndex:0];
} 

- (NSInteger)executeUpdate {
	int result = sqlite3_step(statement_);
	if (result != SQLITE_DONE && result != SQLITE_ROW) {
		@throw [DataAccessException exceptionWithReason:@"Unexpected result after executing update." 
												   code:result];
	}
	int changes = sqlite3_changes(database_);
	return changes;
}

- (NSInteger)lastId {
	return (NSInteger) sqlite3_last_insert_rowid(database_);
}

@end

@implementation SQLiteDatabase

#pragma mark -
#pragma mark Memory Management

- (id)initWithDBPath:(NSString *)dbPath {
	NSParameterAssert(dbPath != nil);
	self = [super init];
	if (nil != self) {
		const char *cFullPath = [dbPath cStringUsingEncoding:NSUTF8StringEncoding];
		
		int result = sqlite3_open(cFullPath, &database_);
		NSAssert(result == SQLITE_OK, FORMAT(@"Error connecting to the database [%d]", result));
	}
	return self;
}

//- (void)dealloc {
//	sqlite3_close(database_);
//	[super dealloc];
//}

#pragma mark -
#pragma mark Public Interface

- (SQLiteStatement *)statementWithSQLString:(NSString *)sqlString {
	NSParameterAssert(sqlString != nil);
	const char *cQuery = [sqlString cStringUsingEncoding:NSUTF8StringEncoding];
	
	sqlite3_stmt *statement;
	int result = sqlite3_prepare_v2(database_, cQuery, -1, &statement, NULL);
	NSAssert(result == SQLITE_OK, FORMAT2(@"Error [%1d] creating statement [%2@]", result, sqlString));

	return [[SQLiteStatement alloc] initWithsqlite3_stmt_:statement sqlite3_database:database_];
}

- (NSInteger)executeInTransaction:(SQLiteStatement *)statements, ... {
	
	SQLiteStatement *statement = statements;
	va_list argumentList;
	int totalCount = 0;
	if (statement) {
		
        [self beginTransaction];
		
		@try {
			totalCount += [statement executeUpdate];
			va_start(argumentList, statements);
            statement = va_arg(argumentList, SQLiteStatement*);
			while (statement) {
				totalCount += [statement executeUpdate];
                statement = va_arg(argumentList, SQLiteStatement*);
            }
			va_end(argumentList);
            
            [self commit];
            
        }
		@catch (DataAccessException *exception) {
            [self rollback];
			@throw exception;
		}
	}
	
	return totalCount;
}

- (BOOL)execute:(NSString *)sql {
	NSParameterAssert(sql != nil);
	const char *cSql = [sql cStringUsingEncoding:NSUTF8StringEncoding];
    char * err = nil;
    int result = sqlite3_exec(database_, cSql, NULL, NULL, &err);
	return result == SQLITE_OK;
}

- (BOOL)executeFile:(NSString *)filePath {
	NSParameterAssert(filePath != nil);
	NSString *script = [NSString stringWithContentsOfFile:filePath
												 encoding:NSUTF8StringEncoding
													error:NULL];
	return [self execute:script];
}

#pragma mark - 
#pragma mark Transactions

- (void)beginTransaction {
    if (sqlite3_exec(database_, "BEGIN", 0, 0, 0) != SQLITE_OK) {
        @throw [DataAccessException exceptionWithReason:@"Can not BEGIN the transaction"];
    }    
}

- (void)commit {
    if (sqlite3_exec(database_, "COMMIT", 0, 0, 0) != SQLITE_OK) {
        @throw [DataAccessException exceptionWithReason:@"Can not COMMIT the transaction"];
    }
}

- (void)rollback {
    sqlite3_exec(database_, "ROLLBACK", 0, 0, 0);
}


@end

