/*
 作者：  yate1996
 文件：  YYPickView.h
 版本：  1.0 <2016.09.28>
 地址：
 描述：  封装单行的数据选择器,延时自动返回,简洁UI,支持横竖屏切换,视图直接放置于keyWindow上
 */

#import <UIKit/UIKit.h>

@interface YYPickView : UIView

/**
 block回调

 @param pickView YYPickView对象自身
 @param title    选中的文本
 @param index    选中的文本索引:  0.1.2...
 */
typedef void(^YYPickViewBlock)(YYPickView *pickView, NSString *title, NSInteger index);

/**
 创建YYPickView视图
 
 @param title                       提示文本
 @param items                     文本数组
 @param defaulSelected        默认选中索引
 @param pickViewBlock         block回调
 
 @return YYPickView对象
 */
- (instancetype)initWithTitle:(NSString *)title
                               items:(NSArray <NSString *>*)items
                  defaulSelected:(NSInteger)defaulSelected
                            handler:(YYPickViewBlock)pickViewBlock;

/**
 创建YYPickView视图(便利构造器)

 @param title                       提示文本
 @param items                     文本数组
 @param defaulSelected        默认选中索引
 @param pickViewBlock         block回调

 @return YYPickView对象
 */
+ (instancetype)pickViewWithTitle:(NSString *)title
                                       items:(NSArray <NSString *>*)items
                          defaulSelected:(NSInteger)defaulSelected
                                    handler:(YYPickViewBlock)pickViewBlock;

/**
 弹出YYPickView视图

 @param title                       提示文本
 @param items                     文本数组
 @param defaulSelected        默认选中索引
 @param pickViewBlock         block回调
 */
+ (void)showPickViewWithTitle:(NSString *)title
                                   items:(NSArray <NSString *>*)items
                      defaulSelected:(NSInteger)defaulSelected
                                handler:(YYPickViewBlock)pickViewBlock;

/**
 弹出视图
 */
- (void)show;

@end
