/*
 作者：  yate1996
 文件：  YYPickView.h
 版本：  1.0 <2016.09.28>
 地址：  
 描述：  封装单行的数据选择器,延时自动返回,简洁UI,支持横竖屏切换,视图直接放置于keyWindow上
 */

#import "YYPickView.h"
static const CGFloat kPickViewHeight = 148.0f;
static const CGFloat kRowLineHeight = 0.5f;
static const CGFloat kRowHeight = 28.f;
static const CGFloat kTitleFontSize = 13.0f;
static const NSTimeInterval kAnimateDuration = 0.2f;
static const NSTimeInterval kWaitTimeDuration = 0.3f;

@interface YYPickView() <UIPickerViewDelegate,UIPickerViewDataSource>

/** 
 block回调
 */
@property (copy, nonatomic) YYPickViewBlock pickViewBlock;

/** 
 背景图片 
 */
@property (strong, nonatomic) UIView *backgroundView;

/** 
 弹出视图 
 */
@property (strong, nonatomic) UIView *mainView;

/**
 UIPickView
 */
@property (strong, nonatomic) UIPickerView *inPickView;

/**
 文本数据
 */
@property (copy, nonatomic) NSArray <NSString *>*items;

/**
 是否已经选中行：用于延时自动选中pickview
 */
@property (assign, nonatomic) BOOL isRowSelected;

/**
 * 收起视图
 */
- (void)dismiss;

/**
 * 通过颜色生成图片
 */
- (UIImage *)imageWithColor:(UIColor *)color;

@end

@implementation YYPickView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithTitle:nil items:nil defaulSelected:0 handler:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithTitle:nil items:nil defaulSelected:0 handler:nil];
}

- (instancetype)initWithTitle:(NSString *)title items:(NSArray <NSString *>*)items  defaulSelected:(NSInteger)defaulSelected handler:(YYPickViewBlock)pickViewBlock {
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        
        self.items = items;
        self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _pickViewBlock = pickViewBlock;
        
        CGFloat pickViewHeight = 0;
        
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
        _backgroundView.alpha = 0;
        [self addSubview:_backgroundView];
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0)];
        _mainView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _mainView.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
        [self addSubview:_mainView];
        
        if (title && title.length > 0)
        {
            pickViewHeight += kRowLineHeight;
            
            CGFloat titleHeight = ceil([title boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kTitleFontSize]} context:nil].size.height) + 15*2;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, pickViewHeight, self.frame.size.width, titleHeight)];
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            titleLabel.text = title;
            titleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
            titleLabel.textColor = [UIColor colorWithRed:135.0f/255.0f green:135.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
            titleLabel.numberOfLines = 0;
            [_mainView addSubview:titleLabel];
    
            pickViewHeight += titleHeight;
        }
        
        _inPickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, pickViewHeight, self.frame.size.width, kPickViewHeight)];
        _inPickView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _inPickView.delegate = self;
        _inPickView.dataSource = self;
        [_inPickView selectRow:defaulSelected inComponent:0 animated:YES];
        [_mainView addSubview:_inPickView];
        
        pickViewHeight += kPickViewHeight;
       
        _mainView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, pickViewHeight);
    }
    
    return self;
}

+ (instancetype)pickViewWithTitle:(NSString *)title items:(NSArray <NSString *>*)items  defaulSelected:(NSInteger)defaulSelected handler:(YYPickViewBlock)pickViewBlock {
    return [[self alloc]initWithTitle:title items:items defaulSelected:defaulSelected handler:pickViewBlock];
}

+ (void)showPickViewWithTitle:(NSString *)title items:(NSArray <NSString *>*)items  defaulSelected:(NSInteger)defaulSelected handler:(YYPickViewBlock)pickViewBlock
{
    YYPickView *pickView = [self pickViewWithTitle:title items:items defaulSelected:defaulSelected handler:pickViewBlock];
    [pickView show];
}

- (void)show {
    // 在主线程中处理,否则在viewDidLoad方法中直接调用,会先加本视图,后加控制器的视图到UIWindow上,导致本视图无法显示出来,这样处理后便会优先加控制器的视图到UIWindow上
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows)
        {
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if(windowOnMainScreen && windowIsVisible && windowLevelNormal)
            {
                [window addSubview:self];
                break;
            }
        }
        
//        [UIView animateWithDuration:kAnimateDuration delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.backgroundView.alpha = 1.0f;
//            self.mainView.frame = CGRectMake(0, self.frame.size.height-self.mainView.frame.size.height, self.frame.size.width, self.mainView.frame.size.height);
//        } completion:nil];
        
        [UIView animateWithDuration:kAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backgroundView.alpha = 1.0f;
            self.mainView.frame = CGRectMake(0, self.frame.size.height-self.mainView.frame.size.height, self.frame.size.width, self.mainView.frame.size.height);
        } completion:nil];
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:kAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundView.alpha = 0.0f;
        self.mainView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.mainView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.backgroundView];
    if (!CGRectContainsPoint(self.mainView.frame, point))
    {
        if (self.pickViewBlock)
        {
            self.pickViewBlock(self, self.items[[self.inPickView selectedRowInComponent:0]],[self.inPickView selectedRowInComponent:0]);
        }
        [self dismiss];
    }
}

/**************************PickViewDelegate****************************/
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.isRowSelected = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kWaitTimeDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isRowSelected) {
            if (self.pickViewBlock)
            {
                self.pickViewBlock(self, self.items[[self.inPickView selectedRowInComponent:0]],[self.inPickView selectedRowInComponent:0]);
            }
            [self dismiss];
        }
    });
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.items.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    self.isRowSelected = NO;
    return self.items[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return kRowHeight;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)dealloc
{
#ifdef DEBUG
        NSLog(@"YYPickView dealloc");
#endif
}
@end
