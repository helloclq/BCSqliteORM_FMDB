//
//  BCConstraints.m
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCConstraints.h"

@implementation BCConstraints
-(instancetype)init
{
    if (self = [super init]) {
        _primaryKey = NO;
        _allowNull =  YES;
        _unique = NO;
        _autoIncrement = NO;
        _foreign = NO;
    }
    return self;
}

-(instancetype)initWithIsPrimaryKey:(BOOL)isPrimaryKey isAllowNull:(BOOL)isAllowNull isUnique:(BOOL)isUnique  autoIncrement:(BOOL)autoIncrement  isForeign:(BOOL)foreign
{
    if (self = [super init]) {
        _primaryKey = isPrimaryKey;
        _allowNull =  isAllowNull;
        _unique = isUnique;
        _autoIncrement = autoIncrement;
        _foreign =foreign;
    }
    return self;
}


-(NSString*)description {
    return [NSString stringWithFormat:@"BCConstraints: %d----%d-----%d",self.primaryKey,self.allowNull,self.foreign];
}
@end

BCConstraints*
BCConstraintsMake(BOOL isPrimaryKey,BOOL isAllowNull,BOOL isUnique,BOOL autoIncrement,BOOL isForeign) {
    return  [[BCConstraints alloc]initWithIsPrimaryKey:isPrimaryKey isAllowNull:isAllowNull isUnique:isUnique autoIncrement:autoIncrement isForeign:isForeign];
};

BCConstraints*
BCConstraintsDefault() {
    return  [[BCConstraints alloc]init];
}
