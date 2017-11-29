//
//  TallyListCellModel.m
//  Tally
//
//  Created by PengLiang on 2017/11/28.
//  Copyright © 2017年 PengLiang. All rights reserved.
//

#import "TallyListCellModel.h"

@implementation TallyListCellModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+ (instancetype)tallyListCellModelWithDict:(NSDictionary *)dict {
    return [[TallyListCellModel alloc] initWithDict:dict];
}
@end
