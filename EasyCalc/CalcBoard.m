//
//  CalcBoard.m
//  EasyCalc
//
//  Created by LiBoli on 16/3/30.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import "CalcBoard.h"
#import "Global.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"
#import "WrapedEqTxtLyr.h"
#import "Parentheses.h"
#import "Utils.h"
#import "DisplayView.h"

@implementation CalcBoard
@synthesize view;
@synthesize eqList;
@synthesize curEqIdx;
@synthesize curEq;

-(id) init : (CGRect)dspFrame : (ViewController *)vc {
    self = [super init];
    if (self) {
        DisplayView *dspView = [[DisplayView alloc] initWithFrame:dspFrame];
        dspView.backgroundColor = [UIColor lightGrayColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [dspView addGestureRecognizer:tapGesture];
        
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:vc action:@selector(handleDspViewSwipeRight:)];
        right.numberOfTouchesRequired = 1;
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [dspView addGestureRecognizer:right];
        
        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:vc action:@selector(handleDspViewSwipeLeft:)];
        left.numberOfTouchesRequired = 1;
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        [dspView addGestureRecognizer:left];
    }
    return self;
}

@end
