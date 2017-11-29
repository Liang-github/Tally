//
//  CareDataOperations.h
//  Tally
//
//  Created by PengLiang on 2017/11/28.
//  Copyright © 2017年 PengLiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Tally+CoreDataModel.h"
#import "TimeLineModel.h"
#import "AppDelegate.h"

@interface CareDataOperations : NSObject

@property (nonatomic, strong) NSManagedObjectContext *manageObjectContex;

+ (instancetype)sharedInstance;

- (void)deleateTally:(Tally *)object;

- (void)saveTally;

- (Tally *)getTallyWithIdentity:(NSString *)identity;
// 获取对应类型
- (TallyType *)getTallyTapeWithTypeName:(NSString *)typeName;
- (NSDictionary *)getAllDataWithDict;
@end
