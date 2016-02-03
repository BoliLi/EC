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
@property UIView *dspConView;
@property UIView *mainKbView;
@property UIView *secondKbView;
@property UIView *kbConView;
@property CALayer *borderLayer;
@property CGFloat scnWidth;
@property CGFloat scnHeight;
@property CGFloat statusBarHeight;
@property (weak) EquationBlock *testeb;
@property NSTimer *delBtnLongPressTmr;

-(void)handleTap: (UITapGestureRecognizer *)gesture;
-(void)handleDspViewSwipeRight: (UISwipeGestureRecognizer *)gesture;
-(void)handleDspViewSwipeLeft: (UISwipeGestureRecognizer *)gesture;
@end
