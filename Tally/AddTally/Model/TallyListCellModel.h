//
//  TallyListCellModel.h
//  Tally
//
//  Created by PengLiang on 2017/11/28.
//  Copyright © 2017年 PengLiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TallyListCellModel : NSObject

@property (nonatomic, copy) NSString *tallyCellImage;
@property (nonatomic, copy) NSString *tallyCellName;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)tallyListCellModelWithDict:(NSDictionary *)dict;
@end
