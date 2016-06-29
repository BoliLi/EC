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

@interface DisplayView : UIScrollView <NSCoding, UIScrollViewDelegate>
@property CALayer *cursor;
@property (weak) CalcBoard *par;
//@property UIButton *swipLBtn;

-(id) init : (CalcBoard *)calcB : (CGRect)dspFrame : (ViewController *)vc;
- (void)updateContentView;
- (void)refreshCursorAnim;
@end
