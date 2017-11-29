//
//  CalculatorView.m
//  Tally
//
//  Created by PengLiang on 2017/11/28.
//  Copyright © 2017年 PengLiang. All rights reserved.
//

#import "CalculatorView.h"

@interface CalculatorView ()

@property (nonatomic, assign) CGFloat btnWidth;

@property (nonatomic, assign) CGFloat btnHeight;

@property (nonatomic, copy) NSString *nValue;

@property (nonatomic, copy) NSString *resultStr;

@property (nonatomic, strong) UILabel *resultLab;

@property (nonatomic, strong) UIButton *addBtn;

@property (nonatomic, strong) UIColor *btnColor;

@property (nonatomic, assign) CGColorRef boardLineColor;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *typeLab;

@property (nonatomic, copy) NSString *tallyIdentity;

@end

static CGFloat const kBoardWidth = 1;
static CGFloat const kMaxCalCount = 9;

@implementation CalculatorView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _btnWidth = (self.frame.size.width - kBoardWidth/2)/4;
        _btnHeight = self.frame.size.height/5;
        _nValue = @"";
        _resultStr = @"";
        _btnColor = [UIColor grayColor];
        _boardLineColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderColor = _boardLineColor;
        self.layer.borderWidth = kBoardWidth;
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        [self loadBtn];
    }
    return self;
}
- (void)setImage:(UIImage *)image {
    _image = image;
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        _imageView.image = image;
    }];
}
- (void)setTypeName:(NSString *)typeName {
    _typeName = typeName;
    _typeLab.text = typeName;
}
- (void)setImageViewSize:(CGSize)imageViewSize {
    _imageViewSize = imageViewSize;
    _imageView.frame = CGRectMake(10, (_btnHeight - imageViewSize.height)/2, imageViewSize.width, imageViewSize.height);
    _imageView.backgroundColor = [UIColor clearColor];
    
    // 回调实际位置
    if (_positionInViewBlock) {
        CGPoint point = CGPointMake(10 + imageViewSize.width/2, self.frame.origin.y + _imageView.frame.origin.y + imageViewSize.height/2);
        _positionInViewBlock(point);
    }
    self.typeLab.frame = CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width + 10, _imageView.frame.origin.y, imageViewSize.width*2, imageViewSize.height);
}
// 类型名称label
- (UILabel *)typeLab {
    if (!_typeLab) {
        _typeLab = [[UILabel alloc] init];
        _typeLab.font = [UIFont systemFontOfSize:14];
        [self addSubview:_typeLab];
    }
    return _typeLab;
}
// 结果label
- (UILabel *)resultLab {
    if (!_resultLab) {
        _resultLab = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width *0.3, 0, self.frame.size.width*0.7 - 10, _btnHeight)];
        _resultLab.text = @"￥0.00";
        _resultLab.textAlignment = NSTextAlignmentRight;
        _resultLab.adjustsFontSizeToFitWidth = YES;
        _resultLab.font = [UIFont systemFontOfSize:25];
        _resultLab.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        tap.numberOfTapsRequired = 1;
        [tap addTarget:self action:@selector(clickResultLab)];
        [_resultLab addGestureRecognizer:tap];
    }
    return _resultLab;
}
- (void)clickResultLab {
    if ([_delegate respondsToSelector:@selector(backPositionWithAnimation)]) {
        [_delegate backPositionWithAnimation];
    }
}
- (UIButton *)addBtn {
    if (!_addBtn) {
        _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(3*_btnWidth, _btnHeight*2, _btnWidth, _btnHeight)];
        [_addBtn setTitle:@"+" forState:0];
        _addBtn.backgroundColor = _btnColor;
        _addBtn.layer.borderColor = _boardLineColor;
        _addBtn.layer.borderWidth = kBoardWidth;
        [_addBtn addTarget:self action:@selector(clickAdd) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}
// 普通数字btn
- (void)loadBtn {
    for (int i = 0; i < 9; i ++) {
        CGFloat btnX = i%3*_btnWidth;
        CGFloat btnY = i/3*_btnHeight + _btnHeight;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, _btnWidth, _btnHeight)];
        btn.tag = i + 1;
        [btn setTitle:[NSString stringWithFormat:@"%ld",btn.tag] forState:0];
        btn.backgroundColor = _btnColor;
        btn.layer.borderColor = _boardLineColor;
        btn.layer.borderWidth = kBoardWidth;
        [btn addTarget:self action:@selector(clickNumber:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    // 小数点 btn
    UIButton *pointBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.btnWidth*2, self.btnHeight*4, self.btnWidth, self.btnHeight)];
    pointBtn.tag = 99;
    [pointBtn setTitle:@"." forState:0];
    [self setBtnColorWithBtn:pointBtn];
    [pointBtn addTarget:self action:@selector(clickNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pointBtn];
    
    UIButton *zeroBtn = [[UIButton alloc] initWithFrame:CGRectMake(_btnWidth, _btnHeight*4, _btnWidth, _btnHeight)];
    zeroBtn.tag = 0;
    [zeroBtn setTitle:@"0" forState:0];
    [self setBtnColorWithBtn:zeroBtn];
    [zeroBtn addTarget:self action:@selector(clickNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:zeroBtn];
    
    // 重置btn
    UIButton *resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, _btnHeight*4, _btnWidth, _btnHeight)];
    [resetBtn setTitle:@"C" forState:0];
    [self setBtnColorWithBtn:resetBtn];
    [resetBtn addTarget:self action:@selector(resetZero) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:resetBtn];
    
    // 删除按钮
    UIButton *delBtn = [[UIButton alloc] initWithFrame:CGRectMake(_btnWidth*3, _btnHeight, _btnWidth, _btnHeight)];
    [delBtn setTitle:@"DEL" forState:0];
    [self setBtnColorWithBtn:delBtn];
    [delBtn addTarget:self action:@selector(clickDel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:delBtn];
    
    // 确定按钮
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(_btnWidth*3, _btnHeight*3, _btnWidth, _btnHeight*2)];
    [okBtn setTitle:@"OK" forState:0];
    [self setBtnColorWithBtn:okBtn];
    [okBtn addTarget:self action:@selector(clickOk) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:okBtn];
    
    [self addSubview:self.addBtn];
    [self addSubview:self.resultLab];
}
- (void)setBtnColorWithBtn:(UIButton *)btn {
    btn.backgroundColor = _btnColor;
    btn.layer.borderColor = _boardLineColor;
    btn.layer.borderWidth = kBoardWidth;
}
// 点击数字按键
- (void)clickNumber:(UIButton *)btn {
    if (_addBtn.isSelected) {
        _nValue = @"";
    }
    NSString *currentValue = @"";
    if (btn.tag == 99) {
        if ([_nValue rangeOfString:@"."].location == NSNotFound) {
            currentValue = @".";
        }
    } else {
        currentValue = [NSString stringWithFormat:@"%ld",btn.tag];
    }
    _nValue = [_nValue stringByAppendingString:currentValue];
    
    //保留小数点后两位
    NSRange pointRange = [_nValue rangeOfString:@"."];
    if (pointRange.location != NSNotFound) {
        if ([_nValue substringFromIndex:pointRange.location + 1].length > 2) {
            _nValue = [_nValue substringWithRange:NSMakeRange(0, pointRange.location + 3)];
        }
        
        //总数不差过9  处理小数部分
        if ([_nValue substringToIndex:pointRange.location].length > kMaxCalCount) {
            _nValue = [NSString stringWithFormat:@"%0.2f", [_nValue doubleValue]];
            _nValue = [_nValue substringToIndex:kMaxCalCount + 3];
        }
    } else {
        //总位数不超过9  处理小数部分
        _nValue = [NSString stringWithFormat:@"%@", @([_nValue doubleValue])];
        if (_nValue.length > kMaxCalCount) {
            _nValue = [NSString stringWithFormat:@"%0.2f", [_nValue doubleValue]];
            if ([_nValue doubleValue] > 0) {
                _nValue = [_nValue substringToIndex:kMaxCalCount];
            } else {
                _nValue = @"0";
            }
        }
    }
    
    //显示数字
    _resultLab.text = [NSString stringWithFormat:@"¥ %.2f", [_nValue doubleValue]];
    _addBtn.selected = NO;
}
// 单击加号
- (void)clickAdd {
    if (!_addBtn.isSelected) {
        _addBtn.selected = YES;
        double result = [_resultStr doubleValue] + [_nValue doubleValue];
        _resultStr = [NSString stringWithFormat:@"%.2f",result];
        _resultLab.text = [NSString stringWithFormat:@"￥%.2f",[_resultStr doubleValue]];
    }
}
- (void)resetZero {
    _resultStr = @"";
    _nValue = @"";
    _resultLab.text = @"￥0.00";
}
- (void)clickDel {
    _nValue = [NSString stringWithFormat:@"%@",@([_nValue doubleValue])];
    if (_nValue.length > 0) {
        _nValue = [_nValue substringWithRange:NSMakeRange(0, _nValue.length - 1)];
    }
    _resultLab.text = [NSString stringWithFormat:@"￥%.2f",[_nValue doubleValue]];
}
- (void)clickOk {
    if (_isTallyExist) {
        [self modifyTallyWithIdentity:_tallyIdentity];
    } else {
        [self addTallySave];
    }
}
- (void)addTallySave {
    if (_typeLab.text != nil && [_nValue doubleValue] != 0) {
        [self clickAdd];
        NSManagedObjectContext *manageObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).persistentContainer.viewContext;
        
        NSDateFormatter *dateForMatter = [[NSDateFormatter alloc] init];
        [dateForMatter setDateFormat:@"yyy-MM-dd"];
        NSString *dateString = [dateForMatter stringFromDate:[NSDate date]];
        
        NSFetchRequest *fdate = [TallyDate fetchRequest];
        NSArray<NSSortDescriptor *> *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        fdate.sortDescriptors = sortDescriptors;
        NSPredicate *p = [NSPredicate predicateWithFormat:@"date = %@",dateString];
        fdate.predicate = p;
        NSArray<TallyDate *> *ss = [manageObjectContext executeFetchRequest:fdate error:nil];
        TallyDate *date;
        if (ss.count > 0) {
            date = ss[0];
        } else {
            date = [[TallyDate alloc] initWithContext:manageObjectContext];
            date.date = dateString;
        }
        // 配置数据
        Tally *model = [[Tally alloc] initWithContext:manageObjectContext];
        NSFetchRequest *ftype = [TallyType fetchRequest];
        NSPredicate *ptype = [NSPredicate predicateWithFormat:@"typename = %@",_typeLab.text];
        ftype.predicate = ptype;
        NSArray<TallyType *> *ssType = [manageObjectContext executeFetchRequest:ftype error:nil];
        TallyType *type = [ssType firstObject];
        
        model.typeship = type;
        model.dateship = date;
        model.identity = [NSString stringWithFormat:@"%@",[model objectID]];
        model.timestamp = [NSDate date];
        
        if ([_typeLab.text isEqualToString:@"工资"]) {
            model.income = [_resultStr doubleValue];
            model.expenses = 0;
        } else {
            model.expenses = [_resultStr doubleValue];
            model.income = 0;
        }
        
        [manageObjectContext save:nil];
        if ([_delegate respondsToSelector:@selector(tallySaveCompleted)]) {
            [_delegate tallySaveCompleted];
        }
        
    } else {
        if ([_delegate respondsToSelector:@selector(tallySaveFailed)]) {
            [_delegate tallySaveFailed];
        }
    }
}
- (void)modifyTallySavedWithIdentity:(NSString *)identity {
    [self clickAdd];
    if ([_resultStr doubleValue] == 0) {
        if ([_delegate respondsToSelector:@selector(tallySaveFailed)]) {
            [_delegate tallySaveFailed];
        }
        return;
    }
    _addBtn.selected = NO;
    
    TallyType *type = [[CareDataOperations sharedInstance] getTallyTapeWithTypeName:_typeLab.text];
    Tally *tally = [[CareDataOperations sharedInstance] getTallyWithIdentity:identity];
    tally.typeship = type;
    if ([_typeLab.text isEqualToString:@"工资"]) {
        tally.income = [_resultStr doubleValue];
        tally.expenses = 0;
    } else {
        tally.expenses = [_resultStr doubleValue];
        tally.income = 0;
    }
    [[CareDataOperations sharedInstance] saveTally];
    if ([_delegate respondsToSelector:@selector(tallySaveCompleted)]) {
        [_delegate tallySaveCompleted];
    }
}
- (void)modifyTallyWithIdentity:(NSString *)identity {
    _tallyIdentity = identity;
    Tally *tally = [[CareDataOperations sharedInstance] getTallyWithIdentity:identity];
    _imageView.image = [UIImage imageNamed:tally.typeship.typeicon];
    _typeLab.text = tally.typeship.typename;
    _nValue = tally.income > 0 ? [NSString stringWithFormat:@"%@",@(tally.income)] : [NSString stringWithFormat:@"%@",@(tally.expenses)];
    _resultLab.text = [NSString stringWithFormat:@"￥%.2f",[_nValue doubleValue]];
    _isTallyExist = YES;
}
@end
