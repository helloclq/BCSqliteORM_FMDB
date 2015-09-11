//
//  BCSqlReal.m
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCSqlReal.h"

@implementation BCSqlReal

@end


BCSqlReal*
BCSqliteTypeMakeReal(NSString* tableColumnName,BOOL isAllowNull)
{
    return [[BCSqlReal alloc] initWithName:tableColumnName isPrimaryKey:NO isAllowNull:isAllowNull isUnique:NO autoIncrement:NO];
}

BCSqlReal*
BCSqliteTypeMakeRealPrimaryKey(NSString* tableColumnName,BOOL autoIncrement)
{
    return [[BCSqlReal alloc] initWithName:tableColumnName isPrimaryKey:YES isAllowNull:NO isUnique:YES autoIncrement:autoIncrement];
}

BCSqlReal*
BCSqliteTypeMakeRealDefault(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue)
{
    return [[BCSqlReal alloc] initWithName:tableColumnName isPrimaryKey:NO isAllowNull:isAllowNull isUnique:NO  autoIncrement:NO defaultValue:defaultValue];
}

BCSqlReal*
BCSqliteTypeMakeRealFull(NSString* tableColumnName,BOOL isPrimaryKey,BOOL isAllowNull,BOOL isUq,BOOL autoIncrement,NSString* defaultValue)
{
    return [[BCSqlReal alloc] initWithName:tableColumnName isPrimaryKey:isPrimaryKey isAllowNull:isAllowNull isUnique:isUq  autoIncrement:autoIncrement defaultValue:defaultValue];
}

BC_EXTERN BCSqlReal*
BCSqliteTypeMakeRealForeignKey(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue,NSString* foreignName,Class referenceClass,NSString* referencePropertyName)
{
    return [[BCSqlReal alloc] initWithName:tableColumnName isPrimaryKey:NO isAllowNull:isAllowNull isUnique:NO  autoIncrement:NO defaultValue:defaultValue isForeignKey:YES foreignName:foreignName referenceClass:referenceClass referencePropertyName:referencePropertyName];
}