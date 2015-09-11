//
//  BCSqlText.h
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import "BCSqliteType.h"
@class BCSqlText;

BC_EXTERN BCSqlText*
    BCSqliteTypeMakeText(NSString* tableColumnName,BOOL isAllowNull);

BC_EXTERN BCSqlText*
    BCSqliteTypeMakeTextPrimaryKey(NSString* tableColumnName,BOOL autoIncrement);

BC_EXTERN BCSqlText*
    BCSqliteTypeMakeTextDefault(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue);

BC_EXTERN BCSqlText*
    BCSqliteTypeMakeTextFull(NSString* tableColumnName,BOOL isPrimaryKey,BOOL isAllowNull,BOOL isUq,BOOL autoIncrement,NSString* defaultValue);

BC_EXTERN BCSqlText*
    BCSqliteTypeMakeTextForeignKey(NSString* tableColumnName,BOOL isAllowNull,NSString* defaultValue,NSString* foreignName,Class referenceClass,NSString* referencePropertyName);



@interface BCSqlText : BCSqliteType


@end


