//
//  main.m
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/15/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCDB.h"
/******************************************************************/
/******************************************************************/
@interface ClassEntity : NSObject<BCORMEntityProtocol>
@property (nonatomic,assign)NSInteger classId;
@property (nonatomic,copy)NSString* className;
@end


@implementation ClassEntity
- (NSString *)description
{
    return [NSString stringWithFormat:@"[Class:id(%ld) name:(%@)]:%p",self.classId,self.className,self];
}

+(NSString*)tableName
{
    return @"class";
}

+(NSDictionary*)tableEntityMapping
{
    return @{ @"classId":BCSqliteTypeMakeIntPrimaryKey(@"id", YES),
              @"className":BCSqliteTypeMakeText(@"name", NO)
              };
}
@end
/******************************************************************/
/******************************************************************/

@interface StudentEntity : NSObject<BCORMEntityProtocol>
@property (nonatomic,assign)NSInteger classId;
@property (nonatomic,assign)int age;
@property (nonatomic,assign)float score;

@property (nonatomic,assign)NSInteger studentNum;
@property (nonatomic,copy)NSString* studentName;
@end


@implementation StudentEntity

- (NSString *)description
{
    return [NSString stringWithFormat:@"[student(%ld) name:(%@)]:%p",self.studentNum,self.studentName,self];
}

+(NSDictionary*)tableEntityMapping
{
    return @{ @"studentNum":BCSqliteTypeMakeIntPrimaryKey(@"num", NO),
              @"studentName":BCSqliteTypeMakeTextDefault(@"name", NO,@"blockcheng")
              ,
              @"age":BCSqliteTypeMakeIntDefault(@"age", NO,@"22")
              ,
              @"score":BCSqliteTypeMakeRealDefault(@"score", NO,@"80.0")
              ,
              @"classId":BCSqliteTypeMakeIntForeignKey(@"classid", YES, nil, @"Software01", [ClassEntity class], @"classId")
              };
}

/**
 * propertyName which should make as a index of the table----- table index;
 **/
+(NSArray*)tableIndexArray
{
    return @[@"studentNum",@"classId"];
}
@end
/******************************************************************/
/******************************************************************/
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //build two model
        ClassEntity* classeEntity = [ClassEntity new];
        classeEntity.className = @"Software02";
        classeEntity.classId = 1;

        StudentEntity* student = [StudentEntity new];
        student.age = 12;
        student.score = 80;
        student.classId = 1;
        student.studentNum = 421125;
        student.studentName = @"BlockCheng";

        //init and mapping ,or open an existing database file,
        BCORMHelper* helper = [[BCORMHelper alloc]initWithDatabaseName:@"test.db" enties: @[ [ClassEntity class],[StudentEntity class]]];

        
        //insert
        for (int i  = 0 ;i <  10; i ++) {
            classeEntity.classId =  i % 10;
            classeEntity.className = [NSString stringWithFormat:@"Class E_%d_%@",i,[NSDate date]];
            [helper save:classeEntity];
        }

        for (int i  = 0 ;i <  100; i ++) {
            student.studentNum = 421125 + i ;
            student.classId = i % 10 + 1;
            student.studentName = [NSString stringWithFormat:@"student_%d_%@",i,[NSDate date]];
             [helper save:student];
        }

        //query
        BCSqlParameter *queryParam  = [[BCSqlParameter  alloc] init];
        queryParam.entityClass = [StudentEntity class];
        queryParam.propertyArray = @[@"age",@"classId",@"score",@"studentName",@"studentNum"];
        queryParam.selection = @"classId = ? and studentNum=?";
        queryParam.selectionArgs = @[@1,@421125];
        queryParam.orderBy = @" studentNum  asc";
        id entity  = [helper queryEntityByCondition:queryParam];
        NSLog(@"entity:----%@",entity);

        //another way to query
        entity  = [helper queryEntityByCondition:BCQueryParameterMake([StudentEntity class], @[@"age",@"classId",@"score",@"studentName",@"studentNum"], @"classId = ? and studentNum=?", @[@1,@421128], nil,@" studentNum  asc",  -1, -1)];
        NSLog(@"entity:----%@",entity);

        //query many models
        queryParam.propertyArray = nil;
        queryParam.selection = @"classId = ?";
        queryParam.selectionArgs = @[@1];
        NSArray* entities  = [helper queryEntitiesByCondition:queryParam];
         NSLog(@"entities:----%@",entities);
        //query by condition
        entities  = [helper queryEntitiesByCondition:BCQueryParameterMake([ClassEntity class], nil, @"classId = ?", @[@1], nil, nil, -1, -1)];
         NSLog(@"entities:----%@",entities);

        //update a model
        student.studentName = @"BlockCheng_Update";
         [helper update:student];

        //query many model by condition
        entity  = [helper queryEntityByCondition:BCQueryParameterMakeSimple([StudentEntity class], nil, @"studentNum=?", @[@421138])];
        NSLog(@"entity:----%@",entity);

        //delete
        [helper remove:entity];

        //query many model by condition
        entity  = [helper queryEntityByCondition:BCQueryParameterMakeSimple([StudentEntity class], nil, @"studentNum=?", @[@421138])];
        NSLog(@"entity:----%@",entity);

        //update many model by condition
        [helper updateByCondition:BCUpdateParameterMake([StudentEntity class], @"studentName=?", @[@"new_name"], @"studentNum=?", @[@421125])];

        entity  = [helper queryEntityByCondition:BCQueryParameterMakeSimple([StudentEntity class], nil, @"studentNum=?", @[@421125])];
        NSLog(@"entity:----%@",entity);

        //delete by condition
        [helper deleteByCondition:BCDeleteParameterMake([StudentEntity class],  @"studentNum < ?", @[@421135])];

    }
    return 0;
}
