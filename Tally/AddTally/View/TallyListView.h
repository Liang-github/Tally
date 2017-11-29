//
//  TallyListView.h
//  Tally
//
//  Created by PengLiang on 2017/11/28.
//  Copyright © 2017年 PengLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Tally+CoreDataModel.h"
#import "AppDelegate.h"
#import "CareDataOperations.h"
#import "TallyListCell.h"

@protocol TallyListViewDelegate <NSObject>

- (void)didSelectItem:(UIImage *)cellImage andTitle:(NSString *)title withRectInCollection:(CGRect)itemRect;

- (void)listScrollToBottom;

@end

@interface TallyListView : UICollectionView

@property (nonatomic, strong) id<TallyListViewDelegate> customDelegate;

@end
