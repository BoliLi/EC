//
//  EquationBlock.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import "Global.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"
#import "WrapedEqTxtLyr.h"
#import "Parentheses.h"
#import "CalcBoard.h"

@implementation EquationBlock
@synthesize children;
@synthesize mainFrame;
@synthesize numerFrame;
@synthesize denomFrame;
@synthesize bar;
@synthesize parent;
@synthesize ancestor;
@synthesize guid;
@synthesize c_idx;
@synthesize roll;
@synthesize numerTopHalf;
@synthesize numerBtmHalf;
@synthesize denomTopHalf;
@synthesize denomBtmHalf;
@synthesize is_base_expo;
@synthesize fontLvl;
@synthesize isCopy;

-(id) init : (Equation *)e {
    self = [super init];
    if (self) {
        CalcBoard *calcB = e.par;
        
        self.ancestor = e;
        self.children = [NSMutableArray array];
        self.guid = e.guid_cnt++;
        self.roll = calcB.curRoll;
        self.is_base_expo = calcB.base_or_expo;
        self.fontLvl = calcB.curFontLvl;
        self.isCopy = NO;
    }
    return self;
}

-(id) init : (CGPoint)inputPos : (Equation *)e {
    self = [super init];
    if (self) {
        CalcBoard *calcB = e.par;
    
        self.ancestor = e;
        self.children = [NSMutableArray array];
        self.guid = e.guid_cnt++;
        self.roll = calcB.curRoll;
        
        self.numerFrame = CGRectMake(inputPos.x, inputPos.y, calcB.curFontW, calcB.curFontH);
        self.mainFrame = self.numerFrame;
        self.numerTopHalf = calcB.curFontH / 2.0;
        self.numerBtmHalf = calcB.curFontH / 2.0;
        self.is_base_expo = calcB.base_or_expo;
        self.fontLvl = calcB.curFontLvl;
        self.isCopy = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.children = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"children"]];
        self.mainFrame = [coder decodeCGRectForKey:@"mainFrame"];
        self.numerFrame = [coder decodeCGRectForKey:@"numerFrame"];
        self.denomFrame = [coder decodeCGRectForKey:@"denomFrame"];
        self.bar = [coder decodeObjectForKey:@"bar"];
        self.guid = [coder decodeIntForKey:@"guid"];
        self.roll = [coder decodeIntForKey:@"roll"];
        self.numerTopHalf = [coder decodeDoubleForKey:@"numerTopHalf"];
        self.numerBtmHalf = [coder decodeDoubleForKey:@"numerBtmHalf"];
        self.denomTopHalf = [coder decodeDoubleForKey:@"denomTopHalf"];
        self.denomBtmHalf = [coder decodeDoubleForKey:@"denomBtmHalf"];
        self.is_base_expo = [coder decodeIntForKey:@"is_base_expo"];
        self.fontLvl = [coder decodeIntForKey:@"fontLvl"];
        self.isCopy = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[NSArray arrayWithArray:self.children] forKey:@"children"];
    [coder encodeCGRect:self.mainFrame forKey:@"mainFrame"];
    [coder encodeCGRect:self.numerFrame forKey:@"numerFrame"];
    [coder encodeCGRect:self.denomFrame forKey:@"denomFrame"];
    if (self.bar != nil) {
        [coder encodeObject:self.bar forKey:@"bar"];
    }
    [coder encodeInt:self.guid forKey:@"guid"];
    [coder encodeInt:self.roll forKey:@"roll"];
    [coder encodeDouble:self.numerTopHalf forKey:@"numerTopHalf"];
    [coder encodeDouble:self.numerBtmHalf forKey:@"numerBtmHalf"];
    [coder encodeDouble:self.denomTopHalf forKey:@"denomTopHalf"];
    [coder encodeDouble:self.denomBtmHalf forKey:@"denomBtmHalf"];
    [coder encodeInt:self.is_base_expo forKey:@"is_base_expo"];
    [coder encodeInt:self.fontLvl forKey:@"fontLvl"];
}

- (void)copyChildrenTo:(EquationBlock *)newEB {
    NSMutableArray *copyArr = [NSMutableArray array];
    
    for (id blk in self.children) {
        id cpy = [blk copy];
        [copyArr addObject:cpy];
        if ([blk isMemberOfClass:[FractionBarLayer class]]) {
            newEB.bar = cpy;
        }
    }
    newEB.children = copyArr;
    NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, copyArr);
}

- (id)copyWithZone:(NSZone *)zone {
    EquationBlock *copy = [[[self class] allocWithZone :zone] init];
    [self copyChildrenTo:copy];
    copy.mainFrame = self.mainFrame;
    copy.numerFrame = self.numerFrame;
    copy.denomFrame = self.denomFrame;
    copy.c_idx = self.c_idx;
    copy.roll = self.roll;
    copy.numerTopHalf = self.numerTopHalf;
    copy.numerBtmHalf = self.numerBtmHalf;
    copy.denomTopHalf = self.denomTopHalf;
    copy.denomBtmHalf = self.denomBtmHalf;
    copy.is_base_expo = self.is_base_expo;
    copy.fontLvl = self.fontLvl;
    copy.isCopy = YES;
    return copy;
}

-(void) reorganize : (Equation *)anc : (ViewController *)vc {
    if (self.roll == ROLL_ROOT) {
        self.parent = nil;
    }
    
    CalcBoard *calcB = anc.par;
    
    NSUInteger cidx = 0;
    for (id b in self.children) {
        if ([b isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *eb = b;
            NSLog(@"%s%i>~%p~~~~~~~~~~", __FUNCTION__, __LINE__, eb.bar);
            eb.c_idx = cidx++;
            eb.parent = self;
            eb.ancestor = anc;
            [eb reorganize:anc :vc];
        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = b;
            l.c_idx = cidx++;
            l.parent = self;
            l.ancestor = anc;
            [calcB.view.layer addSublayer:l];
            if (l.expo != nil) {
                [l.expo reorganize:anc :vc];
            }
        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock *rb = b;
            rb.c_idx = cidx++;
            rb.parent = self;
            rb.ancestor = anc;
            rb.delegate = vc;
            [calcB.view.layer addSublayer: rb];
            [rb setNeedsDisplay];
            
            if (rb.rootNum != nil) {
                [calcB.view.layer addSublayer: rb.rootNum];
            }
            
            [rb.content reorganize:anc :vc];
        } else if ([b isMemberOfClass:[FractionBarLayer class]]) {
            FractionBarLayer *fb = b;
            NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, fb);
            fb.c_idx = cidx++;
            fb.parent = self;
            fb.ancestor = anc;
            fb.delegate = vc;
            [calcB.view.layer addSublayer: fb];
            [fb setNeedsDisplay];
        } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = b;
            wetl.c_idx = cidx++;
            wetl.parent = self;
            wetl.ancestor = anc;
            [calcB.view.layer addSublayer: wetl.title];
            [calcB.view.layer addSublayer: wetl.left_parenth];
            wetl.left_parenth.delegate = vc;
            [wetl.left_parenth setNeedsDisplay];
            [calcB.view.layer addSublayer: wetl.right_parenth];
            wetl.left_parenth.delegate = vc;
            [wetl.right_parenth setNeedsDisplay];
            
            [wetl.content reorganize:anc :vc];
        } else if ([b isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = b;
            p.c_idx = cidx++;
            p.parent = self;
            p.ancestor = anc;
            p.delegate = vc;
            [calcB.view.layer addSublayer: p];
            [p setNeedsDisplay];
            if (p.expo != nil) {
                [p.expo reorganize:anc :vc];
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
}

- (void)updateCopyBlock:(Equation *)e {
    ancestor = e;
    guid = e.guid_cnt++;
    
    for (id b in self.children) {
        if ([b isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock *rb = b;
            
            rb.parent = self;
            [rb updateCopyBlock:e];
        } else if ([b isMemberOfClass:[FractionBarLayer class]]) {
            FractionBarLayer *fb = b;
            
            bar = fb;
            fb.parent = self;
            [fb updateCopyBlock:e];
        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *etl = b;
            
            etl.parent = self;
            [etl updateCopyBlock:e];
        } else if ([b isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *eb = b;
            
            eb.parent = self;
            [eb updateCopyBlock:e];
        } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = b;
            
            wetl.parent = self;
            [wetl updateCopyBlock:e];
        } else if ([b isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = b;
            
            p.parent = self;
            [p updateCopyBlock:e];
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
}

-(void) updateFrame : (CGRect)frame : (int)r {
    
    if (r == ROLL_NUMERATOR) {
        self.numerFrame = CGRectUnion(frame, self.numerFrame);
        if (self.bar == nil) {
            self.mainFrame = self.numerFrame;\
            
            // numer:   ********
            // bar  :   ----------
            // denom:       ******
            if (self.numerFrame.origin.x <= self.denomFrame.origin.x) {
                frame = self.denomFrame;
                frame.origin.x = self.numerFrame.origin.x;
                self.mainFrame = CGRectUnion(self.numerFrame, frame);
            } else {
                frame = self.numerFrame;
                frame.origin.x = self.denomFrame.origin.x;
                self.mainFrame = CGRectUnion(self.denomFrame, frame);
            }
        }
    } else if (r == ROLL_DENOMINATOR) {
        CGFloat orgY = self.denomFrame.origin.y;
        self.denomFrame = CGRectUnion(frame, self.denomFrame);
        CGFloat offsetY = self.denomFrame.origin.y - orgY;
        self.numerFrame = CGRectOffset(self.numerFrame, 0, offsetY);
        //Fix for the following case
        // numer:   ********
        // bar  :   ----------
        // denom:       ******
        if (self.numerFrame.origin.x <= self.denomFrame.origin.x) {
            frame = self.denomFrame;
            frame.origin.x = self.numerFrame.origin.x;
            self.mainFrame = CGRectUnion(self.numerFrame, frame);
        } else {
            frame = self.numerFrame;
            frame.origin.x = self.denomFrame.origin.x;
            self.mainFrame = CGRectUnion(self.denomFrame, frame);
        }
    } else
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
}

-(void) updateFrameWidth : (CGFloat)incrWidth : (int)r {
    CGFloat orgWidth = self.mainFrame.size.width;
    if (r == ROLL_NUMERATOR) {
        CGRect frame = self.numerFrame;
        frame.size.width += incrWidth;
        self.numerFrame = frame;
        if (self.bar == nil) {
            self.mainFrame = self.numerFrame;
        } else {
            //Fix for the following case
            // numer:   ********
            // bar  :   ----------
            // denom:       ******
            if (self.numerFrame.origin.x <= self.denomFrame.origin.x) {
                frame = self.denomFrame;
                frame.origin.x = self.numerFrame.origin.x;
                self.mainFrame = CGRectUnion(self.numerFrame, frame);
            } else {
                frame = self.numerFrame;
                frame.origin.x = self.denomFrame.origin.x;
                self.mainFrame = CGRectUnion(self.denomFrame, frame);
            }
        }
        
    } else if (r == ROLL_DENOMINATOR) {
        if (self.bar == nil) {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
        CGRect frame = self.denomFrame;
        frame.size.width += incrWidth;
        self.denomFrame = frame;
        //Fix for the following case
        // numer:   ********
        // bar  :   ----------
        // denom:       ******
        if (self.numerFrame.origin.x <= self.denomFrame.origin.x) {
            frame = self.denomFrame;
            frame.origin.x = self.numerFrame.origin.x;
            self.mainFrame = CGRectUnion(self.numerFrame, frame);
        } else {
            frame = self.numerFrame;
            frame.origin.x = self.denomFrame.origin.x;
            self.mainFrame = CGRectUnion(self.denomFrame, frame);
        }
    } else
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    
    if ((int)orgWidth != (int)self.mainFrame.size.width) {
        id block = self.parent;
        if (block != nil) {
            if([block isMemberOfClass:[EquationBlock class]]) {
                [block updateFrameWidth:self.mainFrame.size.width - orgWidth :self.roll];
            } else if([block isMemberOfClass:[RadicalBlock class]]) {
                RadicalBlock *rBlock = block;
                CGFloat orgWidth1 = rBlock.frame.size.width;
                [rBlock updateFrame];
                [rBlock setNeedsDisplay];
                if ((int)orgWidth1 != (int)rBlock.frame.size.width) {
                    [rBlock.parent updateFrameWidth:rBlock.frame.size.width - orgWidth1 :rBlock.roll];
                }
            } else if([block isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *layer = block;
                CGFloat orgWidth1 = layer.mainFrame.size.width;
                layer.mainFrame = CGRectUnion(layer.frame, self.mainFrame);
                if ((int)orgWidth1 != (int)layer.mainFrame.size.width) {
                    [layer.parent updateFrameWidth:layer.mainFrame.size.width - orgWidth1 :layer.roll];
                }
            } else if([block isMemberOfClass:[WrapedEqTxtLyr class]]) {
                WrapedEqTxtLyr *wetl = block;
                CGFloat orgWidth1 = wetl.mainFrame.size.width;
                CGFloat newMW = wetl.title.frame.size.width + wetl.left_parenth.frame.size.width + wetl.content.mainFrame.size.width + wetl.right_parenth.frame.size.width;
                wetl.mainFrame = CGRectMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y, newMW, wetl.mainFrame.size.height);
                if ((int)orgWidth1 != (int)wetl.mainFrame.size.width) {
                    [wetl.parent updateFrameWidth:wetl.mainFrame.size.width - orgWidth1 :wetl.roll];
                }
            } else if([block isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = block;
                CGFloat orgWidth1 = p.mainFrame.size.width;
                p.mainFrame = CGRectUnion(p.frame, self.mainFrame);
                if ((int)orgWidth1 != (int)p.mainFrame.size.width) {
                    [p.parent updateFrameWidth:p.mainFrame.size.width - orgWidth1 :p.roll];
                }
            } else
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
}

-(void) updateFrameHeightS2 : (CGFloat)newH : (int)r {
    if (r == ROLL_NUMERATOR) {
        CGRect frame = self.numerFrame;
        CGFloat orgHeight = frame.size.height;
        frame.origin.y -= newH - orgHeight;
        frame.size.height = newH;
        self.numerFrame = frame;
        if (self.bar == nil) {
            self.mainFrame = self.numerFrame;
        } else {
            //Fix for the following case
            // numer:   ********
            // bar  :   ----------
            // denom:       ******
            if (self.numerFrame.origin.x <= self.denomFrame.origin.x) {
                frame = self.denomFrame;
                frame.origin.x = self.numerFrame.origin.x;
                self.mainFrame = CGRectUnion(self.numerFrame, frame);
            } else {
                frame = self.numerFrame;
                frame.origin.x = self.denomFrame.origin.x;
                self.mainFrame = CGRectUnion(self.denomFrame, frame);
            }
        }
    } else if (r == ROLL_DENOMINATOR) {
        if (self.bar == nil) {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
        CGRect frame = self.denomFrame;
        // Both numerator and denominator need update
        CGFloat orgHeight = frame.size.height;
        frame.origin.y -= newH - orgHeight;
        frame.size.height = newH;
        self.denomFrame = frame;
        self.numerFrame = CGRectOffset(self.numerFrame, 0, orgHeight - newH);
        //Fix for the following case
        // numer:   ********
        // bar  :   ----------
        // denom:       ******
        if (self.numerFrame.origin.x <= self.denomFrame.origin.x) {
            frame = self.denomFrame;
            frame.origin.x = self.numerFrame.origin.x;
            self.mainFrame = CGRectUnion(self.numerFrame, frame);
        } else {
            frame = self.numerFrame;
            frame.origin.x = self.denomFrame.origin.x;
            self.mainFrame = CGRectUnion(self.denomFrame, frame);
        }
    } else
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
}

-(BOOL) updateNumerTB {
    CGFloat orgTop = self.numerTopHalf;
    CGFloat orgBtm = self.numerBtmHalf;
    self.numerTopHalf = self.numerBtmHalf = 0.0;
    CGFloat hstack[32];
    CGFloat maxh = 0.0;
    NSMutableArray *pstack = [NSMutableArray array];
    int idx = 0;
    for (id b in self.children) {
        if([b isMemberOfClass:[EquationBlock class]]) {
            EquationBlock * eb = b;
            CGFloat newH = eb.mainFrame.size.height;
            if (maxh < newH && idx > 0) {
                maxh = newH;
            }
            
            if ((int)self.numerTopHalf < (int)(newH / 2.0))
                self.numerTopHalf = newH / 2.0;
            
            if ((int)self.numerBtmHalf < (int)(newH / 2.0))
                self.numerBtmHalf = newH / 2.0;
        } else if([b isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock * rb = b;
            CGFloat newH = rb.frame.size.height;
            if (maxh < newH && idx > 0) {
                maxh = newH;
            }
            
            if ((int)self.numerTopHalf < (int)(newH / 2.0))
                self.numerTopHalf = newH / 2.0;
            
            if ((int)self.numerBtmHalf < (int)(newH / 2.0))
                self.numerBtmHalf = newH / 2.0;
        } else if([b isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *layer = b;
            CGFloat top = layer.mainFrame.size.height - layer.frame.size.height / 2.0;
            CGFloat btm = layer.mainFrame.size.height - top;
            
            if (maxh < layer.mainFrame.size.height && idx > 0) {
                maxh = layer.mainFrame.size.height;
            }
            
            if ((int)self.numerTopHalf < (int)top)
                self.numerTopHalf = top;
            
            if ((int)self.numerBtmHalf < (int)btm)
                self.numerBtmHalf = btm;
        } else if([b isMemberOfClass:[FractionBarLayer class]]) {
            break;
        } else if([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = b;
            CGFloat newH = wetl.mainFrame.size.height;
            if (maxh < newH && idx > 0) {
                maxh = newH;
            }
            
            if ((int)self.numerTopHalf < (int)(newH / 2.0))
                self.numerTopHalf = newH / 2.0;
            
            if ((int)self.numerBtmHalf < (int)(newH / 2.0))
                self.numerBtmHalf = newH / 2.0;
        } else if([b isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = b;
            
            if (p.l_or_r == LEFT_PARENTH) {
                [pstack insertObject:p atIndex:idx];
                hstack[idx++] = maxh;
                maxh = 0.0;
            } else {
                if (idx > 0) {
                    Parentheses *lp = [pstack objectAtIndex:idx - 1];
                    CGFloat inc = 0.0;
                    if ((int)lp.frame.size.height != (int)maxh && (int)maxh >= (int)gCharHeightTbl[lp.fontLvl]) {
                        CGFloat orgW = lp.frame.size.width;
                        lp.frame = CGRectMake(lp.frame.origin.x, lp.frame.origin.y, maxh / PARENTH_HW_R, maxh);
                        [lp setNeedsDisplay];
                        [lp updateFrameBaseOnBase];
                        inc += (lp.frame.size.width - orgW);
                    }
                    
                    if ((int)p.frame.size.height != (int)maxh && (int)maxh >= (int)gCharHeightTbl[p.fontLvl]) {
                        CGFloat orgW = p.frame.size.width;
                        p.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, maxh / PARENTH_HW_R, maxh);
                        [p setNeedsDisplay];
                        [p updateFrameBaseOnBase];
                        inc += (p.frame.size.width - orgW);
                        
                    }
                    
                    if ((int)inc != 0) {
                        [self updateFrameWidth:inc :p.roll];
                    }
                    
                    if (hstack[--idx] > maxh) {
                        maxh = hstack[idx];
                    }
                }
                
                CGFloat top = p.mainFrame.size.height - p.frame.size.height / 2.0;
                CGFloat btm = p.mainFrame.size.height - top;
                if ((int)self.numerTopHalf < (int)top)
                    self.numerTopHalf = top;
                
                if ((int)self.numerBtmHalf < (int)btm)
                    self.numerBtmHalf = btm;
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
    
    while (idx > 0) {    // Handle unpaired parenth
        Parentheses *lp = [pstack objectAtIndex:idx - 1];
        if ((int)lp.frame.size.height != (int)maxh && (int)maxh >= (int)gCharHeightTbl[lp.fontLvl]) {
            CGFloat orgW = lp.frame.size.width;
            lp.frame = CGRectMake(lp.frame.origin.x, lp.frame.origin.y, maxh / PARENTH_HW_R, maxh);
            [lp setNeedsDisplay];
            [lp updateFrameBaseOnBase];
            [self updateFrameWidth:lp.frame.size.width - orgW :lp.roll];
        }
        
        if (hstack[--idx] > maxh) {
            maxh = hstack[idx];
        }
        
        CGFloat top = lp.mainFrame.size.height - lp.frame.size.height / 2.0;
        CGFloat btm = lp.mainFrame.size.height - top;
        if ((int)self.numerTopHalf < (int)top)
            self.numerTopHalf = top;
        
        if ((int)self.numerBtmHalf < (int)btm)
            self.numerBtmHalf = btm;
    }
    
    [pstack removeAllObjects];
    
    return ((int)orgTop != (int)self.numerTopHalf) || ((int)orgBtm != (int)self.numerBtmHalf);
}

-(BOOL) updateDenomTB {
    CGFloat orgTop = self.denomTopHalf;
    CGFloat orgBtm = self.denomBtmHalf;
    self.denomTopHalf = self.denomBtmHalf = 0.0;
    CGFloat hstack[32];
    CGFloat maxh = 0.0;
    NSMutableArray *pstack = [NSMutableArray array];
    int idx = 0;
    for (int i = (int)self.children.count - 1; i > 0; i--) {
        id b = [self.children objectAtIndex:i];
        if([b isMemberOfClass:[EquationBlock class]]) {
            EquationBlock * eb = b;
            CGFloat newH = eb.mainFrame.size.height;
            
            if (maxh < newH && idx > 0) {
                maxh = newH;
            }
            
            if ((int)self.denomTopHalf < (int)(newH / 2.0))
                self.denomTopHalf = newH / 2.0;
            
            if ((int)self.denomBtmHalf < (int)(newH / 2.0))
                self.denomBtmHalf = newH / 2.0;
        } else if([b isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock * rb = b;
            CGFloat newH = rb.frame.size.height;
            
            if (maxh < newH && idx > 0) {
                maxh = newH;
            }
            
            if ((int)self.denomTopHalf < (int)(newH / 2.0))
                self.denomTopHalf = newH / 2.0;
            
            if ((int)self.denomBtmHalf < (int)(newH / 2.0))
                self.denomBtmHalf = newH / 2.0;
        } else if([b isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *layer = b;
            CGFloat top = layer.mainFrame.size.height - layer.frame.size.height / 2.0;
            CGFloat btm = layer.mainFrame.size.height - top;
            
            if (maxh < layer.mainFrame.size.height && idx > 0) {
                maxh = layer.mainFrame.size.height;
            }
            
            if ((int)self.denomTopHalf < (int)top)
                self.denomTopHalf = top;
            
            if ((int)self.denomBtmHalf < (int)btm)
                self.denomBtmHalf = btm;
        } else if([b isMemberOfClass:[FractionBarLayer class]]) {
            break;
        } else if([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = b;
            CGFloat newH = wetl.mainFrame.size.height;
            
            if (maxh < newH && idx > 0) {
                maxh = newH;
            }
            
            if ((int)self.denomTopHalf < (int)(newH / 2.0))
                self.denomTopHalf = newH / 2.0;
            
            if ((int)self.denomBtmHalf < (int)(newH / 2.0))
                self.denomBtmHalf = newH / 2.0;
        } else if([b isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = b;
            
            if (p.l_or_r == RIGHT_PARENTH) {
                [pstack insertObject:p atIndex:idx];
                hstack[idx++] = maxh;
                maxh = 0.0;
            } else {
                if (idx > 0) {
                    Parentheses *rp = [pstack objectAtIndex:idx - 1];
                    CGFloat inc = 0.0;
                    if ((int)rp.frame.size.height != (int)maxh && (int)maxh >= (int)gCharHeightTbl[rp.fontLvl]) {
                        CGFloat orgW = rp.frame.size.width;
                        rp.frame = CGRectMake(rp.frame.origin.x, rp.frame.origin.y, maxh / PARENTH_HW_R, maxh);
                        [rp setNeedsDisplay];
                        [rp updateFrameBaseOnBase];
                        inc += (rp.frame.size.width - orgW);
                    }
                    
                    if ((int)p.frame.size.height != (int)maxh && (int)maxh >= (int)gCharHeightTbl[p.fontLvl]) {
                        CGFloat orgW = p.frame.size.width;
                        p.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, maxh / PARENTH_HW_R, maxh);
                        [p setNeedsDisplay];
                        [p updateFrameBaseOnBase];
                        inc += (p.frame.size.width - orgW);
                        
                    }
                    
                    if ((int)inc != 0) {
                        [self updateFrameWidth:inc :p.roll];
                    }
                    
                    if (hstack[--idx] > maxh) {
                        maxh = hstack[idx];
                    }
                    
                    CGFloat top = rp.mainFrame.size.height - rp.frame.size.height / 2.0;
                    CGFloat btm = rp.mainFrame.size.height - top;
                    if ((int)self.denomTopHalf < (int)top)
                        self.denomTopHalf = top;
                    
                    if ((int)self.denomBtmHalf < (int)btm)
                        self.denomBtmHalf = btm;
                } else {
                    CGFloat top = p.mainFrame.size.height - p.frame.size.height / 2.0;
                    CGFloat btm = p.mainFrame.size.height - top;
                    if ((int)self.denomTopHalf < (int)top)
                        self.denomTopHalf = top;
                    
                    if ((int)self.denomBtmHalf < (int)btm)
                        self.denomBtmHalf = btm;
                }
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
    
    while (idx > 0) {    // Handle unpaired parenth
        Parentheses *rp = [pstack objectAtIndex:idx - 1];
        if ((int)rp.frame.size.height != (int)maxh && (int)maxh >= (int)gCharHeightTbl[rp.fontLvl]) {
            CGFloat orgW = rp.frame.size.width;
            rp.frame = CGRectMake(rp.frame.origin.x, rp.frame.origin.y, maxh / PARENTH_HW_R, maxh);
            [rp setNeedsDisplay];
            [rp updateFrameBaseOnBase];
            [self updateFrameWidth:rp.frame.size.width - orgW :rp.roll];
        }
        
        if (hstack[--idx] > maxh) {
            maxh = hstack[idx];
        }
        
        CGFloat top = rp.mainFrame.size.height - rp.frame.size.height / 2.0;
        CGFloat btm = rp.mainFrame.size.height - top;
        if ((int)self.denomTopHalf < (int)top)
            self.denomTopHalf = top;
        
        if ((int)self.denomBtmHalf < (int)btm)
            self.denomBtmHalf = btm;
    }
    
    [pstack removeAllObjects];
    
    return ((int)orgTop != (int)self.denomTopHalf) || ((int)orgBtm != (int)self.denomBtmHalf);
}

-(void) updateFrameHeightS1 : (id)child {
    if([child isMemberOfClass:[EquationBlock class]]) {
        EquationBlock *eBlock = child;
        int r = eBlock.roll;
        if (r == ROLL_NUMERATOR) {
            if ([self updateNumerTB]) {
                [self updateFrameHeightS2:self.numerTopHalf + self.numerBtmHalf :r];
            }
            
        } else if (r == ROLL_DENOMINATOR) {
            if ([self updateDenomTB]) {
                [self updateFrameHeightS2:self.denomTopHalf + self.denomBtmHalf :r];
            }
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else if([child isMemberOfClass:[RadicalBlock class]]) {
        RadicalBlock *rBlock = child;
        int r = rBlock.roll;
        if (r == ROLL_NUMERATOR) {
            if ([self updateNumerTB]) {
                [self updateFrameHeightS2:self.numerTopHalf + self.numerBtmHalf :r];
            }
        } else if (r == ROLL_DENOMINATOR) {
            if ([self updateDenomTB]) {
                [self updateFrameHeightS2:self.denomTopHalf + self.denomBtmHalf :r];
            }
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else if([child isMemberOfClass:[EquationTextLayer class]]) {
        EquationTextLayer *layer = child;
        int r = layer.roll;
        if (r == ROLL_NUMERATOR) {
            if ([self updateNumerTB]) {
                [self updateFrameHeightS2:self.numerTopHalf + self.numerBtmHalf :r];
            }
        } else if (r == ROLL_DENOMINATOR) {
            if ([self updateDenomTB]) {
                [self updateFrameHeightS2:self.denomTopHalf + self.denomBtmHalf :r];
            }
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else if([child isMemberOfClass:[WrapedEqTxtLyr class]]) {
        WrapedEqTxtLyr *wetl = child;
        int r = wetl.roll;
        if (r == ROLL_NUMERATOR) {
            if ([self updateNumerTB]) {
                [self updateFrameHeightS2:self.numerTopHalf + self.numerBtmHalf :r];
            }
        } else if (r == ROLL_DENOMINATOR) {
            if ([self updateDenomTB]) {
                [self updateFrameHeightS2:self.denomTopHalf + self.denomBtmHalf :r];
            }
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else if([child isMemberOfClass:[Parentheses class]]) {
        Parentheses *p = child;
        int r = p.roll;
        if (r == ROLL_NUMERATOR) {
            if ([self updateNumerTB]) {
                [self updateFrameHeightS2:self.numerTopHalf + self.numerBtmHalf :r];
            }
        } else if (r == ROLL_DENOMINATOR) {
            if ([self updateDenomTB]) {
                [self updateFrameHeightS2:self.denomTopHalf + self.denomBtmHalf :r];
            }
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    
    if (self.parent != nil) {
        if([self.parent isMemberOfClass:[EquationBlock class]]) {
            [(EquationBlock *)self.parent updateFrameHeightS1:self];
        } else if([self.parent isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock *rBlock = self.parent;
            CGFloat orgW = rBlock.frame.size.width;
            [rBlock updateFrame];
            [rBlock setNeedsDisplay];
            if ([rBlock.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)rBlock.parent updateFrameHeightS1:rBlock];
                [(EquationBlock *)rBlock.parent updateFrameWidth:rBlock.frame.size.width - orgW :rBlock.roll];
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else if([self.parent isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *layer = self.parent;
            [layer updateFrameBaseOnExpo];
            if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else if([self.parent isMemberOfClass:[WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = self.parent;
            
            CGFloat orgW = wetl.mainFrame.size.width;
            
            [wetl updateFrame:YES];
            
            if ([wetl.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)wetl.parent updateFrameHeightS1:wetl];
                [(EquationBlock *)wetl.parent updateFrameWidth:wetl.mainFrame.size.width - orgW :wetl.roll];
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else if([self.parent isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = self.parent;
            [p updateFrameBaseOnExpo];
            if ([p.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)p.parent updateFrameHeightS1:p];
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
}

-(void) updateCIdx {
    NSInteger cnt = 0;
    for (id block in self.children) {
        if ([block isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = block;
            layer.c_idx = cnt++;
        } else if ([block isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *br = block;
            br.c_idx = cnt++;
        } else if ([block isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *b = block;
            b.c_idx = cnt++;
        } else if ([block isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *b = block;
            b.c_idx = cnt++;
        } else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *b = block;
            b.c_idx = cnt++;
        } else if ([block isMemberOfClass: [Parentheses class]]) {
            Parentheses *b = block;
            b.c_idx = cnt++;
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}

-(void) moveUp : (CGFloat)distance {
    
    self.mainFrame = CGRectOffset(self.mainFrame, 0.0, -distance);
    self.numerFrame = CGRectOffset(self.numerFrame, 0.0, -distance);
    self.denomFrame = CGRectOffset(self.denomFrame, 0.0, -distance);
    
    for (id block in self.children) {
        if ([block isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *l = block;
            
            l.frame = CGRectOffset(l.frame, 0.0, -distance);
            
            if (l.expo != nil) {
                [l.expo moveUp:distance];
                l.mainFrame = CGRectUnion(l.frame, l.expo.mainFrame);
            } else {
                l.mainFrame = l.frame;
            }
        } else if ([block isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *fb = block;
            fb.frame = CGRectOffset(fb.frame, 0.0, -distance);
        } else if ([block isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eb = block;
            [eb moveUp:distance];
        } else if ([block isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rb = block;
            rb.frame = CGRectOffset(rb.frame, 0.0, -distance);
            [rb.content moveUp:distance];
            
            if (rb.rootNum != nil) {
                rb.rootNum.frame = CGRectOffset(rb.rootNum.frame, 0.0, -distance);
            }
        } else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = block;
            wetl.title.frame = CGRectOffset(wetl.title.frame, 0.0, -distance);
            wetl.left_parenth.frame = CGRectOffset(wetl.left_parenth.frame, 0.0, -distance);
            [wetl.content moveUp:distance];
            wetl.right_parenth.frame = CGRectOffset(wetl.right_parenth.frame, 0.0, -distance);
            wetl.mainFrame = CGRectOffset(wetl.mainFrame, 0.0, -distance);
        } else if ([block isMemberOfClass: [Parentheses class]]) {
            Parentheses *p = block;
            p.frame = CGRectOffset(p.frame, 0.0, -distance);
            
            if (p.expo != nil) {
                [p.expo moveUp:distance];
                p.mainFrame = CGRectUnion(p.frame, p.expo.mainFrame);
            } else {
                p.mainFrame = p.frame;
            }
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}

-(void) updateSize:(int)lvl {
    
    if (self.fontLvl == lvl) {
        return;
    }
    
    CGFloat nTop = 0.0, nBtm = 0.0, dTop = 0.0, dBtm = 0.0, nWidth = 0.0, dWidth = 0.0;
    CGFloat hstack[32];
    CGFloat maxh = 0.0;
    NSMutableArray *pstack = [NSMutableArray array];
    int idx = 0;
    for (id block in self.children) {
        if ([block isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *l = block;
            
            [l updateSize:lvl];
            
            if (maxh < l.mainFrame.size.height && idx > 0) {
                maxh = l.mainFrame.size.height;
            }
            
            CGFloat top = l.mainFrame.size.height - l.frame.size.height / 2.0;
            CGFloat btm = l.frame.size.height / 2.0;
            if (l.roll == ROLL_NUMERATOR) {
                if ((int)nTop < (int)top)
                    nTop = top;
                
                if ((int)nBtm < (int)btm)
                    nBtm = btm;
                
                nWidth += l.mainFrame.size.width;
            } else if (l.roll == ROLL_DENOMINATOR) {
                if ((int)dTop < (int)top)
                    dTop = top;
                
                if ((int)dBtm < (int)btm)
                    dBtm = btm;
                
                dWidth += l.mainFrame.size.width;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else if ([block isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *fb = block;
            
            fb.fontLvl = lvl;
            
            CGRect f = fb.frame;
            f.size.height = gCharHeightTbl[lvl] / FRACTION_BAR_H_R;
            fb.frame = f;
            
            while (idx > 0) {    // Handle unpaired parenth
                Parentheses *lp = [pstack objectAtIndex:idx - 1];
                if ((int)lp.frame.size.height != (int)maxh) {
                    lp.frame = CGRectMake(lp.frame.origin.x, lp.frame.origin.y, maxh / PARENTH_HW_R, maxh);
                    [lp setNeedsDisplay];
                    [lp updateFrameBaseOnBase];
                }
                
                if (hstack[--idx] > maxh) {
                    maxh = hstack[idx];
                }
                
                if (lp.roll == ROLL_NUMERATOR) {
                    nWidth += lp.frame.size.width;
                } else if (lp.roll == ROLL_DENOMINATOR) {
                    dWidth += lp.frame.size.width;
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
            
            maxh = 0.0;
            idx = 0;
        } else if ([block isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eb = block;
            
            [eb updateSize:lvl];
            
            if (maxh < eb.mainFrame.size.height && idx > 0) {
                maxh = eb.mainFrame.size.height;
            }
            
            CGFloat top = eb.mainFrame.size.height / 2.0;
            CGFloat btm = eb.mainFrame.size.height / 2.0;
            if (eb.roll == ROLL_NUMERATOR) {
                if ((int)nTop < (int)top)
                    nTop = top;
                
                if ((int)nBtm < (int)btm)
                    nBtm = btm;
                
                nWidth += eb.mainFrame.size.width;
            } else if (eb.roll == ROLL_DENOMINATOR) {
                if ((int)dTop < (int)top)
                    dTop = top;
                
                if ((int)dBtm < (int)btm)
                    dBtm = btm;
                
                dWidth += eb.mainFrame.size.width;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else if ([block isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rb = block;
            
            [rb updateSize:lvl];
            
            if (maxh < rb.frame.size.height && idx > 0) {
                maxh = rb.frame.size.height;
            }
            
            CGFloat top = rb.frame.size.height / 2.0;
            CGFloat btm = rb.frame.size.height / 2.0;
            if (rb.roll == ROLL_NUMERATOR) {
                if ((int)nTop < (int)top)
                    nTop = top;
                
                if ((int)nBtm < (int)btm)
                    nBtm = btm;
                
                nWidth += rb.frame.size.width;
            } else if (rb.roll == ROLL_DENOMINATOR) {
                if ((int)dTop < (int)top)
                    dTop = top;
                
                if ((int)dBtm < (int)btm)
                    dBtm = btm;
                
                dWidth += rb.frame.size.width;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = block;
            
            [wetl updateSize:lvl];
            
            if (maxh < wetl.mainFrame.size.height && idx > 0) {
                maxh = wetl.mainFrame.size.height;
            }
            
            CGFloat top = wetl.mainFrame.size.height / 2.0;
            CGFloat btm = wetl.mainFrame.size.height / 2.0;
            if (wetl.roll == ROLL_NUMERATOR) {
                if ((int)nTop < (int)top)
                    nTop = top;
                
                if ((int)nBtm < (int)btm)
                    nBtm = btm;
                
                nWidth += wetl.mainFrame.size.width;
            } else if (wetl.roll == ROLL_DENOMINATOR) {
                if ((int)dTop < (int)top)
                    dTop = top;
                
                if ((int)dBtm < (int)btm)
                    dBtm = btm;
                
                dWidth += wetl.mainFrame.size.width;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else if ([block isMemberOfClass: [Parentheses class]]) {
            Parentheses *p = block;
            
            if (p.l_or_r == LEFT_PARENTH) {
                [pstack insertObject:p atIndex:idx];
                hstack[idx++] = maxh;
                maxh = 0.0;
            } else {
                if (idx > 0) {
                    Parentheses *lp = [pstack objectAtIndex:idx - 1];
                    if ((int)p.frame.size.height != (int)maxh) {
                        p.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, maxh / PARENTH_HW_R, maxh);
                        [p setNeedsDisplay];
                        if (p.expo != nil) {
                            [p.expo updateSize:lvl + 1];
                            [p updateFrameBaseOnBase];
                        } else {
                            p.mainFrame = p.frame;
                        }
                        lp.frame = CGRectMake(lp.frame.origin.x, lp.frame.origin.y, maxh / PARENTH_HW_R, maxh);
                        [lp setNeedsDisplay];
                        [lp updateFrameBaseOnBase];
                    }
                    
                    if (hstack[--idx] > maxh) {
                        maxh = hstack[idx];
                    }
                    
                    CGFloat top = p.mainFrame.size.height - p.frame.size.height / 2.0;
                    CGFloat btm = p.mainFrame.size.height - top;
                    if (p.roll == ROLL_NUMERATOR) {
                        if ((int)nTop < (int)top)
                            nTop = top;
                        
                        if ((int)nBtm < (int)btm)
                            nBtm = btm;
                        
                        nWidth += (p.mainFrame.size.width + lp.mainFrame.size.width);
                    } else if (p.roll == ROLL_DENOMINATOR) {
                        if ((int)dTop < (int)top)
                            dTop = top;
                        
                        if ((int)dBtm < (int)btm)
                            dBtm = btm;
                        
                        dWidth += (p.mainFrame.size.width + lp.mainFrame.size.width);
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
            }
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    while (idx > 0) {    // Handle unpaired parenth
        Parentheses *lp = [pstack objectAtIndex:idx - 1];
        if ((int)lp.frame.size.height != (int)maxh) {
            lp.frame = CGRectMake(lp.frame.origin.x, lp.frame.origin.y, maxh / PARENTH_HW_R, maxh);
            [lp setNeedsDisplay];
            [lp updateFrameBaseOnBase];
        }
        
        if (hstack[--idx] > maxh) {
            maxh = hstack[idx];
        }
        
        if (lp.roll == ROLL_NUMERATOR) {
            nWidth += lp.frame.size.width;
        } else if (lp.roll == ROLL_DENOMINATOR) {
            dWidth += lp.frame.size.width;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
    
    [pstack removeAllObjects];
    
    CGPoint orgP = self.mainFrame.origin;
    self.numerTopHalf = nTop;
    self.numerBtmHalf = nBtm;
    self.denomTopHalf = dTop;
    self.denomBtmHalf = dBtm;
    self.numerFrame = CGRectMake(orgP.x, orgP.y, nWidth, nTop + nBtm);
    if (self.bar != nil) {
        self.denomFrame = CGRectMake(orgP.x, orgP.y + self.numerFrame.size.height, dWidth, dTop + dBtm);
        self.mainFrame = CGRectUnion(self.numerFrame, self.denomFrame);
        CGRect f = self.bar.frame;
        f.size.width = self.mainFrame.size.width;
        self.bar.frame = f;
    } else {
        self.denomFrame = CGRectZero;
        self.mainFrame = self.numerFrame;
    }
    
    self.fontLvl = lvl;
}

-(void) adjustElementPosition {
    /* First adjust numerFrame and denomFrame */
    CGFloat mainCenterX = self.mainFrame.origin.x + (self.mainFrame.size.width / 2.0);
    
    CGFloat curNumX = 0.0; // Track the layer/block orgin x
    CGFloat curDenX = 0.0; // Track the layer/block orgin x
    CGRect frame = self.numerFrame;
    frame.origin.y = self.mainFrame.origin.y;
    frame.origin.x = mainCenterX - (frame.size.width / 2.0);
    self.numerFrame = frame;
    curNumX = frame.origin.x;
    
    if (self.bar != nil) {
        frame = self.denomFrame;
        frame.origin.y = self.mainFrame.origin.y + self.numerFrame.size.height;
        frame.origin.x = mainCenterX - (frame.size.width / 2.0);
        self.denomFrame = frame;
        curDenX = frame.origin.x;
    }
    
    /* Then adjust blocks */
    NSMutableArray *blockChildren = self.children;
    NSEnumerator *enumerator = [blockChildren objectEnumerator];
    id cb;
    while (cb = [enumerator nextObject]) {
        if ([cb isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *l = cb;
            
            if (l.isCopy == YES) {
                if (l.roll == ROLL_NUMERATOR) {
                    CGPoint dest;
                    dest.x = curNumX + l.frame.size.width / 2.0;
                    dest.y = self.numerFrame.origin.y + self.numerTopHalf;
                    [l moveCopy:dest];
                    curNumX += l.mainFrame.size.width;
                } else if (l.roll == ROLL_DENOMINATOR) {
                    CGPoint dest;
                    dest.x = curDenX + l.frame.size.width / 2.0;
                    dest.y = self.denomFrame.origin.y + self.denomTopHalf;
                    [l moveCopy:dest];
                    curDenX += l.mainFrame.size.width;
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            } else {
                if (l.roll == ROLL_NUMERATOR) {
                    CGRect frame = l.frame;
                    frame.origin.y = self.numerFrame.origin.y + self.numerTopHalf - (l.frame.size.height / 2.0);
                    frame.origin.x = curNumX;
                    l.frame = frame;
                    [l updateFrameBaseOnBase];
                    curNumX += l.mainFrame.size.width;
                } else if (l.roll == ROLL_DENOMINATOR) {
                    CGRect frame = l.frame;
                    frame.origin.y = self.denomFrame.origin.y + self.denomTopHalf - (l.frame.size.height / 2.0);
                    frame.origin.x = curDenX;
                    l.frame = frame;
                    [l updateFrameBaseOnBase];
                    curDenX += l.mainFrame.size.width;
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                
                if (l.expo != nil) {
                    EquationBlock *b = l.expo;
                    [b adjustElementPosition];
                }
            }
            
        } else if ([cb isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *fb = cb;
            
            if (fb.isCopy == YES) {
                CGPoint dest;
                dest.x = self.mainFrame.origin.x + fb.frame.size.width / 2.0;
                dest.y = self.mainFrame.origin.y + self.numerFrame.size.height;
                [fb moveCopy:dest];
            } else {
                CGRect frame = fb.frame;
                frame.origin.x = self.mainFrame.origin.x;
                frame.origin.y = self.mainFrame.origin.y + self.numerFrame.size.height - (frame.size.height / 2.0);
                if ((int)frame.size.width != (int)self.mainFrame.size.width) {
                    frame.size.width = self.mainFrame.size.width;
                    fb.frame = frame;
                    [fb setNeedsDisplay];
                } else {
                    fb.frame = frame;
                }
            }
        } else if ([cb isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eb = cb;
            
            if (eb.isCopy == YES) {
                if (eb.roll == ROLL_NUMERATOR) {
                    CGPoint dest;
                    dest.x = curNumX + eb.mainFrame.size.width / 2.0;
                    dest.y = self.numerFrame.origin.y + self.numerTopHalf;
                    [eb moveCopy:dest];
                    curNumX += eb.mainFrame.size.width;
                } else if (eb.roll == ROLL_DENOMINATOR) {
                    CGPoint dest;
                    dest.x = curDenX + eb.mainFrame.size.width / 2.0;
                    dest.y = self.denomFrame.origin.y + self.denomTopHalf;
                    [eb moveCopy:dest];
                    curDenX += eb.mainFrame.size.width;
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            } else {
                if (eb.roll == ROLL_NUMERATOR) {
                    CGRect frame = eb.mainFrame;
                    frame.origin.y = self.numerFrame.origin.y + self.numerTopHalf - (eb.mainFrame.size.height / 2.0);
                    frame.origin.x = curNumX;
                    eb.mainFrame = frame;
                    curNumX += frame.size.width;
                } else if (eb.roll == ROLL_DENOMINATOR) {
                    CGRect frame = eb.mainFrame;
                    frame.origin.y = self.denomFrame.origin.y + self.denomTopHalf - (eb.mainFrame.size.height / 2.0);
                    frame.origin.x = curDenX;
                    eb.mainFrame = frame;
                    curDenX += frame.size.width;
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                
                [eb adjustElementPosition];
            }
            
        } else if ([cb isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rb = cb;
            
            if (rb.isCopy == YES) {
                if (rb.roll == ROLL_NUMERATOR) {
                    CGPoint dest;
                    dest.x = curNumX + rb.frame.size.width / 2.0;
                    dest.y = self.numerFrame.origin.y + self.numerTopHalf;
                    [rb moveCopy:dest];
                    curNumX += rb.frame.size.width;
                } else if (rb.roll == ROLL_DENOMINATOR) {
                    CGPoint dest;
                    dest.x = curDenX + rb.frame.size.width / 2.0;
                    dest.y = self.denomFrame.origin.y + self.denomTopHalf;
                    [rb moveCopy:dest];
                    curDenX += rb.frame.size.width;
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            } else {
                CGRect mainF = rb.content.mainFrame;
                CGRect frame = rb.frame;
                
                if (rb.roll == ROLL_NUMERATOR) {
                    frame.origin.y = self.numerFrame.origin.y + self.numerTopHalf - (rb.frame.size.height / 2.0);
                    frame.origin.x = curNumX;
                    rb.frame = frame;
                    curNumX += frame.size.width;
                } else if (rb.roll == ROLL_DENOMINATOR) {
                    frame.origin.y = self.denomFrame.origin.y + self.denomTopHalf - (rb.frame.size.height / 2.0);
                    frame.origin.x = curDenX;
                    rb.frame = frame;
                    curDenX += frame.size.width;
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                
                if (rb.rootNum != nil) {
                    CGFloat ML = RADICAL_MARGINE_L_PERC * rb.frame.size.height;
                    CGRect f = rb.rootNum.frame;
                    rb.rootNum.frame = CGRectMake(frame.origin.x + ML / 2.0 - 4.0, frame.origin.y, f.size.width, f.size.height);
                }
                
                frame.origin.x += RADICAL_MARGINE_L_PERC * rb.frame.size.height;
                frame.origin.y += RADICAL_MARGINE_T;
                mainF.origin = frame.origin;
                rb.content.mainFrame = mainF;
                
                [rb.content adjustElementPosition];
            }
        } else if ([cb isMemberOfClass: [WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = cb;
            
            if (wetl.isCopy == YES) {
                if (wetl.roll == ROLL_NUMERATOR) {
                    CGPoint dest;
                    dest.x = curNumX + wetl.mainFrame.size.width / 2.0;
                    dest.y = self.numerFrame.origin.y + self.numerTopHalf;
                    [wetl moveCopy:dest];
                    curNumX += wetl.mainFrame.size.width;
                } else if (wetl.roll == ROLL_DENOMINATOR) {
                    CGPoint dest;
                    dest.x = curDenX + wetl.mainFrame.size.width / 2.0;
                    dest.y = self.denomFrame.origin.y + self.denomTopHalf;
                    [wetl moveCopy:dest];
                    curDenX += wetl.mainFrame.size.width;
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            } else {
                if (wetl.roll == ROLL_NUMERATOR) {
                    CGRect f = wetl.mainFrame;
                    f.origin.y = self.numerFrame.origin.y + self.numerTopHalf - (wetl.mainFrame.size.height / 2.0);
                    f.origin.x = curNumX;
                    wetl.mainFrame = f;
                    
                    f = wetl.title.frame;
                    f.origin.y = self.numerFrame.origin.y + self.numerTopHalf - (wetl.title.frame.size.height / 2.0);
                    f.origin.x = curNumX;
                    wetl.title.frame = f;
                    curNumX += f.size.width;
                    
                    f = wetl.left_parenth.frame;
                    f.origin.y = self.numerFrame.origin.y + self.numerTopHalf - (wetl.left_parenth.frame.size.height / 2.0);
                    f.origin.x = curNumX;
                    wetl.left_parenth.frame = f;
                    curNumX += f.size.width;
                    
                    f = wetl.content.mainFrame;
                    f.origin.y = self.numerFrame.origin.y + self.numerTopHalf - (wetl.content.mainFrame.size.height / 2.0);
                    f.origin.x = curNumX;
                    wetl.content.mainFrame = f;
                    curNumX += f.size.width;
                    [wetl.content adjustElementPosition];
                    
                    f = wetl.right_parenth.frame;
                    f.origin.y = self.numerFrame.origin.y + self.numerTopHalf - (wetl.right_parenth.frame.size.height / 2.0);
                    f.origin.x = curNumX;
                    wetl.right_parenth.frame = f;
                    curNumX += f.size.width;
                } else if (wetl.roll == ROLL_DENOMINATOR) {
                    CGRect f = wetl.mainFrame;
                    f.origin.y = self.denomFrame.origin.y + self.denomTopHalf - (wetl.mainFrame.size.height / 2.0);
                    f.origin.x = curDenX;
                    wetl.mainFrame = f;
                    
                    f = wetl.title.frame;
                    f.origin.y = self.denomFrame.origin.y + self.denomTopHalf - (wetl.title.frame.size.height / 2.0);
                    f.origin.x = curDenX;
                    wetl.title.frame = f;
                    curDenX += f.size.width;
                    
                    f = wetl.left_parenth.frame;
                    f.origin.y = self.denomFrame.origin.y + self.denomTopHalf - (wetl.left_parenth.frame.size.height / 2.0);
                    f.origin.x = curDenX;
                    wetl.left_parenth.frame = f;
                    curDenX += f.size.width;
                    
                    f = wetl.content.mainFrame;
                    f.origin.y = self.denomFrame.origin.y + self.denomTopHalf - (wetl.content.mainFrame.size.height / 2.0);
                    f.origin.x = curDenX;
                    wetl.content.mainFrame = f;
                    curDenX += f.size.width;
                    [wetl.content adjustElementPosition];
                    
                    f = wetl.right_parenth.frame;
                    f.origin.y = self.denomFrame.origin.y + self.denomTopHalf - (wetl.right_parenth.frame.size.height / 2.0);
                    f.origin.x = curDenX;
                    wetl.right_parenth.frame = f;
                    curDenX += f.size.width;
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else if ([cb isMemberOfClass: [Parentheses class]]) {
            Parentheses *p = cb;
            
            if (p.isCopy == YES) {
                if (p.roll == ROLL_NUMERATOR) {
                    CGPoint dest;
                    dest.x = curNumX + p.frame.size.width / 2.0;
                    dest.y = self.numerFrame.origin.y + self.numerTopHalf;
                    [p moveCopy:dest];
                    curNumX += p.mainFrame.size.width;
                } else if (p.roll == ROLL_DENOMINATOR) {
                    CGPoint dest;
                    dest.x = curDenX + p.frame.size.width / 2.0;
                    dest.y = self.denomFrame.origin.y + self.denomTopHalf;
                    [p moveCopy:dest];
                    curDenX += p.mainFrame.size.width;
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            } else {
                if (p.roll == ROLL_NUMERATOR) {
                    CGRect f = p.frame;
                    f.origin.y = self.numerFrame.origin.y + self.numerTopHalf - f.size.height / 2.0;
                    f.origin.x = curNumX;
                    p.frame = f;
                    [p updateFrameBaseOnBase];
                    curNumX += p.mainFrame.size.width;
                } else if (p.roll == ROLL_DENOMINATOR) {
                    CGRect f = p.frame;
                    f.origin.y = self.denomFrame.origin.y + self.denomTopHalf - f.size.height / 2.0;
                    f.origin.x = curDenX;
                    p.frame = f;
                    [p updateFrameBaseOnBase];
                    curDenX += p.mainFrame.size.width;
                } else
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                
                if (p.expo != nil) {
                    EquationBlock *b = p.expo;
                    [b adjustElementPosition];
                }
            }
            
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
}

-(void) moveCopy:(CGPoint)dest {
    NSLog(@"%s%i>~%@~%@~~~~~~~~~", __FUNCTION__, __LINE__, NSStringFromCGPoint(CGPointMake(self.mainFrame.origin.x + self.mainFrame.size.width / 2.0, self.mainFrame.origin.y + self.mainFrame.size.height / 2.0)), NSStringFromCGPoint(dest));
    
    self.isCopy = NO;
    self.mainFrame = CGRectMake(dest.x - self.mainFrame.size.width / 2.0, dest.y - self.mainFrame.size.height / 2.0, self.mainFrame.size.width, self.mainFrame.size.height);
    
    CGFloat curNumX = 0.0; // Track the layer/block orgin x
    CGFloat curDenX = 0.0; // Track the layer/block orgin x
    CGRect frame = self.numerFrame;
    frame.origin.y = self.mainFrame.origin.y;
    frame.origin.x = dest.x - (frame.size.width / 2.0);
    self.numerFrame = frame;
    curNumX = frame.origin.x;
    
    if (self.bar != nil) {
        frame = self.denomFrame;
        frame.origin.y = self.mainFrame.origin.y + self.numerFrame.size.height;
        frame.origin.x = dest.x - (frame.size.width / 2.0);
        self.denomFrame = frame;
        curDenX = frame.origin.x;
    }
    
    for (id block in self.children) {
        if ([block isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *l = block;
            
            if (l.roll == ROLL_NUMERATOR) {
                CGPoint dest;
                dest.x = curNumX + l.frame.size.width / 2.0;
                dest.y = self.numerFrame.origin.y + self.numerTopHalf;
                [l moveCopy:dest];
                curNumX += l.mainFrame.size.width;
            } else if (l.roll == ROLL_DENOMINATOR) {
                CGPoint dest;
                dest.x = curDenX + l.frame.size.width / 2.0;
                dest.y = self.denomFrame.origin.y + self.denomTopHalf;
                [l moveCopy:dest];
                curDenX += l.mainFrame.size.width;
            } else
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        } else if ([block isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *fb = block;
            
            CGPoint dest;
            dest.x = self.mainFrame.origin.x + fb.frame.size.width / 2.0;
            dest.y = self.mainFrame.origin.y + self.numerFrame.size.height;
            [fb moveCopy:dest];
        } else if ([block isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eb = block;
            
            if (eb.roll == ROLL_NUMERATOR) {
                CGPoint dest;
                dest.x = curNumX + eb.mainFrame.size.width / 2.0;
                dest.y = self.numerFrame.origin.y + self.numerTopHalf;
                [eb moveCopy:dest];
                curNumX += eb.mainFrame.size.width;
            } else if (eb.roll == ROLL_DENOMINATOR) {
                CGPoint dest;
                dest.x = curDenX + eb.mainFrame.size.width / 2.0;
                dest.y = self.denomFrame.origin.y + self.denomTopHalf;
                [eb moveCopy:dest];
                curDenX += eb.mainFrame.size.width;
            } else
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        } else if ([block isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rb = block;
            
            if (rb.roll == ROLL_NUMERATOR) {
                CGPoint dest;
                dest.x = curNumX + rb.frame.size.width / 2.0;
                dest.y = self.numerFrame.origin.y + self.numerTopHalf;
                [rb moveCopy:dest];
                curNumX += rb.frame.size.width;
            } else if (rb.roll == ROLL_DENOMINATOR) {
                CGPoint dest;
                dest.x = curDenX + rb.frame.size.width / 2.0;
                dest.y = self.denomFrame.origin.y + self.denomTopHalf;
                [rb moveCopy:dest];
                curDenX += rb.frame.size.width;
            } else
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        } else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = block;
            
            if (wetl.roll == ROLL_NUMERATOR) {
                CGPoint dest;
                dest.x = curNumX + wetl.mainFrame.size.width / 2.0;
                dest.y = self.numerFrame.origin.y + self.numerTopHalf;
                [wetl moveCopy:dest];
                curNumX += wetl.mainFrame.size.width;
            } else if (wetl.roll == ROLL_DENOMINATOR) {
                CGPoint dest;
                dest.x = curDenX + wetl.mainFrame.size.width / 2.0;
                dest.y = self.denomFrame.origin.y + self.denomTopHalf;
                [wetl moveCopy:dest];
                curDenX += wetl.mainFrame.size.width;
            } else
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        } else if ([block isMemberOfClass: [Parentheses class]]) {
            Parentheses *p = block;
            
            if (p.roll == ROLL_NUMERATOR) {
                CGPoint dest;
                dest.x = curNumX + p.frame.size.width / 2.0;
                dest.y = self.numerFrame.origin.y + self.numerTopHalf;
                [p moveCopy:dest];
                curNumX += p.mainFrame.size.width;
            } else if (p.roll == ROLL_DENOMINATOR) {
                CGPoint dest;
                dest.x = curDenX + p.frame.size.width / 2.0;
                dest.y = self.denomFrame.origin.y + self.denomTopHalf;
                [p moveCopy:dest];
                curDenX += p.mainFrame.size.width;
            } else
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}

-(void) destroy {
    for (id b in self.children) {
        if ([b isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = b;
            [l destroy];
        } else if ([b isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *eb = b;
            [eb destroy];
        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock *rb = b;
            [rb destroy];
        } else if ([b isMemberOfClass:[FractionBarLayer class]]) {
            FractionBarLayer *fb = b;
            [fb destroy];
        } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = b;
            [wetl destroy];
        } else if ([b isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = b;
            [p destroy];
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    [self.children removeAllObjects];
    bar = nil;
}
@end
