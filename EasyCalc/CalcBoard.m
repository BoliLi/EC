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
        curFontLvl = 0;
        
        curFont = getFont(0);
        curFontW = gCharWidthTbl[0][8];
        curFontH = curFont.lineHeight;
        
        view = [[DisplayView alloc] init:self :dspFrame :vc];
        NSLog(@"%s%i>~%@~%@~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGRect(view.frame), NSStringFromCGRect(dspFrame));
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
        [eq.root reorganize:eq :vc :0 :nil];
        
        eq.equalsign.opacity = 1.0;
        eq.result.opacity = 1.0;
        [self.view.layer addSublayer:eq.equalsign];
        [self.view.layer addSublayer:eq.result];
    }
    
    self.curEq.par = self;
    [self.curEq.root reorganize:self.curEq :vc :0 :nil];
}

-(void) insertTemplate :(EquationBlock *)tempRoot :(ViewController *)vc {
    id sltedBlock = nil;
    CGFloat incrWidth = 0.0;
    
    EquationBlock *rootBlk = [tempRoot copy];
    EquationTextLayer *emptyTxtLyr = [rootBlk lookForEmptyTxtLyr];
    
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
        EquationBlock *eb = self.curParent;
        
        if (rootBlk.bar == nil) {
            for (id b in rootBlk.children) {
                [eb.children addObject:b];
                updateRoll(b, self.curRoll);
                [b reorganize:self.curEq :vc :0 :eb];
                sltedBlock = b;
            }
            [rootBlk.children removeAllObjects];
        } else {
            [eb.children addObject:rootBlk];
            rootBlk.roll = self.curRoll;
            [rootBlk reorganize:self.curEq :vc :0 :eb];
            sltedBlock = rootBlk;
        }
        
        [eb updateCIdx];
    } else if(self.curMode == MODE_INSERT) {
        EquationBlock *eb = self.curParent;
        
        if (rootBlk.bar == nil) {
            for (id b in rootBlk.children) {
                [eb.children insertObject:b atIndex:self.insertCIdx++];
                updateRoll(b, self.curRoll);
                [b reorganize:self.curEq :vc :0 :eb];
                sltedBlock = b;
            }
            [rootBlk.children removeAllObjects];
        } else {
            [eb.children insertObject:rootBlk atIndex:self.insertCIdx];
            rootBlk.roll = self.curRoll;
            [rootBlk reorganize:self.curEq :vc :0 :eb];
            sltedBlock = rootBlk;
        }
        
        [eb updateCIdx];
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
                    [b reorganize:self.curEq :vc :0 :newRoot];
                    sltedBlock = b;
                }
                [rootBlk.children removeAllObjects];
            } else {
                [newRoot.children addObject:rootBlk];
                rootBlk.roll = ROLL_NUMERATOR;
                [rootBlk reorganize:self.curEq :vc :0 :newRoot];
                sltedBlock = rootBlk;
            }
            [newRoot.children addObject:eq.root];
            self.curMode = MODE_INSERT;
        } else {
            [newRoot.children addObject:eq.root];
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                    [b reorganize:self.curEq :vc :0 :newRoot];
                    sltedBlock = b;
                }
                [rootBlk.children removeAllObjects];
            } else {
                [newRoot.children addObject:rootBlk];
                rootBlk.roll = ROLL_NUMERATOR;
                [rootBlk reorganize:self.curEq :vc :0 :newRoot];
                sltedBlock = rootBlk;
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
                    [b reorganize:self.curEq :vc :0 :newRootRoot];
                    sltedBlock = b;
                }
                [rootBlk.children removeAllObjects];
            } else {
                [newRootRoot.children addObject:rootBlk];
                rootBlk.roll = ROLL_NUMERATOR;
                [rootBlk reorganize:self.curEq :vc :0 :newRootRoot];
                sltedBlock = rootBlk;
            }
            
            [newRootRoot.children addObject:orgRootRoot];
            self.curMode = MODE_INSERT;
        } else {
            [newRootRoot.children addObject:orgRootRoot];
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newRootRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                    [b reorganize:self.curEq :vc :0 :newRootRoot];
                    sltedBlock = b;
                }
                [rootBlk.children removeAllObjects];
            } else {
                [newRootRoot.children addObject:rootBlk];
                rootBlk.roll = ROLL_NUMERATOR;
                [rootBlk reorganize:self.curEq :vc :0 :newRootRoot];
                sltedBlock = rootBlk;
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
                    [b reorganize:self.curEq :vc :0 :newExpoRoot];
                    sltedBlock = b;
                }
                [rootBlk.children removeAllObjects];
            } else {
                [newExpoRoot.children addObject:rootBlk];
                rootBlk.roll = ROLL_NUMERATOR;
                [rootBlk reorganize:self.curEq :vc :0 :newExpoRoot];
                sltedBlock = rootBlk;
            }
            [newExpoRoot.children addObject:orgExpoRoot];
            self.curMode = MODE_INSERT;
        } else {
            [newExpoRoot.children addObject:orgExpoRoot];
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newExpoRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                    [b reorganize:self.curEq :vc :0 :newExpoRoot];
                    sltedBlock = b;
                }
                [rootBlk.children removeAllObjects];
            } else {
                [newExpoRoot.children addObject:rootBlk];
                rootBlk.roll = ROLL_NUMERATOR;
                [rootBlk reorganize:self.curEq :vc :0 :newExpoRoot];
                sltedBlock = rootBlk;
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
                    [rootBlk reorganize:self.curEq :vc :0 :newWrapRoot];
                    sltedBlock = b;
                }
                [rootBlk.children removeAllObjects];
            } else {
                [newWrapRoot.children addObject:rootBlk];
                rootBlk.roll = ROLL_NUMERATOR;
                [rootBlk reorganize:self.curEq :vc :0 :newWrapRoot];
                sltedBlock = rootBlk;
            }
            [newWrapRoot.children addObject:orgWrapRoot];
            self.curMode = MODE_INSERT;
        } else {
            [newWrapRoot.children addObject:orgWrapRoot];
            if (rootBlk.bar == nil) {
                for (id b in rootBlk.children) {
                    [newWrapRoot.children addObject:b];
                    updateRoll(b, ROLL_NUMERATOR);
                    [rootBlk reorganize:self.curEq :vc :0 :newWrapRoot];
                    sltedBlock = b;
                }
                [rootBlk.children removeAllObjects];
            } else {
                [newWrapRoot.children addObject:rootBlk];
                rootBlk.roll = ROLL_NUMERATOR;
                [rootBlk reorganize:self.curEq :vc :0 :newWrapRoot];
                sltedBlock = rootBlk;
            }
            self.curMode = MODE_INPUT;
        }
        wetl.content = newWrapRoot;
        self.curParent = newWrapRoot;
        [self.curParent updateCIdx];
        self.curRoll = ROLL_NUMERATOR;
    } else if(self.curMode == MODE_REPLACE_ROOT) {
        [self.curEq.root destroy];
        self.curEq.root = rootBlk;
        self.curEq.root.c_idx = 0;
        
        if (rootBlk.bar == nil) {
            self.curMode = MODE_INPUT;
            self.curRoll = ROLL_NUMERATOR;
            self.curParent = rootBlk;
        } else {
            self.curMode = MODE_DUMP_ROOT;
            self.curRoll = ROLL_ROOT;
            self.curParent = nil;
        }
        sltedBlock = rootBlk;
        rootBlk.roll = ROLL_ROOT;
        [rootBlk reorganize:self.curEq :vc :0 :nil];
    } else if(self.curMode == MODE_REPLACE_RADICAL) {
        RadicalBlock *rb = ((EquationBlock *)self.curParent).parent;
        [rb.content destroy];
        rb.content = rootBlk;
        rb.content.c_idx = 0;
        
        
        if (rootBlk.bar == nil) {
            self.curMode = MODE_INPUT;
            self.curRoll = ROLL_NUMERATOR;
            self.curParent = rootBlk;
        } else {
            self.curMode = MODE_DUMP_RADICAL;
            self.curRoll = ROLL_ROOT_ROOT;
            self.curParent = rb;
        }
        sltedBlock = rootBlk;
        rootBlk.roll = ROLL_ROOT_ROOT;
        [rootBlk reorganize:self.curEq :vc :0 :rb];
    } else if(self.curMode == MODE_REPLACE_WETL) {
        WrapedEqTxtLyr *wetl = ((EquationBlock *)self.curParent).parent;
        [wetl.content destroy];
        wetl.content = rootBlk;
        wetl.content.c_idx = 0;
        
        
        if (rootBlk.bar == nil) {
            self.curMode = MODE_INPUT;
            self.curRoll = ROLL_NUMERATOR;
            self.curParent = rootBlk;
        } else {
            self.curMode = MODE_DUMP_WETL;
            self.curRoll = ROLL_WRAP_ROOT;
            self.curParent = wetl;
        }
        sltedBlock = rootBlk;
        rootBlk.roll = ROLL_WRAP_ROOT;
        [rootBlk reorganize:self.curEq :vc :0 :wetl];
    } else if(self.curMode == MODE_REPLACE_EXPO) {
        EquationTextLayer *etl = ((EquationBlock *)self.curParent).parent;
        [etl.expo destroy];
        etl.expo = rootBlk;
        etl.expo.c_idx = 0;
        
        if (rootBlk.bar == nil) {
            self.curMode = MODE_INPUT;
            self.curRoll = ROLL_NUMERATOR;
            self.curParent = rootBlk;
        } else {
            self.curMode = MODE_DUMP_EXPO;
            self.curRoll = ROLL_EXPO_ROOT;
            self.curParent = etl;
        }
        sltedBlock = rootBlk;
        rootBlk.roll = ROLL_EXPO_ROOT;
        [rootBlk reorganize:self.curEq :vc :0 :etl];
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    if ([sltedBlock isMemberOfClass: [RadicalBlock class]]) {
        RadicalBlock *rb = sltedBlock;
        
        [(EquationBlock *)self.curParent updateFrameWidth:incrWidth :rb.roll];
        [(EquationBlock *)self.curParent updateFrameHeightS1:rb];
        [self.curEq.root adjustElementPosition];
    } else if ([sltedBlock isMemberOfClass: [FractionBarLayer class]]) {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else if ([sltedBlock isMemberOfClass: [EquationTextLayer class]]) {
        EquationTextLayer *etl = sltedBlock;
        
        [(EquationBlock *)self.curParent updateFrameWidth:incrWidth :etl.roll];
        [(EquationBlock *)self.curParent updateFrameHeightS1:etl];
        [self.curEq.root adjustElementPosition];
    } else if ([sltedBlock isMemberOfClass: [EquationBlock class]]) {
        EquationBlock *eb = sltedBlock;
        
        if (eb.roll == ROLL_ROOT) {
            CGRect f = eb.mainFrame;
            f.origin.x = self.downLeftBasePoint.x;
            f.origin.y = self.downLeftBasePoint.y - f.size.height - 1.0;
            eb.mainFrame = f;
            if (eb.bar == nil) {
                sltedBlock = eb.children.lastObject;
            }
        } else if (eb.roll == ROLL_ROOT_ROOT) {
            RadicalBlock *rb = eb.parent;
            incrWidth = -rb.frame.size.width;
            [rb updateFrame];
            [rb setNeedsDisplay];
            incrWidth += rb.frame.size.width;
            [(EquationBlock *)rb.parent updateFrameWidth:incrWidth :rb.roll];
            [(EquationBlock *)rb.parent updateFrameHeightS1:rb];
            if (eb.bar == nil) {
                sltedBlock = eb.children.lastObject;
            }
        } else if (eb.roll == ROLL_WRAP_ROOT) {
            WrapedEqTxtLyr *wetl = eb.parent;
            [wetl updateFrame:YES];
            [(EquationBlock *)wetl.parent updateFrameWidth:incrWidth :wetl.roll];
            [(EquationBlock *)wetl.parent updateFrameHeightS1:wetl];
            if (eb.bar == nil) {
                sltedBlock = eb.children.lastObject;
            }
        } else if (eb.roll == ROLL_EXPO_ROOT) {
            EquationTextLayer *etl = eb.parent;
            [etl updateFrameBaseOnExpo];
            [(EquationBlock *)etl.parent updateFrameWidth:incrWidth :etl.roll];
            [(EquationBlock *)etl.parent updateFrameHeightS1:etl];
            if (eb.bar == nil) {
                sltedBlock = eb.children.lastObject;
            }
        } else {
            [(EquationBlock *)self.curParent updateFrameWidth:incrWidth :eb.roll];
            [(EquationBlock *)self.curParent updateFrameHeightS1:eb];
        }
        
        [self.curEq.root adjustElementPosition];
    } else if ([sltedBlock isMemberOfClass: [WrapedEqTxtLyr class]]) {
        WrapedEqTxtLyr *wetl = sltedBlock;
        
        [(EquationBlock *)self.curParent updateFrameWidth:incrWidth :wetl.roll];
        [(EquationBlock *)self.curParent updateFrameHeightS1:wetl];
        [self.curEq.root adjustElementPosition];
    } else if ([sltedBlock isMemberOfClass: [Parentheses class]]) {
        Parentheses *p = sltedBlock;
        
        [(EquationBlock *)self.curParent updateFrameWidth:incrWidth :p.roll];
        [(EquationBlock *)self.curParent updateFrameHeightS1:p];
        [self.curEq.root adjustElementPosition];
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    if (emptyTxtLyr == nil) {
        [sltedBlock updateCalcBoardInfo];
    } else {
        [emptyTxtLyr updateCalcBoardInfo];
    }
    
    if ((int)self.curEq.maxRootHeight < (int)self.curEq.root.mainFrame.size.height) {
        CGFloat dis = self.curEq.root.mainFrame.size.height - self.curEq.maxRootHeight;
        self.curEq.maxRootHeight = self.curEq.root.mainFrame.size.height;
        for (Equation *eq in self.eqList) {
            [eq moveUp:dis];
        }
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
