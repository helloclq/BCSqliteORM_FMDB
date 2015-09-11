//
//  BCSqliteType.h
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCConstraints.h"
#import "BCReferences.h"


@interface BCSqliteType : NSObject

@property (nonatomic,copy)NSString* name;//table column name;

@property (nonatomic,copy)NSString* defalutValue;//default value

@property (nonatomic,strong)BCConstraints* constraints;//constraints
/**
 *when constraints.foreign == YES, reference should be inited;
 *CONSTRAINT "request_tripid" FOREIGN KEY ("tripId") REFERENCES "trip" ("tripId")
 **/
@property (nonatomic,strong)BCReferences*  reference;


-(instancetype)init;

-(instancetype)initWithName:(NSString*)name isPrimaryKey:(BOOL)isPrimaryKey isAllowNull:(BOOL)isAllowNull isUnique:(BOOL)isUnique  autoIncrement:(BOOL)autoIncrement;

-(instancetype)initWithName:(NSString*)name isPrimaryKey:(BOOL)isPrimaryKey isAllowNull:(BOOL)isAllowNull isUnique:(BOOL)isUnique  autoIncrement:(BOOL)autoIncrement defaultValue:(NSString*)dv;

-(instancetype)initWithName:(NSString*)name isPrimaryKey:(BOOL)isPrimaryKey isAllowNull:(BOOL)isAllowNull isUnique:(BOOL)isUnique  autoIncrement:(BOOL)autoIncrement  defaultValue:(NSString*)dv isForeignKey:(BOOL)isForeignKey foreignName:(NSString*)foreignName referenceClass:(Class)cls referencePropertyName:(NSString*)referenceProperty;
@end

