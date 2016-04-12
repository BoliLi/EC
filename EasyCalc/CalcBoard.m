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
@synthesize curEq;
@synthesize downLeftBasePoint;
@synthesize curParent;
@synthesize curBlk;
@synthesize curTxtLyr;
@synthesize curRoll;
@synthesize curMode;
@synthesize curFont;
@synthesize curFontH;
@synthesize curFontW;
@synthesize insertCIdx;
@synthesize txtInsIdx;
@synthesize base_or_expo;
@synthesize curFontLvl;

-(id) init : (CGPoint)downLeft : (CGRect)dspFrame : (ViewController *)vc {
    self = [super init];
    if (self) {
        curRoll = ROLL_NUMERATOR;
        curMode = MODE_INPUT;
        insertCIdx = 0;
        txtInsIdx = 0;
        curTxtLyr = curBlk = nil;
        downLeftBasePoint = downLeft;
        eqList = [NSMutableArray array];
        base_or_expo = IS_BASE;
        curFontLvl = 0;
        
        curFont = [UIFont systemFontOfSize: 30];
        curFontW = gCharWidthTbl[0][8];
        curFontH = curFont.lineHeight;
        
        view = [[DisplayView alloc] init:self :dspFrame :vc];
        curEq = [[Equation alloc] init:self :vc];
        
//        [self addObserver:self forKeyPath:@"curFontLvl" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void) resetParam {
    curRoll = ROLL_NUMERATOR;
    curMode = MODE_INPUT;
    insertCIdx = 0;
    txtInsIdx = 0;
    curTxtLyr = curBlk = nil;
    base_or_expo = IS_BASE;
    curFontLvl = 0;
    
    curFont = [UIFont systemFontOfSize: 30];
    curFontW = gCharWidthTbl[0][8];
    curFontH = curFont.lineHeight;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.view = [coder decodeObjectForKey:@"view"];
        self.eqList = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"eqList"]];
        self.curEq = [coder decodeObjectForKey:@"curEq"];
        self.downLeftBasePoint = [coder decodeCGPointForKey:@"downLeftBasePoint"];
        self.curParent = [coder decodeObjectForKey:@"curParent"];
        self.curBlk = [coder decodeObjectForKey:@"curBlk"];
        self.curTxtLyr = [coder decodeObjectForKey:@"curTxtLyr"];
        self.curRoll = [coder decodeIntForKey:@"curRoll"];
        self.curMode = [coder decodeIntForKey:@"curMode"];
        self.curFont = [coder decodeObjectForKey:@"curFont"];
        self.curFontH = [coder decodeDoubleForKey:@"curFontH"];
        self.curFontW = [coder decodeDoubleForKey:@"curFontW"];
        self.insertCIdx = [coder decodeIntegerForKey:@"insertCIdx"];
        self.txtInsIdx = [coder decodeIntForKey:@"txtInsIdx"];
        self.base_or_expo = [coder decodeIntForKey:@"base_or_expo"];
        self.curFontLvl = [coder decodeIntForKey:@"curFontLvl"];
        
//        [self addObserver:self forKeyPath:@"curFontLvl" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.view forKey:@"view"];
    [coder encodeObject:[NSArray arrayWithArray:self.eqList] forKey:@"eqList"];
    [coder encodeObject:self.curEq forKey:@"curEq"];
    [coder encodeCGPoint:self.downLeftBasePoint forKey:@"downLeftBasePoint"];
    [coder encodeObject:self.curParent forKey:@"curParent"];
    [coder encodeObject:self.curBlk forKey:@"curBlk"];
    if (self.curTxtLyr != nil) {
        [coder encodeObject:self.curTxtLyr forKey:@"curTxtLyr"];
    }
    [coder encodeInt:self.curRoll forKey:@"curRoll"];
    [coder encodeInt:self.curMode forKey:@"curMode"];
    [coder encodeObject:self.curFont forKey:@"curFont"];
    [coder encodeDouble:self.curFontH forKey:@"curFontH"];
    [coder encodeDouble:self.curFontW forKey:@"curFontW"];
    [coder encodeInteger:self.insertCIdx forKey:@"insertCIdx"];
    [coder encodeInt:self.txtInsIdx forKey:@"txtInsIdx"];
    [coder encodeInt:self.base_or_expo forKey:@"base_or_expo"];
    [coder encodeInt:self.curFontLvl forKey:@"curFontLvl"];
}

-(void)updateFontInfo: (int)lvl {

    if (self.curFontLvl == lvl) {
        return;
    }
    
    curFontLvl = lvl;
    curFont = [UIFont systemFontOfSize:getFontSize(lvl)];
    curFontW = gCharWidthTbl[lvl][8];
    curFontH = curFont.lineHeight;
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
//    if ([keyPath isEqual: @"curFont"]) {
//        CalcBoard *cb = object;
//        int newFontLvl = [change objectForKey:@"new"];
//        if (newFont == cb.baseFont) {
//            cb.curFontW = cb.baseCharWidth;
//            cb.curFontH = cb.baseCharHight;
//        } else if (newFont == cb.superscriptFont) {
//            cb.curFontW = cb.expoCharWidth;
//            cb.curFontH = cb.expoCharHight;
//        } else
//            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
//    }
//}
@end
