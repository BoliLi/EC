//
//  SaveTemplateDialog.m
//  EasyCalc
//
//  Created by LiBoli on 16/5/5.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import "SaveTemplateDialog.h"
#import "HTPressableButton.h"
#import "UIColor+HTColor.h"
#import "LRTextField.h"
#import "ViewController.h"

@implementation SaveTemplateDialog
@synthesize background;
@synthesize textField;
@synthesize okBtn;
@synthesize cancelBtn;

- (instancetype)initWithFrame:(CGRect)aRect :(CGRect)bgRect :(ViewController *)vc{
    self = [super initWithFrame:aRect];
    if (self) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        background = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        background.frame = bgRect;
        
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = 10;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [[UIColor blackColor] CGColor];
        
        textField = [[LRTextField alloc] initWithFrame:CGRectMake(3, self.frame.size.height / 2.0 - 30, self.frame.size.width - 6, 30) labelHeight:15];
        textField.placeholder = @"Name";
        textField.placeholderActiveColor = [UIColor redColor];
        textField.placeholderInactiveColor = [UIColor blackColor];
        textField.hintText = @"for Template";
        [self addSubview:textField];
        
        okBtn = [[HTPressableButton alloc] initWithFrame:CGRectMake(textField.frame.origin.x + 5.0, textField.frame.origin.y + textField.frame.size.height + 5, textField.frame.size.width / 2.0 - 7.0, 30) buttonStyle:HTPressableButtonStyleRounded];
        [okBtn setTitle:@"OK" forState:UIControlStateNormal];
        okBtn.cornerRadius = 5;
        okBtn.titleFont = [UIFont fontWithName:@"PingFangSC-Ultralight" size:18];
        [okBtn addTarget:vc action:@selector(saveTemplateOkClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:okBtn];
        
        cancelBtn = [[HTPressableButton alloc] initWithFrame:CGRectMake(textField.frame.origin.x + textField.frame.size.width / 2.0 + 2.0, textField.frame.origin.y + textField.frame.size.height + 5, textField.frame.size.width / 2.0 - 7.0, 30) buttonStyle:HTPressableButtonStyleRounded];
        [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelBtn.cornerRadius = 5;
        cancelBtn.titleFont = [UIFont fontWithName:@"PingFangSC-Ultralight" size:18];
        [cancelBtn addTarget:vc action:@selector(saveTemplateCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
