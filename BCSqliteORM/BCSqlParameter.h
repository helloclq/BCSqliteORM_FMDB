//
//  BCSqlParameter.h
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 9/6/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCORMHeader.h"

typedef NS_ENUM(NSInteger, BCParameterType) {
    BCParameterType_Query  = 0,//query
    BCParameterType_Update   = 1<<1,// update
    BCParameterType_Delete  = 1<<2,//  delete

};

@class BCSqlParameter;
BC_EXTERN BCSqlParameter*
BCQueryParameterMake(Class entityClass,NSArray* propertyArray,NSString* selection,NSArray* selectionArgs,NSString* groupBy,NSString* orderBy,NSInteger count,NSInteger offset) ;


BC_EXTERN BCSqlParameter*
BCQueryParameterMakeSimple(Class entityClass,NSArray* propertyArray,NSString* selection,NSArray* selectionArgs) ;


BC_EXTERN BCSqlParameter*
BCDeleteParameterMake(Class entityClass,NSString* selection,NSArray* selectionArgs) ;


BC_EXTERN BCSqlParameter*
BCUpdateParameterMake(Class entityClass,NSString* update,NSArray* updateArgs,NSString* selection,NSArray* selectionArgs) ;






@interface BCSqlParameter : NSObject

@property(assign,nonatomic)BCParameterType sqlType;//sql type
@property(assign,nonatomic)Class entityClass;//[ClassEntity class]
///property ,which property to get
@property(strong,nonatomic)NSArray* propertyArray;//@[@"ClassId",@"className"];

///where part
@property(strong,nonatomic)NSString* selection;//@"  ClassId = ? AND  "
@property(strong,nonatomic)NSArray* selectionArgs;

///update set part
@property(strong,nonatomic)NSString* update;//@"  className = ?  "
@property(strong,nonatomic)NSArray* updateArgs;//@[@"Level6"]

//group by
@property(strong,nonatomic)NSString* groupBy;
@property(strong,nonatomic)NSString* orderBy;

//limit
@property(assign,nonatomic)NSInteger offset;
@property(assign,nonatomic)NSInteger count;

@end




