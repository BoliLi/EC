//
//  Equation.m
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
#import "Utils.h"

@class EquationTextLayer;
@class EquationBlock;

@implementation Equation
@synthesize guid_cnt;
@synthesize root;
@synthesize curParent;
@synthesize curBlock;
@synthesize curTextLayer;
@synthesize curRoll;
@synthesize curMode;
@synthesize baseFont;
@synthesize superscriptFont;
@synthesize curFont;
@synthesize baseCharWidth;
@synthesize baseCharHight;
@synthesize expoCharWidth;
@synthesize expoCharHight;
@synthesize curFontH;
@synthesize curFontW;
@synthesize insertCIdx;
@synthesize needX;
@synthesize view;
@synthesize needNewLayer;

-(id) init {
    self = [super init];
    if (self) {
        guid_cnt = 0;
        curRoll = ROLL_NUMERATOR;
        curMode = MODE_INPUT;
        needX = NO;
        needNewLayer = YES;
        
        baseFont = [UIFont systemFontOfSize: 20];
        superscriptFont = [UIFont systemFontOfSize:8];
        curFont = baseFont;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)baseFont.fontName, baseFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        CGSize strSize = [attStr size];
        baseCharWidth = strSize.width;
        baseCharHight = strSize.height;
        attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
        ctFont = CTFontCreateWithName((CFStringRef)superscriptFont.fontName, superscriptFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        strSize = [attStr size];
        expoCharWidth = strSize.width;
        expoCharHight = strSize.height;
        
        curFontW = baseCharWidth;
        curFontH = baseCharHight;
        
        root = [[EquationBlock alloc] init:self];
        root.numerTopHalf = baseCharHight / 2.0;
        root.numerBtmHalf = baseCharHight / 2.0;
        root.roll = ROLL_ROOT;
        root.parent = nil;
        curParent = root;
        
        NSLog(@"%s%i---%.1f-%.1f-%.1f-%.1f-", __FUNCTION__, __LINE__, baseCharWidth, baseCharHight, expoCharWidth, expoCharHight);
        
        [self addObserver:self forKeyPath:@"curFont" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(id) init : (CGPoint)rootPos : (CGRect)dspFrame : (CGRect)cursorFrame : (ViewController *)vc {
    self = [super init];
    if (self) {
        guid_cnt = 0;
        curRoll = ROLL_NUMERATOR;
        curMode = MODE_INPUT;
        needX = NO;
        
        baseFont = [UIFont systemFontOfSize: 20];
        superscriptFont = [UIFont systemFontOfSize:10];
        curFont = baseFont;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)baseFont.fontName, baseFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        CGSize strSize = [attStr size];
        baseCharWidth = strSize.width;
        baseCharHight = strSize.height;
        attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
        ctFont = CTFontCreateWithName((CFStringRef)superscriptFont.fontName, superscriptFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        strSize = [attStr size];
        expoCharWidth = strSize.width;
        expoCharHight = strSize.height;
        
        curFontW = baseCharWidth;
        curFontH = baseCharHight;
        
        DisplayView *dspView = [[DisplayView alloc] initWithFrame:dspFrame];
        dspView.backgroundColor = [UIColor lightGrayColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [dspView addGestureRecognizer:tapGesture];
        
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:vc action:@selector(handleSwipeRight:)];
        right.numberOfTouchesRequired = 1;
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [dspView addGestureRecognizer:right];
        
        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:vc action:@selector(handleSwipeLeft:)];
        left.numberOfTouchesRequired = 1;
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        [dspView addGestureRecognizer:left];

        CALayer *clayer = [CALayer layer];
        clayer.contentsScale = [UIScreen mainScreen].scale;
        clayer.name = @"cursorLayer";
        clayer.hidden = NO;
        clayer.backgroundColor = [UIColor clearColor].CGColor;
        CGRect tmpF = cursorFrame;
        tmpF.size = CGSizeMake(3.0, baseCharHight);
        clayer.frame = tmpF;
        clayer.delegate = vc;
        [dspView.layer addSublayer:clayer];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
        anim.fromValue = [NSNumber numberWithBool:YES];
        anim.toValue = [NSNumber numberWithBool:NO];
        anim.duration = 0.5;
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VALF;
        [clayer addAnimation:anim forKey:nil];
        [clayer setNeedsDisplay];

        root = [[EquationBlock alloc] init:rootPos :self];
        root.roll = ROLL_ROOT;
        root.parent = nil;
        curParent = root;

        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :rootPos :self :TEXTLAYER_EMPTY];
        layer.parent = root;
        root.numerFrame = layer.frame;
        root.mainFrame = layer.frame;
        NSLog(@"[%s%i]~%.1f~~~~~~~~~~", __FUNCTION__, __LINE__, layer.frame.size.width);
        layer.c_idx = 0;
        [root.children addObject:layer];
        [dspView.layer addSublayer:layer];
        curTextLayer = layer;
        curBlock = layer;

        dspView.cursor = clayer;
        dspView.inpOrg = clayer.frame.origin;
        view = dspView;

        NSLog(@"%s%i---%.1f-%.1f-%.1f-%.1f-", __FUNCTION__, __LINE__, baseCharWidth, baseCharHight, expoCharWidth, expoCharHight);
        
        [self addObserver:self forKeyPath:@"curFont" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void) dumpObj : (EquationBlock *)parentBlock {
    NSLog(@"%s~eBlk~id:%i~Cidx:%lu~roll:%i>[%.1f %.1f %.1f %.1f]>[%.1f %.1f %.1f %.1f]>[%.1f %.1f %.1f %.1f]>>>>", __FUNCTION__, parentBlock.guid, (unsigned long)parentBlock.c_idx, parentBlock.roll, parentBlock.mainFrame.origin.x, parentBlock.mainFrame.origin.y, parentBlock.mainFrame.size.width, parentBlock.mainFrame.size.height, parentBlock.numerFrame.origin.x, parentBlock.numerFrame.origin.y, parentBlock.numerFrame.size.width, parentBlock.numerFrame.size.height, parentBlock.denomFrame.origin.x, parentBlock.denomFrame.origin.y, parentBlock.denomFrame.size.width, parentBlock.denomFrame.size.height);
    NSMutableArray *blockChildren = parentBlock.children;
    NSEnumerator *enumerator = [blockChildren objectEnumerator];
    id cb;
    while (cb = [enumerator nextObject]) {
        if ([cb isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = cb;
            if (layer.expo != nil) {
                NSLog(@"%s~Txt~id:%i~Cidx:%lu~roll:%i~with expo>>>>", __FUNCTION__, layer.guid, (unsigned long)layer.c_idx, layer.roll);
                [self dumpObj:layer.expo];
                NSLog(@"%s~Txt~id:%i~<<<<<<<<<", __FUNCTION__, layer.guid);
            } else {
                NSLog(@"%s~Txt~id:%i~Cidx:%lu~roll:%i~~~~~~~~~", __FUNCTION__, layer.guid, (unsigned long)layer.c_idx, layer.roll);
            }
        }
        
        if ([cb isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = cb;
            NSLog(@"%s~Bar~id:%i~Cidx:%lu~~~~~~~~~", __FUNCTION__, bar.guid, (unsigned long)bar.c_idx);
        }
        
        if ([cb isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *block = cb;
            [self dumpObj:block];
        }
        
        if ([cb isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *block = cb;
            NSLog(@"%s~rBlk~id:%i~Cidx:%lu~roll:%i>[%.1f %.1f %.1f %.1f]>>>>>", __FUNCTION__, block.guid, (unsigned long)block.c_idx, block.roll, block.frame.origin.x, block.frame.origin.y, block.frame.size.width, block.frame.size.height);
            [self dumpObj:block.content];
            NSLog(@"%s~rBlk~%i<<<<<<", __FUNCTION__, block.guid);
        }
    }
    NSLog(@"%s~eBlk~%i<<<<<<", __FUNCTION__, parentBlock.guid);
}

-(void) dumpEverything : (EquationBlock *)eb {
    [self dumpObj:eb];
}

-(id) lookForElementByPoint : (EquationBlock *)rootB : (CGPoint) point {
    CGFloat x = rootB.mainFrame.origin.x;
    CGFloat y = rootB.mainFrame.origin.y;
    CGFloat w = rootB.mainFrame.size.width;
    CGFloat h = rootB.mainFrame.size.height;
    
    if (!(point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w)) {
        return nil;
    }
    
    for (id child in rootB.children) {
        if ([child isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eB = child;
            CGFloat x = eB.mainFrame.origin.x;
            CGFloat y = eB.mainFrame.origin.y;
            CGFloat w = eB.mainFrame.size.width;
            CGFloat h = eB.mainFrame.size.height;
            if (point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w) {
                return [self lookForElementByPoint :eB :point];
            }
        } else if ([child isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = child;
            EquationBlock *expo = layer.expo;
            CGFloat x = layer.mainFrame.origin.x;
            CGFloat y = layer.mainFrame.origin.y;
            CGFloat w = layer.mainFrame.size.width;
            CGFloat h = layer.mainFrame.size.height;
            
            if (layer.expo != nil) {
                CGFloat ex = expo.mainFrame.origin.x;
                CGFloat ey = expo.mainFrame.origin.y;
                CGFloat ew = expo.mainFrame.size.width;
                CGFloat eh = expo.mainFrame.size.height;
                
                if (point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w) { // In the main frame
                    if (point.y >= ey && point.y <= ey + eh && point.x >= ex && point.x <= ex + ew) { // In expo
                        return [self lookForElementByPoint :expo :point];
                    } else { // In base or blank
                        return layer;
                    }
                }
                
            } else {
                if (point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w) { // In the main frame
                    return layer;
                }
            }
        } else if ([child isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rB = child;
            CGFloat x = rB.frame.origin.x;
            CGFloat y = rB.frame.origin.y;
            CGFloat w = rB.frame.size.width;
            CGFloat h = rB.frame.size.height;
            if (point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w) {
                EquationBlock *eb = rB.content;
                CGFloat ex = eb.mainFrame.origin.x;
                CGFloat ey = eb.mainFrame.origin.y;
                CGFloat ew = eb.mainFrame.size.width;
                CGFloat eh = eb.mainFrame.size.height;
                
                if (point.y >= ey && point.y <= ey + eh && point.x >= ex && point.x <= ex + ew) {
                    return [self lookForElementByPoint :eb :point];
                } else {
                    return rB;
                }
            }
        } else if ([child isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = child;
            CGFloat x = bar.frame.origin.x;
            CGFloat y = bar.frame.origin.y;
            CGFloat w = bar.frame.size.width;
            CGFloat h = bar.frame.size.height;
            
            if (point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w) {
                return bar;
            }
        } else
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    return rootB;
}



-(void) adjustEveryThing : (EquationBlock *)parentBlock {
    /* First adjust numerFrame and denomFrame */
    CGFloat mainCenterX = parentBlock.mainFrame.origin.x + (parentBlock.mainFrame.size.width / 2.0);
    
    CGFloat curNumX = 0.0; // Track the layer/block orgin x
    CGFloat curDenX = 0.0; // Track the layer/block orgin x
    CGRect frame = parentBlock.numerFrame;
    frame.origin.y = parentBlock.mainFrame.origin.y;
    frame.origin.x = mainCenterX - (frame.size.width / 2.0);
    parentBlock.numerFrame = frame;
    curNumX = frame.origin.x;
    
    if (parentBlock.bar != nil) {
        frame = parentBlock.denomFrame;
        frame.origin.y = parentBlock.mainFrame.origin.y + parentBlock.numerFrame.size.height;
        frame.origin.x = mainCenterX - (frame.size.width / 2.0);
        parentBlock.denomFrame = frame;
        curDenX = frame.origin.x;
    }
    
    /* Then adjust blocks */
    NSMutableArray *blockChildren = parentBlock.children;
    NSEnumerator *enumerator = [blockChildren objectEnumerator];
    id cb;
    while (cb = [enumerator nextObject]) {
        if ([cb isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = cb;
            
            if (layer.roll == ROLL_NUMERATOR) {
                CGRect frame = layer.frame;
                frame.origin.y = parentBlock.numerFrame.origin.y + parentBlock.numerTopHalf - (layer.frame.size.height / 2.0);
                frame.origin.x = curNumX;
                layer.frame = frame;
                [layer updateFrameBaseOnBase];
                curNumX += layer.mainFrame.size.width;
            } else if (layer.roll == ROLL_DENOMINATOR) {
                CGRect frame = layer.frame;
                frame.origin.y = parentBlock.denomFrame.origin.y + parentBlock.denomTopHalf - (layer.frame.size.height / 2.0);
                frame.origin.x = curDenX;
                layer.frame = frame;
                [layer updateFrameBaseOnBase];
                curDenX += layer.mainFrame.size.width;
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            if (layer.expo != nil) {
                EquationBlock *b = layer.expo;
                [self adjustEveryThing:b];
            }
        } else if ([cb isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = cb;
            CGRect frame = bar.frame;
            frame.origin.x = parentBlock.mainFrame.origin.x;
            frame.origin.y = parentBlock.mainFrame.origin.y + parentBlock.numerFrame.size.height - (frame.size.height / 2.0);
            if ((int)frame.size.width != (int)parentBlock.mainFrame.size.width) {
                frame.size.width = parentBlock.mainFrame.size.width;
                bar.frame = frame;
                [bar setNeedsDisplay];
            } else {
                bar.frame = frame;
            }
        } else if ([cb isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *block = cb;
            
            if (block.roll == ROLL_NUMERATOR) {
                CGRect frame = block.mainFrame;
                frame.origin.y = parentBlock.numerFrame.origin.y + parentBlock.numerTopHalf - (block.mainFrame.size.height / 2.0);
                frame.origin.x = curNumX;
                block.mainFrame = frame;
                curNumX += frame.size.width;
            } else if (block.roll == ROLL_DENOMINATOR) {
                CGRect frame = block.mainFrame;
                frame.origin.y = parentBlock.denomFrame.origin.y + parentBlock.denomTopHalf - (block.mainFrame.size.height / 2.0);
                frame.origin.x = curDenX;
                block.mainFrame = frame;
                curDenX += frame.size.width;
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            [self adjustEveryThing:block];
        } else if ([cb isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *block = cb;
            CGRect mainF = block.content.mainFrame;
            CGRect frame = block.frame;
            
            if (block.roll == ROLL_NUMERATOR || block.roll == ROLL_ROOT_ROOT) {
                frame.origin.y = parentBlock.numerFrame.origin.y + parentBlock.numerTopHalf - (block.frame.size.height / 2.0);
                frame.origin.x = curNumX;
                block.frame = frame;
                curNumX += frame.size.width;
            } else if (block.roll == ROLL_DENOMINATOR) {
                frame.origin.y = parentBlock.denomFrame.origin.y + parentBlock.denomTopHalf - (block.frame.size.height / 2.0);
                frame.origin.x = curDenX;
                block.frame = frame;
                curDenX += frame.size.width;
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            if (block.rootNum != nil) {
                CGFloat ML = RADICAL_MARGINE_L_PERC * block.frame.size.height;
                CGRect f = block.rootNum.frame;
                block.rootNum.frame = CGRectMake(frame.origin.x + ML / 2.0 - 4.0, frame.origin.y, f.size.width, f.size.height);
            }
            
            frame.origin.x += RADICAL_MARGINE_L_PERC * block.frame.size.height;
            frame.origin.y += RADICAL_MARGINE_T;
            mainF.origin = frame.origin;
            block.content.mainFrame = mainF;
            
            [self adjustEveryThing:block.content];
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
}

-(void)removeElement:(id)blk {
    if ([blk isMemberOfClass: [EquationBlock class]]) {
        EquationBlock *eb = blk;
        if (![eb.parent isMemberOfClass: [EquationBlock class]]) {
            return;
        }
        EquationBlock *parent = eb.parent;
        Equation *e = eb.ancestor;
        CGFloat orgWidth = eb.mainFrame.size.width;
        if (parent.children.count == 1) {
            CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - e.curFontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
            l.parent = parent;
            l.c_idx = 0;
            [eb destroy];
            [parent.children removeObjectAtIndex:0];
            [parent.children addObject:l];
            [e.view.layer addSublayer: l];
            
            [parent updateFrameWidth:l.frame.size.width - orgWidth :e.curRoll];
            [parent updateFrameHeightS1:l];
            [e adjustEveryThing:e.root];
            
            cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else {
            if (eb.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:eb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - e.curFontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
                l.parent = parent;
                l.c_idx = eb.c_idx;
                [eb destroy];
                [parent.children removeLastObject];
                [parent.children addObject:l];
                [e.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :e.curRoll];
                [parent updateFrameHeightS1:l];
                [e adjustEveryThing:e.root];
                
                cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else {
                [eb destroy];
                [parent.children removeObjectAtIndex:eb.c_idx];
                [parent updateCIdx];
                
                id preEle = [parent.children objectAtIndex:eb.c_idx - 1];
                if ([preEle isMemberOfClass:[FractionBarLayer class]]) {
                    [parent updateFrameWidth:-orgWidth :eb.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:eb.c_idx]];
                    [e adjustEveryThing:e.root];
                    preEle = [parent.children objectAtIndex:eb.c_idx - 2];
                    if ([preEle isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb = preEle;
                        cfgEqnBySlctBlk(e, eb, CGPointMake(eb.mainFrame.origin.x + 1.0, eb.mainFrame.origin.y + 1.0));
                    } else if ([preEle isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = preEle;
                        cfgEqnBySlctBlk(e, l, CGPointMake(l.mainFrame.origin.x + 1.0, l.mainFrame.origin.y + 1.0));
                    } else if ([preEle isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb = preEle;
                        cfgEqnBySlctBlk(e, rb, CGPointMake(rb.frame.origin.x + 1.0, rb.frame.origin.y + 1.0));
                    } else {
                        NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else {
                    if ([preEle isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *pre = preEle;
                        [parent updateFrameWidth:-orgWidth :eb.roll];
                        [parent updateFrameHeightS1:pre];
                        [e adjustEveryThing:e.root];
                        cfgEqnBySlctBlk(e, pre, CGPointMake(pre.mainFrame.origin.x + 1.0, pre.mainFrame.origin.y + 1.0));
                    } else if ([preEle isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *pre = preEle;
                        [parent updateFrameWidth:-orgWidth :eb.roll];
                        [parent updateFrameHeightS1:pre];
                        [e adjustEveryThing:e.root];
                        cfgEqnBySlctBlk(e, pre, CGPointMake(pre.mainFrame.origin.x + 1.0, pre.mainFrame.origin.y + 1.0));
                    } else if ([preEle isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *pre = preEle;
                        [parent updateFrameWidth:-orgWidth :eb.roll];
                        [parent updateFrameHeightS1:pre];
                        [e adjustEveryThing:e.root];
                        cfgEqnBySlctBlk(e, pre, CGPointMake(pre.frame.origin.x + 1.0, pre.frame.origin.y + 1.0));
                    } else {
                        NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
            }
        }
    } else if ([blk isMemberOfClass: [EquationTextLayer class]]) {
        EquationTextLayer *l = blk;
        if (![l.parent isMemberOfClass: [EquationBlock class]]) {
            return;
        }
        EquationBlock *parent = l.parent;
        Equation *e = l.ancestor;
        CGFloat orgWidth = l.frame.size.width;
        if (parent.children.count == 1) {
            if (l.type == TEXTLAYER_EMPTY) {
                if (parent.roll == ROLL_ROOT) {
                    return;  // Do nothing
                } else if (parent.roll == ROLL_ROOT_ROOT) {
                    [e removeElement:parent.parent];
                } else if (parent.roll == ROLL_EXPO_ROOT) {
                    EquationTextLayer *parLayer = parent.parent;
                    [parent destroy];
                    parLayer.expo = nil;
                    [parLayer updateFrameBaseOnBase];
                    [parent updateFrameWidth:-orgWidth :parLayer.roll];
                    [parent updateFrameHeightS1:parLayer];
                    [e adjustEveryThing:e.root];
                    cfgEqnBySlctBlk(e, parLayer, CGPointMake(parLayer.frame.origin.x + 1.0, parLayer.frame.origin.y + 1.0));
                } else {
                    NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            } else {
                CGPoint p = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                EquationTextLayer *el = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
                el.parent = parent;
                el.c_idx = 0;
                [l destroy];
                [parent.children removeObjectAtIndex:0];
                [parent.children addObject:el];
                [e.view.layer addSublayer: el];
                
                [parent updateFrameWidth:el.frame.size.width - orgWidth :e.curRoll];
                [parent updateFrameHeightS1:el];
                [e adjustEveryThing:e.root];
                
                cfgEqnBySlctBlk(e, el, CGPointMake(el.frame.origin.x + 1.0, el.frame.origin.y + 1.0));
            }
        } else {
            if (l.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:l.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if (l.type == TEXTLAYER_EMPTY) {
                    /* Remove empty layer */
                    [l destroy];
                    [parent.children removeLastObject];
                    /* Remove fraction bar */
                    [parent.bar destroy];
                    [parent.children removeLastObject];
                    parent.bar = nil;
                    /* Remove denom */
                    if (parent.roll == ROLL_ROOT || parent.roll == ROLL_ROOT_ROOT || parent.roll == ROLL_EXPO_ROOT) { // Just move down numer
                        parent.numerFrame = CGRectOffset(parent.numerFrame, 0.0, e.curFontH);
                        parent.denomFrame = CGRectMake(0, 0, 0, 0);
                        parent.mainFrame = parent.numerFrame;
                        if (parent.roll == ROLL_ROOT_ROOT) {
                            RadicalBlock *rb = parent.parent;
                            [rb updateFrame];
                            [rb.parent updateFrameHeightS1:rb];
                        } else if (parent.roll == ROLL_EXPO_ROOT) {
                            EquationTextLayer *parLayer = parent.parent;
                            [parLayer updateFrameBaseOnExpo];
                            [parLayer.parent updateFrameHeightS1:parLayer];
                        }
                        [e adjustEveryThing:e.root];
                        id b = [parent.children lastObject];
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb = b;
                            cfgEqnBySlctBlk(e, eb, CGPointMake(eb.mainFrame.origin.x + 1.0, eb.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            cfgEqnBySlctBlk(e, l, CGPointMake(l.mainFrame.origin.x + 1.0, l.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb = b;
                            cfgEqnBySlctBlk(e, rb, CGPointMake(rb.frame.origin.x + 1.0, rb.frame.origin.y + 1.0));
                        } else {
                            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        }
                    } else { // Degrade e block
                        EquationBlock *eb = parent.parent;
                        int cnt = 1;
                        for (id b in parent.children) {
                            [eb.children insertObject:b atIndex:parent.c_idx + cnt++];
                        }
                        [eb.children removeObjectAtIndex:parent.c_idx];
                        [eb updateCIdx];
                        [parent.children removeAllObjects];
                        parent.children = nil;
                        
                        id b = [eb.children objectAtIndex:parent.c_idx + cnt - 2];
                        [eb updateFrameHeightS1:b];
                        [e adjustEveryThing:e.root];
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb = b;
                            cfgEqnBySlctBlk(e, eb, CGPointMake(eb.mainFrame.origin.x + 1.0, eb.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            cfgEqnBySlctBlk(e, l, CGPointMake(l.mainFrame.origin.x + 1.0, l.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb = b;
                            cfgEqnBySlctBlk(e, rb, CGPointMake(rb.frame.origin.x + 1.0, rb.frame.origin.y + 1.0));
                        } else {
                            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        }
                    }
                } else {
                    
                }
            } else if(l.c_idx == 0) {
                
            } else {
                
            }
        }
    } else if ([blk isMemberOfClass: [RadicalBlock class]]) {
        RadicalBlock *rb = blk;
        if (![rb.parent isMemberOfClass: [EquationBlock class]]) {
            return;
        }
        EquationBlock *parent = rb.parent;
        Equation *e = rb.ancestor;
        if (parent.children.count == 1) {
            
        } else {
            if (rb.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:rb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                
            } else {
                
            }
        }
    } else {
        
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqual: @"curFont"]) {
        Equation *e = object;
        UIFont *newFont = [change objectForKey:@"new"];
        if (newFont == e.baseFont) {
            e.curFontW = e.baseCharWidth;
            e.curFontH = e.baseCharHight;
        } else if (newFont == e.superscriptFont) {
            e.curFontW = e.expoCharWidth;
            e.curFontH = e.expoCharHight;
        } else
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        
        NSLog(@"[%s%i]~~~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}
@end
