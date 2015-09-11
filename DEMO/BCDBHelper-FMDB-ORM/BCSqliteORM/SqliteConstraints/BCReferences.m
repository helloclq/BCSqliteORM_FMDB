//
//  BCReferences.m
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/19/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCReferences.h"

@implementation BCReferences
-(instancetype)initWithName:(NSString*)name isClass:(Class)referenceClass withPropertyName:(NSString*) referencePropertyName
{

    if (self = [super init]) {
        _name = name;
        _referenceClass =  referenceClass;
        _referencePropertyName = referencePropertyName;
    }
    return self;
}
@end

BCReferences*
BCReferencesMake(NSString* name,Class referenceClass,NSString* referencePropertyName)
{
    return [[BCReferences alloc] initWithName:name isClass:referenceClass withPropertyName:referencePropertyName];
}