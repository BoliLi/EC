//
//  Utils.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/23.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import "Utils.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"
#import "WrapedEqTxtLyr.h"
#import "Parentheses.h"
#import "DisplayView.h"
#import "CalcBoard.h"
#import "DDMathParser.h"
#import "DDMathTokenizer.h"
#import "DDMathTokenInterpreter.h"
#import "DDMathOperator.h"
#import "DDMathOperatorSet.h"

id locaLastLyr(Equation *e, id blk) {
//    if ([blk isMemberOfClass:[EquationTextLayer class]]) {
//        EquationTextLayer *layer = blk;
//        if (layer.expo == nil) {
//            return blk;
//        }
//    }
    
    do {
        if ([blk isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *eb = blk;
            blk = eb.children.lastObject;
        } else if ([blk isMemberOfClass:[RadicalBlock class]]) {
            EquationBlock *eb = ((RadicalBlock *)blk).content;
            blk = eb.children.lastObject;
        } else if ([blk isMemberOfClass:[FractionBarLayer class]]) {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return nil;
        } else if ([blk isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *layer = blk;
            if (layer.expo != nil) {
                blk = layer.expo.children.lastObject;
            } else {
                break;
            }
        } else if ([blk isMemberOfClass:[WrapedEqTxtLyr class]]) {
            EquationBlock *eb = ((WrapedEqTxtLyr *)blk).content;
            blk = eb.children.lastObject;
        } else if ([blk isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = blk;
            if (p.expo != nil) {
                blk = p.expo.children.lastObject;
            } else {
                break;
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return nil;
        }
    } while (blk != nil);
    
    if (blk != nil) {
        if ([blk isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *layer = blk;
            EquationBlock *par = layer.parent;
            CalcBoard *calcB = e.par;
            calcB.curTxtLyr = layer;
            calcB.curBlk = layer;
            calcB.curParent = layer.parent;
            calcB.curRoll = layer.roll;
            if (layer.c_idx == par.children.count - 1) {
                calcB.curMode = MODE_INPUT;
            } else {
                calcB.curMode = MODE_INSERT;
            }
            
            calcB.insertCIdx = layer.c_idx + 1;
            calcB.txtInsIdx = (int)layer.strLenTbl.count - 1;
            
            [calcB updateFontInfo:layer.fontLvl];
            
            if (layer.type == TEXTLAYER_EMPTY) {
                calcB.view.inpOrg = CGPointMake(layer.frame.origin.x, layer.frame.origin.y);
                calcB.view.cursor.frame = CGRectMake(calcB.view.inpOrg.x, calcB.view.inpOrg.y, CURSOR_W, calcB.curFontH);
            } else {
                calcB.view.inpOrg = CGPointMake(layer.frame.origin.x + layer.frame.size.width, layer.frame.origin.y);
                calcB.view.cursor.frame = CGRectMake(calcB.view.inpOrg.x, calcB.view.inpOrg.y, CURSOR_W, calcB.curFontH);
            }
        } else { //[Parentheses class]
            Parentheses *p = blk;
            EquationBlock *par = p.parent;
            CalcBoard *calcB = e.par;
            calcB.curTxtLyr = nil;
            calcB.curBlk = p;
            calcB.curParent = par;
            calcB.curRoll = p.roll;
            if (p.c_idx == par.children.count - 1) {
                calcB.curMode = MODE_INPUT;
            } else {
                calcB.curMode = MODE_INSERT;
            }
            
            calcB.insertCIdx = p.c_idx + 1;
            calcB.txtInsIdx = 1;
            
            [calcB updateFontInfo:p.fontLvl];
            
            calcB.view.inpOrg = CGPointMake(p.mainFrame.origin.x + p.mainFrame.size.width, p.mainFrame.origin.y + p.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0);
            calcB.view.cursor.frame = CGRectMake(calcB.view.inpOrg.x, calcB.view.inpOrg.y, CURSOR_W, calcB.curFontH);
        }
        
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    return blk;
}

void handlePrevBlk(Equation *e, id preBlk) {
    BOOL needRemove = YES;
    
    do {
        if ([preBlk isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *eb = preBlk;
            preBlk = eb.children.lastObject;
            needRemove = NO;
        } else if ([preBlk isMemberOfClass:[RadicalBlock class]]) {
            EquationBlock *eb = ((RadicalBlock *)preBlk).content;
            preBlk = eb.children.lastObject;
            needRemove = NO;
        } else if ([preBlk isMemberOfClass:[FractionBarLayer class]]) {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        } else if ([preBlk isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *layer = preBlk;
            if (layer.expo != nil) {
                preBlk = layer.expo.children.lastObject;
                needRemove = NO;
            } else {
                break;
            }
        } else if ([preBlk isMemberOfClass:[WrapedEqTxtLyr class]]) {
            EquationBlock *eb = ((WrapedEqTxtLyr *)preBlk).content;
            preBlk = eb.children.lastObject;
            needRemove = NO;
        } else if ([preBlk isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = preBlk;
            if (p.expo != nil) {
                preBlk = p.expo.children.lastObject;
                needRemove = NO;
            } else {
                break;
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } while (preBlk != nil);
    
    if (preBlk != nil) {
        if ([preBlk isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = preBlk;
            if (needRemove) {
                if (l.type == TEXTLAYER_EMPTY) {
                    cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                } else if (l.type == TEXTLAYER_OP) {
                    [e removeElement:l];
                } else {
                    if (l.strLenTbl.count == 2) { // 1 char num
                        [e removeElement:l];
                    } else {
                        CGFloat orgW = l.mainFrame.size.width;
                        [l delNumCharAt:(int)l.strLenTbl.count - 1];
                        CGFloat incrWidth = l.mainFrame.size.width - orgW;
                        [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                        [e.root adjustElementPosition];
                        cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                    }
                }
            } else {
                cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
            }
        } else if ([preBlk isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = preBlk;
            if (needRemove) {
                [e removeElement:p];
            } else {
                cfgEqnBySlctBlk(e, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    return;
}

id getPrevBlk(Equation *E, id curBlk) {
    if ([curBlk isMemberOfClass:[EquationBlock class]]) {
        EquationBlock *eb = curBlk;
        if (eb.roll == ROLL_ROOT) {
            return nil;
        }
        
        if ([eb.parent isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *par = eb.parent;
            if (eb.c_idx == 0) {
                return getPrevBlk(E, par);
            } else {
                id b = [par.children objectAtIndex:eb.c_idx - 1];
                
                if ([b isMemberOfClass:[FractionBarLayer class]]) {
                    if (eb.c_idx < 2) {
                        return nil;
                    } else {
                        return [par.children objectAtIndex:eb.c_idx - 2];
                    }
                } else {
                    return b;
                }
            }
        } else if ([eb.parent isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock *rb = eb.parent;
            EquationBlock *par = rb.parent;
            if (rb.c_idx == 0) {
                return getPrevBlk(E, par);
            } else {
                id b = [par.children objectAtIndex:rb.c_idx - 1];
                
                if ([b isMemberOfClass:[FractionBarLayer class]]) {
                    if (rb.c_idx < 2) {
                        return nil;
                    } else {
                        return [par.children objectAtIndex:rb.c_idx - 2];
                    }
                } else {
                    return b;
                }
            }
        } else if ([eb.parent isMemberOfClass:[WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = eb.parent;
            EquationBlock *par = wetl.parent;
            if (wetl.c_idx == 0) {
                return getPrevBlk(E, par);
            } else {
                id b = [par.children objectAtIndex:wetl.c_idx - 1];
                
                if ([b isMemberOfClass:[FractionBarLayer class]]) {
                    if (wetl.c_idx < 2) {
                        return nil;
                    } else {
                        return [par.children objectAtIndex:wetl.c_idx - 2];
                    }
                } else {
                    return b;
                }
            }
        } else if ([eb.parent isMemberOfClass:[EquationTextLayer class]]) {
            return eb.parent;
        } else if ([eb.parent isMemberOfClass:[Parentheses class]]) {
            return eb.parent;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    } else if ([curBlk isMemberOfClass:[RadicalBlock class]]) {
        RadicalBlock *rb = curBlk;
        EquationBlock *par = rb.parent;
        if (rb.c_idx == 0) {
            return getPrevBlk(E, par);
        } else {
            id b = [par.children objectAtIndex:rb.c_idx - 1];
            
            if ([b isMemberOfClass:[FractionBarLayer class]]) {
                if (rb.c_idx < 2) {
                    return nil;
                } else {
                    return [par.children objectAtIndex:rb.c_idx - 2];
                }
            } else {
                return b;
            }
        }
    } else if ([curBlk isMemberOfClass:[WrapedEqTxtLyr class]]) {
        WrapedEqTxtLyr *wetl = curBlk;
        EquationBlock *par = wetl.parent;
        if (wetl.c_idx == 0) {
            return getPrevBlk(E, par);
        } else {
            id b = [par.children objectAtIndex:wetl.c_idx - 1];
            
            if ([b isMemberOfClass:[FractionBarLayer class]]) {
                if (wetl.c_idx < 2) {
                    return nil;
                } else {
                    return [par.children objectAtIndex:wetl.c_idx - 2];
                }
            } else {
                return b;
            }
        }
    } else if ([curBlk isMemberOfClass:[FractionBarLayer class]]) {
        FractionBarLayer *bar = curBlk;
        EquationBlock *par = bar.parent;
        return [par.children objectAtIndex:bar.c_idx - 1];
    } else if ([curBlk isMemberOfClass:[EquationTextLayer class]]) {
        EquationTextLayer *layer = curBlk;
        EquationBlock *par = layer.parent;
        if (layer.c_idx == 0) {
            return getPrevBlk(E, par);
        } else {
            id b = [par.children objectAtIndex:layer.c_idx - 1];
            
            if ([b isMemberOfClass:[FractionBarLayer class]]) {
                if (layer.c_idx < 2) {
                    return nil;
                } else {
                    return [par.children objectAtIndex:layer.c_idx - 2];
                }
            } else {
                return b;
            }
        }
    } else if ([curBlk isMemberOfClass:[Parentheses class]]) {
        Parentheses *p = curBlk;
        EquationBlock *par = p.parent;
        if (p.c_idx == 0) {
            return getPrevBlk(E, par);
        } else {
            id b = [par.children objectAtIndex:p.c_idx - 1];
            
            if ([b isMemberOfClass:[FractionBarLayer class]]) {
                if (p.c_idx < 2) {
                    return nil;
                } else {
                    return [par.children objectAtIndex:p.c_idx - 2];
                }
            } else {
                return b;
            }
        }
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return nil;
    }
    
    return nil;
}

//EquationTextLayer *findPrevTxtLayer(Equation *e, id blk) {
//    
//    if ([blk isMemberOfClass:[EquationBlock class]]) {
//        EquationBlock *eb = blk;
//        if (eb.roll == ROLL_ROOT) {
//            return nil;
//        }
//        
//        if ([eb.parent isMemberOfClass:[EquationBlock class]]) {
//            EquationBlock *par = eb.parent;
//            if (eb.c_idx == 0) {
//                return findPrevTxtLayer(e, par);
//            } else {
//                return locaLastLyr(e, [par.children objectAtIndex:eb.c_idx - 1]);
//            }
//        } else if ([eb.parent isMemberOfClass:[RadicalBlock class]]) {
//            RadicalBlock *rb = eb.parent;
//            EquationBlock *par = rb.parent;
//            if (rb.c_idx == 0) {
//                return findPrevTxtLayer(e, par);
//            } else {
//                return locaLastLyr(e, [par.children objectAtIndex:rb.c_idx - 1]);
//            }
//        } else if ([eb.parent isMemberOfClass:[WrapedEqTxtLyr class]]) {
//            WrapedEqTxtLyr *wetl = eb.parent;
//            EquationBlock *par = wetl.parent;
//            if (wetl.c_idx == 0) {
//                return findPrevTxtLayer(e, par);
//            } else {
//                return locaLastLyr(e, [par.children objectAtIndex:wetl.c_idx - 1]);
//            }
//        } else if ([eb.parent isMemberOfClass:[EquationTextLayer class]]) {
//            return eb.parent;
//        } else {
//            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
//        }
//    } else if ([blk isMemberOfClass:[RadicalBlock class]]) {
//        RadicalBlock *rb = blk;
//        EquationBlock *par = rb.parent;
//        
//        if (rb.c_idx == 0) {
//            return findPrevTxtLayer(e, par);
//        } else {
//            return locaLastLyr(e, [par.children objectAtIndex:rb.c_idx - 1]);
//        }
//    } else if ([blk isMemberOfClass:[WrapedEqTxtLyr class]]) {
//        WrapedEqTxtLyr *wetl = blk;
//        EquationBlock *par = wetl.parent;
//        
//        if (wetl.c_idx == 0) {
//            return findPrevTxtLayer(e, par);
//        } else {
//            return locaLastLyr(e, [par.children objectAtIndex:wetl.c_idx - 1]);
//        }
//    } else if ([blk isMemberOfClass:[FractionBarLayer class]]) {
//        FractionBarLayer *bar = blk;
//        EquationBlock *par = bar.parent;
//        return locaLastLyr(e, [par.children objectAtIndex:bar.c_idx - 1]);
//    } else if ([blk isMemberOfClass:[EquationTextLayer class]]) {
//        EquationTextLayer *layer = blk;
//        EquationBlock *par = layer.parent;
//        if (layer.c_idx == 0) {
//            return findPrevTxtLayer(e, par);
//        } else {
//            return locaLastLyr(e, [par.children objectAtIndex:layer.c_idx - 1]);
//        }
//    } else {
//        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
//        return nil;
//    }
//    
//    return nil;
//}

void cfgEqnBySlctBlk(Equation *e, id b, CGPoint curPoint) {
    if ([b isMemberOfClass: [EquationBlock class]]) {
        EquationBlock *eBlock = b;
        CalcBoard *calcB = e.par;
        if (eBlock.bar != nil && CGRectContainsPoint(eBlock.bar.frame, curPoint)) {
            FractionBarLayer *bar = eBlock.bar;
            EquationBlock *block = bar.parent;
            
            [calcB updateFontInfo:eBlock.fontLvl];
            
            calcB.curTxtLyr = nil;
            calcB.curBlk = block;
            if (block.roll == ROLL_ROOT) {//Root block is a fraction. Need to dump all elements in the root block into new block
                if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                    calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                    calcB.insertCIdx = 0;
                } else {
                    calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                    calcB.insertCIdx = 1;
                }
                
                calcB.curMode = MODE_DUMP_ROOT;
                calcB.curRoll = ROLL_NUMERATOR;
                
            } else if(block.roll == ROLL_ROOT_ROOT) {
                if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                    calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                    calcB.insertCIdx = 0;
                } else {
                    calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                    calcB.insertCIdx = 1;
                }
                
                calcB.curMode = MODE_DUMP_RADICAL;
                calcB.curRoll = ROLL_NUMERATOR;
                calcB.curParent = block.parent;
                
            } else if(block.roll == ROLL_EXPO_ROOT) {
                if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                    calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                    calcB.insertCIdx = 0;
                } else {
                    calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                    calcB.insertCIdx = 1;
                }
                
                calcB.curMode = MODE_DUMP_EXPO;
                calcB.curRoll = ROLL_NUMERATOR;
                calcB.curParent = block.parent;
            } else if(block.roll == ROLL_WRAP_ROOT) {
                if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                    calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                    calcB.insertCIdx = 0;
                } else {
                    calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                    calcB.insertCIdx = 1;
                }
                
                calcB.curMode = MODE_DUMP_WETL;
                calcB.curRoll = ROLL_NUMERATOR;
                calcB.curParent = block.parent;
            } else {
                id lastBlock = [((EquationBlock *)block.parent).children lastObject];
                if ([lastBlock isMemberOfClass: [EquationBlock class]] && block == (EquationBlock *)lastBlock) {
                    if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                        calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                        calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                        calcB.curMode = MODE_INSERT;
                        calcB.insertCIdx = block.c_idx;
                    } else {
                        calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                        calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                        calcB.insertCIdx = block.c_idx + 1;
                        calcB.curMode = MODE_INPUT;
                    }
                } else {
                    if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                        calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                        calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                        calcB.curMode = MODE_INSERT;
                        calcB.insertCIdx = block.c_idx;
                    } else {
                        calcB.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                        calcB.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - calcB.curFontH / 2.0);
                        calcB.curMode = MODE_INSERT;
                        calcB.insertCIdx = block.c_idx + 1;
                    }
                }
                calcB.curParent = block.parent;
                calcB.curRoll = block.roll;
                
            }
        } else {
            id blk;
            
            [calcB updateFontInfo:eBlock.fontLvl];
            
            if (curPoint.y >= eBlock.numerFrame.origin.y && curPoint.y <= eBlock.numerFrame.origin.y + eBlock.numerFrame.size.height) {
                CGFloat centerX = eBlock.mainFrame.origin.x + eBlock.mainFrame.size.width / 2.0;
                if (curPoint.x < centerX) {
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = 0;
                    blk = [eBlock.children objectAtIndex: 0];
                } else {
                    FractionBarLayer *bar = eBlock.bar;
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = bar.c_idx;
                    blk = [eBlock.children objectAtIndex: calcB.insertCIdx - 1];
                }
                
                calcB.curRoll = ROLL_NUMERATOR;
                calcB.curParent = eBlock;
            } else if (curPoint.y >= eBlock.denomFrame.origin.y && curPoint.y <= eBlock.denomFrame.origin.y + eBlock.denomFrame.size.height) {
                CGFloat centerX = eBlock.mainFrame.origin.x + eBlock.mainFrame.size.width / 2.0;
                if (curPoint.x < centerX) {
                    FractionBarLayer *bar = eBlock.bar;
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = bar.c_idx + 1;
                    blk = [eBlock.children objectAtIndex: calcB.insertCIdx];
                } else {
                    calcB.curMode = MODE_INPUT;
                    blk = [eBlock.children lastObject];
                    calcB.insertCIdx = eBlock.children.count;
                }
                
                calcB.curRoll = ROLL_DENOMINATOR;
                calcB.curParent = eBlock;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            if ([blk isMemberOfClass: [EquationTextLayer class]]) {
                EquationTextLayer *layer = blk;
                
                if (layer.type == TEXTLAYER_OP) {
                    CGFloat x = 0.0, y = 0.0;
                    if (calcB.curRoll == ROLL_NUMERATOR) {
                        if (calcB.insertCIdx == 0) {
                            x = layer.mainFrame.origin.x;
                            y = layer.frame.origin.y;
                            calcB.txtInsIdx = 0;
                        } else {
                            x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            y = layer.frame.origin.y;
                            calcB.txtInsIdx = 1;
                        }
                    } else if (calcB.curRoll == ROLL_DENOMINATOR) {
                        if (calcB.curMode == MODE_INSERT) {
                            x = layer.mainFrame.origin.x;
                            y = layer.frame.origin.y;
                            calcB.txtInsIdx = 0;
                        } else {
                            x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            y = layer.frame.origin.y;
                            calcB.txtInsIdx = 1;
                        }
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                    
                    calcB.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.mainFrame.size.height;
                    calcB.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
                    calcB.curBlk = layer;
                    calcB.curTxtLyr = nil;
                } else if (layer.type == TEXTLAYER_NUM) {
                    CGFloat x = 0.0, y = 0.0;
                    if (calcB.curRoll == ROLL_NUMERATOR) {
                        if (calcB.insertCIdx == 0) {
                            x = layer.frame.origin.x;
                            y = layer.frame.origin.y;
                            calcB.curBlk = layer;
                            calcB.curTxtLyr = layer;
                            calcB.txtInsIdx = 0;
                        } else {
                            x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            y = layer.mainFrame.origin.y;
                            calcB.curBlk = layer;
                            if (layer.expo == nil) {
                                calcB.curTxtLyr = layer;
                                calcB.txtInsIdx = (int)layer.strLenTbl.count - 1;
                            } else {
                                calcB.curTxtLyr = nil;
                            }
                        }
                    } else if (calcB.curRoll == ROLL_DENOMINATOR) {
                        if (calcB.curMode == MODE_INSERT) {
                            x = layer.frame.origin.x;
                            y = layer.frame.origin.y;
                            calcB.curBlk = layer;
                            calcB.curTxtLyr = layer;
                            calcB.txtInsIdx = 0;
                        } else {
                            x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            y = layer.mainFrame.origin.y;
                            calcB.curBlk = layer;
                            if (layer.expo == nil) {
                                calcB.curTxtLyr = layer;
                                calcB.txtInsIdx = (int)layer.strLenTbl.count - 1;
                            } else {
                                calcB.curTxtLyr = nil;
                            }
                        }
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                    
                    calcB.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.mainFrame.size.height;
                    calcB.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
                } else if (layer.type == TEXTLAYER_EMPTY) {
                    CGFloat x = 0.0, y = 0.0;
                    if (calcB.curRoll == ROLL_NUMERATOR) {
                        if (calcB.insertCIdx == 0) {
                            x = layer.frame.origin.x;
                            y = layer.frame.origin.y;
                            calcB.curTxtLyr = layer;
                            calcB.curBlk = layer;
                        } else {
                            x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            y = layer.mainFrame.origin.y;
                            if (layer.expo == nil) {
                                calcB.curTxtLyr = layer;
                                calcB.curBlk = layer;
                                calcB.insertCIdx = layer.c_idx;
                            } else {
                                calcB.curTxtLyr = nil;
                                calcB.curBlk = layer;
                            }
                        }
                    } else if (calcB.curRoll == ROLL_DENOMINATOR) {
                        if (calcB.curMode == MODE_INSERT) {
                            x = layer.frame.origin.x;
                            y = layer.frame.origin.y;
                            calcB.curTxtLyr = layer;
                            calcB.curBlk = layer;
                        } else {
                            x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            y = layer.mainFrame.origin.y;
                            if (layer.expo == nil) {
                                calcB.curTxtLyr = layer;
                                calcB.curBlk = layer;
                                calcB.insertCIdx = layer.c_idx;
                                calcB.curMode = MODE_INSERT;
                            } else {
                                calcB.curTxtLyr = nil;
                                calcB.curBlk = layer;
                            }
                        }
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                    calcB.txtInsIdx = 0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = layer.mainFrame.size.height;
                    calcB.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                
            } else if ([blk isMemberOfClass: [EquationBlock class]]) {
                EquationBlock *eBlk = blk;
                if (calcB.curRoll == ROLL_NUMERATOR) {
                    if (calcB.insertCIdx == 0) {
                        calcB.view.inpOrg = CGPointMake(eBlk.mainFrame.origin.x, eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x, eBlk.mainFrame.origin.y, CURSOR_W, eBlk.mainFrame.size.height);
                    } else {
                        calcB.view.inpOrg = CGPointMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.mainFrame.origin.y, CURSOR_W, eBlk.mainFrame.size.height);
                    }
                } else if (calcB.curRoll == ROLL_DENOMINATOR) {
                    if (calcB.curMode == MODE_INSERT) {
                        calcB.view.inpOrg = CGPointMake(eBlk.mainFrame.origin.x, eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x, eBlk.mainFrame.origin.y, CURSOR_W, eBlk.mainFrame.size.height);
                    } else {
                        calcB.view.inpOrg = CGPointMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.mainFrame.origin.y, CURSOR_W, eBlk.mainFrame.size.height);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                calcB.curTxtLyr = nil;
                calcB.curBlk = eBlk;
                
            } else if ([blk isMemberOfClass: [RadicalBlock class]]) {
                RadicalBlock *rBlk = blk;
                if (calcB.curRoll == ROLL_NUMERATOR) {
                    if (calcB.insertCIdx == 0) {
                        calcB.view.inpOrg = CGPointMake(rBlk.frame.origin.x, rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(rBlk.frame.origin.x, rBlk.frame.origin.y, CURSOR_W, rBlk.frame.size.height);
                    } else {
                        calcB.view.inpOrg = CGPointMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y, CURSOR_W, rBlk.frame.size.height);
                    }
                } else if (calcB.curRoll == ROLL_DENOMINATOR) {
                    if (calcB.curMode == MODE_INSERT) {
                        calcB.view.inpOrg = CGPointMake(rBlk.frame.origin.x, rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(rBlk.frame.origin.x, rBlk.frame.origin.y, CURSOR_W, rBlk.frame.size.height);
                    } else {
                        calcB.view.inpOrg = CGPointMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y, CURSOR_W, rBlk.frame.size.height);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                calcB.curTxtLyr = nil;
                calcB.curBlk = rBlk;
                
            } else if ([blk isMemberOfClass: [FractionBarLayer class]]) { // Should not happen anymore
                //                EquationBlock *eBlk = ((FractionBarLayer *)blk).parent;
                //                if (calcB.curRoll == ROLL_NUMERATOR) {
                //                    calcB.view.inpOrg.x = eBlk.numerFrame.origin.x;
                //                    calcB.view.inpOrg.y = eBlk.numerFrame.origin.y;
                //                    CGFloat tmp = eBlk.numerFrame.size.height;
                //                    calcB.view.cursor.frame = CGRectMake(eBlk.numerFrame.origin.x, eBlk.mainFrame.origin.y, CURSOR_W, tmp);
                //                } else if (calcB.curRoll == ROLL_DENOMINATOR) {
                //                    calcB.view.inpOrg.x = eBlk.denomFrame.origin.x;
                //                    calcB.view.inpOrg.y = eBlk.denomFrame.origin.y;
                //                    CGFloat tmp = eBlk.denomFrame.size.height;
                //                    calcB.view.cursor.frame = CGRectMake(eBlk.denomFrame.origin.x, eBlk.denomFrame.origin.y, CURSOR_W, tmp);
                //                } else
                //                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                //                calcB.curTxtLyr = nil;
                //                NSLog(@"%s%i~Tapped at blank. First input at Numer or Denom.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, eBlk.guid, (unsigned long)calcB.insertCIdx, calcB.curMode, calcB.curRoll, ((EquationBlock *)calcB.curBlk).guid);
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            } else if ([blk isMemberOfClass: [WrapedEqTxtLyr class]]) {
                WrapedEqTxtLyr *wetl = blk;
                if (calcB.curRoll == ROLL_NUMERATOR) {
                    if (calcB.insertCIdx == 0) {
                        calcB.view.inpOrg = CGPointMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y + wetl.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                    } else {
                        calcB.view.inpOrg = CGPointMake(wetl.mainFrame.origin.x + wetl.mainFrame.size.width, wetl.mainFrame.origin.y + wetl.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x + wetl.mainFrame.size.width, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                    }
                } else if (calcB.curRoll == ROLL_DENOMINATOR) {
                    if (calcB.curMode == MODE_INSERT) {
                        calcB.view.inpOrg = CGPointMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y + wetl.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                    } else {
                        calcB.view.inpOrg = CGPointMake(wetl.mainFrame.origin.x + wetl.mainFrame.size.width, wetl.mainFrame.origin.y + wetl.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x + wetl.mainFrame.size.width, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                calcB.curTxtLyr = nil;
                calcB.curBlk = wetl;
            } else if ([blk isMemberOfClass: [Parentheses class]]) {
                Parentheses *p = blk;
                if (calcB.curRoll == ROLL_NUMERATOR) {
                    if (calcB.insertCIdx == 0) {
                        calcB.view.inpOrg = CGPointMake(p.frame.origin.x, p.frame.origin.y + p.frame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                    } else {
                        calcB.view.inpOrg = CGPointMake(p.mainFrame.origin.x + p.mainFrame.size.width, p.mainFrame.origin.y + p.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(calcB.view.inpOrg.x, p.mainFrame.origin.y, CURSOR_W, p.mainFrame.size.height);
                    }
                } else if (calcB.curRoll == ROLL_DENOMINATOR) {
                    if (calcB.curMode == MODE_INSERT) {
                        calcB.view.inpOrg = CGPointMake(p.frame.origin.x, p.frame.origin.y + p.frame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                    } else {
                        calcB.view.inpOrg = CGPointMake(p.mainFrame.origin.x + p.mainFrame.size.width, p.mainFrame.origin.y + p.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0);
                        calcB.view.cursor.frame = CGRectMake(calcB.view.inpOrg.x, p.mainFrame.origin.y, CURSOR_W, p.mainFrame.size.height);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                calcB.curTxtLyr = nil;
                calcB.curBlk = p;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        }
        
        
    } else if ([b isMemberOfClass: [EquationTextLayer class]]) {
        EquationTextLayer *layer = b;
        CalcBoard *calcB = e.par;
        
        [calcB updateFontInfo:layer.fontLvl];
        
        if (layer.type == TEXTLAYER_OP) {
            calcB.txtInsIdx = [layer getTxtInsIdx:curPoint];
            CGFloat offset = [[layer.strLenTbl objectAtIndex:calcB.txtInsIdx] doubleValue];
            CGFloat x = layer.frame.origin.x + offset;
            CGFloat y = layer.frame.origin.y;
            calcB.view.cursor.frame = CGRectMake(x, y, CURSOR_W, layer.frame.size.height);
            calcB.view.inpOrg = CGPointMake(x, y);
            calcB.curTxtLyr = nil;
        } else if (layer.type == TEXTLAYER_NUM) {
            if (CGRectContainsPoint(layer.frame, curPoint)) {
                calcB.txtInsIdx = [layer getTxtInsIdx:curPoint];
                CGFloat offset = [[layer.strLenTbl objectAtIndex:calcB.txtInsIdx] doubleValue];
                CGFloat x = layer.frame.origin.x + offset;
                CGFloat y = layer.frame.origin.y;
                calcB.view.cursor.frame = CGRectMake(x, y, CURSOR_W, layer.frame.size.height);
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.curTxtLyr = layer;
            } else {
                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                CGFloat y = layer.frame.origin.y;
                calcB.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                calcB.view.cursor.frame = CGRectMake(calcB.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                calcB.curTxtLyr = nil;
                calcB.txtInsIdx = (int)layer.strLenTbl.count - 1;
            }
        } else if (layer.type == TEXTLAYER_EMPTY) {
            if (CGRectContainsPoint(layer.frame, curPoint)) {
                CGFloat x = layer.frame.origin.x;
                CGFloat y = layer.frame.origin.y;
                calcB.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.frame.size.height;
                calcB.view.cursor.frame = CGRectMake(calcB.view.inpOrg.x, calcB.view.inpOrg.y, CURSOR_W, tmp);
                calcB.curTxtLyr = layer;
                calcB.txtInsIdx = 0;
            } else {
                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                CGFloat y = layer.frame.origin.y;
                calcB.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                calcB.view.cursor.frame = CGRectMake(calcB.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                calcB.curTxtLyr = nil;
                calcB.txtInsIdx = 0;
            }
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        
        EquationBlock *block = layer.parent;
        id lastBlock = [block.children lastObject];
        if ([lastBlock isMemberOfClass: [EquationTextLayer class]] && layer == (EquationTextLayer *)lastBlock) {
            if (calcB.txtInsIdx == 0) {
                if (layer.type == TEXTLAYER_EMPTY) {
                    calcB.insertCIdx = layer.c_idx + 1;
                    calcB.curMode = MODE_INPUT;
                } else {
                    calcB.insertCIdx = layer.c_idx;
                    calcB.curMode = MODE_INSERT;
                }
            } else {
                calcB.insertCIdx = layer.c_idx + 1;
                calcB.curMode = MODE_INPUT;
            }
        } else {
            calcB.curMode = MODE_INSERT;
            if (calcB.txtInsIdx == 0) {
                if (layer.type == TEXTLAYER_EMPTY) {
                    calcB.insertCIdx = layer.c_idx + 1;
                } else {
                    calcB.insertCIdx = layer.c_idx;
                }
            } else {
                calcB.insertCIdx = layer.c_idx + 1;
            }
        }
        calcB.curRoll = layer.roll;
        calcB.curParent = block;
        calcB.curBlk = layer;
    } else if ([b isMemberOfClass: [RadicalBlock class]]) {
        RadicalBlock *block = b;
        CalcBoard *calcB = e.par;
        
        [calcB updateFontInfo:block.fontLvl];
        
        id lastBlock = [((EquationBlock *)block.parent).children lastObject];
        if ([lastBlock isMemberOfClass: [RadicalBlock class]] && block == (RadicalBlock *)lastBlock) {
            if (curPoint.x < block.frame.origin.x + block.frame.size.width / 2.0) {
                calcB.curMode = MODE_INSERT;
                calcB.insertCIdx = block.c_idx;
                CGFloat x = block.frame.origin.x;
                CGFloat y = block.frame.origin.y + block.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(block.frame.origin.x, block.frame.origin.y, CURSOR_W, block.frame.size.height);
            } else {
                calcB.curMode = MODE_INPUT;
                calcB.insertCIdx = block.c_idx + 1;
                CGFloat x = block.frame.origin.x + block.frame.size.width;
                CGFloat y = block.frame.origin.y + block.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(block.frame.origin.x + block.frame.size.width, block.frame.origin.y, CURSOR_W, block.frame.size.height);
            }
        } else {
            if (curPoint.x < block.frame.origin.x + block.frame.size.width / 2.0) {
                calcB.curMode = MODE_INSERT;
                calcB.insertCIdx = block.c_idx;
                CGFloat x = block.frame.origin.x;
                CGFloat y = block.frame.origin.y + block.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(block.frame.origin.x, block.frame.origin.y, CURSOR_W, block.frame.size.height);
            } else {
                calcB.curMode = MODE_INSERT;
                calcB.insertCIdx = block.c_idx + 1;
                CGFloat x = block.frame.origin.x + block.frame.size.width;
                CGFloat y = block.frame.origin.y + block.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(block.frame.origin.x + block.frame.size.width, block.frame.origin.y, CURSOR_W, block.frame.size.height);
            }
        }
        calcB.curParent = block.parent;
        calcB.curRoll = block.roll;
        calcB.curTxtLyr = nil;
        calcB.curBlk = block;
    } else if ([b isMemberOfClass: [WrapedEqTxtLyr class]]) {
        WrapedEqTxtLyr *wetl = b;
        CalcBoard *calcB = e.par;
        
        [calcB updateFontInfo:wetl.fontLvl];
        
        if (curPoint.x >= wetl.title.frame.origin.x && curPoint.x < wetl.left_parenth.frame.origin.x + wetl.left_parenth.frame.size.width / 2.0) {
            calcB.curMode = MODE_INSERT;
            calcB.insertCIdx = wetl.c_idx;
            CGFloat x = wetl.title.frame.origin.x;
            CGFloat y = wetl.title.frame.origin.y + wetl.title.frame.size.height / 2.0 - calcB.curFontH / 2.0;
            calcB.view.inpOrg = CGPointMake(x, y);
            calcB.view.cursor.frame = CGRectMake(wetl.title.frame.origin.x, wetl.title.frame.origin.y, CURSOR_W, wetl.title.frame.size.height);
            calcB.curParent = wetl.parent;
            calcB.curRoll = wetl.roll;
            calcB.curTxtLyr = nil;
            calcB.curBlk = wetl;
        } else if (curPoint.x >= wetl.left_parenth.frame.origin.x + wetl.left_parenth.frame.size.width / 2.0 && curPoint.x < wetl.left_parenth.frame.origin.x + wetl.left_parenth.frame.size.width) {
            if (wetl.content.bar != nil) {
                calcB.curMode = MODE_DUMP_WETL;
                CGFloat x = wetl.content.mainFrame.origin.x;
                CGFloat y = wetl.content.mainFrame.origin.y + wetl.content.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(wetl.content.mainFrame.origin.x, wetl.content.mainFrame.origin.y, CURSOR_W, wetl.content.mainFrame.size.height);
                calcB.curParent = wetl;
                calcB.curRoll = wetl.content.roll;
                calcB.curTxtLyr = nil;
                calcB.curBlk = wetl.content;
                calcB.insertCIdx = 0;
            } else {
                calcB.curMode = MODE_INSERT;
                calcB.insertCIdx = 0;
                id b = wetl.content.children.firstObject;
                if ([b isMemberOfClass:[EquationBlock class]]) {
                    EquationBlock *eb = b;
                    CGFloat x = eb.mainFrame.origin.x;
                    CGFloat y = eb.mainFrame.origin.y + eb.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    calcB.view.cursor.frame = CGRectMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y, CURSOR_W, eb.mainFrame.size.height);
                    calcB.curParent = wetl.content;
                    calcB.curRoll = eb.roll;
                    calcB.curTxtLyr = nil;
                    calcB.curBlk = eb;
                } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = b;
                    CGFloat x = l.mainFrame.origin.x;
                    CGFloat y = l.mainFrame.origin.y + l.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    calcB.view.cursor.frame = CGRectMake(l.mainFrame.origin.x, l.mainFrame.origin.y, CURSOR_W, l.mainFrame.size.height);
                    calcB.curParent = wetl.content;
                    calcB.curRoll = l.roll;
                    calcB.curTxtLyr = l;
                    calcB.txtInsIdx = 0;
                    calcB.curBlk = l;
                } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                    RadicalBlock *rb = b;
                    CGFloat x = rb.frame.origin.x;
                    CGFloat y = rb.frame.origin.y + rb.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    calcB.view.cursor.frame = CGRectMake(rb.frame.origin.x, rb.frame.origin.y, CURSOR_W, rb.frame.size.height);
                    calcB.curParent = wetl.content;
                    calcB.curRoll = rb.roll;
                    calcB.curTxtLyr = nil;
                    calcB.curBlk = rb;
                } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl1 = b;
                    CGFloat x = wetl1.title.frame.origin.x;
                    CGFloat y = wetl1.title.frame.origin.y + wetl1.title.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    calcB.view.cursor.frame = CGRectMake(wetl1.title.frame.origin.x, wetl1.title.frame.origin.y, CURSOR_W, wetl1.title.frame.size.height);
                    calcB.curParent = wetl.content;
                    calcB.curRoll = wetl1.roll;
                    calcB.curTxtLyr = nil;
                    calcB.curBlk = wetl1;
                } else if ([b isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = b;
                    CGFloat x = p.frame.origin.x;
                    CGFloat y = p.frame.origin.y + p.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                    calcB.curParent = wetl.content;
                    calcB.curRoll = p.roll;
                    calcB.curTxtLyr = nil;
                    calcB.curBlk = p;
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
        } else if (curPoint.x >= wetl.right_parenth.frame.origin.x && curPoint.x < wetl.right_parenth.frame.origin.x + wetl.right_parenth.frame.size.width / 2.0) {
            if (wetl.content.bar != nil) {
                calcB.curMode = MODE_DUMP_WETL;
                CGFloat x = wetl.content.mainFrame.origin.x + wetl.content.mainFrame.size.width;
                CGFloat y = wetl.content.mainFrame.origin.y + wetl.content.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(wetl.content.mainFrame.origin.x + wetl.content.mainFrame.size.width, wetl.content.mainFrame.origin.y, CURSOR_W, wetl.content.mainFrame.size.height);
                calcB.curParent = wetl;
                calcB.curRoll = wetl.content.roll;
                calcB.curTxtLyr = nil;
                calcB.curBlk = wetl.content;
                calcB.insertCIdx = 1;
            } else {
                calcB.curMode = MODE_INPUT;
                calcB.insertCIdx = wetl.content.children.count;
                id b = wetl.content.children.lastObject;
                if ([b isMemberOfClass:[EquationBlock class]]) {
                    EquationBlock *eb = b;
                    CGFloat x = eb.mainFrame.origin.x + eb.mainFrame.size.width;
                    CGFloat y = eb.mainFrame.origin.y + eb.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    calcB.view.cursor.frame = CGRectMake(eb.mainFrame.origin.x + eb.mainFrame.size.width, eb.mainFrame.origin.y, CURSOR_W, eb.mainFrame.size.height);
                    calcB.curParent = wetl.content;
                    calcB.curRoll = eb.roll;
                    calcB.curTxtLyr = nil;
                    calcB.curBlk = eb;
                } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = b;
                    CGFloat x = l.mainFrame.origin.x + l.mainFrame.size.width;
                    CGFloat y = l.mainFrame.origin.y + l.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    calcB.view.cursor.frame = CGRectMake(l.mainFrame.origin.x + l.mainFrame.size.width, l.mainFrame.origin.y, CURSOR_W, l.mainFrame.size.height);
                    calcB.curParent = wetl.content;
                    calcB.curRoll = l.roll;
                    if (l.expo != nil) {
                        calcB.curTxtLyr = nil;
                    } else {
                        calcB.curTxtLyr = l;
                        calcB.txtInsIdx = (int)l.strLenTbl.count - 1;
                    }
                    calcB.curBlk = l;
                } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                    RadicalBlock *rb = b;
                    CGFloat x = rb.frame.origin.x + rb.frame.size.width;
                    CGFloat y = rb.frame.origin.y + rb.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    calcB.view.cursor.frame = CGRectMake(rb.frame.origin.x + rb.frame.size.width, rb.frame.origin.y, CURSOR_W, rb.frame.size.height);
                    calcB.curParent = wetl.content;
                    calcB.curRoll = rb.roll;
                    calcB.curTxtLyr = nil;
                    calcB.curBlk = rb;
                } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl1 = b;
                    CGFloat x = wetl1.right_parenth.frame.origin.x + wetl1.right_parenth.frame.size.width;
                    CGFloat y = wetl1.right_parenth.frame.origin.y + wetl1.right_parenth.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    calcB.view.cursor.frame = CGRectMake(wetl1.right_parenth.frame.origin.x + wetl1.right_parenth.frame.size.width, wetl1.right_parenth.frame.origin.y, CURSOR_W, wetl1.right_parenth.frame.size.height);
                    calcB.curParent = wetl.content;
                    calcB.curRoll = wetl1.roll;
                    calcB.curTxtLyr = nil;
                    calcB.curBlk = wetl1;
                } else if ([b isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = b;
                    CGFloat x = p.mainFrame.origin.x + p.mainFrame.size.width;
                    CGFloat y = p.mainFrame.origin.y + p.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0;
                    calcB.view.inpOrg = CGPointMake(x, y);
                    calcB.view.cursor.frame = CGRectMake(x, p.mainFrame.origin.y, CURSOR_W, p.mainFrame.size.height);
                    calcB.curParent = wetl.content;
                    calcB.curRoll = p.roll;
                    calcB.curTxtLyr = nil;
                    calcB.curBlk = p;
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
        } else if (curPoint.x >= wetl.right_parenth.frame.origin.x + wetl.right_parenth.frame.size.width / 2.0 && curPoint.x < wetl.right_parenth.frame.origin.x + wetl.right_parenth.frame.size.width) {
            id lastBlock = [((EquationBlock *)wetl.parent).children lastObject];
            if ([lastBlock isMemberOfClass: [WrapedEqTxtLyr class]] && wetl == (WrapedEqTxtLyr *)lastBlock) {
                calcB.curMode = MODE_INPUT;
                calcB.insertCIdx = wetl.c_idx + 1;
                CGFloat x = wetl.right_parenth.frame.origin.x + wetl.right_parenth.frame.size.width;
                CGFloat y = wetl.right_parenth.frame.origin.y + wetl.right_parenth.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(wetl.right_parenth.frame.origin.x + wetl.right_parenth.frame.size.width, wetl.right_parenth.frame.origin.y, CURSOR_W, wetl.right_parenth.frame.size.height);
                calcB.curParent = wetl.parent;
                calcB.curRoll = wetl.roll;
                calcB.curTxtLyr = nil;
                calcB.curBlk = wetl;
            } else {
                calcB.curMode = MODE_INSERT;
                calcB.insertCIdx = wetl.c_idx + 1;
                CGFloat x = wetl.right_parenth.frame.origin.x + wetl.right_parenth.frame.size.width;
                CGFloat y = wetl.right_parenth.frame.origin.y + wetl.right_parenth.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(wetl.right_parenth.frame.origin.x + wetl.right_parenth.frame.size.width, wetl.right_parenth.frame.origin.y, CURSOR_W, wetl.right_parenth.frame.size.height);
                calcB.curParent = wetl.parent;
                calcB.curRoll = wetl.roll;
                calcB.curTxtLyr = nil;
                calcB.curBlk = wetl;
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    } else if ([b isMemberOfClass: [Parentheses class]]) {
        Parentheses *p = b;
        CalcBoard *calcB = e.par;
        
        if (![p.parent isMemberOfClass:[EquationBlock class]]) {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
        
        EquationBlock *par = p.parent;
        
        [calcB updateFontInfo:par.fontLvl];
        
        id lastBlock = [((EquationBlock *)p.parent).children lastObject];
        if ([lastBlock isMemberOfClass: [Parentheses class]] && p == (Parentheses *)lastBlock) {
            if (curPoint.x < p.frame.origin.x + p.frame.size.width / 2.0) {
                calcB.curMode = MODE_INSERT;
                calcB.insertCIdx = p.c_idx;
                CGFloat x = p.frame.origin.x;
                CGFloat y = p.frame.origin.y + p.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
            } else {
                calcB.curMode = MODE_INPUT;
                calcB.insertCIdx = p.c_idx + 1;
                CGFloat x = p.mainFrame.origin.x + p.mainFrame.size.width;
                CGFloat y = p.mainFrame.origin.y + p.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(x, p.mainFrame.origin.y, CURSOR_W, p.mainFrame.size.height);
            }
        } else {
            if (curPoint.x < p.frame.origin.x + p.frame.size.width / 2.0) {
                calcB.curMode = MODE_INSERT;
                calcB.insertCIdx = p.c_idx;
                CGFloat x = p.frame.origin.x;
                CGFloat y = p.frame.origin.y + p.frame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
            } else {
                calcB.curMode = MODE_INSERT;
                calcB.insertCIdx = p.c_idx + 1;
                CGFloat x = p.mainFrame.origin.x + p.mainFrame.size.width;
                CGFloat y = p.mainFrame.origin.y + p.mainFrame.size.height / 2.0 - calcB.curFontH / 2.0;
                calcB.view.inpOrg = CGPointMake(x, y);
                calcB.view.cursor.frame = CGRectMake(x, p.mainFrame.origin.y, CURSOR_W, p.mainFrame.size.height);
            }
        }
        calcB.curParent = p.parent;
        calcB.curRoll = p.roll;
        calcB.curTxtLyr = nil;
        calcB.curBlk = p;
    } else if ([b isMemberOfClass: [FractionBarLayer class]]) {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
}

NSMutableString *calcParenth(EquationBlock *parent, int *i) {
    NSMutableString *ret = [NSMutableString stringWithCapacity:256];
    BOOL firstLeftP = YES;
    BOOL isCidx0 = NO;
    
    while (*i < parent.children.count) {
        id b = [parent.children objectAtIndex:*i];
        if ([b isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eb = b;
            
            if (eb.c_idx == 0) {
                [ret appendString:@"("];
            }
            
            [ret appendString:@"("];
            int j = 0;
            [ret appendString:equationToString(b, &j)];
            [ret appendString:@")"];
            
            if (eb.c_idx == parent.children.count - 1) {
                [ret appendString:@")"];
            }
        } else if ([b isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *l = b;
            if (l.c_idx == 0) {
                [ret appendString:@"("];
            }
            
            if (l.expo != nil) {
                [ret appendString:@"pow("];
                [ret appendString:[l.string string]];
                [ret appendString:@","];
                int j = 0;
                [ret appendString:equationToString(l.expo, &j)];
                [ret appendString:@")"];
            } else {
                [ret appendString:[l.string string]];
            }
            
            if (l.c_idx == parent.children.count - 1) {
                [ret appendString:@")"];
            }
        } else if ([b isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rb = b;
            
            if (rb.c_idx == 0) {
                [ret appendString:@"("];
            }
            
            if (rb.rootNum != nil) {
                [ret appendString:@"cuberoot("];
                int j = 0;
                [ret appendString:equationToString(rb.content, &j)];
                [ret appendString:@")"];
            } else {
                [ret appendString:@"sqrt("];
                int j = 0;
                [ret appendString:equationToString(rb.content, &j)];
                [ret appendString:@")"];
            }
            
            if (rb.c_idx == parent.children.count - 1) {
                [ret appendString:@")"];
            }
        } else if ([b isMemberOfClass: [FractionBarLayer class]]) {
            [ret appendString:@")/("];
        } else if ([b isMemberOfClass: [WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = b;
            
            if (wetl.c_idx == 0) {
                [ret appendString:@"("];
            }
            
            [ret appendString:[wetl.title.string string]];
            [ret appendString:@"("];
            int j = 0;
            [ret appendString:equationToString(wetl.content, &j)];
            [ret appendString:@")"];
            
            if (wetl.c_idx == parent.children.count - 1) {
                [ret appendString:@")"];
            }
        } else if ([b isMemberOfClass: [Parentheses class]]) {
            Parentheses *p = b;
            
            if (p.c_idx == 0) {
                isCidx0 = YES;
            }
            
            if (p.l_or_r == LEFT_PARENTH) {
                if (firstLeftP) {
                    firstLeftP = NO;
                    [ret appendString:@"("];
                } else {
                    [ret appendString:calcParenth(parent, i)];
                }
            } else {
                if (p.expo == nil) {
                    if (isCidx0) {
                        [ret insertString:@"(" atIndex:0];
                    }
                    [ret appendString:@")"];
                } else {
                    int k = 0;
                    if (isCidx0) {
                        [ret insertString:@"(" atIndex:k++];
                    }
                    [ret insertString:@"pow" atIndex:k];
                    [ret appendString:@","];
                    int j = 0;
                    [ret appendString:equationToString(p.expo, &j)];
                    [ret appendString:@")"];
                }
                
                if (p.c_idx == parent.children.count - 1) {
                    [ret appendString:@")"];
                }
                
                return ret;
            }
            
            if (p.c_idx == parent.children.count - 1) {
                [ret appendString:@")"];
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        (*i)++;
    }
    if (isCidx0) {
        [ret insertString:@"(" atIndex:0];
    }
    return ret;
}

NSMutableString *equationToString(EquationBlock *parent, int *i) {
    NSMutableString *ret = [NSMutableString stringWithCapacity:256];
    
    while (*i < parent.children.count) {
        id b = [parent.children objectAtIndex:*i];
        if ([b isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eb = b;
            
            if (eb.c_idx == 0) {
                [ret appendString:@"("];
            }
            
            [ret appendString:@"("];
            int j = 0;
            [ret appendString:equationToString(b, &j)];
            [ret appendString:@")"];
            
            if (eb.c_idx == parent.children.count - 1) {
                [ret appendString:@")"];
            }
        } else if ([b isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *l = b;
            if (l.c_idx == 0) {
                [ret appendString:@"("];
            }
            
            if (l.expo != nil) {
                [ret appendString:@"pow("];
                [ret appendString:[l.string string]];
                [ret appendString:@","];
                int j = 0;
                [ret appendString:equationToString(l.expo, &j)];
                [ret appendString:@")"];
            } else {
                [ret appendString:[l.string string]];
            }
            
            if (l.c_idx == parent.children.count - 1) {
                [ret appendString:@")"];
            }
        } else if ([b isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rb = b;
            
            if (rb.c_idx == 0) {
                [ret appendString:@"("];
            }
            
            if (rb.rootNum != nil) {
                [ret appendString:@"cuberoot("];
                int j = 0;
                [ret appendString:equationToString(rb.content, &j)];
                [ret appendString:@")"];
            } else {
                [ret appendString:@"sqrt("];
                int j = 0;
                [ret appendString:equationToString(rb.content, &j)];
                [ret appendString:@")"];
            }
            
            if (rb.c_idx == parent.children.count - 1) {
                [ret appendString:@")"];
            }
        } else if ([b isMemberOfClass: [FractionBarLayer class]]) {
            [ret appendString:@")/("];
        } else if ([b isMemberOfClass: [WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = b;
            
            if (wetl.c_idx == 0) {
                [ret appendString:@"("];
            }
            
            [ret appendString:[wetl.title.string string]];
            [ret appendString:@"("];
            int j = 0;
            [ret appendString:equationToString(wetl.content, &j)];
            [ret appendString:@")"];
            
            if (wetl.c_idx == parent.children.count - 1) {
                [ret appendString:@")"];
            }
        } else if ([b isMemberOfClass: [Parentheses class]]) {
            [ret appendString:calcParenth(parent, i)];
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        (*i)++;
    }
    
    return ret;
}

NSNumber *calculate(NSMutableString *input) {
    
    DDMathOperatorSet *defaultOperators = [DDMathOperatorSet defaultOperatorSet];
    defaultOperators.interpretsPercentSignAsModulo = NO;
    DDMathEvaluator *evaluator = [[DDMathEvaluator alloc] init];
    
    evaluator.functionResolver = ^DDMathFunction (NSString *name) {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return ^(NSArray *args, NSDictionary *substitutions, DDMathEvaluator *eval, NSError **error) {
            return [DDExpression numberExpressionWithNumber:@0];
        };
    };
    
    evaluator.variableResolver = ^(NSString *variable) {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return @0;
    };
    
    NSError *error = nil;
    
    DDMathTokenizer *tokenizer = [[DDMathTokenizer alloc] initWithString:input operatorSet:nil error:&error];
    if (error) {
        NSLog(@"%s%i>~~ERR~%@~~~~~~~~", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
    
    DDMathTokenInterpreter *interpreter = [[DDMathTokenInterpreter alloc] initWithTokenizer:tokenizer error:&error];
    if (error) {
        NSLog(@"%s%i>~~ERR~%@~~~~~~~~", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
    DDParser *parser = [[DDParser alloc] initWithTokenInterpreter:interpreter];
    
    DDExpression *expression = [parser parsedExpressionWithError:&error];
    if (error) {
        NSLog(@"%s%i>~~ERR~%@~~~~~~~~", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
    DDExpression *rewritten = [[DDExpressionRewriter defaultRewriter] expressionByRewritingExpression:expression withEvaluator:evaluator];
    
    NSNumber *value = [evaluator evaluateExpression:rewritten withSubstitutions:nil error:&error];
    if (error) {
        NSLog(@"%s%i>~~ERR~%@~~~~~~~~", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
    
    return value;
}

void updateRoll(id b, int r) {
    if ([b isMemberOfClass: [EquationTextLayer class]]) {
        EquationTextLayer *layer = b;
        layer.roll = r;
    } else if ([b isMemberOfClass: [FractionBarLayer class]]) {
        
    } else if ([b isMemberOfClass: [EquationBlock class]]) {
        EquationBlock *eb = b;
        eb.roll = r;
    } else if ([b isMemberOfClass: [RadicalBlock class]]) {
        RadicalBlock *rb = b;
        rb.roll = r;
    } else if ([b isMemberOfClass: [WrapedEqTxtLyr class]]) {
        WrapedEqTxtLyr *wetl = b;
        wetl.roll = r;
    } else if ([b isMemberOfClass: [Parentheses class]]) {
        Parentheses *p = b;
        p.roll = r;
    } else
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
}

bool rectContainsRect(CGRect rect1, CGRect rect2) {
    int x1 = (int)rect1.origin.x;
    int x2 = (int)rect2.origin.x;
    int y1 = (int)rect1.origin.y;
    int y2 = (int)rect2.origin.y;
    int w1 = (int)rect1.size.width;
    int w2 = (int)rect2.size.width;
    int h1 = (int)rect1.size.height;
    int h2 = (int)rect2.size.height;
    if (x1 <= x2) {
        if (x1+w1 >= x2+w2) {
            if (y1 <= y2) {
                if (y1+h1 >= y2+h2) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

BOOL isNumber(NSString *str) {
    NSScanner* scan = [NSScanner scannerWithString:str];
    int val;
    float val1;
    return ([scan scanInt:&val] && [scan isAtEnd]) || ([scan scanFloat:&val1] && [scan isAtEnd]);
}

EquationTextLayer *lookForEmptyTxtLyr(EquationBlock *rootBlock) {
    for (id b in rootBlock.children) {
        if ([b isMemberOfClass:[EquationTextLayer class]] && ((EquationTextLayer *)b).type == TEXTLAYER_EMPTY) {
            return b;
        }
    }
    return nil;
}

UIButton *makeButton(CGRect btmFrame, NSString *title, UIFont *buttonFont) {
    UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
    bn.titleLabel.font = buttonFont;
    bn.layer.borderWidth = 1;
    bn.layer.cornerRadius = 5;
    bn.layer.borderColor = [[UIColor blueColor] CGColor];
    bn.showsTouchWhenHighlighted = YES;
    [bn setTitle:title forState:UIControlStateNormal];
    bn.frame = btmFrame;
    return bn;
}
