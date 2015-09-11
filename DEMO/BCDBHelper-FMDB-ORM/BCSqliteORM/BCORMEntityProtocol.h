//
//  BCORMEntityProtocol.h
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BCORMEntityProtocol <NSObject>

@required
/**
 *propertyName: databaseInfo;
 **/
+(NSDictionary*)tableEntityMapping;


@optional
+(NSString*)tableName;





/**
 *propertyName----- table index;
 **/
+(NSArray*)tableIndexArray;

@end
