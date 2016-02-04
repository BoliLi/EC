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
#import "WrapedEqTxtLyr.h"
#import "Utils.h"


@class EquationTextLayer;
@class EquationBlock;

@implementation Equation
@synthesize guid_cnt;
@synthesize root;
@synthesize curParent;
@synthesize curBlk;
@synthesize curTxtLyr;
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
@synthesize view;
@synthesize txtInsIdx;
@synthesize downLeftBasePoint;
@synthesize hasResult;
@synthesize zoomInLvl;

//-(id) init {
//    self = [super init];
//    if (self) {
//        guid_cnt = 0;
//        curRoll = ROLL_NUMERATOR;
//        curMode = MODE_INPUT;
//        curTxtLyr = curBlk = nil;
//        txtInsIdx = 0;
//        
//        baseFont = [UIFont systemFontOfSize: 20];
//        superscriptFont = [UIFont systemFontOfSize:8];
//        curFont = baseFont;
//        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
//        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)baseFont.fontName, baseFont.pointSize, NULL);
//        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
//        CFRelease(ctFont);
//        CGSize strSize = [attStr size];
//        baseCharWidth = strSize.width;
//        baseCharHight = strSize.height;
//        attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
//        ctFont = CTFontCreateWithName((CFStringRef)superscriptFont.fontName, superscriptFont.pointSize, NULL);
//        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
//        CFRelease(ctFont);
//        strSize = [attStr size];
//        expoCharWidth = strSize.width;
//        expoCharHight = strSize.height;
//        
//        curFontW = baseCharWidth;
//        curFontH = baseCharHight;
//        
//        root = [[EquationBlock alloc] init:self];
//        root.numerTopHalf = baseCharHight / 2.0;
//        root.numerBtmHalf = baseCharHight / 2.0;
//        root.roll = ROLL_ROOT;
//        root.parent = nil;
//        curParent = root;
//        
//        NSLog(@"%s%i---%.1f-%.1f-%.1f-%.1f-", __FUNCTION__, __LINE__, baseCharWidth, baseCharHight, expoCharWidth, expoCharHight);
//        
//        [self addObserver:self forKeyPath:@"curFont" options:NSKeyValueObservingOptionNew context:nil];
//    }
//    return self;
//}

-(id) init : (CGPoint)downLeft : (CGRect)dspFrame : (ViewController *)vc {
    self = [super init];
    if (self) {
        guid_cnt = 0;
        curRoll = ROLL_NUMERATOR;
        curMode = MODE_INPUT;
        curTxtLyr = curBlk = nil;
        txtInsIdx = 0;
        downLeftBasePoint = downLeft;
        hasResult = NO;
        zoomInLvl = 0;
        
        baseFont = [UIFont systemFontOfSize: 30];
        superscriptFont = [UIFont systemFontOfSize:15];
        curFont = baseFont;
        
        baseCharWidth = gBaseCharWidthTbl[0][8];
        baseCharHight = baseFont.lineHeight;
        
        expoCharWidth = gExpoCharWidthTbl[0][8];
        expoCharHight = superscriptFont.lineHeight;
        
        curFontW = baseCharWidth;
        curFontH = baseCharHight;
        
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
        
        CGPoint rootPos = CGPointMake(downLeft.x, downLeft.y - baseCharHight - 1.0);
        
        CALayer *clayer = [CALayer layer];
        clayer.contentsScale = [UIScreen mainScreen].scale;
        clayer.name = @"cursorLayer";
        clayer.hidden = NO;
        clayer.backgroundColor = [UIColor clearColor].CGColor;
        clayer.frame = CGRectMake(rootPos.x, rootPos.y, 3.0, baseCharHight);
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
        root.ancestor = self;
        curParent = root;

        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :rootPos :self :TEXTLAYER_EMPTY];
        layer.parent = root;
        root.numerFrame = layer.frame;
        root.mainFrame = layer.frame;
        
        layer.c_idx = 0;
        [root.children addObject:layer];
        [dspView.layer addSublayer:layer];
        curTxtLyr = layer;
        curBlk = layer;

        dspView.cursor = clayer;
        dspView.inpOrg = clayer.frame.origin;
        view = dspView;
        
        [self addObserver:self forKeyPath:@"curFont" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.guid_cnt = [coder decodeIntForKey:@"guid_cnt"];
        self.root = [coder decodeObjectForKey:@"root"];
        self.curParent = [coder decodeObjectForKey:@"curParent"];
        self.curBlk = [coder decodeObjectForKey:@"curBlk"];
        self.curTxtLyr = [coder decodeObjectForKey:@"curTxtLyr"];
        self.curRoll = [coder decodeIntForKey:@"curRoll"];
        self.curMode = [coder decodeIntForKey:@"curMode"];
        self.baseFont = [coder decodeObjectForKey:@"baseFont"];
        self.superscriptFont = [coder decodeObjectForKey:@"superscriptFont"];
        self.curFont = [coder decodeObjectForKey:@"curFont"];
        self.baseCharWidth = [coder decodeDoubleForKey:@"baseCharWidth"];
        self.baseCharHight = [coder decodeDoubleForKey:@"baseCharHight"];
        self.expoCharWidth = [coder decodeDoubleForKey:@"expoCharWidth"];
        self.expoCharHight = [coder decodeDoubleForKey:@"expoCharHight"];
        self.curFontH = [coder decodeDoubleForKey:@"curFontH"];
        self.curFontW = [coder decodeDoubleForKey:@"curFontW"];
        self.insertCIdx = [coder decodeIntegerForKey:@"insertCIdx"];
        self.view = [coder decodeObjectForKey:@"view"];
        self.txtInsIdx = [coder decodeIntForKey:@"txtInsIdx"];
        self.downLeftBasePoint = [coder decodeCGPointForKey:@"downLeftBasePoint"];
        self.hasResult = [coder decodeBoolForKey:@"hasResult"];
        self.zoomInLvl = [coder decodeIntForKey:@"zoomInLvl"];
        
        [self addObserver:self forKeyPath:@"curFont" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self.guid_cnt forKey:@"guid_cnt"];
    [coder encodeObject:self.root forKey:@"root"];
    [coder encodeObject:self.curParent forKey:@"curParent"];
    [coder encodeObject:self.curBlk forKey:@"curBlk"];
    if (self.curTxtLyr != nil) {
        [coder encodeObject:self.curTxtLyr forKey:@"curTxtLyr"];
    }
    [coder encodeInt:self.curRoll forKey:@"curRoll"];
    [coder encodeInt:self.curMode forKey:@"curMode"];
    [coder encodeObject:self.baseFont forKey:@"baseFont"];
    [coder encodeObject:self.superscriptFont forKey:@"superscriptFont"];
    [coder encodeObject:self.curFont forKey:@"curFont"];
    [coder encodeDouble:self.baseCharWidth forKey:@"baseCharWidth"];
    [coder encodeDouble:self.baseCharHight forKey:@"baseCharHight"];
    [coder encodeDouble:self.expoCharWidth forKey:@"expoCharWidth"];
    [coder encodeDouble:self.expoCharHight forKey:@"expoCharHight"];
    [coder encodeDouble:self.curFontH forKey:@"curFontH"];
    [coder encodeDouble:self.curFontW forKey:@"curFontW"];
    [coder encodeInteger:self.insertCIdx forKey:@"insertCIdx"];
    [coder encodeObject:self.view forKey:@"view"];
    [coder encodeInt:self.txtInsIdx forKey:@"txtInsIdx"];
    [coder encodeCGPoint:self.downLeftBasePoint forKey:@"downLeftBasePoint"];
    [coder encodeBool:self.hasResult forKey:@"hasResult"];
    [coder encodeInt:self.zoomInLvl forKey:@"zoomInLvl"];
}

-(void) dumpObj : (EquationBlock *)parentBlock {
    NSLog(@"%s~%@~id:%i~Cidx:%lu~roll:%i>[%.1f %.1f %.1f %.1f]>[%.1f %.1f %.1f %.1f]>[%.1f %.1f %.1f %.1f]>>>>", __FUNCTION__, parentBlock, parentBlock.guid, (unsigned long)parentBlock.c_idx, parentBlock.roll, parentBlock.mainFrame.origin.x, parentBlock.mainFrame.origin.y, parentBlock.mainFrame.size.width, parentBlock.mainFrame.size.height, parentBlock.numerFrame.origin.x, parentBlock.numerFrame.origin.y, parentBlock.numerFrame.size.width, parentBlock.numerFrame.size.height, parentBlock.denomFrame.origin.x, parentBlock.denomFrame.origin.y, parentBlock.denomFrame.size.width, parentBlock.denomFrame.size.height);
    NSMutableArray *blockChildren = parentBlock.children;
    NSEnumerator *enumerator = [blockChildren objectEnumerator];
    id cb;
    while (cb = [enumerator nextObject]) {
        if ([cb isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = cb;
            if (layer.expo != nil) {
                NSLog(@"%s~%@~id:%i~Cidx:%lu~roll:%i~with expo>>>>", __FUNCTION__, layer, layer.guid, (unsigned long)layer.c_idx, layer.roll);
                [self dumpObj:layer.expo];
                NSLog(@"%s~%@~id:%i~<<<<<<<<<", __FUNCTION__, layer, layer.guid);
            } else {
                NSLog(@"%s~%@~id:%i~Cidx:%lu~roll:%i~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, layer, layer.guid, (unsigned long)layer.c_idx, layer.roll, layer.frame.origin.x, layer.frame.origin.y, layer.frame.size.width, layer.frame.size.height);
            }
        }
        
        if ([cb isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = cb;
            NSLog(@"%s~%@~id:%i~Cidx:%lu~~~~~~~~~", __FUNCTION__, bar, bar.guid, (unsigned long)bar.c_idx);
        }
        
        if ([cb isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *block = cb;
            [self dumpObj:block];
        }
        
        if ([cb isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *block = cb;
            NSLog(@"%s~%@~id:%i~Cidx:%lu~roll:%i>[%.1f %.1f %.1f %.1f]>>>>>", __FUNCTION__, block, block.guid, (unsigned long)block.c_idx, block.roll, block.frame.origin.x, block.frame.origin.y, block.frame.size.width, block.frame.size.height);
            [self dumpObj:block.content];
            NSLog(@"%s~%@~%i<<<<<<", __FUNCTION__, block, block.guid);
        }
    }
    NSLog(@"%s~%@~%i<<<<<<", __FUNCTION__, parentBlock, parentBlock.guid);
}

-(void) dumpEverything : (EquationBlock *)eb {
    [self dumpObj:eb];
    NSLog(@"%s>~%@~%@~%@~%i~%lu~%i~~~~~", __FUNCTION__, self.curParent, self.curBlk, self.curTxtLyr, self.curMode, (unsigned long)self.insertCIdx, self.txtInsIdx);
}

-(id) lookForElementByPoint : (EquationBlock *)rootB : (CGPoint) point {
    
    if (!CGRectContainsPoint(rootB.mainFrame, point)) {
        return nil;
    }
    
    for (id child in rootB.children) {
        if ([child isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eB = child;
            if (CGRectContainsPoint(eB.mainFrame, point)) {
                return [self lookForElementByPoint :eB :point];
            }
        } else if ([child isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = child;
            EquationBlock *expo = layer.expo;
            if (layer.expo != nil) {
                if (CGRectContainsPoint(layer.mainFrame, point)) { // In the main frame
                    if (CGRectContainsPoint(expo.mainFrame, point)) { // In expo
                        return [self lookForElementByPoint :expo :point];
                    } else { // In base or blank
                        return layer;
                    }
                }
            } else {
                if (CGRectContainsPoint(layer.mainFrame, point)) { // In the main frame
                    return layer;
                }
            }
        } else if ([child isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rB = child;
            if (CGRectContainsPoint(rB.frame, point)) {
                EquationBlock *eb = rB.content;
                if (CGRectContainsPoint(eb.mainFrame, point)) {
                    return [self lookForElementByPoint :eb :point];
                } else {
                    return rB;
                }
            }
        } else if ([child isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = child;
            if (CGRectContainsPoint(bar.frame, point)) {
                return bar;
            }
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    return rootB;
}

-(void)removeElement:(id)blk {
    if ([blk isMemberOfClass: [EquationBlock class]]) {
        EquationBlock *eb = blk;
        Equation *e = eb.ancestor;
        
        if (eb.roll == ROLL_ROOT) {
            CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - e.curFontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
            l.roll = ROLL_NUMERATOR;
            l.parent = eb;
            l.c_idx = 0;
            [eb destroy];
            [eb.children removeAllObjects];
            [eb.children addObject:l];
            [e.view.layer addSublayer: l];
            eb.mainFrame = eb.numerFrame = l.frame;
            eb.denomFrame = CGRectMake(0, 0, 0, 0);
            eb.numerTopHalf = eb.numerBtmHalf = l.frame.size.height / 2.0;
            eb.denomTopHalf = eb.denomBtmHalf = 0.0;
            
            cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else if (eb.roll == ROLL_ROOT_ROOT) {
            RadicalBlock *rb = eb.parent;
            CGFloat orgWidth = rb.frame.size.width;
            CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - e.curFontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
            l.roll = ROLL_NUMERATOR;
            l.parent = eb;
            l.c_idx = 0;
            [eb destroy];
            [eb.children removeAllObjects];
            [eb.children addObject:l];
            [e.view.layer addSublayer: l];
            eb.mainFrame = eb.numerFrame = l.frame;
            eb.denomFrame = CGRectMake(0, 0, 0, 0);
            eb.numerTopHalf = eb.numerBtmHalf = l.frame.size.height / 2.0;
            eb.denomTopHalf = eb.denomBtmHalf = 0.0;
            
            [rb updateFrame];
            [rb setNeedsDisplay];
            
            [rb.parent updateFrameWidth:rb.frame.size.width - orgWidth :rb.roll];
            [rb.parent updateFrameHeightS1:rb];
            [e.root adjustElementPosition];
            
            cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else if (eb.roll == ROLL_EXPO_ROOT) {
            EquationTextLayer *parLayer = eb.parent;
            CGFloat orgWidth = parLayer.mainFrame.size.width;
            CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - e.curFontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
            l.roll = ROLL_NUMERATOR;
            l.parent = eb;
            l.c_idx = 0;
            [eb destroy];
            [eb.children removeAllObjects];
            [eb.children addObject:l];
            [e.view.layer addSublayer: l];
            eb.mainFrame = eb.numerFrame = l.frame;
            eb.denomFrame = CGRectMake(0, 0, 0, 0);
            eb.numerTopHalf = eb.numerBtmHalf = l.frame.size.height / 2.0;
            eb.denomTopHalf = eb.denomBtmHalf = 0.0;
            
            [parLayer updateFrameBaseOnExpo];
            
            [parLayer.parent updateFrameWidth:parLayer.mainFrame.size.width - orgWidth :parLayer.roll];
            [parLayer.parent updateFrameHeightS1:parLayer];
            [e.root adjustElementPosition];
            
            cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else if ([eb.parent isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *parent = eb.parent;
            CGFloat orgWidth = eb.mainFrame.size.width;
            if (parent.children.count == 1) {
                CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - e.curFontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
                l.roll = ROLL_NUMERATOR;
                l.parent = parent;
                l.c_idx = 0;
                [eb destroy];
                [parent.children removeObjectAtIndex:0];
                [parent.children addObject:l];
                [e.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                [parent updateFrameHeightS1:l];
                [e.root adjustElementPosition];
                
                cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else {
                if (eb.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:eb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                    /* Case:  @ @
                              ---
                               *  */
                    CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - e.curFontH);
                    EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
                    l.roll = eb.roll;
                    l.parent = parent;
                    l.c_idx = eb.c_idx;
                    [eb destroy];
                    [parent.children removeLastObject];
                    [parent.children addObject:l];
                    [e.view.layer addSublayer: l];
                    
                    [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                    [parent updateFrameHeightS1:l];
                    [e.root adjustElementPosition];
                    
                    cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                } else if(eb.c_idx == 0 && [[parent.children objectAtIndex:eb.c_idx + 1] isMemberOfClass:[FractionBarLayer class]]) {
                    /* Case:  *
                             ---
                             @ @ */
                    CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - e.curFontH);
                    EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
                    l.roll = eb.roll;
                    l.parent = parent;
                    l.c_idx = 0;
                    [eb destroy];
                    [parent.children removeObjectAtIndex:0];
                    [parent.children insertObject:l atIndex:0];
                    [e.view.layer addSublayer: l];
                    
                    [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                    [parent updateFrameHeightS1:l];
                    [e.root adjustElementPosition];
                    
                    cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                } else {
                    /* Case:  @ @
                              ---
                              @ @ */
                    
                    if (eb.c_idx == 0) {
                        [eb destroy];
                        [parent.children removeObjectAtIndex:0];
                        [parent updateCIdx];
                        
                        [parent updateFrameWidth:-orgWidth :eb.roll];
                        [parent updateFrameHeightS1:[parent.children objectAtIndex:0]];
                        [e.root adjustElementPosition];
                        
                        id b = parent.children.firstObject;
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb1 = b;
                            e.view.inpOrg = CGPointMake(eb1.mainFrame.origin.x, eb1.numerFrame.origin.y + eb1.numerFrame.size.height - e.curFontH / 2.0);;
                            e.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                            e.curTxtLyr = nil;
                            e.curRoll = eb1.roll;
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            e.view.inpOrg = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                            e.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                            e.curTxtLyr = l;
                            e.curRoll = l.roll;
                            e.txtInsIdx = 0;
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb1 = b;
                            e.view.inpOrg = CGPointMake(rb1.frame.origin.x, rb1.frame.origin.y + rb1.frame.size.height / 2.0 - e.curFontH / 2.0);;
                            e.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                            e.curTxtLyr = nil;
                            e.curRoll = rb1.roll;
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            return;
                        }
                        e.curMode = MODE_INSERT;
                        e.insertCIdx = 0;
                        e.curParent = parent;
                        e.curBlk = b;
                    } else if ([[parent.children objectAtIndex:eb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                        [eb destroy];
                        [parent.children removeObjectAtIndex:eb.c_idx];
                        [parent updateCIdx];
                        
                        [parent updateFrameWidth:-orgWidth :eb.roll];
                        [parent updateFrameHeightS1:[parent.children objectAtIndex:eb.c_idx]];
                        [e.root adjustElementPosition];
                        
                        id b = [parent.children objectAtIndex:eb.c_idx];
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb1 = b;
                            e.view.inpOrg = CGPointMake(eb1.mainFrame.origin.x, eb1.numerFrame.origin.y + eb1.numerFrame.size.height - e.curFontH / 2.0);;
                            e.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                            e.curTxtLyr = nil;
                            e.curRoll = eb1.roll;
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            e.view.inpOrg = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                            e.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                            e.curTxtLyr = l;
                            e.curRoll = l.roll;
                            e.txtInsIdx = 0;
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb1 = b;
                            e.view.inpOrg = CGPointMake(rb1.frame.origin.x, rb1.frame.origin.y + rb1.frame.size.height / 2.0 - e.curFontH / 2.0);;
                            e.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                            e.curTxtLyr = nil;
                            e.curRoll = rb1.roll;
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            return;
                        }
                        e.curMode = MODE_INSERT;
                        e.insertCIdx = eb.c_idx;
                        e.curParent = parent;
                        e.curBlk = b;
                    } else {
                        [eb destroy];
                        [parent.children removeObjectAtIndex:eb.c_idx];
                        [parent updateCIdx];
                        
                        id b = [parent.children objectAtIndex:eb.c_idx - 1];
                        [parent updateFrameWidth:-orgWidth :eb.roll];
                        [parent updateFrameHeightS1:b];
                        [e.root adjustElementPosition];
                        
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb = b;
                            if (eb.bar != nil) {
                                cfgEqnBySlctBlk(e, eb.bar, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                            } else {
                                cfgEqnBySlctBlk(e, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                            }
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            cfgEqnBySlctBlk(e, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb = b;
                            cfgEqnBySlctBlk(e, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 0.5, rb.frame.origin.y + 0.5));
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        }
                    }
                }
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if ([blk isMemberOfClass: [EquationTextLayer class]]) {
        EquationTextLayer *l = blk;
        if (![l.parent isMemberOfClass: [EquationBlock class]]) {
            return;
        }
        EquationBlock *parent = l.parent;
        Equation *e = l.ancestor;
        CGFloat orgWidth = l.mainFrame.size.width;
        if (parent.children.count == 1) {
            if (l.type == TEXTLAYER_EMPTY) {
                if (parent.roll == ROLL_ROOT) {
                    if (l.expo != nil) {
                        [l.expo destroy];
                        l.expo = nil;
                        [l updateFrameBaseOnBase];
                        
                        parent.mainFrame = parent.numerFrame = l.frame;
                        parent.denomFrame = CGRectMake(0, 0, 0, 0);
                        parent.numerTopHalf = parent.numerBtmHalf = l.frame.size.height / 2.0;
                        parent.denomTopHalf = parent.denomBtmHalf = 0.0;
                    }
                } else if (parent.roll == ROLL_ROOT_ROOT) {
                    [e removeElement:parent.parent];
                } else if (parent.roll == ROLL_EXPO_ROOT) {
                    EquationTextLayer *parLayer = parent.parent;
                    [parent destroy];
                    parLayer.expo = nil;
                    [parLayer updateFrameBaseOnBase];
                    [parLayer.parent updateFrameWidth:-orgWidth :parLayer.roll];
                    [parLayer.parent updateFrameHeightS1:parLayer];
                    [e.root adjustElementPosition];
                    cfgEqnBySlctBlk(e, parLayer, CGPointMake(parLayer.frame.origin.x + parLayer.frame.size.width - 1.0, parLayer.frame.origin.y + 1.0));
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            } else {
                CGPoint p = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                EquationTextLayer *el = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
                el.roll = l.roll;
                el.parent = parent;
                el.c_idx = 0;
                [l destroy];
                [parent.children removeAllObjects];
                [parent.children addObject:el];
                [e.view.layer addSublayer: el];
                
                [parent updateFrameWidth:el.frame.size.width - orgWidth :el.roll];
                [parent updateFrameHeightS1:el];
                [e.root adjustElementPosition];
                
                cfgEqnBySlctBlk(e, el, CGPointMake(el.frame.origin.x + 1.0, el.frame.origin.y + 1.0));
            }
        } else {
            if (l.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:l.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  @ @
                          ---
                           *  */
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
                            CGFloat orgW = rb.frame.size.width;
                            [rb updateFrame];
                            [rb setNeedsDisplay];
                            [rb.parent updateFrameWidth:rb.frame.size.width - orgW :rb.roll];
                            [rb.parent updateFrameHeightS1:rb];
                        } else if (parent.roll == ROLL_EXPO_ROOT) {
                            EquationTextLayer *parLayer = parent.parent;
                            [parLayer updateFrameBaseOnExpo];
                            [parLayer.parent updateFrameHeightS1:parLayer];
                        }
                        [e.root adjustElementPosition];
                        id b = [parent.children lastObject];
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb = b;
                            if (eb.bar != nil) {
                                cfgEqnBySlctBlk(e, eb.bar, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                            } else {
                                cfgEqnBySlctBlk(e, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                            }
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            cfgEqnBySlctBlk(e, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb = b;
                            cfgEqnBySlctBlk(e, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 0.5, rb.frame.origin.y + 0.5));
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        }
                    } else { // Degrade e block
                        EquationBlock *eb = parent.parent;
                        int cnt = 1;
                        int r = ROLL_NUMERATOR;
                        if (eb.bar != nil) {
                            if (parent.c_idx < eb.bar.c_idx) {
                                r = ROLL_NUMERATOR;
                            } else {
                                r = ROLL_DENOMINATOR;
                            }
                        }
                        for (id b in parent.children) {
                            if ([b isMemberOfClass:[EquationBlock class]]) {
                                ((EquationBlock *)b).roll = r;
                                ((EquationBlock *)b).parent = eb;
                            } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                                ((EquationTextLayer *)b).roll = r;
                                ((EquationTextLayer *)b).parent = eb;
                            } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                                ((RadicalBlock *)b).roll = r;
                                ((RadicalBlock *)b).parent = eb;
                            } else {
                                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            }
                            [eb.children insertObject:b atIndex:parent.c_idx + cnt++];
                        }
                        
                        [eb.children removeObjectAtIndex:parent.c_idx];
                        [eb updateCIdx];
                        
                        [parent.children removeAllObjects];
                        parent.children = nil;
                        
                        id b = [eb.children objectAtIndex:parent.c_idx + cnt - 2];
                        [eb updateFrameHeightS1:b];
                        [e.root adjustElementPosition];
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb = b;
                            if (eb.bar != nil) {
                                cfgEqnBySlctBlk(e, eb.bar, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                            } else {
                                cfgEqnBySlctBlk(e, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                            }
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            cfgEqnBySlctBlk(e, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb = b;
                            cfgEqnBySlctBlk(e, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 1.0, rb.frame.origin.y + 1.0));
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        }
                    }
                } else {
                    CGPoint p = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                    EquationTextLayer *el = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
                    el.roll = l.roll;
                    el.parent = parent;
                    el.c_idx = l.c_idx;
                    [l destroy];
                    [parent.children removeLastObject];
                    [parent.children addObject:el];
                    [e.view.layer addSublayer: el];
                    
                    [parent updateFrameWidth:el.frame.size.width - orgWidth :el.roll];
                    [parent updateFrameHeightS1:el];
                    [e.root adjustElementPosition];
                    
                    cfgEqnBySlctBlk(e, el, CGPointMake(el.frame.origin.x + 1.0, el.frame.origin.y + 1.0));
                }
            } else if(l.c_idx == 0 && [[parent.children objectAtIndex:l.c_idx + 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  *
                         ---
                         @ @ */
                if (l.type == TEXTLAYER_EMPTY) {
                    if (parent.roll == ROLL_ROOT) {
                        return;  // Do nothing
                    } else {
                        id pre = getPrevBlk(e, l);
                        if (pre != nil) {
                            if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                                EquationTextLayer *layer = pre;
                                if (layer.is_base_expo == l.is_base_expo) {
                                    (void)locaLastTxtLyr(e, pre);
                                } else { //Switch from expo to base in a same text layer
                                    e.curTxtLyr = layer;
                                    e.curBlk = layer;
                                    e.curParent = layer.parent;
                                    e.curRoll = layer.roll;
                                    e.curMode = MODE_INSERT;
                                    e.insertCIdx = layer.c_idx + 1;
                                    e.txtInsIdx = (int)layer.strLenTbl.count - 1;
                                    
                                    if (layer.is_base_expo == IS_BASE) {
                                        e.curFont = e.baseFont;
                                    } else if (layer.is_base_expo == IS_EXPO) {
                                        e.curFont = e.superscriptFont;
                                    } else {
                                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                                    }
                                    
                                    e.view.inpOrg = CGPointMake(layer.frame.origin.x + layer.frame.size.width, layer.frame.origin.y);
                                    e.view.cursor.frame = CGRectMake(e.view.inpOrg.x, e.view.inpOrg.y, CURSOR_W, e.curFontH);
                                }
                            } else {
                                (void)locaLastTxtLyr(e, pre);
                            }
                        } else {
                            return;
                        }
                    }
                    
                } else {
                    CGPoint p = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                    EquationTextLayer *el = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
                    el.roll = l.roll;
                    el.parent = parent;
                    el.c_idx = l.c_idx;
                    [l destroy];
                    [parent.children removeObjectAtIndex:0];
                    [parent.children insertObject:el atIndex:0];
                    [e.view.layer addSublayer: el];
                    
                    [parent updateFrameWidth:el.frame.size.width - orgWidth :el.roll];
                    [parent updateFrameHeightS1:el];
                    [e.root adjustElementPosition];
                    
                    cfgEqnBySlctBlk(e, el, CGPointMake(el.frame.origin.x + 1.0, el.frame.origin.y + 1.0));
                }
            } else {
                /* Case:  @ @
                          ---
                          @ @ */
                if (l.c_idx == 0) {
                    [l destroy];
                    [parent.children removeObjectAtIndex:0];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :l.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:0]];
                    [e.root adjustElementPosition];
                    
                    id b = parent.children.firstObject;
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        e.view.inpOrg = CGPointMake(eb1.mainFrame.origin.x, eb1.numerFrame.origin.y + eb1.numerFrame.size.height - e.curFontH / 2.0);;
                        e.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        e.curTxtLyr = nil;
                        e.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        e.view.inpOrg = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                        e.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        if (l.type == TEXTLAYER_EMPTY || l.type == TEXTLAYER_NUM) {
                            e.curTxtLyr = l;
                        } else {
                            e.curTxtLyr = nil;
                        }
                        e.txtInsIdx = 0;
                        e.curRoll = l.roll;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        e.view.inpOrg = CGPointMake(rb1.frame.origin.x, rb1.frame.origin.y + rb1.frame.size.height / 2.0 - e.curFontH / 2.0);;
                        e.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        e.curTxtLyr = nil;
                        e.curRoll = rb1.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    e.curMode = MODE_INSERT;
                    e.insertCIdx = 0;
                    e.curParent = parent;
                    e.curBlk = b;
                } else if ([[parent.children objectAtIndex:l.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                    [l destroy];
                    [parent.children removeObjectAtIndex:l.c_idx];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :l.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:l.c_idx]];
                    [e.root adjustElementPosition];
                    
                    id b = [parent.children objectAtIndex:l.c_idx];
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        e.view.inpOrg = CGPointMake(eb1.mainFrame.origin.x, eb1.numerFrame.origin.y + eb1.numerFrame.size.height - e.curFontH / 2.0);;
                        e.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        e.curTxtLyr = nil;
                        e.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        e.view.inpOrg = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                        e.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        e.curTxtLyr = l;
                        e.curRoll = l.roll;
                        e.txtInsIdx = 0;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        e.view.inpOrg = CGPointMake(rb1.frame.origin.x, rb1.frame.origin.y + rb1.frame.size.height / 2.0 - e.curFontH / 2.0);;
                        e.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        e.curTxtLyr = nil;
                        e.curRoll = rb1.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    e.curMode = MODE_INSERT;
                    e.insertCIdx = l.c_idx;
                    e.curParent = parent;
                    e.curBlk = b;
                } else {
                    [l destroy];
                    [parent.children removeObjectAtIndex:l.c_idx];
                    [parent updateCIdx];
                    
                    id b = [parent.children objectAtIndex:l.c_idx - 1];
                    [parent updateFrameWidth:-orgWidth :l.roll];
                    [parent updateFrameHeightS1:b];
                    [e.root adjustElementPosition];
                    
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb = b;
                        if (eb.bar != nil) {
                            cfgEqnBySlctBlk(e, eb.bar, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                        } else {
                            cfgEqnBySlctBlk(e, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                        }
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        cfgEqnBySlctBlk(e, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb = b;
                        cfgEqnBySlctBlk(e, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 1.0, rb.frame.origin.y + 1.0));
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
            }
        }
    } else if ([blk isMemberOfClass: [RadicalBlock class]]) {
        RadicalBlock *rb = blk;
        if (![rb.parent isMemberOfClass: [EquationBlock class]]) {
            return;
        }
        EquationBlock *parent = rb.parent;
        Equation *e = rb.ancestor;
        CGFloat orgWidth = rb.frame.size.width;
        if (parent.children.count == 1) {
            CGPoint p = CGPointMake(rb.frame.origin.x, rb.frame.origin.y + rb.frame.size.height - e.curFontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
            l.roll = ROLL_NUMERATOR;
            l.parent = parent;
            l.c_idx = 0;
            [rb destroy];
            [parent.children removeObjectAtIndex:0];
            [parent.children addObject:l];
            [e.view.layer addSublayer: l];
            
            [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
            [parent updateFrameHeightS1:l];
            [e.root adjustElementPosition];
            
            cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else {
            if (rb.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:rb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  @ @
                          ---
                           *  */
                CGPoint p = CGPointMake(rb.frame.origin.x, rb.frame.origin.y + rb.frame.size.height - e.curFontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
                l.roll = rb.roll;
                l.parent = parent;
                l.c_idx = rb.c_idx;
                [rb destroy];
                [parent.children removeLastObject];
                [parent.children addObject:l];
                [e.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                [parent updateFrameHeightS1:l];
                [e.root adjustElementPosition];
                
                cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else if(rb.c_idx == 0 && [[parent.children objectAtIndex:rb.c_idx + 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  *
                         ---
                         @ @ */
                CGPoint p = CGPointMake(rb.frame.origin.x, rb.frame.origin.y + rb.frame.size.height - e.curFontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :p :e :TEXTLAYER_EMPTY];
                l.roll = rb.roll;
                l.parent = parent;
                l.c_idx = 0;
                [rb destroy];
                [parent.children removeObjectAtIndex:0];
                [parent.children insertObject:l atIndex:0];
                [e.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                [parent updateFrameHeightS1:l];
                [e.root adjustElementPosition];
                
                cfgEqnBySlctBlk(e, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else {
                /* Case:  @ @
                          ---
                          @ @ */
                if (rb.c_idx == 0) {
                    [rb destroy];
                    [parent.children removeObjectAtIndex:0];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :rb.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:0]];
                    [e.root adjustElementPosition];
                    
                    id b = parent.children.firstObject;
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        e.view.inpOrg = CGPointMake(eb1.mainFrame.origin.x, eb1.numerFrame.origin.y + eb1.numerFrame.size.height - e.curFontH / 2.0);;
                        e.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        e.curTxtLyr = nil;
                        e.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        e.view.inpOrg = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                        e.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        e.curTxtLyr = l;
                        e.curRoll = l.roll;
                        e.txtInsIdx = 0;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        e.view.inpOrg = CGPointMake(rb1.frame.origin.x, rb1.frame.origin.y + rb1.frame.size.height / 2.0 - e.curFontH / 2.0);;
                        e.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        e.curTxtLyr = nil;
                        e.curRoll = rb1.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    e.curMode = MODE_INSERT;
                    e.insertCIdx = 0;
                    e.curParent = parent;
                    e.curBlk = b;
                } else if ([[parent.children objectAtIndex:rb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                    [rb destroy];
                    [parent.children removeObjectAtIndex:rb.c_idx];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :rb.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:rb.c_idx]];
                    [e.root adjustElementPosition];
                    
                    id b = [parent.children objectAtIndex:rb.c_idx];
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        e.view.inpOrg = CGPointMake(eb1.mainFrame.origin.x, eb1.numerFrame.origin.y + eb1.numerFrame.size.height - e.curFontH / 2.0);;
                        e.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        e.curTxtLyr = nil;
                        e.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        e.view.inpOrg = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                        e.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        e.curTxtLyr = l;
                        e.curRoll = l.roll;
                        e.txtInsIdx = 0;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        e.view.inpOrg = CGPointMake(rb1.frame.origin.x, rb1.frame.origin.y + rb1.frame.size.height / 2.0 - e.curFontH / 2.0);;
                        e.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        e.curTxtLyr = nil;
                        e.curRoll = rb1.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    e.curMode = MODE_INSERT;
                    e.insertCIdx = rb.c_idx;
                    e.curParent = parent;
                    e.curBlk = b;
                } else {
                    [rb destroy];
                    [parent.children removeObjectAtIndex:rb.c_idx];
                    [parent updateCIdx];
                    
                    id b = [parent.children objectAtIndex:rb.c_idx - 1];
                    [parent updateFrameWidth:-orgWidth :rb.roll];
                    [parent updateFrameHeightS1:b];
                    [e.root adjustElementPosition];
                    
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb = b;
                        if (eb.bar != nil) {
                            cfgEqnBySlctBlk(e, eb.bar, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                        } else {
                            cfgEqnBySlctBlk(e, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                        }
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        cfgEqnBySlctBlk(e, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb = b;
                        cfgEqnBySlctBlk(e, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 1.0, rb.frame.origin.y + 1.0));
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
            }
        }
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqual: @"curFont"]) {
        Equation *E = object;
        UIFont *newFont = [change objectForKey:@"new"];
        if (newFont == E.baseFont) {
            E.curFontW = E.baseCharWidth;
            E.curFontH = E.baseCharHight;
        } else if (newFont == E.superscriptFont) {
            E.curFontW = E.expoCharWidth;
            E.curFontH = E.expoCharHight;
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}
@end
