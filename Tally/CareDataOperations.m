//
//  CareDataOperations.m
//  Tally
//
//  Created by PengLiang on 2017/11/28.
//  Copyright © 2017年 PengLiang. All rights reserved.
//

#import "CareDataOperations.h"



@implementation CareDataOperations
static CareDataOperations *instance = nil;

+ (instancetype)sharedInstance {
    return [[CareDataOperations alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}
- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super init];
        if (instance) {
            instance.manageObjectContex = ((AppDelegate *)[UIApplication sharedApplication].delegate).persistentContainer.viewContext;
        }
    });
    return instance;
}
// 从数据库中删除 Tally中某一数据
- (void)deleateTally:(Tally *)object {
    [self.manageObjectContex deleteObject:object];
}
// 保存
- (void)saveTally {
    [self.manageObjectContex save:nil];
}
// 读取对应的字段
- (Tally *)getTallyWithIdentity:(NSString *)identity {
    NSFetchRequest *fetchRequest = [Tally fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identity = %@",identity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.manageObjectContex executeFetchRequest:fetchRequest error:&error];
    
    return [fetchedObjects firstObject];
}
// 获取对应类型
- (TallyType *)getTallyTapeWithTypeName:(NSString *)typeName {
    // 设置账单类型
    NSFetchRequest *ftype = [TallyType fetchRequest];
    NSPredicate *ptype = [NSPredicate predicateWithFormat:@"typename = %@",typeName];
    ftype.predicate = ptype;
    NSArray<TallyType *> *sstype = [self.manageObjectContex executeFetchRequest:ftype error:nil];
    return [sstype firstObject];
}
// 读取数据库的数据 以字典的形式 key:@"日期" object:[账单信息]
- (NSDictionary *)getAllDataWithDict {
    // 线查询日期 遍历日期表
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TallyDate" inManagedObjectContext:self.manageObjectContex];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    NSError *error = nil;
    NSArray<TallyDate *> *fetchedObjects = [self.manageObjectContex executeFetchRequest:fetchRequest error:&error];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (TallyDate *date in fetchedObjects) {
        NSString *key = date.date;
        NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"Tally" inManagedObjectContext:self.manageObjectContex];
        [fetchRequest2 setEntity:entity2];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateship.date = %@",key];
        [fetchRequest2 setPredicate:predicate];
        
        NSSortDescriptor *sortDesriptor2 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        [fetchRequest2 setSortDescriptors:[NSArray arrayWithObjects:sortDesriptor2, nil]];
        NSError *error = nil;
        NSArray<Tally *> *fetchedObjects2 = [self.manageObjectContex executeFetchRequest:fetchRequest2 error:&error];
        NSMutableArray *array = [NSMutableArray array];
        for (Tally *tally in fetchedObjects2) {
            TimeLineModel *model = [[TimeLineModel alloc] init];
            model.tallyIconName = tally.typeship.typeicon;
            model.tallyMoney = tally.income > 0 ? tally.income : tally.expenses;
            model.tallyMoneyType = tally.income > 0 ? TallyMoneyTypeIn : TallyMoneyTypeOut;
            model.tallyType = tally.typeship.typename;
            model.identity = tally.identity;
            model.income = tally.income;
            model.expense = tally.expenses;
            
            [array addObject:model];
        }
        [dict setObject:array forKey:key];
    }
    return dict;
}
@end
