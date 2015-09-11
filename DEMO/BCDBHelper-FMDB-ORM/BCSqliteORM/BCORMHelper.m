//
//  BCORMHelper.m
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCORMHelper.h"
#import "FMDB.h"
#import "BCORMEntityProtocol.h"
#import "BCSqliteType.h"
#import "BCSqlInt.h"
#import "BCSqlText.h"
#import "BCSqlReal.h"
#import "BCSqlParameter.h"

#import <objc/runtime.h>

@interface BCORMHelper()

@property (nonatomic,strong) FMDatabaseQueue *dbQueue;
@property (nonatomic,strong) __block NSMutableDictionary *tablePrimaryKeyMapping;
@property (nonatomic,strong) __block NSMutableArray *tableArray;

@property (nonatomic,copy)NSString *dbPath;
@property(strong, nonatomic) NSRecursiveLock *threadLock;
/**
 *open the data base
 **/
-(BOOL)openDataBase;
/**
 *close the data base
 **/
-(void)closeDataBase;

/**
 *init database ;create table,insert init data,
 **/
-(BOOL)p_databaseInit;

/**
 *get a class property by it property name;
 **/
-(NSString*)p_getPropertyNameBy:(NSString*)propertyKey withClass:(Class)class;

/**
 *generate a create table sql sentence like 
 *   "'id'  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL"
 **/
-(NSString*)p_generateCreateTableColumnSentenceBy:(BCSqliteType*)type;

/**
 *get a table name by class;
 **/
-(NSString*)p_getTableNameWithClass:(Class)class;

/**
 *get table column name from the class with it propertyKEY;
 **/
-(NSString*)p_getTableColumnNameBy:(NSString*)propertyKey withClass:(Class)class;

/**
 *generate a create table constrants sql sentence like
 * CONSTRAINT "request_tripid" FOREIGN KEY ("tripId") REFERENCES "trip" ("tripId")
 **/
-(NSString*)p_generateCreateTableConstrantsBy:(BCSqliteType*)sqlType;

/**
 *generate a create table sql with table name and entity class;then execute sql
 **/
-(BOOL)p_buildTableWithName:(NSString*)tableName withClass:(Class)class andFMDatabase:(FMDatabase *) fmdb;

/**
 *generate a table  index sql with table name and entity class;then execute sql
 *CREATE INDEX idx_move ON move("tripId","tripNodeId","moveId");
 **/
-(void)p_buildIndexWithTableName:(NSString*)tableName withClass:(Class)class andFMDatabase:(FMDatabase *) fmdb;



/**
 *generate a map:  tableName <----> primary key property of the entity
 *
 **/
-(void)p_buildTablePrimaryKeyMapWithClass:(Class)class andDic:(NSMutableDictionary *) dic;

/**
 *generater a insert sql by the entity
 *@param (id<BCORMEntityProtocol>)entity     the enetity to save.
 *@param (NSMutableString**)sql     the insert sql
 *@param (NSMutableDictionary**)dic     the sql argument dictionary.
 *@return status
 **/
-(BOOL)p_buildInsertSql_Entity:(id<BCORMEntityProtocol>)entity andKeyString:(NSMutableString**)sql andArgs:(NSMutableDictionary**)dic;

/**
 *build a select sql by Query Condition entity.
 **/
-(NSString*)p_buildSelectSqlByCondition:(BCSqlParameter*)condition;


/**
 *generater a update sql by the entity
 *@param (id<BCORMEntityProtocol>)entity  the enetity to save.
 *@param (NSMutableString**)sql    the update sql
 *@param (NSMutableDictionary**)dic   the sql argument dictionary.
 *@return status
 **/
-(BOOL)p_buildUpdateSql_Entity:(id<BCORMEntityProtocol>)entity andKeyString:(NSMutableString**)sql andArgs:(NSMutableDictionary**)dic;

/**
 *build a update sql by Query Condition entity.
 **/
-(NSString*)p_buildUpdateSqlByCondition:(BCSqlParameter*)condition;


/**
 *generater a delete sql by the entity
 *@param (id<BCORMEntityProtocol>)entity  the enetity to save.
 *@param (NSMutableString**)sql    the delete sql
 *@return status
 **/
-(BOOL)p_buildDeleteSql_Entity:(id<BCORMEntityProtocol>)entity andKeyString:(NSMutableString**)sql;


/**
 *build a delete sql by Query Condition entity.
 **/
-(NSString*)p_buildDeleteSqlByCondition:(BCSqlParameter*)condition;
@end

@implementation BCORMHelper

@synthesize dbPath;
@synthesize dbQueue;

/**
 *get a class property by it property name;
 **/
-(NSString*)p_getPropertyNameBy:(NSString*)propertyKey withClass:(Class)class
{
    objc_property_t tmpPropery = class_getProperty(class, [propertyKey UTF8String]);
    return [NSString stringWithUTF8String: property_getName(tmpPropery) ];
}

/**
 *get a table name by class;
 **/
-(NSString*)p_getTableNameWithClass:(Class)c
{
    NSString* tableName = NSStringFromClass(c);
    if ([c respondsToSelector:@selector(tableName)]) {
        tableName = [c tableName];
    }
    return tableName;
}

/**
 *get table column name from the class And its propertyKEY;
 **/
-(NSString*)p_getTableColumnNameBy:(NSString*)propertyKey withClass:(Class)c
{
    if ([c conformsToProtocol:@protocol(BCORMEntityProtocol)])/*000 001*/ {
        NSDictionary* classTableMapping = [c tableEntityMapping];
        BCSqliteType* sqlType = [classTableMapping objectForKey:propertyKey];
        return sqlType.name;
    }
    return nil;
}
/**
 *generate a create table sql sentence like
 *   "'id'  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL"
 **/
-(NSString*)p_generateCreateTableColumnSentenceBy:(BCSqliteType*)sqlType
{
    //"webPageId"  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    NSMutableString* str  = [[NSMutableString alloc] init];
   [str appendFormat:@"'%@'",sqlType.name];
    if ([sqlType isMemberOfClass:[BCSqlReal class]]) {
        [str appendString:@"  REAL"];
    }else if ([sqlType isMemberOfClass:[BCSqlText class]]) {
        [str appendString:@"  TEXT"];
    }else if ([sqlType isMemberOfClass:[BCSqlInt class]]) {
        [str appendString:@"  INTEGER"];
    }else {
        [str appendString:@"  TEXT"];
    }
    BCConstraints* constaints  =sqlType.constraints;
    if (constaints) {
        if (constaints.primaryKey) {
            [str appendString:@"  PRIMARY KEY"];
            if (constaints.autoIncrement) {
                [str appendString:@"  AUTOINCREMENT"];
            }
        }
        if (!constaints.allowNull) {
            [str appendString:@"   NOT NULL"];
        }

    }else {

    }

    if (sqlType.defalutValue) {
        [str appendFormat:@"   DEFAULT '%@' ",sqlType.defalutValue];
    }

    return str;
}

/**
 *generate a create table constrants sql sentence like
 * CONSTRAINT "request_tripid" FOREIGN KEY ("tripId") REFERENCES "trip" ("tripId")
 **/
-(NSString*)p_generateCreateTableConstrantsBy:(BCSqliteType*)sqlType
{
    //"webPageId"  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    NSMutableString* str  = [[NSMutableString alloc] init];
    BCConstraints* constaints  =sqlType.constraints;
    if (constaints && constaints.foreign) {
            [str appendString:@","];
            //CONSTRAINT "request_tripid" FOREIGN KEY ("tripId") REFERENCES "trip" ("tripId")
            BCReferences * reference = sqlType.reference;
            [str appendFormat:@"  CONSTRAINT '%@' ",reference.name];
            [str appendFormat:@"FOREIGN KEY ('%@')  ",sqlType.name];
            NSString* tableName = [self p_getTableNameWithClass:reference.referenceClass];
            [str appendFormat:@"REFERENCES '%@'",tableName];
            NSString* tableColumnName = [self p_getTableColumnNameBy:reference.referencePropertyName withClass:reference.referenceClass];
            [str appendFormat:@"('%@')",tableColumnName];
    }
    return str;
}


/**
 *generate a create table sql with table name and entity class;then execute sql
 **/
-(BOOL)p_buildTableWithName:(NSString*)tableName withClass:(Class)c andFMDatabase:(FMDatabase *) fmdb
{
    if ([c respondsToSelector:@selector(tableEntityMapping)]) {
        //create table sql build process....
        NSMutableString* createTableSql = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE '%@' (",tableName];
        NSDictionary* classTableMapping = [c tableEntityMapping];
        NSArray* keys  = [classTableMapping allKeys];
        NSUInteger size  = [keys count];
        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BCSqliteType* sqlType = [classTableMapping objectForKey:obj];
            [createTableSql  appendString:[self p_generateCreateTableColumnSentenceBy:sqlType ]];
            if (idx < size - 1 ) {
                [createTableSql  appendString:@" , "];
            }

        }];

        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BCSqliteType* sqlType = [classTableMapping objectForKey:obj];
            [createTableSql  appendString:[self p_generateCreateTableConstrantsBy:sqlType ]];
        }];

        [createTableSql appendString:@");"];
        [fmdb executeUpdate:createTableSql];
        LogDB(@"execute a sql:\nSSQL:::[\n\r%@\n\r]",createTableSql);
        LOG_DB_ERROR(fmdb);
        return YES;
    }else {
         @throw [[NSException alloc] initWithName:@"BCORMException" reason:@"Every entity which wants to be persistence should implement BCORMEntityProtocol protocol, tableEntityMapping method required.." userInfo:nil];
    }

    return  NO;
}


/**
 *generate a table  index sql with table name and entity class;then execute sql
 *CREATE INDEX idx_move ON move("tripId","tripNodeId","moveId");
 **/
-(void)p_buildIndexWithTableName:(NSString*)tableName withClass:(Class)c andFMDatabase:(FMDatabase *) fmdb
{
    if ([c respondsToSelector:@selector(tableIndexArray)]) {
        LogDB(@"build table index.....");
        __block NSMutableString* createIndexSql = [[NSMutableString alloc] init];
        NSArray* indexArray = [c tableIndexArray];
        NSDictionary* classTableMapping = [c tableEntityMapping];
        [indexArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* indexProperty = obj;
            BCSqliteType* sqlType = [classTableMapping objectForKey:indexProperty];
            if (sqlType) {
                NSString* tmpCreateIndexStr = [NSString stringWithFormat:@"CREATE INDEX idx_%@_%@ ON %@('%@');",tableName,sqlType.name,tableName,sqlType.name];
                [createIndexSql appendString:tmpCreateIndexStr];
            }else {
                @throw [[NSException alloc] initWithName:@"BCORMException" reason:[NSString stringWithFormat:@"%@ is not contained in tableEntityMapping result",indexProperty] userInfo:nil];
            }

        }];
        [fmdb executeUpdate:createIndexSql];
        LogDB(@"execute a sql:\nSSQL:::[\n\r%@\n\r]",createIndexSql);
        LOG_DB_ERROR(fmdb);

    }

}


/**
 *generate a map:  tableName <----> property[primary key] of the entity
 *
 **/
-(void)p_buildTablePrimaryKeyMapWithClass:(Class)c andDic:(NSMutableDictionary *) dic
{
    NSString* tableName = [self p_getTableNameWithClass:c];
    NSDictionary* classTableMapping = [c tableEntityMapping];
    __block NSString* primaryKey = nil;
    [classTableMapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) /*01*/{
        NSString* propertyName = key;
        BCSqliteType* sqlType = obj;
        if (sqlType.constraints.primaryKey) {
            primaryKey = propertyName;
            *stop = YES;
        }
    }/*01*/];
    assert( primaryKey );
    [self.tablePrimaryKeyMapping setObject:primaryKey forKey:tableName];
}
-(BOOL)p_databaseInit
{
    if (!self.tableArray || [self.tableArray count] <= 0) /*000 1*/{
        return NO;
    }/*000 1*/
    self.threadLock = [[NSRecursiveLock alloc]init];

    self.tablePrimaryKeyMapping  = [[NSMutableDictionary alloc] initWithCapacity:self.tableArray.count];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dbPath] == NO)/*001*/ {
        FMDatabase * dbtmp = [FMDatabase databaseWithPath:dbPath];
        if ([dbtmp open]) /*000 2*/{
            __block NSMutableString* createTableSql = nil;
            for (int i = 0; i < self.tableArray.count; i ++) /*000 01*/{
                Class c = self.tableArray[i];
                LogDB(@"add a new class:%@",NSStringFromClass(c));
                NSString* tableName = [self p_getTableNameWithClass:c];
                createTableSql = [[NSMutableString alloc] initWithFormat:@"DROP TABLE IF EXISTS \"%@\" ;",tableName];
                [dbtmp executeUpdate:createTableSql];
                LogDB(@"execute a sql:\nSSQL:::[\n\r%@\n\r]",createTableSql);
                LOG_DB_ERROR(dbtmp);

                if ([c conformsToProtocol:@protocol(BCORMEntityProtocol)])/*000 001*/ {
                    [self p_buildTableWithName:tableName withClass:c andFMDatabase:dbtmp];

                    [self p_buildIndexWithTableName:tableName withClass:c andFMDatabase:dbtmp];

                    [self p_buildTablePrimaryKeyMapWithClass:c andDic:self.tablePrimaryKeyMapping];
                }else /*000 001*/{
                    @throw [[NSException alloc] initWithName:@"BCORMException" reason:@"Every entity which wants to be persistence should implement BCORMEntityProtocol protocol.." userInfo:nil];
                }/*000 001*/

                
            }/*000 01*/

            [dbtmp close];
        }else /*000 2*/{
            LogDB(@"error when open db");
             return NO;
        }/*000 2*/

    }/*001*/else {
        //build primary key of each table mapping.
        for (int i = 0; i < self.tableArray.count; i ++) /*000 01*/{
            Class c = self.tableArray[i];
            LogDB(@"add a new class:%@",NSStringFromClass(c));
            if ([c conformsToProtocol:@protocol(BCORMEntityProtocol)])/*000 001*/ {
                [self p_buildTablePrimaryKeyMapWithClass:c andDic:self.tablePrimaryKeyMapping];
            }else /*000 001*/{
                @throw [[NSException alloc] initWithName:@"BCORMException" reason:@"Every entity which wants to be persistence should implement BCORMEntityProtocol protocol.." userInfo:nil];
            }/*000 001*/

        }/*000 01*/

    }
    return YES;
}

-(id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ ::please use initWithXXX:` instead.", NSStringFromClass([self class])] userInfo:nil];
}
/**
 * init db with such as "documents/" + fileName + ".db"
 *@param (NSString*)databaseName
 *@return BCORMHelper instance;
 */
/**
 * init db with such as "documents/" + fileName + ".db"
 *@param (NSString*)databaseName
 *@return BCORMHelper instance;
 */
-(instancetype)initWithDatabaseName:(NSString*)databaseName enties:(NSArray*)entities
{
    self.tableArray = [[NSMutableArray alloc] initWithArray:entities];
    [self setDatabaseName:databaseName];
    if (![self p_databaseInit]) {
        @throw [[NSException alloc] initWithName:@"Init Error" reason:@" init failed" userInfo:nil];
    }
    return self;
}
-(void)setDatabaseName:(NSString*)fileName
{
    if (![fileName isEqualToString:self.dbPath]  &&   self.dbQueue) {
        [self closeDataBase];
    }
    self.dbPath = [PATH_OF_LIBRARY_SUPPORT stringByAppendingPathComponent:fileName];
    LogDB(@"sqlite file path:%@",self.dbPath);
    return;
}

/**
 *@param (NSString*)databaseFilePath
 *@return BCORMHelper instance;
 */
-(instancetype)initWithDatabasePath:(NSString*)databaseFilePath  enties:(NSArray*)entities
{
    self.tableArray = [[NSMutableArray alloc] initWithArray:entities];
    [self setDatabasePath:databaseFilePath];
    if (![self p_databaseInit]) {
        @throw [[NSException alloc] initWithName:@"Init Error" reason:@" init failed;please implement the ORMDatabaseProtocol ." userInfo:nil];
    }
    return self;
}

-(void)setDatabasePath:(NSString*)filePath
{
    if (![filePath isEqualToString:self.dbPath]  &&   self.dbQueue) {
        [self closeDataBase];
    }
    self.dbPath = filePath;
}

/***********************Database init,open,close*********************************/
/**
 *open the data base
 **/
-(BOOL)openDataBase
{
    if (!self.dbPath ) {
        return NO;
    }
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
     LogDB(@"database path::%@",self.dbPath);
    return YES;
}


/**
 *close the data base
 **/
-(void)closeDataBase
{
    [self.dbQueue close];
    self.dbQueue = nil;
}

/**
 *execute a sql;
 **/
-(BOOL)executeUpdateSql:(NSString*)sql
{
    if (!self.dbQueue) {
        [self openDataBase];
    }
    __block BOOL res = YES;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        //[db open];
        LogDB(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\r");
        LogDB(@"executeUpdateSql:\nSSQL:::[\n\r%@\n\r]",sql);
        LogDB(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\r");
        NSString* tmpSql = [sql uppercaseString];
        if ([tmpSql hasPrefix:@"SELECT "] || [tmpSql containsString:@" SELECT "] ) {
            res = NO;
            return ;
        }else {
            res = [db executeUpdate:sql];
            LOG_DB_ERROR(db);
        }

        //[db close];
    }];

    return res;
}

/******************************************************************/
/******************************************************************/
/******************************************************************/

-(BOOL)save:(id<BCORMEntityProtocol>)entity
{
    if (!self.dbQueue) {
        [self openDataBase];
    }
    if (!entity) {
        LogDB(@"\n\nERROR----->can update a nil obj;\n\n\r");
        return NO;
    }

    NSString* tableName = [self p_getTableNameWithClass:[entity class]];
    NSString* primaryKey = [self.tablePrimaryKeyMapping objectForKey:tableName];
    id propertyValue = [(NSObject*)entity valueForKey:primaryKey];
    assert(propertyValue);//primary ket property of the entity can not be null;
    id oldEntity  = [self queryEntityByCondition:BCQueryParameterMakeSimple([entity class], @[primaryKey], [NSString stringWithFormat:@"%@=?",primaryKey], @[propertyValue])];
    if (oldEntity) {
        [self update:entity];
        return YES;
    }

    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSMutableDictionary *dictionaryArgs;
        NSMutableString* insertSqlKey;
        if ([self p_buildInsertSql_Entity:entity andKeyString:&insertSqlKey andArgs:&dictionaryArgs]) {
            LogDB(@"save:\nSSQL:::[\n\r%@\n\r] \n args:%@",insertSqlKey,dictionaryArgs);
          res =   [db executeUpdate:insertSqlKey withParameterDictionary:dictionaryArgs] ;
         LOG_DB_ERROR(db);
        }
    }];
    return res;
}


/**
 *generater a insert sql by the entity
 *@param (id<BCORMEntityProtocol>)entity  the enetity to save.
 *@param (NSMutableString**)sql  the insert sql
 *@param (NSMutableDictionary**)dic the sql argument dictionary.
 *@return status
 **/
-(BOOL)p_buildInsertSql_Entity:(id<BCORMEntityProtocol>)entity andKeyString:(NSMutableString**)sql andArgs:(NSMutableDictionary**)dic
{
    
    Class entityClass = [entity class];
    NSDictionary* classTableMapping = [entityClass tableEntityMapping];
    NSString* tableName = [self p_getTableNameWithClass:entityClass];

    //build insert entity sql;
    *sql = [[NSMutableString alloc] init];
    *dic = [[NSMutableDictionary alloc] init];

    __block NSMutableDictionary *dictionaryArgs = *dic;
    __block NSMutableString* insertSqlKey =  *sql;
    [insertSqlKey appendFormat:@"INSERT INTO %@ ( ",tableName];
    __block NSMutableString* insertSqlValue = [[NSMutableString alloc] init];
    [insertSqlValue appendString:@") VALUES ("];
    NSInteger size  = [[classTableMapping allKeys]count];
    __block NSUInteger index  = 0;
    [classTableMapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) /*01*/{
        NSString* propertyName = key;
        BCSqliteType* sqlType = obj;
        id propertyValue = [(NSObject*)entity valueForKey:propertyName];
        LogDB(@" %@----%@---%@",propertyName,NSStringFromClass([propertyValue class]),propertyValue);
        if (propertyValue)/*001*/ {
            if (index < size - 1) {
                [insertSqlKey appendFormat:@"'%@',",sqlType.name];
                [insertSqlValue appendFormat:@":%@ ,",sqlType.name];
                [dictionaryArgs setObject:propertyValue forKey:sqlType.name];
            }else {
                [insertSqlKey appendFormat:@"'%@'",sqlType.name];
                [insertSqlValue appendFormat:@":%@ )",sqlType.name];
                [dictionaryArgs setObject:propertyValue forKey:sqlType.name];
            }
        }/*001*/
        index ++;

    }/*01*/];
    [insertSqlKey appendString:insertSqlValue];
    return  YES;
}


/******************************************************************/
/******************************************************************/
/******************************************************************/

/**
 *query a entity by the giving query condition.
 **/
-(id<BCORMEntityProtocol>)queryEntityByCondition:(BCSqlParameter*)condition
{
    if (!self.dbQueue) {
        [self openDataBase];
    }


    __block  id<BCORMEntityProtocol> entity = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString* selectSql = [self p_buildSelectSqlByCondition:condition];
        //[db open];
        LogDB(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\r");
        FMResultSet *result  = [db executeQuery:selectSql withArgumentsInArray:condition.selectionArgs];
        LogDB(@"queryEntityByCondition:\nSSQL:::[\n\r%@\n\r] \n  arg:%@",selectSql,condition.selectionArgs);
        LogDB(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\r");

        if ([result next]) {
            entity  = [self translateEntityFromFMResultSet:result queryCondition:condition];
            LogDB(@"queryEntityByCondition:\nSSQL:::[\n\r%@\n\r]",entity);
        }
        [result close];
        LOG_DB_ERROR(db);
        //[db close];
    }];


    return entity;
}


/**
 *query entities by the condition,return a array of entity;
 **/
-(NSArray*)queryEntitiesByCondition:(BCSqlParameter*)condition
{
    if (!self.dbQueue) {
        [self openDataBase];
    }
    __block  NSMutableArray* entities =  [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString* selectSql = [self p_buildSelectSqlByCondition:condition];
        //[db open];
        LogDB(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\r");
        FMResultSet *result  = [db executeQuery:selectSql withArgumentsInArray:condition.selectionArgs];
        LogDB(@"queryEntitiesByCondition:\nSSQL:::[\n\r%@\n\r] \n  arg:%@",selectSql,condition.selectionArgs);
        LogDB(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\r");

        while ([result next]) {
            id<BCORMEntityProtocol> entity  = [self translateEntityFromFMResultSet:result queryCondition:condition];
            LogDB(@"queryEntitiesByCondition:\nSSQL:::[\n\r%@\n\r]",entity);
            [entities addObject:entity];

        }
        [result close];
        LOG_DB_ERROR(db);
        //[db close];
    }];


    return entities;
}
/**
 *build a select sql by Query Condition entity.
 **/
-(NSString*)p_buildSelectSqlByCondition:(BCSqlParameter*)condition {
    Class entityClass = [condition entityClass];
    NSDictionary* classTableMapping = [entityClass tableEntityMapping];
    NSString* tableName = [self p_getTableNameWithClass:entityClass];
    __block NSMutableString* selectSql = [[NSMutableString alloc] initWithString:@"SELECT "];

    if (condition.propertyArray.count > 0)  /*001*/{
        NSInteger size = condition.propertyArray.count;
        [condition.propertyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* tmpPropertyName = obj;
            BCSqliteType* sqlType = [classTableMapping objectForKey:tmpPropertyName];
            assert(sqlType);
            if (idx < size - 1) {
                [selectSql appendFormat:@" %@, ",sqlType.name];
            }else {
                [selectSql appendFormat:@" %@ ",sqlType.name];
            }
        }];
    }else /*001*/{
        [selectSql appendString:@" * "];
    }/*001*/
    [selectSql appendFormat:@" FROM %@ ",tableName];
    //sort property key by lenght of string.
    NSArray* tmpProperties  = [classTableMapping allKeys];
    tmpProperties = [tmpProperties sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* item1 = obj1,  * item2 = obj2;
        if ( item1.length <  item2.length ) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    __block NSString* tmpSelection =  condition.selection;
    __block NSString* tmpOrderBy =  condition.orderBy;
    __block NSString* tmpGroupBy =  condition.groupBy;
    if (condition.selection || condition.orderBy || condition.groupBy) {
        [tmpProperties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* item1 = obj;
             BCSqliteType* sqlType = [classTableMapping objectForKey:item1];
            if ([tmpSelection containsString:item1]) {
                tmpSelection = [tmpSelection stringByReplacingOccurrencesOfString:item1 withString:sqlType.name];
            }
            if ([tmpGroupBy containsString:item1]) {
                tmpGroupBy = [tmpGroupBy stringByReplacingOccurrencesOfString:item1 withString:sqlType.name];
            }
            if ([tmpOrderBy containsString:item1]) {
                tmpOrderBy = [tmpOrderBy stringByReplacingOccurrencesOfString:item1 withString:sqlType.name];

            }
        }];
    }
    if (tmpSelection) {
        [selectSql appendFormat:@" WHERE %@ ",tmpSelection];
    }

    if (tmpGroupBy) {
        [selectSql appendFormat:@" GROUP BY %@ ",tmpGroupBy];
    }

    if (tmpOrderBy) {
        [selectSql appendFormat:@" ORDER BY %@ ",tmpOrderBy];
    }

    if (condition.offset > -1 && condition.count > -1) {
        [selectSql appendFormat:@" LIMIT %ld OFFSET %ld ",condition.count,condition.offset];
    }
    return selectSql;
}

/**
 *create a entity by  FMResultSet and query condition.
 **/
-(id<BCORMEntityProtocol>)translateEntityFromFMResultSet:(FMResultSet*)rs queryCondition:(BCSqlParameter*)condition
{
    Class entityClass = [condition entityClass];
    NSDictionary* classTableMapping = [entityClass tableEntityMapping];
    __block id entity  = [[entityClass alloc]init];
    NSArray* tmpProperties ;
    if (condition.propertyArray.count > 0)  /*001*/{
        tmpProperties = condition.propertyArray;
    }else {
        tmpProperties = [classTableMapping allKeys];
    }

    [tmpProperties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* tmpPropertyName  = obj;
        BCSqliteType* sqlType = [classTableMapping objectForKey:tmpPropertyName];
        objc_property_t tmpPropery = class_getProperty(entityClass, [tmpPropertyName UTF8String]);

        const char * type = property_getAttributes(tmpPropery);
        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        NSString * propertyType = [typeAttribute substringFromIndex:1];
        const char * rawPropertyType = [propertyType UTF8String];
        //https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        if (strcmp(rawPropertyType, @encode(CGFloat)) == 0 ||strcmp(rawPropertyType, @encode(float)) == 0 ||strcmp(rawPropertyType, @encode(double)) == 0 )/*0001*/ {
            //it's a float
            double value  = [rs  doubleForColumn:sqlType.name];
            [entity setValue:[NSNumber numberWithDouble:value] forKey:tmpPropertyName];
        } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
            //it's an int
            int  value  = [rs  intForColumn:sqlType.name];
            [entity setValue:[NSNumber numberWithInt:value] forKey:tmpPropertyName];
        } else if (strcmp(rawPropertyType, @encode(long)) == 0) {
            //it's a long
            long long  value  = [rs  longForColumn:sqlType.name];
            [entity setValue:[NSNumber numberWithLong:value] forKey:tmpPropertyName];

        } else if (strcmp(rawPropertyType, @encode(long long)) == 0) {
            //it's   long long
            long long  value  = [rs  longLongIntForColumn :sqlType.name];
            [entity setValue:[NSNumber numberWithLongLong:value] forKey:tmpPropertyName];

        } else if (strcmp(rawPropertyType, @encode(id)) == 0) {
            //it's some sort of object: id
            id value  = [rs  objectForColumnName:sqlType.name];
            [entity setValue:value forKey:tmpPropertyName];
        }  else if (strcmp(rawPropertyType, @encode(BOOL)) == 0 || strcmp(rawPropertyType, @encode(_Bool)) == 0) {
            //it's some sort of object: id
            BOOL value  = [rs  boolForColumn:sqlType.name];
            [entity setValue:[NSNumber numberWithBool:value] forKey:tmpPropertyName];

        } else {
            // According to Apples Documentation you can determine the corresponding encoding values
        }/*0001*/

        if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1)/*0001*/ {
            NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];  //turns @"NSDate" into NSDate
            Class typeClass = NSClassFromString(typeClassName);
            if (typeClass != nil) {
                if (typeClass == [NSDate class]) {
                    //nsdate
                    NSDate *value  = [rs  dateForColumn:sqlType.name];
                    if (value) {
                        [entity setValue:value forKey:tmpPropertyName];
                    }
                }else if (typeClass == [NSString class] ||typeClass == [NSMutableString class] ) {
                    //nsstring.
                    NSString* value  = [rs  stringForColumn:sqlType.name];
                    if (value) {
                        [entity setValue:value forKey:tmpPropertyName];
                    }
                }
            }
        }/*0001*/

    }];
    return entity;
}
/******************************************************************/
/******************************************************************/
/******************************************************************/



/**
 *save a entity to database.
 **/
-(BOOL)update:(id<BCORMEntityProtocol>)entity
{
    if (!self.dbQueue) {
        [self openDataBase];
    }

    if (!entity) {
        LogDB(@"\n\nERROR----->can update a nil obj;\n\n\r");
        return NO;
    }
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSMutableDictionary *dictionaryArgs;
        NSMutableString* insertSqlKey;
        if ([self p_buildUpdateSql_Entity:entity andKeyString:&insertSqlKey andArgs:&dictionaryArgs]) {
            LogDB(@"update:\nSSQL:::[\n\r%@\n\r] \n args:%@",insertSqlKey,dictionaryArgs);
            res =   [db executeUpdate:insertSqlKey withParameterDictionary:dictionaryArgs] ;
            LOG_DB_ERROR(db);
        }
    }];
    return res;
}

/**
 *generater a update sql by the entity
 *@param (id<BCORMEntityProtocol>)entity  the enetity to save.
 *@param (NSMutableString**)sql  the update sql
 *@param (NSMutableDictionary**)dic the sql argument dictionary.
 *@return status
 **/
-(BOOL)p_buildUpdateSql_Entity:(id<BCORMEntityProtocol>)entity andKeyString:(NSMutableString**)sql andArgs:(NSMutableDictionary**)dic
{
    Class entityClass = [entity class];
    NSDictionary* classTableMapping = [entityClass tableEntityMapping];
    NSString* tableName = [self p_getTableNameWithClass:entityClass];

    //build insert entity sql;
    *sql = [[NSMutableString alloc] init];
    *dic = [[NSMutableDictionary alloc] init];

    __block NSMutableDictionary *dictionaryArgs = *dic;
    __block NSMutableString* updateSqlKey =  *sql;
    [updateSqlKey appendFormat:@"UPDATE %@ SET ",tableName];

    NSInteger size  = [[classTableMapping allKeys]count];
    __block NSUInteger index  = 0;

    __block NSString* primaryKey = nil;
    [classTableMapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) /*01*/{
        NSString* propertyName = key;
        BCSqliteType* sqlType = obj;
        if (sqlType.constraints.primaryKey) {
            primaryKey = propertyName;
        }
        id propertyValue = [(NSObject*)entity valueForKey:propertyName];
        if (propertyValue)/*001*/ {
            if (index < size - 1) {
                [updateSqlKey appendFormat:@"%@ = :%@",sqlType.name,sqlType.name];
                [updateSqlKey appendString:@","];
                [dictionaryArgs setObject:propertyValue forKey:sqlType.name];

            }else {
                [updateSqlKey appendFormat:@"%@ = :%@",sqlType.name,sqlType.name];
                [dictionaryArgs setObject:propertyValue forKey:sqlType.name];
            }
        }/*001*/
        index ++;
    }/*01*/];
    assert( primaryKey );

    BCSqliteType* sqlType = [classTableMapping objectForKey:primaryKey];
    id propertyValue = [(NSObject*)entity valueForKey:primaryKey];
    [updateSqlKey appendFormat:@"  WHERE %@ ='%@'",sqlType.name,propertyValue];

    return  YES;

}


/**
 *execute a update sql with the special BCSqlParameter conditionl
 **/
-(BOOL)updateByCondition:(BCSqlParameter*)condition
{
    if (!self.dbQueue) {
        [self openDataBase];
    }
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString* updateSql = [self p_buildUpdateSqlByCondition:condition];
        NSMutableArray* updateArgs = [NSMutableArray arrayWithArray:condition.updateArgs];
        [updateArgs addObjectsFromArray:condition.selectionArgs];
        LogDB(@"updateByCondition:\nSSQL:::[\n\r%@\n\r] \n args:%@",updateSql,updateArgs);
        res = [db executeUpdate:updateSql withArgumentsInArray:updateArgs];
        LOG_DB_ERROR(db);
    }];
    return res;
}

/**
 *build a update sql by Query Condition entity.
 **/
-(NSString*)p_buildUpdateSqlByCondition:(BCSqlParameter*)condition
{
    Class entityClass = [condition entityClass];
    NSDictionary* classTableMapping = [entityClass tableEntityMapping];
    NSString* tableName = [self p_getTableNameWithClass:entityClass];
    __block NSMutableString* selectSql = [[NSMutableString alloc] initWithFormat:@"UPDATE %@ SET ",tableName];

    //sort property key by lenght of string.
    NSArray* tmpProperties  = [classTableMapping allKeys];
    LogDB(@"%@",tmpProperties);
    tmpProperties = [tmpProperties sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* item1 = obj1,  * item2 = obj2;
        if ( item1.length <  item2.length ) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    LogDB(@"%@",tmpProperties);
    __block NSString* tmpUpdate =  condition.update;
     __block NSString* tmpSelection =  condition.selection;
    
    if (condition.update || condition.selection ) {
        [tmpProperties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* item1 = obj;
            BCSqliteType* sqlType = [classTableMapping objectForKey:item1];
            if ([tmpUpdate containsString:item1]) {
                tmpUpdate = [tmpUpdate stringByReplacingOccurrencesOfString:item1 withString:sqlType.name];
            }

            if ([tmpSelection containsString:item1]) {
                tmpSelection = [tmpSelection stringByReplacingOccurrencesOfString:item1 withString:sqlType.name];
            }
        }];
    }
    if (tmpUpdate) {
        [selectSql appendFormat:@" %@ ",tmpUpdate];
    }

    if (tmpSelection) {
        [selectSql appendFormat:@" WHERE %@ ",tmpSelection];
    }
    return selectSql;
}

/******************************************************************/
/******************************************************************/
/**
 *delete a entity from database.
 **/
-(BOOL)remove:(id<BCORMEntityProtocol>)entity
{
    if (!self.dbQueue) {
        [self openDataBase];
    }
    if (!entity) {
        LogDB(@"\n\nERROR----->can remove a nil obj;\n\n\r");
        return NO;
    }
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSMutableString* deleteSql;
        if ([self p_buildDeleteSql_Entity:entity andKeyString:&deleteSql  ]) {
            LogDB(@"remove:\nSSQL:::[\n\r%@\n\r]",deleteSql);
            res =   [db executeUpdate:deleteSql] ;
            LOG_DB_ERROR(db);
        }
    }];
    return res;
}

/**
 *generater a delete sql by the entity
 *@param (id<BCORMEntityProtocol>)entity  the enetity to save.
 *@param (NSMutableString**)sql    the delete sql
 *@return status
 **/
-(BOOL)p_buildDeleteSql_Entity:(id<BCORMEntityProtocol>)entity andKeyString:(NSMutableString**)sql
{
    Class entityClass = [entity class];
    NSDictionary* classTableMapping = [entityClass tableEntityMapping];
    NSString* tableName = [self p_getTableNameWithClass:entityClass];
    //build insert entity sql;
    *sql = [[NSMutableString alloc] init];
    __block NSMutableString* updateSqlKey =  *sql;
    [updateSqlKey appendFormat:@"DELETE FROM %@ ",tableName];

    NSString* primaryKey = [self.tablePrimaryKeyMapping objectForKey:tableName];

    assert( primaryKey );
    BCSqliteType* sqlType = [classTableMapping objectForKey:primaryKey];
    id propertyValue = [(NSObject*)entity valueForKey:primaryKey];
    assert(propertyValue );
    [updateSqlKey appendFormat:@"  WHERE %@ ='%@'",sqlType.name,propertyValue];
    return YES;
}

/**
 *execute a delete sql with the special BCSqlParameter conditionl
 **/
-(BOOL)deleteByCondition:(BCSqlParameter*)condition
{
    if (!self.dbQueue) {
        [self openDataBase];
    }
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString* updateSql = [self p_buildDeleteSqlByCondition:condition];
        LogDB(@"deleteByCondition:\nSSQL:::[\n\r%@\n\r] \n args:%@",updateSql,condition.selectionArgs);
        res = [db executeUpdate:updateSql withArgumentsInArray:condition.selectionArgs];
        LOG_DB_ERROR(db);
    }];
    return res;
}


/**
 *build a delete sql by Query Condition entity.
 **/
-(NSString*)p_buildDeleteSqlByCondition:(BCSqlParameter*)condition
{
    Class entityClass = [condition entityClass];
    NSDictionary* classTableMapping = [entityClass tableEntityMapping];
    NSString* tableName = [self p_getTableNameWithClass:entityClass];
    __block NSMutableString* selectSql = [[NSMutableString alloc] initWithFormat:@"DELETE  FROM %@  ",tableName];

    //sort property key by lenght of string.
    NSArray* tmpProperties  = [classTableMapping allKeys];
    tmpProperties = [tmpProperties sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* item1 = obj1,  * item2 = obj2;
        if ( item1.length <  item2.length ) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    __block NSString* tmpSelection =  condition.selection;

    if ( condition.selection ) {
        [tmpProperties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* item1 = obj;
            BCSqliteType* sqlType = [classTableMapping objectForKey:item1];
            if ([tmpSelection containsString:item1]) {
                tmpSelection = [tmpSelection stringByReplacingOccurrencesOfString:item1 withString:sqlType.name];
            }
        }];
    }

    if (tmpSelection) {
        [selectSql appendFormat:@" WHERE %@ ",tmpSelection];
    }
    return selectSql;
    
}

/******************************************************************/


/**
 *execute a  sql with the special BCSqlParameter conditionl
 **/
-(BOOL)excuteByCondition:(BCSqlParameter*)condition
{

    if (condition.sqlType == BCParameterType_Update) {
        return [self updateByCondition:condition];
    }else if (condition.sqlType == BCParameterType_Delete) {
        return [self deleteByCondition:condition];
    }
    return NO;
}

@end
