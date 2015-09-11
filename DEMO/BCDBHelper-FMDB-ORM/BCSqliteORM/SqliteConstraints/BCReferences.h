//
//  BCReferences.h
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/19/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCORMHeader.h"
#import <objc/runtime.h>


@class BCReferences;

BC_EXTERN BCReferences*
    BCReferencesMake(NSString* name,Class referenceClass,NSString* referencePropertyName) ;

//CONSTRAINT "request_tripid" FOREIGN KEY ("tripId") REFERENCES "trip" ("tripId")
@interface BCReferences : NSObject

@property (nonatomic,copy)NSString* name;

@property (nonatomic,assign)Class referenceClass;
@property (nonatomic,copy)NSString* referencePropertyName;

-(instancetype)initWithName:(NSString*)name isClass:(Class)referenceClass withPropertyName:(NSString*) referencePropertyName;
@end


