//
//  BCSqlInt.h
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCSqliteType.h"

@class BCSqlInt;

BC_EXTERN BCSqlInt*
    BCSqliteTypeMakeInt(NSString* tableColumnName,BOOL isAllowNull);

BC_EXTERN BCSqlInt*
    BCSqliteTypeMakeIntPrimaryKey(NSString* tableColumnName,BOOL autoIncrement);

BC_EXTERN BCSqlInt*
    BCSqliteTypeMakeIntDefault(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue);

BC_EXTERN BCSqlInt*
    BCSqliteTypeMakeIntFull(NSString* tableColumnName,BOOL isPrimaryKey,BOOL isAllowNull,BOOL isUq,BOOL autoIncrement,NSString* defaultValue);


BC_EXTERN BCSqlInt*
    BCSqliteTypeMakeIntForeignKey(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue,NSString* foreignName,Class referenceClass,NSString* referencePropertyName);

@interface BCSqlInt : BCSqliteType
 
@end

