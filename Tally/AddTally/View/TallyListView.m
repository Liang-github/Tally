//
//  TallyListView.m
//  Tally
//
//  Created by PengLiang on 2017/11/28.
//  Copyright © 2017年 PengLiang. All rights reserved.
//

#import "TallyListView.h"
@interface TallyListView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy) NSArray *tallyListArray;

@property (nonatomic, assign) CGFloat offSety;
@end

static NSString *cellId = @"tallyListCellId";

@implementation TallyListView
// 读取plist数据
- (NSArray *)tallyListArray {
    if (!_tallyListArray) {
        NSMutableArray *res = [NSMutableArray array];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"TallyList" ofType:@"plist"];
        NSArray *list = [NSArray arrayWithContentsOfFile:path];
        for (NSDictionary *dict in list) {
            TallyListCellModel *model = [TallyListCellModel tallyListCellModelWithDict:dict];
            [res addObject:model];
        }
        _tallyListArray = [NSArray arrayWithArray:res];
        [self writeToSqlite];
    }
    return _tallyListArray;
}
- (void)writeToSqlite {
    // 将类型名字和图片信息写入数据库
    for (TallyListCellModel *model in self.tallyListArray) {
        TallyType *ssr = [[CareDataOperations sharedInstance] getTallyTapeWithTypeName:model.tallyCellName];
        if (ssr == nil) {
            TallyType *type = [[TallyType alloc] initWithContext:[CareDataOperations sharedInstance].manageObjectContex];
            type.typename = model.tallyCellName;
            type.typeicon = model.tallyCellImage;
            [[CareDataOperations sharedInstance] saveTally];
        }
    }
}
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor clearColor];
        [self registerNib:[UINib nibWithNibName:@"TallyListCell" bundle:nil] forCellWithReuseIdentifier:cellId];
    }
    return self;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tallyListArray.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TallyListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.cellModel = self.tallyListArray[indexPath.item];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TallyListCell *cell = (TallyListCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect cellRect = [collectionView convertRect:cell.frame toView:collectionView];
    
    CGRect imageCellRect = cell.imageView.frame;
    CGFloat x = cellRect.origin.x + imageCellRect.origin.x;
    CGFloat y = cellRect.origin.y + imageCellRect.origin.y + 64 - self.offSety;
    
    CGRect imgRect = CGRectMake(x, y, imageCellRect.size.width, imageCellRect.size.height);
    // 回调
    if ([_customDelegate respondsToSelector:@selector(didSelectItem:andTitle:withRectInCollection:)]) {
        [_customDelegate didSelectItem:cell.imageView.image andTitle:cell.imageLab.text withRectInCollection:imgRect];
    }
}

@end
