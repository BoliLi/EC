//
//  Equation.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DisplayView.h"
#import "ViewController.h"

@class EquationTextLayer;
@class EquationBlock;

@interface Equation : NSObject <NSCoding>
@property int guid_cnt;
@property EquationBlock *root;
@property (weak) CalcBoard *par;
@property EquationTextLayer *equalsign;
@property EquationTextLayer *result;
@property CGFloat maxRootHeight;

//-(id) init;
//-(id) init : (CGPoint)downLeft : (CGRect)dspFrame : (ViewController *)vc;
-(id) init : (CalcBoard *)calcB : (ViewController *)vc;
-(void) dumpObj : (EquationBlock *)parentBlock;
-(void) dumpEverything : (EquationBlock *)eb;
-(id) lookForElementByPoint : (EquationBlock *)rootB : (CGPoint) point;
-(void)removeElement:(id)blk;
-(void) moveUp : (CGFloat)distance;
-(void) destroy;
@end
