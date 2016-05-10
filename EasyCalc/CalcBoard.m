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
        
        curFont = getFont(0);
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
    
    curFont = getFont(0);
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
    curFont = getFont(lvl);
    curFontW = gCharWidthTbl[lvl][8];
    curFontH = curFont.lineHeight;
}

-(void) reorganize : (ViewController *)vc {
    for (Equation *eq in self.eqList) {
        eq.par = self;
        [eq.root reorganize:eq :vc];
        
        eq.equalsign.opacity = 1.0;
        eq.result.opacity = 1.0;
        [self.view.layer addSublayer:eq.equalsign];
        [self.view.layer addSublayer:eq.result];
    }
    
    self.curEq.par = self;
    [self.curEq.root reorganize:self.curEq :vc];
}

-(void) insertTemplate :(EquationBlock *)rootBlk :(ViewController *)vc{
    CGFloat incrWidth = 0.0;
    
    if (self.curTxtLyr != nil && self.curTxtLyr.type == TEXTLAYER_EMPTY) {
        if (self.curTxtLyr.expo == nil) {
            EquationBlock *cb = self.curParent;
            [self.curTxtLyr destroy];
            [cb.children removeObjectAtIndex:self.curTxtLyr.c_idx];
            [cb updateCIdx];
            incrWidth -= self.curTxtLyr.mainFrame.size.width;
            if (cb.children.count == 0) {
                if (cb.roll == ROLL_ROOT) {
                    self.curMode = MODE_REPLACE_ROOT;
                } else if (cb.roll == ROLL_ROOT_ROOT) {
                    self.curMode = MODE_REPLACE_RADICAL;
                } else if (cb.roll == ROLL_WRAP_ROOT) {
                    self.curMode = MODE_REPLACE_WETL;
                } else if (cb.roll == ROLL_EXPO_ROOT) {
                    self.curMode = MODE_REPLACE_EXPO;
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
        } else if ([self.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = self.curTxtLyr.expo.children.firstObject;
            if (l.type == TEXTLAYER_EMPTY) {
                EquationBlock *cb = self.curParent;
                [self.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:self.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= self.curTxtLyr.mainFrame.size.width;
                if (cb.children.count == 0) {
                    if (cb.roll == ROLL_ROOT) {
                        self.curMode = MODE_REPLACE_ROOT;
                    } else if (cb.roll == ROLL_ROOT_ROOT) {
                        self.curMode = MODE_REPLACE_RADICAL;
                    } else if (cb.roll == ROLL_WRAP_ROOT) {
                        self.curMode = MODE_REPLACE_WETL;
                    } else if (cb.roll == ROLL_EXPO_ROOT) {
                        self.curMode = MODE_REPLACE_EXPO;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
            } else {
                self.curMode = MODE_INSERT;
                self.insertCIdx = self.curTxtLyr.c_idx;
            }
        } else {
            self.curMode = MODE_INSERT;
            self.insertCIdx = self.curTxtLyr.c_idx;
        }
    }
    
    [rootBlk updateSize:self.curFontLvl];
    
    
    
    incrWidth += rootBlk.mainFrame.size.width;
    
    if(self.curMode == MODE_INPUT) {
        EquationBlock *block = self.curParent;
        
        if (rootBlk.bar == nil) {
            for (id b in rootBlk.children) {
                [block.children addObject:b];
                updateRoll(b, self.curRoll);
            }
        } else {
            [block.children addObject:rootBlk];
            rootBlk.roll = self.curRoll;
            [rootBlk reorganize:self.curEq :vc];
        }
        
        [self.curParent updateCIdx];
    } else if(self.curMode == MODE_INSERT) {
        EquationBlock *block = self.curParent;
        
        if (rootBlk.bar == nil) {
            for (id b in rootBlk.children) {
                [block.children insertObject:b atIndex:self.insertCIdx++];
                updateRoll(b, self.curRoll);
            }
        } else {
            [block.children insertObject:rootBlk atIndex:self.insertCIdx];
        }
        
        [self.curParent updateCIdx];
    } else if(self.curMode == MODE_DUMP_ROOT) {
        Equation *eq = self.curEq;
        EquationBlock *newRoot = [[EquationBlock alloc] init:eq];
        newRoot.roll = ROLL_ROOT;
        newRoot.parent = nil;
        newRoot.numerFrame = eq.root.mainFrame;
        newRoot.numerTopHalf = eq.root.mainFrame.size.height / 2.0;
        newRoot.numerBtmHalf = eq.root.mainFrame.size.height / 2.0;
        newRoot.mainFrame = newRoot.numerFrame;
        eq.root.roll = ROLL_NUMERATOR;
        eq.root.parent = newRoot;
        if (self.insertCIdx == 0) {
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                }
            } else {
                [newRoot.children addObject:rootBlk];
            }
            [newRoot.children addObject:eq.root];
            self.curMode = MODE_INSERT;
        } else {
            [newRoot.children addObject:eq.root];
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                }
            } else {
                [newRoot.children addObject:rootBlk];
            }
            self.curMode = MODE_INPUT;
        }
        eq.root = newRoot;
        self.curParent = newRoot;
        [self.curParent updateCIdx];
        self.curRoll = ROLL_NUMERATOR;
    } else if(self.curMode == MODE_DUMP_RADICAL) {
        RadicalBlock *rBlock = self.curParent;
        EquationBlock *orgRootRoot = rBlock.content;
        EquationBlock *newRootRoot = [[EquationBlock alloc] init:self.curEq];
        newRootRoot.roll = ROLL_ROOT_ROOT;
        newRootRoot.parent = rBlock;
        newRootRoot.numerFrame = orgRootRoot.mainFrame;
        newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.mainFrame = newRootRoot.numerFrame;
        orgRootRoot.roll = ROLL_NUMERATOR;
        orgRootRoot.parent = newRootRoot;
        if (self.insertCIdx == 0) {
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newRootRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                }
            } else {
                [newRootRoot.children addObject:rootBlk];
            }
            
            [newRootRoot.children addObject:orgRootRoot];
            self.curMode = MODE_INSERT;
        } else {
            [newRootRoot.children addObject:orgRootRoot];
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newRootRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                }
            } else {
                [newRootRoot.children addObject:rootBlk];
            }
            self.curMode = MODE_INPUT;
        }
        rBlock.content = newRootRoot;
        self.curParent = newRootRoot;
        [self.curParent updateCIdx];
        self.curRoll = ROLL_NUMERATOR;
    } else if(self.curMode == MODE_DUMP_EXPO) {
        EquationTextLayer *layer = self.curParent;
        EquationBlock *orgExpoRoot = layer.expo;
        EquationBlock *newExpoRoot = [[EquationBlock alloc] init:self.curEq];
        newExpoRoot.roll = ROLL_EXPO_ROOT;
        newExpoRoot.parent = layer;
        newExpoRoot.numerFrame = orgExpoRoot.mainFrame;
        newExpoRoot.numerTopHalf = orgExpoRoot.mainFrame.size.height / 2.0;
        newExpoRoot.numerBtmHalf = orgExpoRoot.mainFrame.size.height / 2.0;
        newExpoRoot.mainFrame = newExpoRoot.numerFrame;
        orgExpoRoot.roll = ROLL_NUMERATOR;
        orgExpoRoot.parent = newExpoRoot;
        if (self.insertCIdx == 0) {
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newExpoRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                }
            } else {
                [newExpoRoot.children addObject:rootBlk];
            }
            [newExpoRoot.children addObject:orgExpoRoot];
            self.curMode = MODE_INSERT;
        } else {
            [newExpoRoot.children addObject:orgExpoRoot];
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newExpoRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                }
            } else {
                [newExpoRoot.children addObject:rootBlk];
            }
            self.curMode = MODE_INPUT;
        }
        layer.expo = newExpoRoot;
        self.curParent = newExpoRoot;
        [self.curParent updateCIdx];
        self.curRoll = ROLL_NUMERATOR;
    } else if(self.curMode == MODE_DUMP_WETL) {
        WrapedEqTxtLyr *wetl = self.curParent;
        EquationBlock *orgWrapRoot = wetl.content;
        EquationBlock *newWrapRoot = [[EquationBlock alloc] init:self.curEq];
        newWrapRoot.roll = ROLL_WRAP_ROOT;
        newWrapRoot.parent = wetl;
        newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
        newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.mainFrame = newWrapRoot.numerFrame;
        orgWrapRoot.roll = ROLL_NUMERATOR;
        orgWrapRoot.parent = newWrapRoot;
        if (self.insertCIdx == 0) {
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newWrapRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                }
            } else {
                [newWrapRoot.children addObject:rootBlk];
            }
            [newWrapRoot.children addObject:orgWrapRoot];
            self.curMode = MODE_INSERT;
        } else {
            [newWrapRoot.children addObject:orgWrapRoot];
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newWrapRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                }
            } else {
                [newWrapRoot.children addObject:rootBlk];
            }
            self.curMode = MODE_INPUT;
        }
        wetl.content = newWrapRoot;
        self.curParent = newWrapRoot;
        [self.curParent updateCIdx];
        self.curRoll = ROLL_NUMERATOR;
    } else if(gCurCB.curMode == MODE_REPLACE_ROOT) {
        [gCurCB.curEq.root destroy];
        gCurCB.curEq.root = rootBlk;
        gCurCB.curEq.root.c_idx = 0;
        gCurCB.curParent = nil;
        gCurCB.curRoll = ROLL_ROOT;
        gCurCB.curMode = MODE_DUMP_ROOT;
    } else if(gCurCB.curMode == MODE_REPLACE_RADICAL) {
        RadicalBlock *rb = ((EquationBlock *)gCurCB.curParent).parent;
        [rb.content destroy];
        rb.content = rootBlk;
        rb.content.c_idx = 0;
        gCurCB.curParent = rb;
        gCurCB.curRoll = ROLL_ROOT_ROOT;
        gCurCB.curMode = MODE_DUMP_RADICAL;
    } else if(gCurCB.curMode == MODE_REPLACE_WETL) {
        WrapedEqTxtLyr *wetl = ((EquationBlock *)gCurCB.curParent).parent;
        [wetl.content destroy];
        wetl.content = rootBlk;
        wetl.content.c_idx = 0;
        gCurCB.curParent = wetl;
        gCurCB.curRoll = ROLL_WRAP_ROOT;
        gCurCB.curMode = MODE_DUMP_WETL;
    } else if(gCurCB.curMode == MODE_REPLACE_EXPO) {
        EquationTextLayer *etl = ((EquationBlock *)gCurCB.curParent).parent;
        [etl.expo destroy];
        etl.expo = rootBlk;
        etl.expo.c_idx = 0;
        gCurCB.curParent = etl;
        gCurCB.curRoll = ROLL_EXPO_ROOT;
        gCurCB.curMode = MODE_DUMP_EXPO;
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
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
