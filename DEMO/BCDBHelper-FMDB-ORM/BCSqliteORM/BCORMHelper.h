//
//  BCORMHelper.h
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCORMHeader.h"

#if DBLOGOPEN
    #define LOG_DB_ERROR(DB) \
    if ([DB hadError]) \
    NSLog(@"DB [%d] Error %d: %@",__LINE__, [DB lastErrorCode], [DB lastErrorMessage])
    #else
    #define LOG_DB_ERROR(...)
#endif

#define FILE_DATABASE  @"BCDatabase"

@protocol  BCORMEntityProtocol;
@protocol  ORMDatabaseProtocol;

@class BCSqlParameter;

@interface BCORMHelper : NSObject

/**
 * init db with such as "documents/" + fileName + ".db"
 *@param (NSString*)databaseName
 *@return BCORMHelper instance;
 */
-(instancetype)initWithDatabaseName:(NSString*)databaseName enties:(NSArray*)entities;
-(void)setDatabaseName:(NSString*)fileName;

/**
 *@param (NSString*)databaseFilePath
 *@return BCORMHelper instance;
 */
-(instancetype)initWithDatabasePath:(NSString*)databaseFilePath  enties:(NSArray*)entities;
-(void)setDatabasePath:(NSString*)filePath;

/******************************************************************/
/******************************************************************/
/**
 *execute a sql;
 **/
-(BOOL)executeUpdateSql:(NSString*)sql;


/******************************************************************/
/******************************************************************/

/**
 *save a entity to database.
 **/
-(BOOL)save:(id<BCORMEntityProtocol>)entity;


/******************************************************************/
/******************************************************************/
/**
 *query a entity by the giving query condition.
 **/
-(id<BCORMEntityProtocol>)queryEntityByCondition:(BCSqlParameter*)condition;

/**
 *query entities by the query condition,return a array of entity;
 **/
-(NSArray*)queryEntitiesByCondition:(BCSqlParameter*)condition;

/******************************************************************/
/******************************************************************/
/**
 *save a entity to database.
 **/
-(BOOL)update:(id<BCORMEntityProtocol>)entity;


/**
 *execute a update sql with the special BCSqlParameter conditionl
 **/
-(BOOL)updateByCondition:(BCSqlParameter*)condition;

/******************************************************************/
/******************************************************************/

/**
 *delete a entity from database.
 **/
-(BOOL)remove:(id<BCORMEntityProtocol>)entity;

/**
 *execute a delete sql with the special BCSqlParameter conditionl
 **/
-(BOOL)deleteByCondition:(BCSqlParameter*)condition;

/******************************************************************/


/**
 *execute a  sql with the special BCSqlParameter conditionl
 **/
-(BOOL)excuteByCondition:(BCSqlParameter*)condition;

@end
