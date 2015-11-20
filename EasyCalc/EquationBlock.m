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
@synthesize numerStatus;
@synthesize denomStatus;
@synthesize is_base_expo;

-(id) init : (Equation *)e {
    self = [super init];
    if (self) {
        self.ancestor = e;
        self.children = [NSMutableArray array];
        self.guid = ++e.guid_cnt;
        self.roll = e.curRoll;
        
        if (e.curFont == e.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
    }
    return self;
}

-(id) init : (CGPoint)inputPos : (Equation *)e {
    self = [super init];
    if (self) {
        self.ancestor = e;
        self.children = [NSMutableArray array];
        self.guid = ++e.guid_cnt;
        self.roll = e.curRoll;
        
        self.numerFrame = CGRectMake(inputPos.x, inputPos.y, e.curFontW, e.curFontH);
        self.mainFrame = self.numerFrame;
        self.numerTopHalf = e.curFontH / 2.0;
        self.numerBtmHalf = e.curFontH / 2.0;
        
        if (e.curFont == e.baseFont) {
            is_base_expo = IS_BASE;
        } else {
            is_base_expo = IS_EXPO;
        }
    }
    return self;
}

-(void) updateFrame : (CGRect)frame : (int)r {
    
    if (r == ROLL_NUMERATOR) {
        self.numerFrame = CGRectUnion(frame, self.numerFrame);
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
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
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
            NSLog(@"[%s-%i]~ERR~~~~~~~~~~", __FUNCTION__, __LINE__);
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
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    
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
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
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
            NSLog(@"[%s-%i]~ERR~~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
        CGRect frame = self.denomFrame;
        if (frame.size.height >= newH) { // If the frame is already heigher than newH, then nothing needs to be update.
            return;
        }
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
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
}

-(void) updateFrameHeightS1 : (id)child {
    if([child isMemberOfClass:[EquationBlock class]]) {
        EquationBlock *eBlock = child;
        int r = eBlock.roll;
        CGFloat newH = eBlock.mainFrame.size.height;
        bool needUpdate = NO;
        if (r == ROLL_NUMERATOR) {
            if ((int)self.numerTopHalf < (int)(newH / 2.0)) {
                needUpdate = YES;
                self.numerTopHalf = newH / 2.0;
            }
            
            if ((int)self.numerBtmHalf < (int)(newH / 2.0)) {
                needUpdate = YES;
                self.numerBtmHalf = newH / 2.0;
            }
            
            if (needUpdate) {
                [self updateFrameHeightS2:self.numerTopHalf + self.numerBtmHalf :r];
            }
            
        } else if (r == ROLL_DENOMINATOR) {
            if ((int)self.denomTopHalf < (int)(newH / 2.0)) {
                needUpdate = YES;
                self.denomTopHalf = newH / 2.0;
            }
            
            if ((int)self.denomBtmHalf < (int)(newH / 2.0)) {
                needUpdate = YES;
                self.denomBtmHalf = newH / 2.0;
            }
            
            if (needUpdate) {
                [self updateFrameHeightS2:self.denomTopHalf + self.denomBtmHalf :r];
            }
        } else
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else if([child isMemberOfClass:[RadicalBlock class]]) {
        RadicalBlock *rBlock = child;
        int r = rBlock.roll;
        CGFloat newH = rBlock.frame.size.height;
        bool needUpdate = NO;
        if (r == ROLL_NUMERATOR) {
            if ((int)self.numerTopHalf < (int)(newH / 2.0)) {
                needUpdate = YES;
                self.numerTopHalf = newH / 2.0;
            }
            
            if ((int)self.numerBtmHalf < (int)(newH / 2.0)) {
                needUpdate = YES;
                self.numerBtmHalf = newH / 2.0;
            }
            
            if (needUpdate) {
                [self updateFrameHeightS2:self.numerTopHalf + self.numerBtmHalf :r];
            }
        } else if (r == ROLL_DENOMINATOR) {
            if ((int)self.denomTopHalf < (int)(newH / 2.0)) {
                needUpdate = YES;
                self.denomTopHalf = newH / 2.0;
            }
            
            if ((int)self.denomBtmHalf < (int)(newH / 2.0)) {
                needUpdate = YES;
                self.denomBtmHalf = newH / 2.0;
            }
            
            if (needUpdate) {
                [self updateFrameHeightS2:self.denomTopHalf + self.denomBtmHalf :r];
            }
        } else
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else if([child isMemberOfClass:[EquationTextLayer class]]) {
        EquationTextLayer *layer = child;
        int r = layer.roll;
        bool needUpdate = NO;
        CGFloat top = layer.mainFrame.size.height - layer.frame.size.height / 2.0;
        CGFloat btm = layer.frame.size.height / 2.0;
        if (r == ROLL_NUMERATOR) {
            if ((int)self.numerTopHalf < (int)top) {
                needUpdate = YES;
                self.numerTopHalf = top;
            }
            
            if ((int)self.numerBtmHalf < (int)btm) {
                needUpdate = YES;
                self.numerBtmHalf = btm;
            }
            
            if (needUpdate) {
                [self updateFrameHeightS2:self.numerTopHalf + self.numerBtmHalf :r];
            }
        } else if (r == ROLL_DENOMINATOR) {
            if ((int)self.denomTopHalf < (int)top) {
                needUpdate = YES;
                self.denomTopHalf = top;
            }
            
            if ((int)self.denomBtmHalf < (int)btm) {
                needUpdate = YES;
                self.denomBtmHalf = btm;
            }
            
            if (needUpdate) {
                [self updateFrameHeightS2:self.denomTopHalf + self.denomBtmHalf :r];
            }
        } else
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    } else
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    
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
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else if([self.parent isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *layer = self.parent;
            [layer updateFrameBaseOnExpo];
            if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
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
        } else
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
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
        } else
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    [self.children removeAllObjects];
    bar = nil;
}
@end
