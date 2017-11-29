//
//  ViewController.m
//  Tally
//
//  Created by PengLiang on 2017/11/28.
//  Copyright © 2017年 PengLiang. All rights reserved.
//

#import "ViewController.h"
#import "TimeLineView.h"
#import "AddTallyViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<TimeLineViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSDictionary *timeLineModelsDict;
@property (nonatomic, assign) CGFloat allDateAllLine;

@property (nonatomic, strong) UILabel *incomLab;
@property (nonatomic, strong) UILabel *expenseLab;

@property (nonatomic, strong) UIButton *addTallyBtn;


@end

@implementation ViewController

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + 80, self.view.frame.size.width, self.view.frame.size.height - 64 - 80)];
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的账本";
    [self.view addSubview:self.scrollView];
    [self setUI];
}
- (void)setUI {
    _addTallyBtn = [[UIButton alloc] init];
    _addTallyBtn.frame = CGRectMake((SCREEN_WIDTH - 80)/2, 64, 80, 80);
    [_addTallyBtn setBackgroundImage:[UIImage imageNamed:@"增加"] forState:0];
    [_addTallyBtn addTarget:self action:@selector(addTallyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addTallyBtn];
    
    _incomLab = [[UILabel alloc] init];
    _incomLab.frame = CGRectMake(0, 74, (SCREEN_WIDTH - 80)/2, 20);
    _incomLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_incomLab];
    
    _expenseLab = [[UILabel alloc] init];
    _expenseLab.frame = CGRectMake((SCREEN_WIDTH - 80)/2 + 80, 74, (SCREEN_WIDTH - 80)/2, 20);
    _expenseLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_expenseLab];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 114, (SCREEN_WIDTH - 80)/2, 20);
    label.text = @"收入总计";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake((SCREEN_WIDTH - 80)/2 + 80, 114, (SCREEN_WIDTH - 80)/2, 20);
    label1.text = @"支出总计";
    label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label1];
}
// 点击增加
- (void)addTallyBtnClick {
    AddTallyViewController *addVC = [[AddTallyViewController alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
}
// 出现时 刷新整个时间线
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showTimeLineView];
}
- (void)showTimeLineView {
    [self readSqliteData];
    
    for (UIView *view in self.scrollView.subviews) {
        if (view.tag == 1990) {
            [view removeFromSuperview];
        }
    }
    // 计算收支
    double incomeTotal = 0;
    double expresTotal = 0;
    _allDateAllLine = 0;
    
    // 计算时间长度
    for (NSString *key in _timeLineModelsDict.allKeys) {
        NSArray<TimeLineModel *> *modelArray = _timeLineModelsDict[key];
        NSLog(@"====================%ld",modelArray.count);
        // 一天的时间线总长
        _allDateAllLine = _allDateAllLine + kDateWidth + (kBtnWidth + kLineHight)*modelArray.count + kLineHight;
        for (TimeLineModel *model in modelArray) {
            incomeTotal = incomeTotal + model.income;
            expresTotal = expresTotal + model.expense;
        }
    }
    _incomLab.text = [NSString stringWithFormat:@"%.2f",incomeTotal];
    _expenseLab.text = [NSString stringWithFormat:@"%.2f",expresTotal];
    
    // 设置时间线视图timeLineView
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, _allDateAllLine);
    TimeLineView *view = [[TimeLineView alloc] initWithFrame:rect];
    view.tag = 1990;
    view.delegate = self;
    view.backgroundColor = [UIColor whiteColor];
    view.timeLineModelDict = _timeLineModelsDict;
    [_scrollView addSubview:view];
    _scrollView.contentSize = CGSizeMake(0, _allDateAllLine);
    [_scrollView setContentOffset:CGPointZero animated:YES];
}
- (void)readSqliteData {
    _timeLineModelsDict = nil;
    _timeLineModelsDict = [[CareDataOperations sharedInstance] getAllDataWithDict];
}
// 删除前确认
- (void)willDeleteCurrentTallyWithIndentity:(NSString *)identity {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认删除" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 操作数据库 从数据库中删除对应的identity字段行
        Tally *tally = [[CareDataOperations sharedInstance] getTallyWithIdentity:identity];
        [[CareDataOperations sharedInstance] deleateTally:tally];
        // 删除后刷新视图
        [self showTimeLineView];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
}
- (void)willModifyCurrentTallyWithIdentity:(NSString *)identity {
    AddTallyViewController *addVC = [[AddTallyViewController alloc] init];
    [addVC setSelectTallyWithIdentity:identity];
    [self.navigationController pushViewController:addVC animated:YES];
}

@end
