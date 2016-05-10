//
//  SaveTemplateDialog.h
//  EasyCalc
//
//  Created by LiBoli on 16/5/5.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LRTextField;
@class HTPressableButton;
@class ViewController;

@interface SaveTemplateDialog : UIView
@property UIVisualEffectView *background;
@property LRTextField *textField;
@property HTPressableButton *okBtn;
@property HTPressableButton *cancelBtn;

- (instancetype)initWithFrame:(CGRect)aRect :(CGRect)bgRect :(ViewController *)vc;
@end
