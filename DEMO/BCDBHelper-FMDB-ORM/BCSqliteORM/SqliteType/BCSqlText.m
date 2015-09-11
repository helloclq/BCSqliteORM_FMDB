//
//  BCSqlText.m
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCSqlText.h"

@implementation BCSqlText

@end


BCSqlText*
BCSqliteTypeMakeText(NSString* tableColumnName,BOOL isAllowNull)
{
    return [[BCSqlText alloc] initWithName:tableColumnName isPrimaryKey:NO isAllowNull:isAllowNull isUnique:NO autoIncrement:NO];
}

BCSqlText*
BCSqliteTypeMakeTextPrimaryKey(NSString* tableColumnName,BOOL autoIncrement)
{
    return [[BCSqlText alloc] initWithName:tableColumnName isPrimaryKey:YES isAllowNull:NO isUnique:YES autoIncrement:autoIncrement];
}

BCSqlText*
BCSqliteTypeMakeTextDefault(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue)
{
    return [[BCSqlText alloc] initWithName:tableColumnName isPrimaryKey:NO isAllowNull:isAllowNull isUnique:NO  autoIncrement:NO defaultValue:defaultValue];
}

BCSqlText*
BCSqliteTypeMakeTextFull(NSString* tableColumnName,BOOL isPrimaryKey,BOOL isAllowNull,BOOL isUq,BOOL autoIncrement,NSString* defaultValue)
{
    return [[BCSqlText alloc] initWithName:tableColumnName isPrimaryKey:isPrimaryKey isAllowNull:isAllowNull isUnique:isUq  autoIncrement:autoIncrement defaultValue:defaultValue];
}

BC_EXTERN BCSqlText*
BCSqliteTypeMakeTextForeignKey(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue,NSString* foreignName,Class referenceClass,NSString* referencePropertyName)
{
    return [[BCSqlText alloc] initWithName:tableColumnName isPrimaryKey:NO isAllowNull:isAllowNull isUnique:NO  autoIncrement:NO defaultValue:defaultValue isForeignKey:YES foreignName:foreignName referenceClass:referenceClass referencePropertyName:referencePropertyName];
}