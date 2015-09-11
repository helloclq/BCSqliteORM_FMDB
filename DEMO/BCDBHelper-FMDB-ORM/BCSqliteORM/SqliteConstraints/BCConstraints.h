//
//  BCConstraints.h
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCORMHeader.h"
@class BCConstraints;

BC_EXTERN BCConstraints*
    BCConstraintsMake(BOOL isPrimaryKey,BOOL isAllowNull,BOOL isUnique,BOOL autoIncrement,BOOL isForeign) ;

BC_EXTERN BCConstraints*
    BCConstraintsDefault() ;


@interface BCConstraints : NSObject

@property (nonatomic,assign)BOOL primaryKey;
@property (nonatomic,assign)BOOL allowNull;
@property (nonatomic,assign)BOOL unique;

@property (nonatomic,assign)BOOL autoIncrement;

@property (nonatomic,assign)BOOL foreign;

-(instancetype)init;
-(instancetype)initWithIsPrimaryKey:(BOOL)isPrimaryKey isAllowNull:(BOOL)isAllowNull isUnique:(BOOL)isUnique autoIncrement:(BOOL)autoIncrement isForeign:(BOOL)foreign;

@end


