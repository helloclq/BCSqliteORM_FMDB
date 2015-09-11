//
//  BCSqlParameter.m
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 9/6/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCSqlParameter.h"

@implementation BCSqlParameter
-(id)init {
    self  = [super init];
    if (self) {
        self.offset = -1;
        self.count = -1;
        self.sqlType  = BCParameterType_Query;
    }
    return self;
}

@end


BCSqlParameter*
BCQueryParameterMake(Class entityClass,NSArray* propertyArray,NSString* selection,NSArray* selectionArgs,NSString* groupBy,NSString* orderBy,NSInteger count,NSInteger offset)
{
    BCSqlParameter* entity  = [[BCSqlParameter alloc]init];
    entity.entityClass  = entityClass;
    entity.propertyArray = propertyArray;

    entity.selection = selection;
    entity.selectionArgs = selectionArgs;
    entity.groupBy = groupBy;

    entity.orderBy = orderBy;
    entity.count = count;
    entity.offset = offset;

    entity.sqlType  = BCParameterType_Query;

    return entity;
}

BCSqlParameter*
BCQueryParameterMakeSimple(Class entityClass,NSArray* propertyArray,NSString* selection,NSArray* selectionArgs)
{
    return BCQueryParameterMake(entityClass, propertyArray, selection, selectionArgs, nil, nil, -1, -1);
}



BCSqlParameter*
BCDeleteParameterMake(Class entityClass,NSString* selection,NSArray* selectionArgs)
{
    BCSqlParameter* entity  = [[BCSqlParameter alloc]init];
    entity.entityClass  = entityClass;
    entity.selection = selection;
    entity.selectionArgs = selectionArgs;

    entity.sqlType  = BCParameterType_Delete;
    return entity;
}

BCSqlParameter*
BCUpdateParameterMake(Class entityClass,NSString* update,NSArray* updateArgs,NSString* selection,NSArray* selectionArgs)
{
    BCSqlParameter* entity  = [[BCSqlParameter alloc]init];
    entity.entityClass  = entityClass;
    entity.selection = selection;
    entity.selectionArgs = selectionArgs;

    entity.update = update;
    entity.updateArgs = updateArgs;
    entity.sqlType  = BCParameterType_Update;
    return entity;
}

