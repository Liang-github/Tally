//
//  CalculatorView.h
//  Tally
//
//  Created by PengLiang on 2017/11/28.
//  Copyright © 2017年 PengLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CareDataOperations.h"

typedef void (^PostionInViewBlock)(CGPoint point);

@protocol CalculatorViewDelegate <NSObject>
// 保存成功
- (void)tallySaveCompleted;
// 保存失败
- (void)tallySaveFailed;
// 回到原来的位置
- (void)backPositionWithAnimation;


@end
@interface CalculatorView : UIView
// 类型图片的size
@property (nonatomic, assign) CGSize imageViewSize;
// 类型图
@property (nonatomic, strong) UIImage *image;
// 类型名
@property (nonatomic, copy) NSString *typeName;
// 账单是否存在
@property (nonatomic, assign) BOOL isTallyExist;

@property (nonatomic, weak) id<CalculatorViewDelegate> delegate;
@property (nonatomic, copy) PostionInViewBlock positionInViewBlock;

- (void)modifyTallyWithIdentity:(NSString *)identity;
@end
