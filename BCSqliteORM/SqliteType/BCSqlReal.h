//
//  BCSqlReal.h
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCSqliteType.h"
@class BCSqlReal;


BC_EXTERN BCSqlReal*
    BCSqliteTypeMakeReal(NSString* tableColumnName,BOOL isAllowNull);

BC_EXTERN BCSqlReal*
    BCSqliteTypeMakeRealPrimaryKey(NSString* tableColumnName,BOOL autoIncrement);

BC_EXTERN BCSqlReal*
    BCSqliteTypeMakeRealDefault(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue);

BC_EXTERN BCSqlReal*
    BCSqliteTypeMakeRealFull(NSString* tableColumnName,BOOL isPrimaryKey,BOOL isAllowNull,BOOL isUq,BOOL autoIncrement,NSString* defaultValue);

BC_EXTERN BCSqlReal*
    BCSqliteTypeMakeRealForeignKey(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue,NSString* foreignName,Class referenceClass,NSString* referencePropertyName);




@interface BCSqlReal : BCSqliteType

@end

