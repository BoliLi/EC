//
//  ViewController.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayView.h"

@class Equation;
@class EquationBlock;
@class EquationTextLayer;
@class RadicalBlock;

@interface ViewController : UIViewController
@property UIFont *buttonFont;
@property UIView *dspConView;
@property UIView *keyboardView;
@property UIView *kbConView;
@property CALayer *borderLayer;
@property Equation *E;
@property CGFloat scnWidth;
@property CGFloat scnHeight;
@property CGFloat statusBarHeight;
@property (weak) EquationBlock *testeb;
@property NSTimer *delBtnLongPressTmr;

-(void)handleTap: (UITapGestureRecognizer *)gesture;
-(void)handleSwipeRight: (UISwipeGestureRecognizer *)gesture;
-(void)handleSwipeLeft: (UISwipeGestureRecognizer *)gesture;
@end
