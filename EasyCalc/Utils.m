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
#import "DisplayView.h"

EquationTextLayer *locaLastTxtLyr(Equation *e, id blk) {
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
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return nil;
        }
    } while (blk != nil);
    
    if (blk != nil) {
        EquationTextLayer *layer = blk;
        EquationBlock *par = layer.parent;
        e.curTxtLyr = layer;
        e.curBlk = layer;
        e.curParent = layer.parent;
        e.curRoll = layer.roll;
        if (layer.c_idx == par.children.count - 1) {
            e.curMode = MODE_INPUT;
        } else {
            e.curMode = MODE_INSERT;
        }
        
        e.insertCIdx = layer.c_idx + 1;
        e.txtInsIdx = (int)layer.strLenTbl.count - 1;
        
        if (layer.is_base_expo == IS_BASE) {
            e.curFont = e.baseFont;
        } else if (layer.is_base_expo == IS_EXPO) {
            e.curFont = e.superscriptFont;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        if (layer.type == TEXTLAYER_EMPTY) {
            e.view.inpOrg = CGPointMake(layer.frame.origin.x, layer.frame.origin.y);
            e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, e.curFontH);
        } else {
            e.view.inpOrg = CGPointMake(layer.frame.origin.x + layer.frame.size.width, layer.frame.origin.y);
            e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, e.curFontH);
        }
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    return blk;
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
        } else if ([eb.parent isMemberOfClass:[EquationTextLayer class]]) {
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
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return nil;
    }
    
    return nil;
}

EquationTextLayer *findPrevTxtLayer(Equation *e, id blk) {
    
    if ([blk isMemberOfClass:[EquationBlock class]]) {
        EquationBlock *eb = blk;
        if (eb.roll == ROLL_ROOT) {
            return nil;
        }
        
        if ([eb.parent isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *par = eb.parent;
            if (eb.c_idx == 0) {
                return findPrevTxtLayer(e, par);
            } else {
                return locaLastTxtLyr(e, [par.children objectAtIndex:eb.c_idx - 1]);
            }
        } else if ([eb.parent isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock *rb = eb.parent;
            EquationBlock *par = rb.parent;
            if (rb.c_idx == 0) {
                return findPrevTxtLayer(e, par);
            } else {
                return locaLastTxtLyr(e, [par.children objectAtIndex:rb.c_idx - 1]);
            }
        } else if ([eb.parent isMemberOfClass:[EquationTextLayer class]]) {
            return eb.parent;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    } else if ([blk isMemberOfClass:[RadicalBlock class]]) {
        RadicalBlock *rb = blk;
        EquationBlock *par = rb.parent;
        
        if (rb.c_idx == 0) {
            return findPrevTxtLayer(e, par);
        } else {
            return locaLastTxtLyr(e, [par.children objectAtIndex:rb.c_idx - 1]);
        }
    } else if ([blk isMemberOfClass:[FractionBarLayer class]]) {
        FractionBarLayer *bar = blk;
        EquationBlock *par = bar.parent;
        return locaLastTxtLyr(e, [par.children objectAtIndex:bar.c_idx - 1]);
    } else if ([blk isMemberOfClass:[EquationTextLayer class]]) {
        EquationTextLayer *layer = blk;
        EquationBlock *par = layer.parent;
        if (layer.c_idx == 0) {
            return findPrevTxtLayer(e, par);
        } else {
            return locaLastTxtLyr(e, [par.children objectAtIndex:layer.c_idx - 1]);
        }
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return nil;
    }
    
    return nil;
}

void cfgEqnBySlctBlk(Equation *e, id b, CGPoint curPoint) {
    if ([b isMemberOfClass: [EquationBlock class]]) {
        EquationBlock *eBlock = b;
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        
        id blk;
        
        if (eBlock.is_base_expo == IS_BASE) {
            e.curFont = e.baseFont;
        } else if (eBlock.is_base_expo == IS_EXPO) {
            e.curFont = e.superscriptFont;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        if (curPoint.y >= eBlock.numerFrame.origin.y && curPoint.y <= eBlock.numerFrame.origin.y + eBlock.numerFrame.size.height) {
            CGFloat centerX = eBlock.mainFrame.origin.x + eBlock.mainFrame.size.width / 2.0;
            if (curPoint.x < centerX) {
                e.curMode = MODE_INSERT;
                e.insertCIdx = 0;
                blk = [eBlock.children objectAtIndex: 0];
            } else {
                FractionBarLayer *bar = eBlock.bar;
                e.curMode = MODE_INSERT;
                e.insertCIdx = bar.c_idx;
                blk = [eBlock.children objectAtIndex: e.insertCIdx - 1];
            }
            
            e.curRoll = ROLL_NUMERATOR;
            e.curParent = eBlock;
        } else if (curPoint.y >= eBlock.denomFrame.origin.y && curPoint.y <= eBlock.denomFrame.origin.y + eBlock.denomFrame.size.height) {
            CGFloat centerX = eBlock.mainFrame.origin.x + eBlock.mainFrame.size.width / 2.0;
            if (curPoint.x < centerX) {
                FractionBarLayer *bar = eBlock.bar;
                e.curMode = MODE_INSERT;
                e.insertCIdx = bar.c_idx + 1;
                blk = [eBlock.children objectAtIndex: e.insertCIdx];
            } else {
                e.curMode = MODE_INPUT;
                blk = [eBlock.children lastObject];
                e.insertCIdx = eBlock.children.count;
            }
            
            e.curRoll = ROLL_DENOMINATOR;
            e.curParent = eBlock;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        if ([blk isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = blk;
            
            if (layer.type == TEXTLAYER_OP) {
                CGFloat x = 0.0, y = 0.0;
                if (e.curRoll == ROLL_NUMERATOR) {
                    if (e.insertCIdx == 0) {
                        x = layer.mainFrame.origin.x;
                        y = layer.frame.origin.y;
                        e.txtInsIdx = 0;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.frame.origin.y;
                        e.txtInsIdx = 1;
                    }
                } else if (e.curRoll == ROLL_DENOMINATOR) {
                    if (e.curMode == MODE_INSERT) {
                        x = layer.mainFrame.origin.x;
                        y = layer.frame.origin.y;
                        e.txtInsIdx = 0;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.frame.origin.y;
                        e.txtInsIdx = 1;
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
                e.curBlk = layer;
                e.curTxtLyr = nil;
            } else if (layer.type == TEXTLAYER_NUM) {
                CGFloat x = 0.0, y = 0.0;
                if (e.curRoll == ROLL_NUMERATOR) {
                    if (e.insertCIdx == 0) {
                        x = layer.frame.origin.x;
                        y = layer.frame.origin.y;
                        e.curBlk = layer;
                        e.curTxtLyr = layer;
                        e.txtInsIdx = 0;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.mainFrame.origin.y;
                        e.curBlk = layer;
                        if (layer.expo == nil) {
                            e.curTxtLyr = layer;
                            e.txtInsIdx = (int)layer.strLenTbl.count - 1;
                        } else {
                            e.curTxtLyr = nil;
                        }
                    }
                } else if (e.curRoll == ROLL_DENOMINATOR) {
                    if (e.curMode == MODE_INSERT) {
                        x = layer.frame.origin.x;
                        y = layer.frame.origin.y;
                        e.curBlk = layer;
                        e.curTxtLyr = layer;
                        e.txtInsIdx = 0;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.mainFrame.origin.y;
                        e.curBlk = layer;
                        if (layer.expo == nil) {
                            e.curTxtLyr = layer;
                            e.txtInsIdx = (int)layer.strLenTbl.count - 1;
                        } else {
                            e.curTxtLyr = nil;
                        }
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
            } else if (layer.type == TEXTLAYER_EMPTY) {
                CGFloat x = 0.0, y = 0.0;
                if (e.curRoll == ROLL_NUMERATOR) {
                    if (e.insertCIdx == 0) {
                        x = layer.frame.origin.x;
                        y = layer.frame.origin.y;
                        e.curTxtLyr = layer;
                        e.curBlk = layer;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.mainFrame.origin.y;
                        if (layer.expo == nil) {
                            e.curTxtLyr = layer;
                            e.curBlk = layer;
                            e.insertCIdx = layer.c_idx;
                        } else {
                            e.curTxtLyr = nil;
                            e.curBlk = layer;
                        }
                    }
                } else if (e.curRoll == ROLL_DENOMINATOR) {
                    if (e.curMode == MODE_INSERT) {
                        x = layer.frame.origin.x;
                        y = layer.frame.origin.y;
                        e.curTxtLyr = layer;
                        e.curBlk = layer;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.mainFrame.origin.y;
                        if (layer.expo == nil) {
                            e.curTxtLyr = layer;
                            e.curBlk = layer;
                            e.insertCIdx = layer.c_idx;
                            e.curMode = MODE_INSERT;
                        } else {
                            e.curTxtLyr = nil;
                            e.curBlk = layer;
                        }
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                e.txtInsIdx = 0;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
            } else if (layer.type == TEXTLAYER_PARENTH) {
                CGFloat x = 0.0, y = 0.0;
                if (e.curRoll == ROLL_NUMERATOR) {
                    if (e.insertCIdx == 0) {
                        x = layer.mainFrame.origin.x;
                        y = layer.frame.origin.y;
                        e.txtInsIdx = 0;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.frame.origin.y;
                        e.txtInsIdx = 1;
                    }
                } else if (e.curRoll == ROLL_DENOMINATOR) {
                    if (e.curMode == MODE_INSERT) {
                        x = layer.mainFrame.origin.x;
                        y = layer.frame.origin.y;
                        e.txtInsIdx = 0;
                    } else {
                        x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                        y = layer.frame.origin.y;
                        e.txtInsIdx = 1;
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, tmp);
                e.curBlk = layer;
                e.curTxtLyr = nil;
            } else
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
        } else if ([blk isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eBlk = blk;
            if (e.curRoll == ROLL_NUMERATOR) {
                if (e.insertCIdx == 0) {
                    e.view.inpOrg = CGPointMake(eBlk.mainFrame.origin.x, eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - e.curFontH / 2.0);
                    e.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x, eBlk.mainFrame.origin.y, CURSOR_W, eBlk.mainFrame.size.height);
                } else {
                    e.view.inpOrg = CGPointMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - e.curFontH / 2.0);
                    e.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.mainFrame.origin.y, CURSOR_W, eBlk.mainFrame.size.height);
                }
            } else if (e.curRoll == ROLL_DENOMINATOR) {
                if (e.curMode == MODE_INSERT) {
                    e.view.inpOrg = CGPointMake(eBlk.mainFrame.origin.x, eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - e.curFontH / 2.0);
                    e.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x, eBlk.mainFrame.origin.y, CURSOR_W, eBlk.mainFrame.size.height);
                } else {
                    e.view.inpOrg = CGPointMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.numerFrame.origin.y + eBlk.numerFrame.size.height - e.curFontH / 2.0);
                    e.view.cursor.frame = CGRectMake(eBlk.mainFrame.origin.x + eBlk.mainFrame.size.width, eBlk.mainFrame.origin.y, CURSOR_W, eBlk.mainFrame.size.height);
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            e.curTxtLyr = nil;
            e.curBlk = eBlk;
            
        } else if ([blk isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rBlk = blk;
            if (e.curRoll == ROLL_NUMERATOR) {
                if (e.insertCIdx == 0) {
                    e.view.inpOrg = CGPointMake(rBlk.frame.origin.x, rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - e.curFontH / 2.0);
                    e.view.cursor.frame = CGRectMake(rBlk.frame.origin.x, rBlk.frame.origin.y, CURSOR_W, rBlk.frame.size.height);
                } else {
                    e.view.inpOrg = CGPointMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - e.curFontH / 2.0);
                    e.view.cursor.frame = CGRectMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y, CURSOR_W, rBlk.frame.size.height);
                }
            } else if (e.curRoll == ROLL_DENOMINATOR) {
                if (e.curMode == MODE_INSERT) {
                    e.view.inpOrg = CGPointMake(rBlk.frame.origin.x, rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - e.curFontH / 2.0);
                    e.view.cursor.frame = CGRectMake(rBlk.frame.origin.x, rBlk.frame.origin.y, CURSOR_W, rBlk.frame.size.height);
                } else {
                    e.view.inpOrg = CGPointMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y + rBlk.frame.size.height / 2.0 - e.curFontH / 2.0);
                    e.view.cursor.frame = CGRectMake(rBlk.frame.origin.x + rBlk.frame.size.width, rBlk.frame.origin.y, CURSOR_W, rBlk.frame.size.height);
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            e.curTxtLyr = nil;
            e.curBlk = rBlk;
            
        } else if ([blk isMemberOfClass: [FractionBarLayer class]]) { // Should not happen anymore
            //                EquationBlock *eBlk = ((FractionBarLayer *)blk).parent;
            //                if (e.curRoll == ROLL_NUMERATOR) {
            //                    e.view.inpOrg.x = eBlk.numerFrame.origin.x;
            //                    e.view.inpOrg.y = eBlk.numerFrame.origin.y;
            //                    CGFloat tmp = eBlk.numerFrame.size.height;
            //                    e.view.cursor.frame = CGRectMake(eBlk.numerFrame.origin.x, eBlk.mainFrame.origin.y, CURSOR_W, tmp);
            //                } else if (e.curRoll == ROLL_DENOMINATOR) {
            //                    e.view.inpOrg.x = eBlk.denomFrame.origin.x;
            //                    e.view.inpOrg.y = eBlk.denomFrame.origin.y;
            //                    CGFloat tmp = eBlk.denomFrame.size.height;
            //                    e.view.cursor.frame = CGRectMake(eBlk.denomFrame.origin.x, eBlk.denomFrame.origin.y, CURSOR_W, tmp);
            //                } else
            //                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            //                e.curTxtLyr = nil;
            //                NSLog(@"%s%i~Tapped at blank. First input at Numer or Denom.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, eBlk.guid, (unsigned long)e.insertCIdx, e.curMode, e.curRoll, ((EquationBlock *)e.curBlk).guid);
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
    } else if ([b isMemberOfClass: [EquationTextLayer class]]) {
        EquationTextLayer *layer = b;
        
        if (layer.is_base_expo == IS_BASE) {
            e.curFont = e.baseFont;
        } else if (layer.is_base_expo == IS_EXPO) {
            e.curFont = e.superscriptFont;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        if (layer.type == TEXTLAYER_OP) {
            e.txtInsIdx = [layer getTxtInsIdx:curPoint];
            CGFloat offset = [[layer.strLenTbl objectAtIndex:e.txtInsIdx] doubleValue];
            CGFloat x = layer.frame.origin.x + offset;
            CGFloat y = layer.frame.origin.y;
            e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, layer.frame.size.height);
            e.view.inpOrg = CGPointMake(x, y);
            e.curTxtLyr = nil;
        } else if (layer.type == TEXTLAYER_NUM) {
            if (CGRectContainsPoint(layer.frame, curPoint)) {
                e.txtInsIdx = [layer getTxtInsIdx:curPoint];
                CGFloat offset = [[layer.strLenTbl objectAtIndex:e.txtInsIdx] doubleValue];
                CGFloat x = layer.frame.origin.x + offset;
                CGFloat y = layer.frame.origin.y;
                e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, layer.frame.size.height);
                e.view.inpOrg = CGPointMake(x, y);
                e.curTxtLyr = layer;
            } else {
                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                e.curTxtLyr = nil;
                e.txtInsIdx = (int)layer.strLenTbl.count - 1;
            }
        } else if (layer.type == TEXTLAYER_EMPTY) {
            if (CGRectContainsPoint(layer.frame, curPoint)) {
                CGFloat x = layer.frame.origin.x;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.frame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, tmp);
                e.curTxtLyr = layer;
                e.txtInsIdx = 0;
            } else {
                CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                CGFloat y = layer.frame.origin.y;
                e.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = layer.mainFrame.size.height;
                e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                e.curTxtLyr = nil;
                e.txtInsIdx = 0;
            }
        } else if (layer.type == TEXTLAYER_PARENTH) {
            e.txtInsIdx = [layer getTxtInsIdx:curPoint];
            CGFloat offset = [[layer.strLenTbl objectAtIndex:e.txtInsIdx] doubleValue];
            CGFloat x = layer.frame.origin.x + offset;
            CGFloat y = layer.frame.origin.y;
            e.view.cursor.frame = CGRectMake(x, y, CURSOR_W, layer.frame.size.height);
            e.view.inpOrg = CGPointMake(x, y);
            e.curTxtLyr = nil;
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        
        EquationBlock *block = layer.parent;
        id lastBlock = [block.children lastObject];
        if ([lastBlock isMemberOfClass: [EquationTextLayer class]] && layer == (EquationTextLayer *)lastBlock) {
            if (e.txtInsIdx == 0) {
                if (layer.type == TEXTLAYER_EMPTY) {
                    e.insertCIdx = layer.c_idx + 1;
                    e.curMode = MODE_INPUT;
                } else {
                    e.insertCIdx = layer.c_idx;
                    e.curMode = MODE_INSERT;
                }
            } else {
                e.insertCIdx = layer.c_idx + 1;
                e.curMode = MODE_INPUT;
            }
        } else {
            e.curMode = MODE_INSERT;
            if (e.txtInsIdx == 0) {
                if (layer.type == TEXTLAYER_EMPTY) {
                    e.insertCIdx = layer.c_idx + 1;
                } else {
                    e.insertCIdx = layer.c_idx;
                }
            } else {
                e.insertCIdx = layer.c_idx + 1;
            }
        }
        e.curRoll = layer.roll;
        e.curParent = block;
        e.curBlk = layer;
    } else if ([b isMemberOfClass: [RadicalBlock class]]) {
        RadicalBlock *block = b;
        
        if (block.is_base_expo == IS_BASE) {
            e.curFont = e.baseFont;
        } else if (block.is_base_expo == IS_EXPO) {
            e.curFont = e.superscriptFont;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        id lastBlock = [((EquationBlock *)block.parent).children lastObject];
        if ([lastBlock isMemberOfClass: [RadicalBlock class]] && block == (RadicalBlock *)lastBlock) {
            if (curPoint.x < block.frame.origin.x + block.frame.size.width / 2.0) {
                e.curMode = MODE_INSERT;
                e.insertCIdx = block.c_idx;
                CGFloat x = block.frame.origin.x;
                CGFloat y = block.frame.origin.y + block.frame.size.height / 2.0 - e.curFontH / 2.0;
                e.view.inpOrg = CGPointMake(x, y);
                e.view.cursor.frame = CGRectMake(block.frame.origin.x, block.frame.origin.y, CURSOR_W, block.frame.size.height);
            } else {
                e.curMode = MODE_INPUT;
                e.insertCIdx = block.c_idx + 1;
                CGFloat x = block.frame.origin.x + block.frame.size.width;
                CGFloat y = block.frame.origin.y + block.frame.size.height / 2.0 - e.curFontH / 2.0;
                e.view.inpOrg = CGPointMake(x, y);
                e.view.cursor.frame = CGRectMake(block.frame.origin.x + block.frame.size.width, block.frame.origin.y, CURSOR_W, block.frame.size.height);
            }
        } else {
            if (curPoint.x < block.frame.origin.x + block.frame.size.width / 2.0) {
                e.curMode = MODE_INSERT;
                e.insertCIdx = block.c_idx;
                CGFloat x = block.frame.origin.x;
                CGFloat y = block.frame.origin.y + block.frame.size.height / 2.0 - e.curFontH / 2.0;
                e.view.inpOrg = CGPointMake(x, y);
                e.view.cursor.frame = CGRectMake(block.frame.origin.x, block.frame.origin.y, CURSOR_W, block.frame.size.height);
            } else {
                e.curMode = MODE_INSERT;
                e.insertCIdx = block.c_idx + 1;
                CGFloat x = block.frame.origin.x + block.frame.size.width;
                CGFloat y = block.frame.origin.y + block.frame.size.height / 2.0 - e.curFontH / 2.0;
                e.view.inpOrg = CGPointMake(x, y);
                e.view.cursor.frame = CGRectMake(block.frame.origin.x + block.frame.size.width, block.frame.origin.y, CURSOR_W, block.frame.size.height);
            }
        }
        e.curParent = block.parent;
        e.curRoll = block.roll;
        e.curTxtLyr = nil;
        e.curBlk = block;
    } else if ([b isMemberOfClass: [FractionBarLayer class]]) {
        FractionBarLayer *bar = b;
        EquationBlock *block = bar.parent;
        
        if (bar.is_base_expo == IS_BASE) {
            e.curFont = e.baseFont;
        } else if (bar.is_base_expo == IS_EXPO) {
            e.curFont = e.superscriptFont;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        e.curTxtLyr = nil;
        e.curBlk = block;
        if (block.roll == ROLL_ROOT) {//Root block is a fraction. Need to dump all elements in the root block into new block
            if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                e.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0);
                e.insertCIdx = 0;
            } else {
                e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                e.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0);
                e.insertCIdx = 1;
            }
            
            e.curMode = MODE_DUMP_ROOT;
            e.curRoll = ROLL_NUMERATOR;
            
        } else if(block.roll == ROLL_ROOT_ROOT) {
            if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                e.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0);
                e.insertCIdx = 0;
            } else {
                e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                e.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0);
                e.insertCIdx = 1;
            }
            
            e.curMode = MODE_DUMP_RADICAL;
            e.curRoll = ROLL_NUMERATOR;
            e.curParent = block.parent;
            
        } else if(block.roll == ROLL_EXPO_ROOT) {
            if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                e.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0);
                e.insertCIdx = 0;
            } else {
                e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                e.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0);
                e.insertCIdx = 1;
            }
            
            e.curMode = MODE_DUMP_EXPO;
            e.curRoll = ROLL_NUMERATOR;
            e.curParent = block.parent;
            
        } else {
            id lastBlock = [((EquationBlock *)block.parent).children lastObject];
            if ([lastBlock isMemberOfClass: [EquationBlock class]] && block == (EquationBlock *)lastBlock) {
                if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                    e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    e.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0);
                    e.curMode = MODE_INSERT;
                    e.insertCIdx = block.c_idx;
                } else {
                    e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    e.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0);
                    e.insertCIdx = block.c_idx + 1;
                    e.curMode = MODE_INPUT;
                }
            } else {
                if (curPoint.x < block.mainFrame.origin.x + block.mainFrame.size.width / 2.0) {
                    e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    e.view.inpOrg = CGPointMake(block.bar.frame.origin.x, block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0);
                    e.curMode = MODE_INSERT;
                    e.insertCIdx = block.c_idx;
                } else {
                    e.view.cursor.frame = CGRectMake(block.mainFrame.origin.x + block.mainFrame.size.width, block.mainFrame.origin.y, CURSOR_W, block.mainFrame.size.height);
                    e.view.inpOrg = CGPointMake(block.bar.frame.origin.x + block.bar.frame.size.width, block.numerFrame.origin.y + block.numerFrame.size.height - e.curFontH / 2.0);
                    e.curMode = MODE_INSERT;
                    e.insertCIdx = block.c_idx + 1;
                }
            }
            e.curParent = block.parent;
            e.curRoll = block.roll;
            
        }
    } else
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
}

NSMutableString *equationToString(EquationBlock *parent) {
    NSMutableString *ret = [NSMutableString stringWithCapacity:256];
    
    for (id b in parent.children) {
        if ([b isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eb = b;
            
            if (eb.c_idx == 0) {
                [ret appendString:@"("];
            }
            
            [ret appendString:@"("];
            [ret appendString:equationToString(b)];
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
                [ret appendString:l.value];
                [ret appendString:@","];
                [ret appendString:equationToString(l.expo)];
                [ret appendString:@")"];
            } else {
                [ret appendString:l.value];
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
                [ret appendString:equationToString(rb.content)];
                [ret appendString:@")"];
            } else {
                [ret appendString:@"sqrt("];
                [ret appendString:equationToString(rb.content)];
                [ret appendString:@")"];
            }
            
            if (rb.c_idx == parent.children.count - 1) {
                [ret appendString:@")"];
            }
        } else if ([b isMemberOfClass: [FractionBarLayer class]]) {
            [ret appendString:@")/("];
        }
    }
    
    return ret;
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