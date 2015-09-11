//
//  BCSqliteType.m
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCSqliteType.h"



@implementation BCSqliteType

-(instancetype)init
{
    if (self = [super init]) {
        _constraints = BCConstraintsDefault();
        
    }
    return self;
}

-(instancetype)initWithName:(NSString*)name isPrimaryKey:(BOOL)isPrimaryKey isAllowNull:(BOOL)isAllowNull isUnique:(BOOL)isUnique  autoIncrement:(BOOL)autoIncrement
{
    if (self = [super init]) {
        _constraints = BCConstraintsMake(isPrimaryKey, isAllowNull, isUnique,autoIncrement,NO);
        _name = name;
    }
    return self;

}

-(instancetype)initWithName:(NSString*)name isPrimaryKey:(BOOL)isPrimaryKey isAllowNull:(BOOL)isAllowNull isUnique:(BOOL)isUnique  autoIncrement:(BOOL)autoIncrement defaultValue:(NSString*)v
{
    if (self = [super init]) {
        _constraints = BCConstraintsMake(isPrimaryKey, isAllowNull, isUnique,autoIncrement,NO);
        _name = name;
        _defalutValue = v;
    }
    return self;

}


-(instancetype)initWithName:(NSString*)name isPrimaryKey:(BOOL)isPrimaryKey isAllowNull:(BOOL)isAllowNull isUnique:(BOOL)isUnique  autoIncrement:(BOOL)autoIncrement  defaultValue:(NSString*)dv isForeignKey:(BOOL)isForeignKey foreignName:(NSString*)foreignName referenceClass:(Class)cls referencePropertyName:(NSString*)referenceProperty
{

    if (self = [super init]) {
        _constraints = BCConstraintsMake(isPrimaryKey, isAllowNull, isUnique,autoIncrement,YES);
        _name = name;
        _defalutValue = dv;
        _reference = BCReferencesMake(foreignName, cls, referenceProperty);
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"SqliteType:{ %@----[%@]-----[%@]}",self.name,self.constraints,self.reference];
}
@end
