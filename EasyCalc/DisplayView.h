//
//  DisplayView.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class CalcBoard;

@interface DisplayView : UIScrollView <NSCoding>
@property CALayer *cursor;
@property CGPoint inpOrg;
@property UIButton *swipLBtn;
@property UIButton *swipRBtn;
@property (weak) CalcBoard *par;

-(id) init : (CalcBoard *)calcB : (CGRect)dspFrame : (ViewController *)vc;
@end
