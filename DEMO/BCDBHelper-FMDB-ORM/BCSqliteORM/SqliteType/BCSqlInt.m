//
//  BCSqlInt.m
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCSqlInt.h"


@implementation BCSqlInt



@end



BCSqlInt*
BCSqliteTypeMakeInt(NSString* tableColumnName,BOOL isAllowNull)
{
     return [[BCSqlInt alloc] initWithName:tableColumnName isPrimaryKey:NO isAllowNull:isAllowNull isUnique:NO autoIncrement:NO];
}

BCSqlInt*
BCSqliteTypeMakeIntPrimaryKey(NSString* tableColumnName,BOOL autoIncrement)
{
    return [[BCSqlInt alloc] initWithName:tableColumnName isPrimaryKey:YES isAllowNull:NO isUnique:YES autoIncrement:autoIncrement];
}

BCSqlInt*
BCSqliteTypeMakeIntDefault(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue)
{
    return [[BCSqlInt alloc] initWithName:tableColumnName isPrimaryKey:NO isAllowNull:isAllowNull isUnique:NO  autoIncrement:NO defaultValue:defaultValue];
}

BCSqlInt*
BCSqliteTypeMakeIntFull(NSString* tableColumnName,BOOL isPrimaryKey,BOOL isAllowNull,BOOL isUq,BOOL autoIncrement,NSString* defaultValue)
{
    return [[BCSqlInt alloc] initWithName:tableColumnName isPrimaryKey:isPrimaryKey isAllowNull:isAllowNull isUnique:isUq  autoIncrement:autoIncrement defaultValue:defaultValue];
}

BC_EXTERN BCSqlInt*
BCSqliteTypeMakeIntForeignKey(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue,NSString* foreignName,Class referenceClass,NSString* referencePropertyName)
{
    return [[BCSqlInt alloc] initWithName:tableColumnName isPrimaryKey:NO isAllowNull:isAllowNull isUnique:NO  autoIncrement:NO defaultValue:defaultValue isForeignKey:YES foreignName:foreignName referenceClass:referenceClass referencePropertyName:referencePropertyName];
}